USE [master]
GO
/****** Object:  Database [CLINICAUPC]    Script Date: 26/05/2025 16:46:51 ******/
CREATE DATABASE [CLINICAUPC]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CLINICAUPC', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CLINICAUPC.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [FG_Citas_2025_01] 
( NAME = N'CLINICAUPC_FG_Citas_2025_01', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CLINICAUPC_FG_Citas_2025_01.ndf' , SIZE = 512000KB , MAXSIZE = 512000KB , FILEGROWTH = 10240KB ), 
 FILEGROUP [FG_Citas_2025_02] 
( NAME = N'CLINICAUPC_FG_Citas_2025_02', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CLINICAUPC_FG_Citas_2025_02.ndf' , SIZE = 51200KB , MAXSIZE = 512000KB , FILEGROWTH = 10240KB ), 
 FILEGROUP [FG_Citas_2025_03] 
( NAME = N'CLINICAUPC_FG_Citas_2025_03', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CLINICAUPC_FG_Citas_2025_03.ndf' , SIZE = 51200KB , MAXSIZE = 512000KB , FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'CLINICAUPC_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CLINICAUPC_log.ldf' , SIZE = 598016KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [CLINICAUPC] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CLINICAUPC].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CLINICAUPC] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CLINICAUPC] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CLINICAUPC] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CLINICAUPC] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CLINICAUPC] SET ARITHABORT OFF 
GO
ALTER DATABASE [CLINICAUPC] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CLINICAUPC] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CLINICAUPC] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CLINICAUPC] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CLINICAUPC] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CLINICAUPC] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CLINICAUPC] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CLINICAUPC] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CLINICAUPC] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CLINICAUPC] SET  ENABLE_BROKER 
GO
ALTER DATABASE [CLINICAUPC] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CLINICAUPC] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CLINICAUPC] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CLINICAUPC] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CLINICAUPC] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CLINICAUPC] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CLINICAUPC] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CLINICAUPC] SET RECOVERY FULL 
GO
ALTER DATABASE [CLINICAUPC] SET  MULTI_USER 
GO
ALTER DATABASE [CLINICAUPC] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CLINICAUPC] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CLINICAUPC] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CLINICAUPC] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CLINICAUPC] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CLINICAUPC] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'CLINICAUPC', N'ON'
GO
ALTER DATABASE [CLINICAUPC] SET QUERY_STORE = ON
GO
ALTER DATABASE [CLINICAUPC] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
ALTER AUTHORIZATION ON DATABASE::[CLINICAUPC] TO [sa]
GO
USE [CLINICAUPC]
GO
/****** Object:  PartitionFunction [PF_CitasFecha]    Script Date: 26/05/2025 16:46:51 ******/
CREATE PARTITION FUNCTION [PF_CitasFecha](datetime) AS RANGE RIGHT FOR VALUES (N'2025-04-01T00:00:00.000')
GO
/****** Object:  PartitionScheme [PS_CitasScheme]    Script Date: 26/05/2025 16:46:51 ******/
CREATE PARTITION SCHEME [PS_CitasScheme] AS PARTITION [PF_CitasFecha] TO ([FG_Citas_2025_01], [PRIMARY])
GO
/****** Object:  UserDefinedTableType [dbo].[TipoMedicamentosDetalle]    Script Date: 26/05/2025 16:46:51 ******/
CREATE TYPE [dbo].[TipoMedicamentosDetalle] AS TABLE(
	[medicamento_id] [int] NULL,
	[cantidad] [int] NULL
)
GO
ALTER AUTHORIZATION ON TYPE::[dbo].[TipoMedicamentosDetalle] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Citas]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Citas](
	[cita_id] [int] IDENTITY(1,1) NOT NULL,
	[paciente_id] [int] NULL,
	[doctor_id] [int] NULL,
	[fecha] [datetime] NULL,
	[motivo] [varchar](255) NULL,
	[estado] [char](1) NULL,
	[activo] [bit] NULL
) ON [PS_CitasScheme]([fecha])
GO
ALTER AUTHORIZATION ON [dbo].[Citas] TO  SCHEMA OWNER 
GO
/****** Object:  Index [CIX_Citas_Fecha]    Script Date: 26/05/2025 16:46:51 ******/
CREATE CLUSTERED INDEX [CIX_Citas_Fecha] ON [dbo].[Citas]
(
	[fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PS_CitasScheme]([fecha])
GO
/****** Object:  View [dbo].[vw_CitasParticionadas]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2) Crear la vista unificada
CREATE VIEW [dbo].[vw_CitasParticionadas] AS
SELECT
  cita_id,
  paciente_id,
  doctor_id,
  fecha,
  motivo,
  estado
FROM dbo.Citas;
GO
ALTER AUTHORIZATION ON [dbo].[vw_CitasParticionadas] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[AlergiasPaciente]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlergiasPaciente](
	[alergia_id] [int] IDENTITY(1,1) NOT NULL,
	[paciente_id] [int] NULL,
	[descripcion] [varchar](255) NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[alergia_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[AlergiasPaciente] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[AuditoriaPacientes]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditoriaPacientes](
	[auditoria_id] [int] IDENTITY(1,1) NOT NULL,
	[paciente_id] [int] NULL,
	[accion] [varchar](100) NULL,
	[fecha] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[auditoria_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[AuditoriaPacientes] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[BitacoraAcciones]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BitacoraAcciones](
	[bitacora_id] [int] IDENTITY(1,1) NOT NULL,
	[usuario_id] [int] NULL,
	[accion] [varchar](255) NULL,
	[fecha] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[bitacora_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[BitacoraAcciones] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Citas_Archivo_Enero2025]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Citas_Archivo_Enero2025](
	[fecha] [datetime] NOT NULL,
	[cita_id] [int] NOT NULL,
	[paciente_id] [int] NOT NULL,
	[doctor_id] [int] NOT NULL,
	[motivo] [varchar](255) NULL,
	[estado] [char](1) NULL,
	[activo] [bit] NULL,
 CONSTRAINT [PK_CitasArchivo_Ene] PRIMARY KEY CLUSTERED 
(
	[fecha] ASC,
	[cita_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PS_CitasScheme]([fecha])
) ON [PS_CitasScheme]([fecha])
GO
ALTER AUTHORIZATION ON [dbo].[Citas_Archivo_Enero2025] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[DetalleReceta]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetalleReceta](
	[detalle_id] [int] IDENTITY(1,1) NOT NULL,
	[receta_id] [int] NULL,
	[medicamento_id] [int] NULL,
	[cantidad] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[detalle_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[DetalleReceta] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Diagnosticos]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Diagnosticos](
	[diagnostico_id] [int] IDENTITY(1,1) NOT NULL,
	[codigo_cie10] [varchar](10) NULL,
	[descripcion] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[diagnostico_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Diagnosticos] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Doctores]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctores](
	[doctor_id] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) NULL,
	[especialidad_id] [int] NULL,
	[telefono] [varchar](15) NULL,
	[correo] [varchar](100) NULL,
	[fecha_registro] [datetime] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[doctor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Doctores] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Especialidades]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Especialidades](
	[especialidad_id] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[especialidad_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Especialidades] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Medicamentos]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medicamentos](
	[medicamento_id] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) NULL,
	[descripcion] [varchar](255) NULL,
	[stock] [int] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[medicamento_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Medicamentos] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Pacientes]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pacientes](
	[paciente_id] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) NULL,
	[dni] [varchar](20) NULL,
	[fecha_nacimiento] [date] NULL,
	[sexo] [char](1) NULL,
	[direccion] [varchar](200) NULL,
	[telefono] [varchar](15) NULL,
	[correo] [varchar](100) NULL,
	[fecha_registro] [datetime] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[paciente_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[dni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Pacientes] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Recetas]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recetas](
	[receta_id] [int] IDENTITY(1,1) NOT NULL,
	[cita_id] [int] NULL,
	[doctor_id] [int] NULL,
	[fecha] [datetime] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[receta_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Recetas] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[SignosVitales]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SignosVitales](
	[signo_id] [int] IDENTITY(1,1) NOT NULL,
	[cita_id] [int] NULL,
	[presion_arterial] [varchar](20) NULL,
	[temperatura] [decimal](5, 2) NULL,
	[frecuencia_cardiaca] [int] NULL,
	[frecuencia_respiratoria] [int] NULL,
	[saturacion_oxigeno] [decimal](5, 2) NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[signo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[SignosVitales] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuarios](
	[usuario_id] [int] IDENTITY(1,1) NOT NULL,
	[nombre_usuario] [varchar](50) NULL,
	[contrasena] [varchar](255) NULL,
	[rol] [varchar](50) NULL,
	[activo] [bit] NULL,
	[fecha_registro] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[usuario_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[Usuarios] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[VacunasAplicadas]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VacunasAplicadas](
	[vacuna_id] [int] IDENTITY(1,1) NOT NULL,
	[paciente_id] [int] NULL,
	[vacuna_nombre] [varchar](100) NULL,
	[fecha_aplicacion] [date] NULL,
	[activo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[vacuna_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[VacunasAplicadas] TO  SCHEMA OWNER 
GO
ALTER TABLE [dbo].[AlergiasPaciente] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[AuditoriaPacientes] ADD  DEFAULT (getdate()) FOR [fecha]
GO
ALTER TABLE [dbo].[BitacoraAcciones] ADD  DEFAULT (getdate()) FOR [fecha]
GO
ALTER TABLE [dbo].[Citas] ADD  DEFAULT ('P') FOR [estado]
GO
ALTER TABLE [dbo].[Citas] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[Doctores] ADD  DEFAULT (getdate()) FOR [fecha_registro]
GO
ALTER TABLE [dbo].[Doctores] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[Medicamentos] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[Pacientes] ADD  DEFAULT (getdate()) FOR [fecha_registro]
GO
ALTER TABLE [dbo].[Pacientes] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[Recetas] ADD  DEFAULT (getdate()) FOR [fecha]
GO
ALTER TABLE [dbo].[Recetas] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[SignosVitales] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (getdate()) FOR [fecha_registro]
GO
ALTER TABLE [dbo].[VacunasAplicadas] ADD  DEFAULT ((1)) FOR [activo]
GO
ALTER TABLE [dbo].[AlergiasPaciente]  WITH CHECK ADD FOREIGN KEY([paciente_id])
REFERENCES [dbo].[Pacientes] ([paciente_id])
GO
ALTER TABLE [dbo].[AuditoriaPacientes]  WITH CHECK ADD FOREIGN KEY([paciente_id])
REFERENCES [dbo].[Pacientes] ([paciente_id])
GO
ALTER TABLE [dbo].[BitacoraAcciones]  WITH CHECK ADD FOREIGN KEY([usuario_id])
REFERENCES [dbo].[Usuarios] ([usuario_id])
GO
ALTER TABLE [dbo].[Citas]  WITH CHECK ADD FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctores] ([doctor_id])
GO
ALTER TABLE [dbo].[Citas]  WITH CHECK ADD FOREIGN KEY([paciente_id])
REFERENCES [dbo].[Pacientes] ([paciente_id])
GO
ALTER TABLE [dbo].[DetalleReceta]  WITH CHECK ADD FOREIGN KEY([medicamento_id])
REFERENCES [dbo].[Medicamentos] ([medicamento_id])
GO
ALTER TABLE [dbo].[DetalleReceta]  WITH CHECK ADD FOREIGN KEY([receta_id])
REFERENCES [dbo].[Recetas] ([receta_id])
GO
ALTER TABLE [dbo].[Doctores]  WITH CHECK ADD FOREIGN KEY([especialidad_id])
REFERENCES [dbo].[Especialidades] ([especialidad_id])
GO
ALTER TABLE [dbo].[Recetas]  WITH CHECK ADD FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctores] ([doctor_id])
GO
ALTER TABLE [dbo].[VacunasAplicadas]  WITH CHECK ADD FOREIGN KEY([paciente_id])
REFERENCES [dbo].[Pacientes] ([paciente_id])
GO
ALTER TABLE [dbo].[Citas_Archivo_Enero2025]  WITH CHECK ADD  CONSTRAINT [CK_CitasArchivo_Ene] CHECK  (([fecha]<'20250201'))
GO
ALTER TABLE [dbo].[Citas_Archivo_Enero2025] CHECK CONSTRAINT [CK_CitasArchivo_Ene]
GO
/****** Object:  StoredProcedure [dbo].[sp_CrearRecetaConDetalles]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CrearRecetaConDetalles]
    @cita_id INT,
    @doctor_id INT,
    @medicamentosDetalle TipoMedicamentosDetalle READONLY
AS
BEGIN
    DECLARE @receta_id INT;

    -- Insertar cabecera
    INSERT INTO Recetas(cita_id, doctor_id)
    VALUES(@cita_id, @doctor_id);

    SET @receta_id = SCOPE_IDENTITY();

    -- Insertar detalle
    INSERT INTO DetalleReceta(receta_id, medicamento_id, cantidad)
    SELECT @receta_id, medicamento_id, cantidad
    FROM @medicamentosDetalle;
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_CrearRecetaConDetalles] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_DesactivarDoctor]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DesactivarDoctor]
    @doctor_id INT
AS
BEGIN
    UPDATE Doctores
    SET activo=0
    WHERE doctor_id=@doctor_id;
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_DesactivarDoctor] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarPaciente]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_InsertarPaciente]
    @nombre VARCHAR(100),
    @dni VARCHAR(20),
    @fecha_nacimiento DATE,
    @sexo CHAR(1),
    @direccion VARCHAR(200),
    @telefono VARCHAR(15),
    @correo VARCHAR(100)
AS
BEGIN
    -- Insert histórico del paciente
    INSERT INTO Pacientes
      (nombre, dni, fecha_nacimiento, sexo, direccion, telefono, correo)
    VALUES
      (@nombre, @dni, @fecha_nacimiento, @sexo, @direccion, @telefono, @correo);

    -- Registrar auditoría
    INSERT INTO AuditoriaPacientes(paciente_id, accion)
    VALUES (SCOPE_IDENTITY(), 'Insertar paciente');
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_InsertarPaciente] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarCitasPorDoctor]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ListarCitasPorDoctor]
    @doctor_id INT
AS
BEGIN
    SELECT
      C.cita_id,
      P.nombre    AS paciente,
      C.fecha,
      C.motivo,
      C.estado
    FROM Citas C
    JOIN Pacientes P ON C.paciente_id=P.paciente_id
    WHERE C.doctor_id=@doctor_id
      AND C.activo=1
    ORDER BY C.fecha;
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_ListarCitasPorDoctor] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_RegistrarCita]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_RegistrarCita]
    @paciente_id INT,
    @doctor_id INT,
    @fecha DATETIME,
    @motivo VARCHAR(255)
AS
BEGIN
    -- Insertar cita
    INSERT INTO Citas (paciente_id, doctor_id, fecha, motivo)
    VALUES (@paciente_id, @doctor_id, @fecha, @motivo);
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_RegistrarCita] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_RegistrarSignosVitales]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_RegistrarSignosVitales]
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
ALTER AUTHORIZATION ON [dbo].[sp_RegistrarSignosVitales] TO  SCHEMA OWNER 
GO
/****** Object:  Trigger [dbo].[trg_RestarStockMedicamentos]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_RestarStockMedicamentos]
ON [dbo].[DetalleReceta]
AFTER INSERT
AS
BEGIN
    UPDATE M
    SET M.stock = M.stock - D.cantidad
    FROM Medicamentos M
    JOIN inserted D ON M.medicamento_id=D.medicamento_id;
END;
GO
ALTER TABLE [dbo].[DetalleReceta] ENABLE TRIGGER [trg_RestarStockMedicamentos]
GO
/****** Object:  Trigger [dbo].[trg_DesactivarDoctorInactivo]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_DesactivarDoctorInactivo]
ON [dbo].[Doctores]
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @did INT = (SELECT doctor_id FROM inserted);

    IF EXISTS (
      SELECT 1
      FROM Doctores
      WHERE doctor_id=@did
        AND activo=0
        AND DATEDIFF(MONTH, fecha_registro, GETDATE())>=6
    )
    BEGIN
        UPDATE Doctores SET activo=0 WHERE doctor_id=@did;
    END
END;
GO
ALTER TABLE [dbo].[Doctores] ENABLE TRIGGER [trg_DesactivarDoctorInactivo]
GO
/****** Object:  Trigger [dbo].[trg_DesactivarMedicamento]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_DesactivarMedicamento]
ON [dbo].[Medicamentos]
AFTER UPDATE
AS
BEGIN
    DECLARE @mid INT, @stk INT;
    SELECT @mid = medicamento_id, @stk = stock FROM inserted;

    IF @stk=0
    BEGIN
        UPDATE Medicamentos SET activo=0 WHERE medicamento_id=@mid;
    END
END;
GO
ALTER TABLE [dbo].[Medicamentos] ENABLE TRIGGER [trg_DesactivarMedicamento]
GO
/****** Object:  Trigger [dbo].[trg_DesactivarPaciente120]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_DesactivarPaciente120]
ON [dbo].[Pacientes]
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @nid INT; DECLARE @fn DATE;
    SELECT @nid=paciente_id, @fn=fecha_nacimiento FROM inserted;

    IF DATEDIFF(YEAR, @fn, GETDATE())>=120
    BEGIN
        UPDATE Pacientes SET activo=0 WHERE paciente_id=@nid;
    END
END;
GO
ALTER TABLE [dbo].[Pacientes] ENABLE TRIGGER [trg_DesactivarPaciente120]
GO
/****** Object:  Trigger [dbo].[trg_DesactivarPacienteSinCitas]    Script Date: 26/05/2025 16:46:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trg_DesactivarPacienteSinCitas]
ON [dbo].[Pacientes]
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @pid INT = (SELECT paciente_id FROM inserted);

    IF NOT EXISTS (
      SELECT 1
      FROM Citas
      WHERE paciente_id=@pid
        AND fecha>=DATEADD(YEAR,-1,GETDATE())
        AND activo=1
    )
    BEGIN
        UPDATE Pacientes
        SET activo=0
        WHERE paciente_id=@pid;
    END
END;
GO
ALTER TABLE [dbo].[Pacientes] ENABLE TRIGGER [trg_DesactivarPacienteSinCitas]
GO
USE [master]
GO
ALTER DATABASE [CLINICAUPC] SET  READ_WRITE 
GO
