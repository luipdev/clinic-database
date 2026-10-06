/* =============================================================================
   CLINICAUPC v2 - manual checks for the fixes
   Run after v2/01_fixes.sql on a TEST copy of the database.
   Test rows use the prefix 'TEST' and are deleted at the end of the script.
   No outer transaction is used on purpose: the procedures roll back their own
   transaction on error, which would also cancel an outer one.
   Expected results are written next to each check.
   ============================================================================= */
USE CLINICAUPC;
GO
SET NOCOUNT ON;

-- Test data -------------------------------------------------------------------
DECLARE @esp INT, @doc INT, @pac1 INT, @pac2 INT, @cita INT, @medA INT, @medB INT;

INSERT INTO dbo.Especialidades (nombre) VALUES ('TEST Medicina general');
SET @esp = SCOPE_IDENTITY();
INSERT INTO dbo.Doctores (nombre, especialidad_id) VALUES ('TEST Doctor', @esp);
SET @doc = SCOPE_IDENTITY();

-- FIX 3: a new patient must stay active
EXEC dbo.sp_InsertarPaciente 'TEST Paciente 1', 'T0000001', '1990-01-01', 'M', 'x', '1', NULL;
SELECT @pac1 = paciente_id FROM dbo.Pacientes WHERE dni = 'T0000001';
SELECT 'FIX 3: new patient active' AS [check],
       CASE WHEN activo = 1 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dbo.Pacientes WHERE paciente_id = @pac1;

-- FIX 5: two patients without email are allowed
EXEC dbo.sp_InsertarPaciente 'TEST Paciente 2', 'T0000002', '1985-05-05', 'F', 'x', '2', NULL;
SELECT @pac2 = paciente_id FROM dbo.Pacientes WHERE dni = 'T0000002';
SELECT 'FIX 5: second patient without email' AS [check],
       CASE WHEN @pac2 IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS result;

INSERT INTO dbo.Citas (paciente_id, doctor_id, fecha, motivo) VALUES (@pac1, @doc, GETDATE(), 'TEST');
SET @cita = SCOPE_IDENTITY();

INSERT INTO dbo.Medicamentos (nombre, stock) VALUES ('TEST Med A', 10), ('TEST Med B', 3);
SELECT @medA = medicamento_id FROM dbo.Medicamentos WHERE nombre = 'TEST Med A';
SELECT @medB = medicamento_id FROM dbo.Medicamentos WHERE nombre = 'TEST Med B';

-- FIX 1a: valid prescription subtracts stock for every row
DECLARE @ok dbo.TipoMedicamentosDetalle;
INSERT INTO @ok VALUES (@medA, 4), (@medB, 1);
EXEC dbo.sp_CrearRecetaConDetalles @cita, @doc, @ok;
SELECT 'FIX 1a: stock subtracted for both medicines (expect 6 and 2)' AS [check],
       CASE WHEN (SELECT stock FROM dbo.Medicamentos WHERE medicamento_id = @medA) = 6
             AND (SELECT stock FROM dbo.Medicamentos WHERE medicamento_id = @medB) = 2
            THEN 'PASS' ELSE 'FAIL' END AS result;

-- FIX 1b: asking for more than the stock fails and leaves nothing behind
DECLARE @recetasAntes INT = (SELECT COUNT(*) FROM dbo.Recetas WHERE cita_id = @cita);
DECLARE @tooMuch dbo.TipoMedicamentosDetalle;
INSERT INTO @tooMuch VALUES (@medA, 1), (@medB, 5);
BEGIN TRY
    EXEC dbo.sp_CrearRecetaConDetalles @cita, @doc, @tooMuch;
    SELECT 'FIX 1b: over-stock prescription rejected' AS [check], 'FAIL (no error)' AS result;
END TRY
BEGIN CATCH
    SELECT 'FIX 1b: over-stock prescription rejected' AS [check],
           CASE WHEN ERROR_NUMBER() = 50003 THEN 'PASS' ELSE 'FAIL: ' + ERROR_MESSAGE() END AS result;
END CATCH

SELECT 'FIX 1b: stock unchanged after rejection (expect 6 and 2)' AS [check],
       CASE WHEN (SELECT stock FROM dbo.Medicamentos WHERE medicamento_id = @medA) = 6
             AND (SELECT stock FROM dbo.Medicamentos WHERE medicamento_id = @medB) = 2
            THEN 'PASS' ELSE 'FAIL' END AS result;

SELECT 'FIX 1b: no empty prescription left' AS [check],
       CASE WHEN (SELECT COUNT(*) FROM dbo.Recetas WHERE cita_id = @cita) <= @recetasAntes
            THEN 'PASS' ELSE 'FAIL' END AS result;

-- FIX 2: multi-row update deactivates every medicine that reaches 0
UPDATE dbo.Medicamentos SET stock = 0 WHERE medicamento_id IN (@medA, @medB);
SELECT 'FIX 2: both medicines deactivated' AS [check],
       CASE WHEN (SELECT COUNT(*) FROM dbo.Medicamentos
                  WHERE medicamento_id IN (@medA, @medB) AND activo = 0) = 2
            THEN 'PASS' ELSE 'FAIL' END AS result;

-- Cleanup -------------------------------------------------------------------
DELETE dr FROM dbo.DetalleReceta dr JOIN dbo.Recetas r ON r.receta_id = dr.receta_id WHERE r.cita_id = @cita;
DELETE FROM dbo.Recetas WHERE cita_id = @cita;
DELETE FROM dbo.Citas WHERE cita_id = @cita;
DELETE FROM dbo.AuditoriaPacientes WHERE paciente_id IN (@pac1, @pac2);
DELETE FROM dbo.Pacientes WHERE paciente_id IN (@pac1, @pac2);
DELETE FROM dbo.Medicamentos WHERE medicamento_id IN (@medA, @medB);
DELETE FROM dbo.Doctores WHERE doctor_id = @doc;
DELETE FROM dbo.Especialidades WHERE especialidad_id = @esp;
