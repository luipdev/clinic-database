/* =============================================================================
   CLINICAUPC v2 - fixes found when reviewing the original project
   Target: SQL Server 2019+ (compatibility level 160 in the original database)
   Run after original/01_schema.sql and original/02_procedures_triggers_security.sql.

   Each block says what was wrong and how it is fixed. See README.md for the
   full write-up.
   ============================================================================= */
USE CLINICAUPC;
GO

/* -----------------------------------------------------------------------------
   FIX 1 - Prescriptions: no transaction, and stock could go negative
   Before: if inserting the details failed, an empty prescription was left
   behind, and nothing stopped prescribing more units than in stock.
   After: one transaction, stock validated first (duplicate medicines in the
   same request are added up), and a CHECK constraint as a last line of defense.
   ----------------------------------------------------------------------------- */

-- Last line of defense: stock can never be negative, whoever updates it.
-- WITH CHECK validates existing rows too; fix any negative stock before running.
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_Medicamentos_StockNoNegativo')
    ALTER TABLE dbo.Medicamentos WITH CHECK
        ADD CONSTRAINT CHK_Medicamentos_StockNoNegativo CHECK (stock >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_DetalleReceta_CantidadPositiva')
    ALTER TABLE dbo.DetalleReceta WITH CHECK
        ADD CONSTRAINT CHK_DetalleReceta_CantidadPositiva CHECK (cantidad > 0);
GO

CREATE OR ALTER PROCEDURE dbo.sp_CrearRecetaConDetalles
    @cita_id INT,
    @doctor_id INT,
    @medicamentosDetalle dbo.TipoMedicamentosDetalle READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- any runtime error rolls the whole transaction back

    IF NOT EXISTS (SELECT 1 FROM @medicamentosDetalle)
        THROW 50001, 'A prescription needs at least one medicine.', 1;

    IF EXISTS (SELECT 1 FROM @medicamentosDetalle WHERE cantidad IS NULL OR cantidad <= 0)
        THROW 50002, 'Every quantity must be greater than zero.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Lock the medicine rows so two prescriptions can't both spend the same stock.
        IF EXISTS (
            SELECT 1
            FROM (
                SELECT medicamento_id, SUM(cantidad) AS pedido
                FROM @medicamentosDetalle
                GROUP BY medicamento_id
            ) AS req
            LEFT JOIN dbo.Medicamentos AS m WITH (UPDLOCK, HOLDLOCK)
                   ON m.medicamento_id = req.medicamento_id
            WHERE m.medicamento_id IS NULL      -- unknown medicine
               OR m.activo = 0                  -- inactive medicine
               OR m.stock < req.pedido          -- not enough stock
        )
            THROW 50003, 'Unknown or inactive medicine, or not enough stock.', 1;

        DECLARE @receta_id INT;

        INSERT INTO dbo.Recetas (cita_id, doctor_id)
        VALUES (@cita_id, @doctor_id);

        SET @receta_id = SCOPE_IDENTITY();

        -- trg_RestarStockMedicamentos subtracts the stock for these rows.
        INSERT INTO dbo.DetalleReceta (receta_id, medicamento_id, cantidad)
        SELECT @receta_id, medicamento_id, cantidad
        FROM @medicamentosDetalle;

        COMMIT TRANSACTION;
        SELECT @receta_id AS receta_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;  -- re-raise the original error to the caller
    END CATCH
END;
GO

/* -----------------------------------------------------------------------------
   FIX 2 - Triggers that only handled one row
   Before: `SELECT @id = x FROM inserted` keeps a single value, so a multi-row
   INSERT or UPDATE only applied the rule to one of the rows.
   After: set-based UPDATE ... JOIN inserted, which works for any number of rows.
   ----------------------------------------------------------------------------- */

CREATE OR ALTER TRIGGER dbo.trg_DesactivarMedicamento
ON dbo.Medicamentos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE m
    SET m.activo = 0
    FROM dbo.Medicamentos AS m
    JOIN inserted AS i ON i.medicamento_id = m.medicamento_id
    WHERE i.stock = 0 AND m.activo <> 0;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_DesactivarPaciente120
ON dbo.Pacientes
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.activo = 0
    FROM dbo.Pacientes AS p
    JOIN inserted AS i ON i.paciente_id = p.paciente_id
    WHERE i.fecha_nacimiento <= DATEADD(YEAR, -120, CAST(GETDATE() AS date))
      AND p.activo <> 0;
END;
GO

/* -----------------------------------------------------------------------------
   FIX 3 - Every new patient was deactivated on creation
   Before: trg_DesactivarPacienteSinCitas ran AFTER INSERT and deactivated any
   patient with no appointment in the last year. A brand-new patient never has
   one, so every new patient was saved as inactive.
   After: the inactivity rule is not a row event, it depends on time passing.
   It moves to a procedure meant to run on a schedule (e.g. a nightly SQL Agent
   job), and it gives new patients one year before they can be deactivated.
   ----------------------------------------------------------------------------- */

DROP TRIGGER IF EXISTS dbo.trg_DesactivarPacienteSinCitas;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DesactivarPacientesInactivos
    @meses INT = 12
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @desde DATETIME = DATEADD(MONTH, -@meses, GETDATE());

    UPDATE p
    SET p.activo = 0
    FROM dbo.Pacientes AS p
    WHERE p.activo = 1
      AND p.fecha_registro < @desde                 -- grace period for new patients
      AND NOT EXISTS (
            SELECT 1 FROM dbo.Citas AS c
            WHERE c.paciente_id = p.paciente_id
              AND c.activo = 1
              AND c.fecha >= @desde
      );

    SELECT @@ROWCOUNT AS pacientes_desactivados;
END;
GO

/* -----------------------------------------------------------------------------
   FIX 4 - A trigger that never changed anything
   Before: trg_DesactivarDoctorInactivo set activo = 0 only for doctors whose
   activo was already 0, so it had no effect.
   After: the intended rule ("deactivate doctors inactive for 6+ months") as a
   scheduled procedure. Inactive is read here as "no appointments in that time".
   ----------------------------------------------------------------------------- */

DROP TRIGGER IF EXISTS dbo.trg_DesactivarDoctorInactivo;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DesactivarDoctoresInactivos
    @meses INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @desde DATETIME = DATEADD(MONTH, -@meses, GETDATE());

    UPDATE d
    SET d.activo = 0
    FROM dbo.Doctores AS d
    WHERE d.activo = 1
      AND d.fecha_registro < @desde
      AND NOT EXISTS (
            SELECT 1 FROM dbo.Citas AS c
            WHERE c.doctor_id = d.doctor_id
              AND c.fecha >= @desde
      );

    SELECT @@ROWCOUNT AS doctores_desactivados;
END;
GO

/* -----------------------------------------------------------------------------
   FIX 5 - Unique email index blocked a second patient without email
   Before: CREATE UNIQUE INDEX on a nullable column. SQL Server treats NULLs as
   equal in a unique index, so only one patient could have no email.
   After: a filtered unique index that only applies to rows with an email.
   ----------------------------------------------------------------------------- */

DROP INDEX IF EXISTS IX_CorreoPaciente ON dbo.Pacientes;
GO
CREATE UNIQUE INDEX IX_CorreoPaciente
    ON dbo.Pacientes (correo)
    WHERE correo IS NOT NULL;
GO

/* -----------------------------------------------------------------------------
   FIX 6 - Patient insert and its audit row were not atomic
   ----------------------------------------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.sp_InsertarPaciente
    @nombre VARCHAR(100),
    @dni VARCHAR(20),
    @fecha_nacimiento DATE,
    @sexo CHAR(1),
    @direccion VARCHAR(200),
    @telefono VARCHAR(15),
    @correo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Pacientes (nombre, dni, fecha_nacimiento, sexo, direccion, telefono, correo)
        VALUES (@nombre, @dni, @fecha_nacimiento, @sexo, @direccion, @telefono, @correo);

        DECLARE @paciente_id INT = SCOPE_IDENTITY();

        INSERT INTO dbo.AuditoriaPacientes (paciente_id, accion)
        VALUES (@paciente_id, 'Insertar paciente');

        COMMIT TRANSACTION;
        SELECT @paciente_id AS paciente_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
