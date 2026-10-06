USE CLINICAUPC;
GO

-- ============================================================================
-- SCRIPT MANUAL - PROYECTO CLINICAUPC
-- Date: 2025-05-26 · UPC Database course final project
-- ============================================================================


-- ============================================================================
-- CONSULTAS SQL REPRESENTATIVAS
-- ============================================================================

-- CONSULTA 1: Pacientes activos con correo registrado
SELECT nombre, dni, telefono, correo
FROM Pacientes
WHERE correo IS NOT NULL AND activo = 1;
GO

-- CONSULTA 2: Vacunas aplicadas este año
SELECT P.nombre AS paciente, V.vacuna_nombre, V.fecha_aplicacion
FROM VacunasAplicadas V
JOIN Pacientes P ON V.paciente_id = P.paciente_id
WHERE YEAR(V.fecha_aplicacion) = YEAR(GETDATE());
GO

-- CONSULTA 3: Citas canceladas del último mes
SELECT cita_id, motivo, fecha
FROM Citas
WHERE estado = 'C'
  AND fecha >= DATEADD(MONTH, -1, GETDATE());
GO

-- CONSULTA 4: Número de citas por doctor en el mes actual
SELECT d.nombre AS doctor, COUNT(*) AS cantidad_citas
FROM Citas c
JOIN Doctores d ON c.doctor_id = d.doctor_id
WHERE MONTH(c.fecha) = MONTH(GETDATE()) AND YEAR(c.fecha) = YEAR(GETDATE())
GROUP BY d.nombre;
GO


-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
-- ============================================================================

-- SP: Insertar paciente y registrar auditoría
CREATE PROCEDURE sp_InsertarPaciente
    @nombre VARCHAR(100),
    @dni VARCHAR(20),
    @fecha_nacimiento DATE,
    @sexo CHAR(1),
    @direccion VARCHAR(200),
    @telefono VARCHAR(15),
    @correo VARCHAR(100)
AS
BEGIN
    INSERT INTO Pacientes (nombre, dni, fecha_nacimiento, sexo, direccion, telefono, correo)
    VALUES (@nombre, @dni, @fecha_nacimiento, @sexo, @direccion, @telefono, @correo);

    INSERT INTO AuditoriaPacientes(paciente_id, accion)
    VALUES (SCOPE_IDENTITY(), 'Insertar paciente');
END;
GO

-- SP: Registrar nueva cita
CREATE PROCEDURE sp_RegistrarCita
    @paciente_id INT,
    @doctor_id INT,
    @fecha DATETIME,
    @motivo VARCHAR(255)
AS
BEGIN
    INSERT INTO Citas (paciente_id, doctor_id, fecha, motivo)
    VALUES (@paciente_id, @doctor_id, @fecha, @motivo);
END;
GO

-- SP: Registrar signos vitales
CREATE PROCEDURE sp_RegistrarSignosVitales
    @cita_id INT,
    @presion_arterial VARCHAR(20),
    @temperatura DECIMAL(5,2),
    @frecuencia_cardiaca INT,
    @frecuencia_respiratoria INT,
    @saturacion_oxigeno DECIMAL(5,2)
AS
BEGIN
    INSERT INTO SignosVitales
      (cita_id, presion_arterial, temperatura, frecuencia_cardiaca,
       frecuencia_respiratoria, saturacion_oxigeno)
    VALUES
      (@cita_id, @presion_arterial, @temperatura, @frecuencia_cardiaca,
       @frecuencia_respiratoria, @saturacion_oxigeno);
END;
GO

-- SP: Crear receta con detalles (tabla tipo)
CREATE PROCEDURE sp_CrearRecetaConDetalles
    @cita_id INT,
    @doctor_id INT,
    @medicamentosDetalle TipoMedicamentosDetalle READONLY
AS
BEGIN
    DECLARE @receta_id INT;

    INSERT INTO Recetas(cita_id, doctor_id)
    VALUES(@cita_id, @doctor_id);

    SET @receta_id = SCOPE_IDENTITY();

    INSERT INTO DetalleReceta(receta_id, medicamento_id, cantidad)
    SELECT @receta_id, medicamento_id, cantidad
    FROM @medicamentosDetalle;
END;
GO

-- SP: Listar citas por doctor
CREATE PROCEDURE sp_ListarCitasPorDoctor
    @doctor_id INT
AS
BEGIN
    SELECT
      C.cita_id,
      P.nombre AS paciente,
      C.fecha,
      C.motivo,
      C.estado
    FROM Citas C
    JOIN Pacientes P ON C.paciente_id = P.paciente_id
    WHERE C.doctor_id = @doctor_id
      AND C.activo = 1
    ORDER BY C.fecha;
END;
GO

-- SP: Desactivar doctor (lógica)
CREATE PROCEDURE sp_DesactivarDoctor
    @doctor_id INT
AS
BEGIN
    UPDATE Doctores
    SET activo = 0
    WHERE doctor_id = @doctor_id;
END;
GO


-- ============================================================================
-- TRIGGERS (DESENCADENADORES)
-- ============================================================================

-- Trigger: Restar stock de medicamentos al insertar detalle de receta
CREATE TRIGGER trg_RestarStockMedicamentos
ON DetalleReceta
AFTER INSERT
AS
BEGIN
    UPDATE M
    SET M.stock = M.stock - D.cantidad
    FROM Medicamentos M
    JOIN inserted D ON M.medicamento_id = D.medicamento_id;
END;
GO

-- Trigger: Desactivar doctor inactivo por más de 6 meses
CREATE TRIGGER trg_DesactivarDoctorInactivo
ON Doctores
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @did INT = (SELECT doctor_id FROM inserted);

    IF EXISTS (
      SELECT 1
      FROM Doctores
      WHERE doctor_id = @did
        AND activo = 0
        AND DATEDIFF(MONTH, fecha_registro, GETDATE()) >= 6
    )
    BEGIN
        UPDATE Doctores SET activo = 0 WHERE doctor_id = @did;
    END
END;
GO

-- Trigger: Desactivar medicamento con stock 0
CREATE TRIGGER trg_DesactivarMedicamento
ON Medicamentos
AFTER UPDATE
AS
BEGIN
    DECLARE @mid INT, @stk INT;
    SELECT @mid = medicamento_id, @stk = stock FROM inserted;

    IF @stk = 0
    BEGIN
        UPDATE Medicamentos SET activo = 0 WHERE medicamento_id = @mid;
    END
END;
GO

-- Trigger: Desactivar paciente mayor o igual a 120 años
CREATE TRIGGER trg_DesactivarPaciente120
ON Pacientes
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @nid INT; DECLARE @fn DATE;
    SELECT @nid = paciente_id, @fn = fecha_nacimiento FROM inserted;

    IF DATEDIFF(YEAR, @fn, GETDATE()) >= 120
    BEGIN
        UPDATE Pacientes SET activo = 0 WHERE paciente_id = @nid;
    END
END;
GO

-- Trigger: Desactivar paciente sin citas en el último año
CREATE TRIGGER trg_DesactivarPacienteSinCitas
ON Pacientes
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @pid INT = (SELECT paciente_id FROM inserted);

    IF NOT EXISTS (
      SELECT 1
      FROM Citas
      WHERE paciente_id = @pid
        AND fecha >= DATEADD(YEAR, -1, GETDATE())
        AND activo = 1
    )
    BEGIN
        UPDATE Pacientes
        SET activo = 0
        WHERE paciente_id = @pid;
    END
END;
GO


-- ============================================================================
-- COMANDOS DDL (ALTER TABLE)
-- ============================================================================

-- Aumentar tamaño del campo descripcion en Diagnosticos
ALTER TABLE Diagnosticos
ALTER COLUMN descripcion VARCHAR(500);
GO

-- Agregar columna "peso_kg" a SignosVitales
ALTER TABLE SignosVitales
ADD peso_kg DECIMAL(5, 2) NULL;
GO


-- ============================================================================
-- COMANDOS DCL (GRANT y REVOKE)
-- ============================================================================

GRANT SELECT, UPDATE ON Usuarios TO usuarioSoporte;
GRANT DELETE ON Citas TO rolAdministrador;
GRANT INSERT ON DetalleReceta TO rolFarmacia;
GRANT SELECT ON vw_CitasParticionadas TO usuarioConsulta;
GO

GRANT EXECUTE ON sp_InsertarPaciente TO rolMedico;
GRANT EXECUTE ON sp_RegistrarCita TO rolMedico;
GRANT EXECUTE ON sp_ListarCitasPorDoctor TO rolMedico;
GRANT EXECUTE ON sp_DesactivarDoctor TO rolMedico;
GRANT EXECUTE ON sp_RegistrarSignosVitales TO rolMedico;
GRANT EXECUTE ON sp_CrearRecetaConDetalles TO rolMedico;
GO

REVOKE DELETE ON Pacientes FROM usuarioConsulta;
REVOKE UPDATE ON Doctores FROM rolRecepcion;
REVOKE INSERT ON Medicamentos FROM usuarioConsulta;
GO


-- ============================================================================
-- CREACIÓN DE RESTRICCIONES Y ÍNDICES (MANUAL)
-- ============================================================================

-- Restricción CHECK para validar fecha de nacimiento
ALTER TABLE Pacientes
ADD CONSTRAINT CHK_FechaNacimiento CHECK (fecha_nacimiento <= GETDATE());
GO

-- Restricción CHECK para validar sexo
ALTER TABLE Pacientes
ADD CONSTRAINT CHK_Sexo CHECK (sexo IN ('M', 'F'));
GO

-- Índice único para evitar duplicados de correo
CREATE UNIQUE INDEX IX_CorreoPaciente ON Pacientes(correo);
GO

-- Índice no único para acelerar consultas por fecha de cita
CREATE INDEX IX_Citas_Fecha ON Citas(fecha);
GO
