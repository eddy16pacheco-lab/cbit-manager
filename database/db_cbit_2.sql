-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         12.1.2-MariaDB - MariaDB Server
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.22.0.7382
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para db_cbit_2
CREATE DATABASE IF NOT EXISTS `db_cbit_2` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `db_cbit_2`;

-- Volcando estructura para tabla db_cbit_2.actividad
CREATE TABLE IF NOT EXISTS `actividad` (
  `id_actividad` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion_actividad` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_actividad`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.actividad: ~10 rows (aproximadamente)
INSERT INTO `actividad` (`id_actividad`, `nombre`, `descripcion_actividad`) VALUES
	(1, 'Clase de Programación', 'Clase práctica de programación'),
	(2, 'Taller de Robótica', 'Taller de robótica educativa'),
	(3, 'Presentación de Proyectos', 'Presentación de proyectos finales'),
	(4, 'Examen Práctico', 'Evaluación práctica de habilidades'),
	(5, 'Laboratorio de Física', 'Prácticas de laboratorio'),
	(6, 'Clase de Inglés', 'Clase de inglés técnico'),
	(7, 'Taller de Diseño', 'Taller de diseño gráfico'),
	(8, 'Seminario de Investigación', 'Seminario de investigación académica'),
	(9, 'Clase de Matemáticas', 'Clase de matemáticas aplicadas'),
	(10, 'Taller de Electrónica', 'Taller de electrónica básica');

-- Volcando estructura para tabla db_cbit_2.alerta_prestamo
CREATE TABLE IF NOT EXISTS `alerta_prestamo` (
  `id_alerta` int(11) NOT NULL AUTO_INCREMENT,
  `id_solicitud` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `tipo_alerta` enum('Proximo a vencer','Vencido','Devuelto') NOT NULL,
  `mensaje` varchar(255) NOT NULL,
  `fecha_alerta` datetime NOT NULL DEFAULT current_timestamp(),
  `leida` enum('Si','No') NOT NULL DEFAULT 'No',
  PRIMARY KEY (`id_alerta`),
  KEY `alerta_solicitud` (`id_solicitud`),
  KEY `alerta_usuario` (`id_usuario`),
  CONSTRAINT `alerta_solicitud` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alerta_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.alerta_prestamo: ~1 rows (aproximadamente)

-- Volcando estructura para tabla db_cbit_2.asistencia
CREATE TABLE IF NOT EXISTS `asistencia` (
  `id_asistencia` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) DEFAULT NULL,
  `id_solicitud` int(11) DEFAULT NULL,
  `asistio` enum('Si','No') NOT NULL,
  PRIMARY KEY (`id_asistencia`),
  KEY `tiene_` (`id_estudiante`),
  KEY `tiene` (`id_solicitud`),
  CONSTRAINT `tiene` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tiene_` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiante` (`id_estudiante`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.asistencia: ~0 rows (aproximadamente)
INSERT INTO `asistencia` (`id_asistencia`, `id_estudiante`, `id_solicitud`, `asistio`) VALUES
	(11, 1, 11, 'Si'),
	(12, 2, 21, 'Si');

-- Volcando estructura para tabla db_cbit_2.auditoria
CREATE TABLE IF NOT EXISTS `auditoria` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `tabla` varchar(60) NOT NULL COMMENT 'Tabla afectada',
  `operacion` enum('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Tipo de operación',
  `id_registro` int(11) DEFAULT NULL COMMENT 'PK del registro afectado',
  `campo` varchar(60) DEFAULT NULL COMMENT 'Campo modificado (solo UPDATE)',
  `valor_anterior` text DEFAULT NULL COMMENT 'Valor antes del cambio',
  `valor_nuevo` text DEFAULT NULL COMMENT 'Valor después del cambio',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Usuario que realizó la acción',
  `nombre_usuario` varchar(100) DEFAULT NULL COMMENT 'Nombre de usuario en sesión',
  `ip_usuario` varchar(45) DEFAULT NULL COMMENT 'IP del cliente',
  `fecha_hora` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora exacta',
  `descripcion` text DEFAULT NULL COMMENT 'Descripción legible del evento',
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_tabla` (`tabla`),
  KEY `idx_operacion` (`operacion`),
  KEY `idx_usuario` (`id_usuario`),
  KEY `idx_fecha` (`fecha_hora`),
  KEY `idx_registro` (`tabla`,`id_registro`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Registro de auditoría de todas las operaciones del sistema';

-- Volcando datos para la tabla db_cbit_2.auditoria: ~72 rows (aproximadamente)
INSERT INTO `auditoria` (`id_auditoria`, `tabla`, `operacion`, `id_registro`, `campo`, `valor_anterior`, `valor_nuevo`, `id_usuario`, `nombre_usuario`, `ip_usuario`, `fecha_hora`, `descripcion`) VALUES
	(1, 'espacio', 'INSERT', 1, NULL, NULL, 'nombre:Salón del cbit | capacidad:20', NULL, NULL, NULL, '2026-07-28 06:00:54', 'Nuevo espacio registrado: Salón del cbit (Cap: 20)'),
	(2, 'solicitud', 'INSERT', 11, NULL, NULL, 'fecha:2026-07-28 | horario:09:00:00-10:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 06:01:52', 'Nueva solicitud #11 creada con estado Pendiente'),
	(3, 'usuario', 'UPDATE', 1, 'correo', 'eddy.pacheco@gmail.com', 'eddy15pacheco@gmail.com', NULL, NULL, NULL, '2026-07-28 06:02:32', 'Cambio de correo electrónico'),
	(4, 'solicitud', 'UPDATE', 11, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 06:02:52', 'Solicitud #11 cambió de Pendiente a Aprobado'),
	(5, 'solicitud', 'DELETE', 10, NULL, 'fecha:2026-07-27 | estado:Completado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:37', 'Solicitud #10 eliminada (estado previo: Completado)'),
	(6, 'solicitud', 'DELETE', 8, NULL, 'fecha:2026-07-26 | estado:Aprobado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:40', 'Solicitud #8 eliminada (estado previo: Aprobado)'),
	(7, 'solicitud', 'DELETE', 9, NULL, 'fecha:2026-07-26 | estado:Aprobado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:42', 'Solicitud #9 eliminada (estado previo: Aprobado)'),
	(8, 'solicitud', 'DELETE', 6, NULL, 'fecha:2026-07-25 | estado:Aprobado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:45', 'Solicitud #6 eliminada (estado previo: Aprobado)'),
	(9, 'solicitud', 'DELETE', 1, NULL, 'fecha:2026-07-22 | estado:Aprobado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:49', 'Solicitud #1 eliminada (estado previo: Aprobado)'),
	(10, 'solicitud', 'DELETE', 4, NULL, 'fecha:2026-07-24 | estado:Completado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:52', 'Solicitud #4 eliminada (estado previo: Completado)'),
	(11, 'solicitud', 'DELETE', 5, NULL, 'fecha:2026-07-24 | estado:Cancelado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:54', 'Solicitud #5 eliminada (estado previo: Cancelado)'),
	(12, 'solicitud', 'DELETE', 3, NULL, 'fecha:2026-07-23 | estado:Aprobado', NULL, NULL, NULL, NULL, '2026-07-28 06:09:57', 'Solicitud #3 eliminada (estado previo: Aprobado)'),
	(13, 'solicitud', 'DELETE', 2, NULL, 'fecha:2026-07-22 | estado:Pendiente', NULL, NULL, NULL, NULL, '2026-07-28 06:10:02', 'Solicitud #2 eliminada (estado previo: Pendiente)'),
	(14, 'solicitud', 'UPDATE', 7, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 06:10:13', 'Solicitud #7 cambió de Pendiente a Aprobado'),
	(15, 'solicitud', 'INSERT', 12, NULL, NULL, 'fecha:2026-07-29 | horario:06:22:00-07:22:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 06:22:54', 'Nueva solicitud #12 creada con estado Pendiente'),
	(16, 'solicitud', 'UPDATE', 12, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 06:23:13', 'Solicitud #12 cambió de Pendiente a Aprobado'),
	(17, 'solicitud', 'UPDATE', 12, 'estado', 'Aprobado', 'Cancelado', NULL, NULL, NULL, '2026-07-28 06:23:47', 'Solicitud #12 cambió de Aprobado a Cancelado'),
	(18, 'solicitud', 'DELETE', 12, NULL, 'fecha:2026-07-29 | estado:Cancelado', NULL, NULL, NULL, NULL, '2026-07-28 06:23:51', 'Solicitud #12 eliminada (estado previo: Cancelado)'),
	(19, 'solicitud', 'INSERT', 13, NULL, NULL, 'fecha:2026-07-29 | horario:07:24:00-08:24:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 06:24:11', 'Nueva solicitud #13 creada con estado Pendiente'),
	(20, 'solicitud', 'UPDATE', 13, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 06:24:13', 'Solicitud #13 cambió de Pendiente a Aprobado'),
	(21, 'persona', 'INSERT', 11, NULL, NULL, 'nombre:Daniel Pacheco | cedula:V-32566687', NULL, NULL, NULL, '2026-07-28 07:19:26', 'Nueva persona registrada: Daniel Pacheco — C.I.: V-32566687'),
	(22, 'asistencia', 'INSERT', 11, NULL, NULL, 'estudiante_id:1 | solicitud_id:11 | asistio:Si', NULL, NULL, NULL, '2026-07-28 07:19:38', 'Asistencia registrada — Estudiante #1 en solicitud #11: Si'),
	(23, 'persona', 'INSERT', 12, NULL, NULL, 'nombre:Danilo Serrano | cedula:V-31360528', NULL, NULL, NULL, '2026-07-28 10:36:51', 'Nueva persona registrada: Danilo Serrano — C.I.: V-31360528'),
	(24, 'usuario', 'INSERT', 11, NULL, NULL, 'usuario:Dani | rol:Administrador | estado:Activo', NULL, NULL, NULL, '2026-07-28 10:39:09', 'Nuevo usuario registrado: Dani (Administrador)'),
	(25, 'solicitud', 'INSERT', 14, NULL, NULL, 'fecha:2026-07-28 | horario:10:40:00-11:40:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:40:25', 'Nueva solicitud #14 creada con estado Pendiente'),
	(26, 'solicitud', 'UPDATE', 14, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 10:40:33', 'Solicitud #14 cambió de Pendiente a Aprobado'),
	(27, 'usuario', 'UPDATE', 11, 'roles', 'Administrador', 'Docente', NULL, NULL, NULL, '2026-07-28 10:42:45', 'Cambio de rol: Administrador → Docente'),
	(28, 'solicitud', 'INSERT', 15, NULL, NULL, 'fecha:2026-07-29 | horario:10:44:00-11:44:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:44:35', 'Nueva solicitud #15 creada con estado Pendiente'),
	(29, 'solicitud', 'INSERT', 16, NULL, NULL, 'fecha:2026-07-29 | horario:10:44:00-11:44:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:44:36', 'Nueva solicitud #16 creada con estado Pendiente'),
	(30, 'solicitud', 'INSERT', 17, NULL, NULL, 'fecha:2026-07-30 | horario:10:46:00-11:45:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:45:52', 'Nueva solicitud #17 creada con estado Pendiente'),
	(31, 'solicitud', 'INSERT', 18, NULL, NULL, 'fecha:2026-07-30 | horario:10:46:00-11:45:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:45:53', 'Nueva solicitud #18 creada con estado Pendiente'),
	(32, 'solicitud', 'UPDATE', 17, 'estado', 'Pendiente', 'Cancelado', NULL, NULL, NULL, '2026-07-28 10:48:15', 'Solicitud #17 cambió de Pendiente a Cancelado'),
	(33, 'usuario', 'UPDATE', 11, 'estado', 'Activo', 'Inactivo', NULL, NULL, NULL, '2026-07-28 10:51:58', 'Cambio de estado usuario: Activo → Inactivo'),
	(34, 'usuario', 'UPDATE', 11, 'correo', 'danilo.pacheco754@gmail.com', 'danilo.pacheco754@gmail.comj', NULL, NULL, NULL, '2026-07-28 10:52:33', 'Cambio de correo electrónico'),
	(35, 'usuario', 'UPDATE', 1, 'correo', 'eddy15pacheco@gmail.com', 'danilo.pacheco754@gmail.com', NULL, NULL, NULL, '2026-07-28 10:52:40', 'Cambio de correo electrónico'),
	(36, 'solicitud', 'INSERT', 19, NULL, NULL, 'fecha:2026-07-29 | horario:10:52:00-11:52:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:53:04', 'Nueva solicitud #19 creada con estado Pendiente'),
	(37, 'solicitud', 'UPDATE', 18, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 10:53:11', 'Solicitud #18 cambió de Pendiente a Aprobado'),
	(38, 'usuario', 'UPDATE', 1, 'correo', 'danilo.pacheco754@gmail.com', 'eddy15pacheco@gmail.com', NULL, NULL, NULL, '2026-07-28 10:54:34', 'Cambio de correo electrónico'),
	(39, 'solicitud', 'INSERT', 20, NULL, NULL, 'fecha:2026-07-30 | horario:06:57:00-07:56:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 10:56:50', 'Nueva solicitud #20 creada con estado Pendiente'),
	(40, 'solicitud', 'UPDATE', 20, 'estado', 'Pendiente', 'Cancelado', NULL, NULL, NULL, '2026-07-28 10:57:02', 'Solicitud #20 cambió de Pendiente a Cancelado'),
	(41, 'usuario', 'UPDATE', 2, 'correo', 'ana.ramirez@instituto.edu', 'eddy16pacheco@gmail.com', NULL, NULL, NULL, '2026-07-28 10:59:17', 'Cambio de correo electrónico'),
	(42, 'usuario', 'UPDATE', 2, 'contrasena_usuario', '***', '***', NULL, NULL, NULL, '2026-07-28 11:00:09', 'Cambio de contraseña'),
	(43, 'solicitud', 'INSERT', 21, NULL, NULL, 'fecha:2026-07-31 | horario:11:00:00-12:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 11:00:54', 'Nueva solicitud #21 creada con estado Pendiente'),
	(44, 'solicitud', 'UPDATE', 21, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 11:01:20', 'Solicitud #21 cambió de Pendiente a Aprobado'),
	(45, 'categoria', 'INSERT', 11, NULL, NULL, 'SAMSUGN', NULL, NULL, NULL, '2026-07-28 11:29:54', 'Nueva categoría registrada: SAMSUGN'),
	(46, 'marca', 'INSERT', 11, NULL, NULL, 'Eddy', NULL, NULL, NULL, '2026-07-28 11:30:10', 'Nueva marca registrada: Eddy'),
	(47, 'equipos', 'INSERT', 11, NULL, NULL, 'nombre:Monitor', NULL, NULL, NULL, '2026-07-28 11:30:34', 'Nuevo equipo registrado en catálogo: Monitor'),
	(48, 'solicitud', 'INSERT', 22, NULL, NULL, 'fecha:2026-07-29 | horario:10:33:00-11:33:00 | estado:Pendiente', NULL, NULL, NULL, '2026-07-28 11:34:26', 'Nueva solicitud #22 creada con estado Pendiente'),
	(49, 'solicitud', 'UPDATE', 22, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-07-28 11:35:26', 'Solicitud #22 cambió de Pendiente a Aprobado'),
	(50, 'solicitud', 'DELETE', 20, NULL, 'fecha:2026-07-30 | estado:Cancelado', NULL, NULL, NULL, NULL, '2026-07-28 11:37:39', 'Solicitud #20 eliminada (estado previo: Cancelado)'),
	(51, 'solicitud', 'UPDATE', 22, 'estado', 'Aprobado', 'Cancelado', NULL, NULL, NULL, '2026-07-28 11:38:46', 'Solicitud #22 cambió de Aprobado a Cancelado'),
	(52, 'persona', 'INSERT', 13, NULL, NULL, 'nombre:Mailo Perez | cedula:55328562', NULL, NULL, NULL, '2026-07-28 11:41:43', 'Nueva persona registrada: Mailo Perez — C.I.: 55328562'),
	(53, 'persona', 'UPDATE', 13, 'cedula', '55328562', 'V-120982123', NULL, NULL, NULL, '2026-07-28 11:42:25', 'Cédula modificada'),
	(54, 'persona', 'UPDATE', 13, 'telefono', '9999999999999999999999', '04129574227', NULL, NULL, NULL, '2026-07-28 11:42:25', 'Teléfono modificado'),
	(55, 'tecnicos', 'INSERT', 4, NULL, NULL, 'persona_id:13 | especialidad:Hardware', NULL, NULL, NULL, '2026-07-28 11:42:51', 'Nuevo técnico registrado — Especialidad: Hardware'),
	(56, 'persona', 'INSERT', 14, NULL, NULL, 'nombre:Pepe Palacios | cedula:V-3298212', NULL, NULL, NULL, '2026-07-28 11:44:37', 'Nueva persona registrada: Pepe Palacios — C.I.: V-3298212'),
	(57, 'asistencia', 'INSERT', 12, NULL, NULL, 'estudiante_id:2 | solicitud_id:21 | asistio:Si', NULL, NULL, NULL, '2026-07-28 11:44:56', 'Asistencia registrada — Estudiante #2 en solicitud #21: Si'),
	(58, 'persona', 'UPDATE', 1, 'cedula', '31394074', 'V-31394074', NULL, NULL, NULL, '2026-07-29 20:37:24', 'Cédula modificada'),
	(59, 'solicitud', 'INSERT', 23, NULL, NULL, 'fecha:2026-09-07 | horario:09:39:00-10:45:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-04 09:39:39', 'Nueva solicitud #23 creada con estado Pendiente'),
	(60, 'solicitud', 'UPDATE', 23, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-04 09:40:16', 'Solicitud #23 cambió de Pendiente a Aprobado'),
	(61, 'persona', 'INSERT', 15, NULL, NULL, 'nombre:Manuel Pacheco | cedula:V-30937772', NULL, NULL, NULL, '2026-09-04 18:25:41', 'Nueva persona registrada: Manuel Pacheco — C.I.: V-30937772'),
	(62, 'usuario', 'INSERT', 12, NULL, NULL, 'usuario:manu123 | rol:Docente | estado:Activo', NULL, NULL, NULL, '2026-09-04 18:28:49', 'Nuevo usuario registrado: manu123 (Docente)'),
	(63, 'solicitud', 'INSERT', 24, NULL, NULL, 'fecha:2026-10-06 | horario:07:30:00-09:30:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-04 18:30:49', 'Nueva solicitud #24 creada con estado Pendiente'),
	(64, 'solicitud', 'UPDATE', 24, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-04 18:31:01', 'Solicitud #24 cambió de Pendiente a Aprobado'),
	(65, 'persona', 'INSERT', 16, NULL, NULL, 'nombre:dolk dmo | cedula:V-120343', NULL, NULL, NULL, '2026-09-15 15:56:06', 'Nueva persona registrada: dolk dmo — C.I.: V-120343'),
	(66, 'persona', 'DELETE', 16, NULL, 'dolk dmo | cedula:V-120343', NULL, NULL, NULL, NULL, '2026-09-15 15:56:45', 'Persona eliminada: dolk dmo'),
	(67, 'categoria', 'INSERT', 12, NULL, NULL, 'wdqqqqqqqqqqDWDwq', NULL, NULL, NULL, '2026-09-15 16:00:47', 'Nueva categoría registrada: wdqqqqqqqqqqDWDwq'),
	(68, 'marca', 'INSERT', 12, NULL, NULL, 'k3pq2dkdq3k`dq', NULL, NULL, NULL, '2026-09-15 16:02:13', 'Nueva marca registrada: k3pq2dkdq3k`dq'),
	(69, 'equipos', 'INSERT', 12, NULL, NULL, 'nombre:dwwwwwwwwwwwwwwwww', NULL, NULL, NULL, '2026-09-15 16:02:32', 'Nuevo equipo registrado en catálogo: dwwwwwwwwwwwwwwwww'),
	(70, 'solicitud', 'INSERT', 25, NULL, NULL, 'fecha:2026-09-16 | horario:08:00:00-09:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-15 16:05:23', 'Nueva solicitud #25 creada con estado Pendiente'),
	(71, 'solicitud', 'INSERT', 26, NULL, NULL, 'fecha:2026-09-16 | horario:08:00:00-21:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-15 16:05:58', 'Nueva solicitud #26 creada con estado Pendiente'),
	(72, 'solicitud', 'UPDATE', 26, 'horario', '2026-09-16 08:00:00-21:00:00', '2026-09-16 08:00:00-09:00:00', NULL, NULL, NULL, '2026-09-15 16:12:29', 'Horario modificado en solicitud #26'),
	(73, 'solicitud', 'UPDATE', 25, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-15 16:12:35', 'Solicitud #25 cambió de Pendiente a Aprobado'),
	(74, 'solicitud', 'DELETE', 26, NULL, 'fecha:2026-09-16 | estado:Pendiente', NULL, NULL, NULL, NULL, '2026-09-15 16:13:13', 'Solicitud #26 eliminada (estado previo: Pendiente)'),
	(75, 'solicitud', 'INSERT', 27, NULL, NULL, 'fecha:2026-09-17 | horario:08:05:00-10:01:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-15 17:01:49', 'Nueva solicitud #27 creada con estado Pendiente'),
	(76, 'solicitud', 'UPDATE', 27, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-15 17:01:54', 'Solicitud #27 cambió de Pendiente a Aprobado'),
	(77, 'persona', 'INSERT', 17, NULL, NULL, 'nombre:Eddy Pacheco | cedula:V-31394213', NULL, NULL, NULL, '2026-09-15 17:04:01', 'Nueva persona registrada: Eddy Pacheco — C.I.: V-31394213'),
	(78, 'solicitud', 'INSERT', 28, NULL, NULL, 'fecha:2026-09-25 | horario:10:00:00-11:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-24 19:58:35', 'Nueva solicitud #28 creada con estado Pendiente'),
	(79, 'solicitud', 'UPDATE', 28, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-24 19:59:17', 'Solicitud #28 cambió de Pendiente a Aprobado'),
	(80, 'inventario', 'DELETE', 1, NULL, 'serial:HP-ELITE-001 | estado:Operativo', NULL, NULL, NULL, NULL, '2026-09-27 09:51:16', 'Equipo eliminado del inventario — Serial: HP-ELITE-001'),
	(81, 'inventario', 'DELETE', 2, NULL, 'serial:HP-ELITE-002 | estado:Operativo', NULL, NULL, NULL, NULL, '2026-09-27 09:51:45', 'Equipo eliminado del inventario — Serial: HP-ELITE-002'),
	(82, 'equipos', 'DELETE', 1, NULL, 'Laptop HP EliteBook 840', NULL, NULL, NULL, NULL, '2026-09-27 09:51:48', 'Equipo eliminado del catálogo: Laptop HP EliteBook 840'),
	(83, 'solicitud', 'INSERT', 29, NULL, NULL, 'fecha:2026-09-28 | horario:08:00:00-10:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-27 10:24:23', 'Nueva solicitud #29 creada con estado Pendiente'),
	(84, 'solicitud', 'UPDATE', 29, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-27 10:24:27', 'Solicitud #29 cambió de Pendiente a Aprobado'),
	(85, 'solicitud', 'INSERT', 30, NULL, NULL, 'fecha:2026-09-29 | horario:10:00:00-12:00:00 | estado:Aprobado', NULL, NULL, NULL, '2026-09-27 10:25:22', 'Nueva solicitud #30 creada con estado Aprobado'),
	(86, 'solicitud', 'INSERT', 31, NULL, NULL, 'fecha:2026-09-30 | horario:11:00:00-13:00:00 | estado:Pendiente', NULL, NULL, NULL, '2026-09-27 10:26:31', 'Nueva solicitud #31 creada con estado Pendiente'),
	(87, 'solicitud', 'UPDATE', 31, 'estado', 'Pendiente', 'Aprobado', NULL, NULL, NULL, '2026-09-27 10:26:34', 'Solicitud #31 cambió de Pendiente a Aprobado');

-- Volcando estructura para tabla db_cbit_2.categoria
CREATE TABLE IF NOT EXISTS `categoria` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.categoria: ~10 rows (aproximadamente)
INSERT INTO `categoria` (`id_categoria`, `nombre`, `descripcion`) VALUES
	(1, 'Computadoras', 'Equipos de cómputo y laptops'),
	(2, 'Proyectores', 'Proyectores multimedia y videoproyectores'),
	(3, 'Impresoras', 'Impresoras y equipos de impresión'),
	(4, 'Redes', 'Equipos de red y conectividad'),
	(5, 'Dispositivos móviles', 'Tablets y dispositivos móviles'),
	(6, 'Audio y Video', 'Equipos de audio y video'),
	(7, 'Software', 'Licencias y software educativo'),
	(8, 'Periféricos', 'Teclados, mouse, monitores'),
	(9, 'Laboratorio', 'Equipos de laboratorio y medición'),
	(10, 'Seguridad', 'Equipos de seguridad y vigilancia'),
	(11, 'SAMSUGN', NULL),
	(12, 'wdqqqqqqqqqqDWDwq', NULL);

-- Volcando estructura para tabla db_cbit_2.detalle_solicitud
CREATE TABLE IF NOT EXISTS `detalle_solicitud` (
  `id_detalle_solicitud` int(11) NOT NULL AUTO_INCREMENT,
  `id_solicitud` int(11) DEFAULT NULL,
  `id_inventario` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_detalle_solicitud`),
  KEY `puede_tener` (`id_solicitud`),
  KEY `puede_tener_` (`id_inventario`),
  CONSTRAINT `puede_tener` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `puede_tener_` FOREIGN KEY (`id_inventario`) REFERENCES `inventario` (`id_inventario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.detalle_solicitud: ~55 rows (aproximadamente)
INSERT INTO `detalle_solicitud` (`id_detalle_solicitud`, `id_solicitud`, `id_inventario`) VALUES
	(9, 7, 9),
	(13, 11, 9),
	(14, 11, 3),
	(19, 13, 12),
	(20, 14, 9),
	(22, 15, 9),
	(23, 15, 6),
	(24, 16, 9),
	(25, 16, 6),
	(26, 17, 3),
	(28, 17, 12),
	(29, 18, 3),
	(31, 18, 12),
	(33, 19, 5),
	(34, 19, 10),
	(35, 19, 11),
	(41, 22, 3),
	(43, 23, 9),
	(44, 23, 3),
	(47, 24, 3),
	(48, 25, 9),
	(49, 25, 3),
	(52, 25, 7),
	(53, 25, 12),
	(54, 25, 10),
	(55, 25, 11),
	(58, 27, 9),
	(59, 27, 3),
	(62, 27, 5),
	(63, 27, 6),
	(64, 27, 7),
	(65, 27, 12),
	(66, 27, 10),
	(67, 27, 11),
	(68, 28, 9),
	(69, 28, 3),
	(72, 29, 9),
	(73, 29, 3),
	(74, 29, 5),
	(75, 29, 6),
	(76, 29, 10),
	(77, 29, 11),
	(78, 30, 9),
	(79, 30, 3),
	(80, 30, 5),
	(81, 30, 7),
	(82, 30, 12),
	(83, 30, 10),
	(84, 31, 9),
	(85, 31, 3),
	(86, 31, 5),
	(87, 31, 6),
	(88, 31, 7),
	(89, 31, 12),
	(90, 31, 10),
	(91, 31, 11);

-- Volcando estructura para tabla db_cbit_2.disponibilidad_calendario
CREATE TABLE IF NOT EXISTS `disponibilidad_calendario` (
  `id_disponibilidad` int(11) NOT NULL AUTO_INCREMENT,
  `tipo_recurso` enum('Equipo','Espacio') NOT NULL,
  `id_recurso` int(11) NOT NULL COMMENT 'id_inventario si es Equipo, id_espacio si es Espacio',
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `disponible` enum('Si','No') NOT NULL DEFAULT 'Si',
  PRIMARY KEY (`id_disponibilidad`),
  KEY `idx_tipo_recurso` (`tipo_recurso`,`id_recurso`),
  KEY `idx_fechas` (`fecha_inicio`,`fecha_fin`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.disponibilidad_calendario: ~4 rows (aproximadamente)
INSERT INTO `disponibilidad_calendario` (`id_disponibilidad`, `tipo_recurso`, `id_recurso`, `fecha_inicio`, `fecha_fin`, `motivo`, `disponible`) VALUES
	(1, 'Equipo', 4, '2026-07-15 08:00:00', '2026-07-25 17:00:00', 'En mantenimiento por falla', 'No'),
	(2, 'Equipo', 8, '2026-07-18 10:00:00', '2026-07-28 18:00:00', 'Reparación de proyector', 'No'),
	(3, 'Espacio', 2, '2026-07-25 08:00:00', '2026-07-25 12:00:00', 'Reservado para clase especial', 'No'),
	(4, 'Espacio', 1, '2026-07-30 14:00:00', '2026-07-30 18:00:00', 'Evento institucional', 'No');

-- Volcando estructura para tabla db_cbit_2.equipos
CREATE TABLE IF NOT EXISTS `equipos` (
  `id_equipos` int(11) NOT NULL AUTO_INCREMENT,
  `id_categoria` int(11) DEFAULT NULL,
  `id_modelo` int(11) DEFAULT NULL,
  `id_marca` int(11) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_equipos`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `esta_coformado` (`id_categoria`),
  KEY `tiene_asignado` (`id_modelo`),
  KEY `_tiene_` (`id_marca`),
  CONSTRAINT `_tiene_` FOREIGN KEY (`id_marca`) REFERENCES `marca` (`id_marca`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `esta_coformado` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tiene_asignado` FOREIGN KEY (`id_modelo`) REFERENCES `modelo` (`id_modelo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.equipos: ~10 rows (aproximadamente)
INSERT INTO `equipos` (`id_equipos`, `id_categoria`, `id_modelo`, `id_marca`, `nombre`) VALUES
	(2, 1, 2, 2, 'Laptop Dell Latitude 7420'),
	(3, 1, 3, 3, 'Laptop Lenovo ThinkPad T14'),
	(4, 1, 4, 4, 'MacBook Air M2'),
	(5, 2, 6, 6, 'Proyector Epson PowerLite'),
	(6, 3, 7, 7, 'Impresora Canon Multifuncional'),
	(7, 4, 8, 8, 'Switch Cisco Catalyst'),
	(8, 5, 5, 5, 'Tablet Samsung Galaxy Tab S7'),
	(9, 1, 10, 10, 'Microsoft Surface Pro 8'),
	(10, 6, 9, 9, 'Monitor Sony Bravia Pro'),
	(11, 11, 4, 11, 'Monitor'),
	(12, 12, 10, 12, 'dwwwwwwwwwwwwwwwww');

-- Volcando estructura para tabla db_cbit_2.espacio
CREATE TABLE IF NOT EXISTS `espacio` (
  `id_espacio` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `capacidad` int(11) NOT NULL,
  PRIMARY KEY (`id_espacio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.espacio: ~0 rows (aproximadamente)
INSERT INTO `espacio` (`id_espacio`, `nombre`, `capacidad`) VALUES
	(1, 'Salón del cbit', 20);

-- Volcando estructura para tabla db_cbit_2.estudiante
CREATE TABLE IF NOT EXISTS `estudiante` (
  `id_estudiante` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) DEFAULT NULL,
  `seccion` enum('A','B','C','D','U') DEFAULT NULL,
  `año` enum('1er año','2er año','3er año','4er año','5er año','6er año') NOT NULL,
  PRIMARY KEY (`id_estudiante`),
  KEY `es` (`id_persona`),
  CONSTRAINT `fk_estudiante_persona` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.estudiante: ~0 rows (aproximadamente)
INSERT INTO `estudiante` (`id_estudiante`, `id_persona`, `seccion`, `año`) VALUES
	(1, 11, 'A', '2er año'),
	(2, 14, 'B', '3er año');

-- Volcando estructura para tabla db_cbit_2.historial_actividad
CREATE TABLE IF NOT EXISTS `historial_actividad` (
  `id_historial` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) DEFAULT NULL,
  `usuario` varchar(150) DEFAULT NULL,
  `accion` varchar(50) NOT NULL,
  `modulo` varchar(80) NOT NULL,
  `detalle` varchar(255) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_historial`),
  KEY `idx_historial_usuario` (`id_usuario`),
  KEY `idx_historial_fecha` (`fecha`),
  KEY `idx_historial_modulo` (`modulo`),
  CONSTRAINT `fk_historial_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.historial_actividad: ~95 rows (aproximadamente)
INSERT INTO `historial_actividad` (`id_historial`, `id_usuario`, `usuario`, `accion`, `modulo`, `detalle`, `ip`, `fecha`) VALUES
	(1, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-04 09:31:18'),
	(2, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 09:32:46'),
	(3, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 09:32:49'),
	(4, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:192.168.100.33', '2026-09-04 09:37:34'),
	(5, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 09:37:47'),
	(6, 2, 'Ana Ramírez', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::ffff:192.168.100.33', '2026-09-04 09:39:41'),
	(7, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', NULL, '2026-09-04 09:41:19'),
	(8, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 18:21:50'),
	(9, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 18:21:50'),
	(10, 1, 'Eddy Pacheco', 'Creación', 'Personas', 'Persona registrada', '::ffff:192.168.100.33', '2026-09-04 18:25:41'),
	(11, 1, 'Eddy Pacheco', 'Creación', 'Usuarios', 'Usuario registrado', '::ffff:192.168.100.33', '2026-09-04 18:28:50'),
	(12, NULL, 'manu123', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::ffff:192.168.100.190', '2026-09-04 18:29:08'),
	(13, 12, 'Manuel Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.190', '2026-09-04 18:29:16'),
	(14, 12, 'Manuel Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::ffff:192.168.100.190', '2026-09-04 18:30:49'),
	(15, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', NULL, '2026-09-04 18:32:13'),
	(16, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', NULL, '2026-09-04 18:32:14'),
	(17, 12, 'Manuel Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:192.168.100.190', '2026-09-04 18:32:26'),
	(18, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 18:35:30'),
	(19, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 18:35:30'),
	(20, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 22:20:25'),
	(21, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-04 22:20:25'),
	(22, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-15 15:38:54'),
	(23, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-15 15:38:54'),
	(24, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-15 15:54:23'),
	(25, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-15 15:54:39'),
	(26, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-15 15:54:39'),
	(27, 1, 'Eddy Pacheco', 'Creación', 'Personas', 'Persona registrada', '::1', '2026-09-15 15:56:06'),
	(28, 1, 'Eddy Pacheco', 'Eliminación', 'Personas', 'Persona eliminada', '::1', '2026-09-15 15:56:45'),
	(29, 1, 'Eddy Pacheco', 'Creación', 'Categorías', 'Categoría registrada', '::1', '2026-09-15 16:00:47'),
	(30, 1, 'Eddy Pacheco', 'Creación', 'Marcas', 'Marca registrada', '::1', '2026-09-15 16:02:13'),
	(31, 1, 'Eddy Pacheco', 'Creación', 'Equipos', 'Equipo registrado', '::1', '2026-09-15 16:02:32'),
	(32, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-09-15 16:05:24'),
	(33, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-09-15 16:05:58'),
	(34, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud actualizada', '::1', '2026-09-15 16:12:30'),
	(35, 1, 'Eddy Pacheco', 'Eliminación', 'Solicitudes', 'Solicitud eliminada', '::1', '2026-09-15 16:13:13'),
	(36, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', NULL, '2026-09-15 16:13:48'),
	(37, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-15 16:13:56'),
	(38, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-15 17:00:47'),
	(39, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-09-15 17:01:50'),
	(40, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', NULL, '2026-09-15 17:02:50'),
	(41, 1, 'Eddy Pacheco', 'Creación', 'Personas', 'Persona registrada', '::1', '2026-09-15 17:04:01'),
	(42, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-16 10:07:40'),
	(43, 1, 'Eddy Pacheco', 'Creación', 'Modelos', 'Modelo registrado', '::1', '2026-09-16 10:11:13'),
	(44, 1, 'Eddy Pacheco', 'Eliminación', 'Modelos', 'Modelo eliminado', '::1', '2026-09-16 10:11:22'),
	(45, NULL, 'docente', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::ffff:10.91.124.92', '2026-09-16 10:13:25'),
	(46, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:10.91.124.92', '2026-09-16 10:13:33'),
	(47, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-16 10:14:49'),
	(48, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-20 09:11:04'),
	(49, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-20 09:11:51'),
	(50, NULL, 'docente1', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::1', '2026-09-20 09:11:55'),
	(51, NULL, 'docente', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::1', '2026-09-20 09:12:01'),
	(52, NULL, 'docente', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::1', '2026-09-20 09:12:04'),
	(53, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-20 09:12:09'),
	(54, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-20 09:12:46'),
	(55, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-20 09:12:50'),
	(56, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-24 19:57:12'),
	(57, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:172.28.190.182', '2026-09-24 19:57:24'),
	(58, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:172.28.190.182', '2026-09-24 19:57:40'),
	(59, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:172.28.190.182', '2026-09-24 19:58:01'),
	(60, 2, 'Ana Ramírez', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::ffff:172.28.190.182', '2026-09-24 19:58:35'),
	(61, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', '::1', '2026-09-24 19:59:17'),
	(62, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-24 20:01:27'),
	(63, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-25 20:05:52'),
	(64, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-25 20:06:30'),
	(65, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-25 20:06:46'),
	(66, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-25 20:06:49'),
	(67, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-26 12:41:31'),
	(68, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-26 12:42:20'),
	(69, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-26 12:44:31'),
	(70, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-26 12:44:34'),
	(71, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:45:37'),
	(72, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:45:39'),
	(73, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:45:41'),
	(74, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:45:43'),
	(75, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:45:44'),
	(76, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:45:47'),
	(77, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', NULL, '2026-09-26 12:45:48'),
	(78, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', NULL, '2026-09-26 12:45:50'),
	(79, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', NULL, '2026-09-26 12:45:51'),
	(80, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-26 12:46:02'),
	(81, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-26 12:46:23'),
	(82, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:46:31'),
	(83, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:46:33'),
	(84, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió un enlace de restablecimiento de contraseña', '::1', '2026-09-26 12:47:06'),
	(85, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-27 09:35:44'),
	(86, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-27 09:35:44'),
	(87, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-27 09:35:44'),
	(88, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:192.168.100.33', '2026-09-27 09:35:51'),
	(89, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-27 09:37:16'),
	(90, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-27 09:37:20'),
	(91, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:192.168.100.33', '2026-09-27 09:37:29'),
	(92, NULL, 'docente1', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::ffff:192.168.100.33', '2026-09-27 09:37:43'),
	(93, NULL, 'docente', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::ffff:192.168.100.33', '2026-09-27 09:38:02'),
	(94, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-27 09:38:04'),
	(95, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:192.168.100.33', '2026-09-27 09:38:26'),
	(96, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:192.168.100.33', '2026-09-27 09:39:14'),
	(97, 1, 'Eddy Pacheco', 'Eliminación', 'Inventario', 'Registro eliminado', '::1', '2026-09-27 09:51:16'),
	(98, 1, 'Eddy Pacheco', 'Eliminación', 'Inventario', 'Registro eliminado', '::1', '2026-09-27 09:51:45'),
	(99, 1, 'Eddy Pacheco', 'Eliminación', 'Equipos', 'Equipo eliminado', '::1', '2026-09-27 09:51:48'),
	(100, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-09-27 10:24:24'),
	(101, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', '::1', '2026-09-27 10:24:30'),
	(102, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud creada y aprobada. Correo enviado al docente ✅', '::1', '2026-09-27 10:25:23'),
	(103, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-09-27 10:26:32'),
	(104, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', '::1', '2026-09-27 10:26:35'),
	(105, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-27 16:29:03'),
	(106, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-27 16:29:11'),
	(107, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió la contraseña actual al correo registrado', '::1', '2026-09-27 16:30:24'),
	(108, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-27 16:30:54'),
	(109, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-27 20:20:28'),
	(110, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-27 20:20:31'),
	(111, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió la contraseña actual al correo registrado', '::1', '2026-09-27 20:21:45'),
	(112, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-28 12:27:29'),
	(113, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-09-28 12:28:28'),
	(114, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-09-28 12:32:14'),
	(115, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-10-09 09:28:08'),
	(116, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-10-09 09:28:13'),
	(117, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió la contraseña actual al correo registrado', '::1', '2026-10-09 09:29:17'),
	(118, 1, 'admin', 'Solicitud de recuperación', 'Autenticación', 'Se envió la contraseña actual al correo registrado', '::1', '2026-10-09 09:29:19'),
	(119, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-10-09 09:29:56'),
	(120, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-10-25 22:27:09'),
	(121, NULL, 'docente', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::ffff:127.0.0.1', '2026-10-30 17:26:14'),
	(122, NULL, 'docente', 'Inicio de sesión fallido', 'Autenticación', 'Usuario o contraseña incorrectos', '::ffff:127.0.0.1', '2026-10-30 17:26:14'),
	(123, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:127.0.0.1', '2026-10-30 17:26:21'),
	(124, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:127.0.0.1', '2026-10-30 17:26:21'),
	(125, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::ffff:127.0.0.1', '2026-10-30 17:35:15'),
	(126, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:127.0.0.1', '2026-10-30 17:35:32'),
	(127, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::ffff:127.0.0.1', '2026-10-30 17:35:32'),
	(128, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-11-12 12:44:46'),
	(129, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-11-13 16:12:53');

-- Volcando estructura para tabla db_cbit_2.horario
CREATE TABLE IF NOT EXISTS `horario` (
  `id_horario` int(11) NOT NULL AUTO_INCREMENT,
  `dias` enum('Lunes','Martes','Miercoles','Jueves','Viernes') NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_final` time NOT NULL,
  PRIMARY KEY (`id_horario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.horario: ~5 rows (aproximadamente)
INSERT INTO `horario` (`id_horario`, `dias`, `hora_inicio`, `hora_final`) VALUES
	(1, 'Lunes', '07:30:00', '15:30:00'),
	(2, 'Martes', '07:30:00', '15:30:00'),
	(3, 'Miercoles', '07:30:00', '15:30:00'),
	(4, 'Jueves', '07:30:00', '15:30:00'),
	(5, 'Viernes', '07:30:00', '14:00:00');

-- Volcando estructura para tabla db_cbit_2.inventario
CREATE TABLE IF NOT EXISTS `inventario` (
  `id_inventario` int(11) NOT NULL AUTO_INCREMENT,
  `id_equipos` int(11) DEFAULT NULL,
  `id_ubicacion_fisica` int(11) DEFAULT NULL,
  `serial` varchar(30) NOT NULL,
  `estado` enum('Operativo','No operativo','En Reparacion','Dañado') NOT NULL,
  PRIMARY KEY (`id_inventario`),
  UNIQUE KEY `codigo_barra` (`serial`),
  KEY `tiene_registros` (`id_equipos`),
  KEY `tiene___` (`id_ubicacion_fisica`),
  CONSTRAINT `tiene___` FOREIGN KEY (`id_ubicacion_fisica`) REFERENCES `ubicacion_fisica` (`id_ubicacion_fisica`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tiene_registros` FOREIGN KEY (`id_equipos`) REFERENCES `equipos` (`id_equipos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.inventario: ~12 rows (aproximadamente)
INSERT INTO `inventario` (`id_inventario`, `id_equipos`, `id_ubicacion_fisica`, `serial`, `estado`) VALUES
	(3, 2, 1, 'DELL-LAT-001', 'Operativo'),
	(4, 2, 3, 'DELL-LAT-002', 'En Reparacion'),
	(5, 3, 2, 'LEN-T14-001', 'Operativo'),
	(6, 3, 1, 'LEN-T14-002', 'Operativo'),
	(7, 4, 4, 'MAC-M2-001', 'Operativo'),
	(8, 5, 5, 'EPS-POW-001', 'No operativo'),
	(9, 6, 1, 'CAN-MF-001', 'Operativo'),
	(10, 7, 5, 'CIS-CAT-001', 'Operativo'),
	(11, 8, 2, 'SAM-GAL-001', 'Operativo'),
	(12, 9, 1, 'MS-SUR-001', 'Operativo');

-- Volcando estructura para tabla db_cbit_2.mantenimiento
CREATE TABLE IF NOT EXISTS `mantenimiento` (
  `id_mantenimiento` int(11) NOT NULL AUTO_INCREMENT,
  `id_tecnicos` int(11) DEFAULT NULL,
  `fecha_reporte` datetime NOT NULL,
  `nivel_prioridad` enum('Alta','Media','Baja') NOT NULL,
  PRIMARY KEY (`id_mantenimiento`),
  KEY `realiza_` (`id_tecnicos`),
  CONSTRAINT `realiza_` FOREIGN KEY (`id_tecnicos`) REFERENCES `tecnicos` (`id_tecnicos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.mantenimiento: ~2 rows (aproximadamente)
INSERT INTO `mantenimiento` (`id_mantenimiento`, `id_tecnicos`, `fecha_reporte`, `nivel_prioridad`) VALUES
	(1, 1, '2026-07-15 09:30:00', 'Alta'),
	(2, 2, '2026-07-18 14:20:00', 'Media');

-- Volcando estructura para tabla db_cbit_2.mantenimiento_equipos
CREATE TABLE IF NOT EXISTS `mantenimiento_equipos` (
  `id_mantenimiento_equipos` int(11) NOT NULL AUTO_INCREMENT,
  `id_mantenimiento` int(11) DEFAULT NULL,
  `id_equipos` int(11) DEFAULT NULL,
  `descripcion_fallas` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id_mantenimiento_equipos`),
  KEY `es_implementado` (`id_mantenimiento`),
  KEY `resiv` (`id_equipos`),
  CONSTRAINT `es_implementado` FOREIGN KEY (`id_mantenimiento`) REFERENCES `mantenimiento` (`id_mantenimiento`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `resiv` FOREIGN KEY (`id_equipos`) REFERENCES `equipos` (`id_equipos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.mantenimiento_equipos: ~2 rows (aproximadamente)
INSERT INTO `mantenimiento_equipos` (`id_mantenimiento_equipos`, `id_mantenimiento`, `id_equipos`, `descripcion_fallas`) VALUES
	(1, 1, 4, 'Laptop no enciende, posible falla en placa base'),
	(2, 2, 8, 'Proyector no enfoca correctamente, imagen borrosa');

-- Volcando estructura para tabla db_cbit_2.marca
CREATE TABLE IF NOT EXISTS `marca` (
  `id_marca` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_marca`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.marca: ~10 rows (aproximadamente)
INSERT INTO `marca` (`id_marca`, `nombre`, `descripcion`) VALUES
	(1, 'HP', 'Hewlett-Packard'),
	(2, 'Dell', 'Dell Technologies'),
	(3, 'Lenovo', 'Lenovo Group'),
	(4, 'Apple', 'Apple Inc.'),
	(5, 'Samsung', 'Samsung Electronics'),
	(6, 'Epson', 'Seiko Epson Corporation'),
	(7, 'Canon', 'Canon Inc.'),
	(8, 'Cisco', 'Cisco Systems'),
	(9, 'Sony', 'Sony Corporation'),
	(10, 'Microsoft', 'Microsoft Corporation'),
	(11, 'Eddy', NULL),
	(12, 'k3pq2dkdq3k`dq', NULL);

-- Volcando estructura para tabla db_cbit_2.modelo
CREATE TABLE IF NOT EXISTS `modelo` (
  `id_modelo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_modelo`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.modelo: ~10 rows (aproximadamente)
INSERT INTO `modelo` (`id_modelo`, `nombre`, `descripcion`) VALUES
	(1, 'EliteBook 840', 'Laptop HP EliteBook 840 G8'),
	(2, 'Latitude 7420', 'Laptop Dell Latitude 7420'),
	(3, 'ThinkPad T14', 'Laptop Lenovo ThinkPad T14'),
	(4, 'MacBook Air', 'Apple MacBook Air M2'),
	(5, 'Galaxy Tab S7', 'Samsung Galaxy Tab S7'),
	(6, 'PowerLite 5600', 'Proyector Epson PowerLite 5600'),
	(7, 'MultiFunction 320', 'Impresora Multifuncional Canon'),
	(8, 'Catalyst 9200', 'Switch Cisco Catalyst 9200'),
	(9, 'Bravia Pro', 'Monitor Sony Bravia Pro'),
	(10, 'Surface Pro 8', 'Microsoft Surface Pro 8');

-- Volcando estructura para tabla db_cbit_2.notificacion
CREATE TABLE IF NOT EXISTS `notificacion` (
  `id_notificacion` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) DEFAULT NULL,
  `titulo` varchar(30) NOT NULL,
  `mensaje` text NOT NULL,
  `fecha_envio` datetime NOT NULL,
  PRIMARY KEY (`id_notificacion`),
  KEY `resive__` (`id_usuario`),
  CONSTRAINT `resive__` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.notificacion: ~5 rows (aproximadamente)
INSERT INTO `notificacion` (`id_notificacion`, `id_usuario`, `titulo`, `mensaje`, `fecha_envio`) VALUES
	(1, 2, 'Solicitud Aprobada', 'Su solicitud para el Laboratorio 1 ha sido aprobada', '2026-07-20 09:00:00'),
	(2, 3, 'Solicitud Pendiente', 'Su solicitud está en revisión, espere confirmación', '2026-07-20 10:30:00'),
	(3, 4, 'Recordatorio', 'Tiene una solicitud programada para mañana', '2026-07-22 08:00:00'),
	(4, 6, 'Solicitud Cancelada', 'Su solicitud ha sido cancelada por mantenimiento', '2026-07-23 14:15:00'),
	(5, 8, 'Nuevo Préstamo', 'Equipos asignados para su clase de inglés', '2026-07-24 07:00:00');

-- Volcando estructura para tabla db_cbit_2.persona
CREATE TABLE IF NOT EXISTS `persona` (
  `id_persona` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `cedula` varchar(30) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `cedula` (`cedula`),
  UNIQUE KEY `telefono` (`telefono`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.persona: ~16 rows (aproximadamente)
INSERT INTO `persona` (`id_persona`, `nombre`, `apellido`, `cedula`, `telefono`) VALUES
	(1, 'Eddy', 'Pacheco', 'V-31394074', '04129574257'),
	(2, 'Ana', 'Ramírez', '7654321', '555-0102'),
	(3, 'Luis', 'Torres', '11223344', '555-0103'),
	(4, 'María', 'Flores', '44332211', '555-0104'),
	(5, 'Jorge', 'Díaz', '556677', '555-0105'),
	(6, 'Laura', 'García', '776655', '555-0106'),
	(7, 'Roberto', 'Sánchez', '7766', '555-0107'),
	(8, 'Patricia', 'López', '3344566', '555-0108'),
	(9, 'Miguel', 'Hernández', '66778899', '555-0109'),
	(10, 'Carmen', 'Jiménez', '22334455', '555-0110'),
	(11, 'Daniel', 'Pacheco', 'V-32566687', '04269154122'),
	(12, 'Danilo', 'Serrano', 'V-31360528', '0412453421'),
	(13, 'Mailo', 'Perez', 'V-120982123', '04129574227'),
	(14, 'Pepe', 'Palacios', 'V-3298212', '04269152212'),
	(15, 'Manuel', 'Pacheco', 'V-30937772', '04141527890'),
	(17, 'Eddy', 'Pacheco', 'V-31394213', '04129512227');

-- Volcando estructura para tabla db_cbit_2.solicitud
CREATE TABLE IF NOT EXISTS `solicitud` (
  `id_solicitud` int(11) NOT NULL AUTO_INCREMENT,
  `id_espacio` int(11) DEFAULT NULL,
  `id_actividad` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `estado` enum('Aprobado','Pendiente','Cancelado','Completado') NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_solicitud`),
  KEY `es_asignado` (`id_espacio`),
  KEY `es_elegida` (`id_actividad`),
  KEY `_realiza` (`id_usuario`),
  CONSTRAINT `_realiza` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `es_asignado` FOREIGN KEY (`id_espacio`) REFERENCES `espacio` (`id_espacio`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `es_elegida` FOREIGN KEY (`id_actividad`) REFERENCES `actividad` (`id_actividad`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.solicitud: ~18 rows (aproximadamente)
INSERT INTO `solicitud` (`id_solicitud`, `id_espacio`, `id_actividad`, `id_usuario`, `fecha`, `hora_inicio`, `hora_fin`, `estado`, `descripcion`) VALUES
	(7, 1, 7, 3, '2026-07-25', '11:00:00', '13:00:00', 'Aprobado', 'Taller de diseño gráfico'),
	(11, 1, 2, 1, '2026-07-28', '09:00:00', '10:00:00', 'Aprobado', ''),
	(13, 1, 7, 1, '2026-07-29', '07:24:00', '08:24:00', 'Aprobado', ''),
	(14, 1, 7, 11, '2026-07-28', '10:40:00', '11:40:00', 'Aprobado', ''),
	(15, 1, 3, 1, '2026-07-29', '10:44:00', '11:44:00', 'Pendiente', ''),
	(16, 1, 3, 1, '2026-07-29', '10:44:00', '11:44:00', 'Pendiente', ''),
	(17, 1, 1, 11, '2026-07-30', '10:46:00', '11:45:00', 'Cancelado', ''),
	(18, 1, 1, 11, '2026-07-30', '10:46:00', '11:45:00', 'Aprobado', ''),
	(19, 1, 4, 1, '2026-07-29', '10:52:00', '11:52:00', 'Pendiente', ''),
	(21, 1, 4, 2, '2026-07-31', '11:00:00', '12:00:00', 'Aprobado', ''),
	(22, 1, 1, 1, '2026-07-29', '10:33:00', '11:33:00', 'Cancelado', ''),
	(23, 1, 4, 2, '2026-09-07', '09:39:00', '10:45:00', 'Aprobado', ''),
	(24, 1, 2, 12, '2026-10-06', '07:30:00', '09:30:00', 'Aprobado', ''),
	(25, 1, 1, 1, '2026-09-16', '08:00:00', '09:00:00', 'Aprobado', ''),
	(27, 1, 1, 1, '2026-09-17', '08:05:00', '10:01:00', 'Aprobado', ''),
	(28, 1, 4, 2, '2026-09-25', '10:00:00', '11:00:00', 'Aprobado', ''),
	(29, 1, 3, 1, '2026-09-28', '08:00:00', '10:00:00', 'Aprobado', ''),
	(30, 1, 7, 1, '2026-09-29', '10:00:00', '12:00:00', 'Aprobado', ''),
	(31, 1, 1, 1, '2026-09-30', '11:00:00', '13:00:00', 'Aprobado', '');

-- Volcando estructura para tabla db_cbit_2.solicitud_horario
CREATE TABLE IF NOT EXISTS `solicitud_horario` (
  `id_solicitud_horario` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_horario` varchar(50) NOT NULL,
  `id_solicitud` int(11) DEFAULT NULL,
  `id_horario` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_solicitud_horario`),
  UNIQUE KEY `codigo_horario` (`codigo_horario`),
  KEY `se_le_asigna` (`id_solicitud`),
  KEY `se_conforma` (`id_horario`),
  CONSTRAINT `se_conforma` FOREIGN KEY (`id_horario`) REFERENCES `horario` (`id_horario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `se_le_asigna` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.solicitud_horario: ~1 rows (aproximadamente)

-- Volcando estructura para procedimiento db_cbit_2.sp_auditar
DELIMITER //
CREATE PROCEDURE `sp_auditar`(
    IN p_tabla        VARCHAR(60),
    IN p_operacion    VARCHAR(10),
    IN p_id_registro  INT,
    IN p_campo        VARCHAR(60),
    IN p_valor_antes  TEXT,
    IN p_valor_nuevo  TEXT,
    IN p_descripcion  TEXT
)
BEGIN
    INSERT INTO auditoria
        (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES
        (p_tabla, p_operacion, p_id_registro, p_campo, p_valor_antes, p_valor_nuevo, NOW(), p_descripcion);
END//
DELIMITER ;

-- Volcando estructura para tabla db_cbit_2.tecnicos
CREATE TABLE IF NOT EXISTS `tecnicos` (
  `id_tecnicos` int(11) NOT NULL AUTO_INCREMENT,
  `especialidad` enum('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_tecnicos`),
  KEY `puede_ser` (`id_persona`),
  CONSTRAINT `puede_ser` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.tecnicos: ~3 rows (aproximadamente)
INSERT INTO `tecnicos` (`id_tecnicos`, `especialidad`, `id_persona`) VALUES
	(1, 'Hardware', 1),
	(2, 'Redes', 7),
	(3, 'Soporte técnico', 10),
	(4, 'Hardware', 13);

-- Volcando estructura para tabla db_cbit_2.ubicacion_fisica
CREATE TABLE IF NOT EXISTS `ubicacion_fisica` (
  `id_ubicacion_fisica` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) NOT NULL,
  PRIMARY KEY (`id_ubicacion_fisica`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.ubicacion_fisica: ~5 rows (aproximadamente)
INSERT INTO `ubicacion_fisica` (`id_ubicacion_fisica`, `nombre`) VALUES
	(1, 'Laboratorio de Cómputo - Aula 101'),
	(2, 'Laboratorio de Cómputo - Aula 102'),
	(3, 'Biblioteca - Área de recursos'),
	(4, 'Sala de Profesores'),
	(5, 'Almacén General');

-- Volcando estructura para tabla db_cbit_2.usuario
CREATE TABLE IF NOT EXISTS `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) DEFAULT NULL,
  `nombre_usuario` varchar(100) NOT NULL,
  `contrasena_usuario` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `estado` enum('Activo','Inactivo','Bloqueado') NOT NULL,
  `roles` enum('Administrador','Docente') NOT NULL,
  `reset_token` varchar(100) DEFAULT NULL,
  `reset_expira` datetime DEFAULT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  UNIQUE KEY `correo` (`correo`),
  KEY `tiene_un` (`id_persona`),
  KEY `idx_reset_token` (`reset_token`),
  CONSTRAINT `tiene_un` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.usuario: ~12 rows (aproximadamente)
INSERT INTO `usuario` (`id_usuario`, `id_persona`, `nombre_usuario`, `contrasena_usuario`, `correo`, `estado`, `roles`, `reset_token`, `reset_expira`) VALUES
	(1, 1, 'admin', 'admin123', 'eddy15pacheco@gmail.com', 'Activo', 'Administrador', '03fd045f28d5535d1e1e3ebadb3225f9ad2a376b014743252055dbf8756442d6', '2026-09-26 17:47:04'),
	(2, 2, 'docente', 'docente123.', 'eddy16pacheco@gmail.com', 'Activo', 'Docente', NULL, NULL),
	(3, 3, 'ltorres', 'hash345678', 'luis.torres@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(4, 4, 'mflores', 'hash456789', 'maria.flores@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(5, 5, 'jdiaz', 'hash567890', 'jorge.diaz@instituto.edu', 'Inactivo', 'Docente', NULL, NULL),
	(6, 6, 'lgarcia', 'hash678901', 'laura.garcia@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(7, 7, 'rsanchez', 'hash789012', 'roberto.sanchez@instituto.edu', 'Activo', 'Administrador', NULL, NULL),
	(8, 8, 'plopez', 'hash890123', 'patricia.lopez@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(9, 9, 'mhernandez', 'hash901234', 'miguel.hernandez@instituto.edu', 'Bloqueado', 'Docente', NULL, NULL),
	(10, 10, 'cjimenez', 'hash012345', 'carmen.jimenez@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(11, 12, 'Dani', 'Dani123.', 'danilo.pacheco754@gmail.comj', 'Inactivo', 'Docente', NULL, NULL),
	(12, 15, 'manu123', 'manu123', 'manu123@gmail.com', 'Activo', 'Docente', NULL, NULL);

-- Volcando estructura para vista db_cbit_2.v_auditoria_completa
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_auditoria_completa` (
	`id_auditoria` INT(11) NOT NULL,
	`fecha_hora` DATETIME NOT NULL COMMENT 'Fecha y hora exacta',
	`tabla` VARCHAR(1) NOT NULL COMMENT 'Tabla afectada' COLLATE 'utf8mb4_uca1400_ai_ci',
	`operacion` ENUM('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Tipo de operación' COLLATE 'utf8mb4_uca1400_ai_ci',
	`id_registro` INT(11) NULL COMMENT 'PK del registro afectado',
	`campo` VARCHAR(1) NULL COMMENT 'Campo modificado (solo UPDATE)' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_anterior` TEXT NULL COMMENT 'Valor antes del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_nuevo` TEXT NULL COMMENT 'Valor después del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion` TEXT NULL COMMENT 'Descripción legible del evento' COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_usuario` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_completo` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`roles` ENUM('Administrador','Docente') NULL COLLATE 'utf8mb4_uca1400_ai_ci'
);

-- Volcando estructura para vista db_cbit_2.v_auditoria_inventario
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_auditoria_inventario` (
	`id_auditoria` INT(11) NOT NULL,
	`fecha_hora` DATETIME NOT NULL COMMENT 'Fecha y hora exacta',
	`operacion` ENUM('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Tipo de operación' COLLATE 'utf8mb4_uca1400_ai_ci',
	`id_inventario` INT(11) NULL COMMENT 'PK del registro afectado',
	`campo` VARCHAR(1) NULL COMMENT 'Campo modificado (solo UPDATE)' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_anterior` TEXT NULL COMMENT 'Valor antes del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_nuevo` TEXT NULL COMMENT 'Valor después del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion` TEXT NULL COMMENT 'Descripción legible del evento' COLLATE 'utf8mb4_uca1400_ai_ci',
	`serial` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`equipo` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci'
);

-- Volcando estructura para vista db_cbit_2.v_auditoria_resumen
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_auditoria_resumen` (
	`tabla` VARCHAR(1) NOT NULL COMMENT 'Tabla afectada' COLLATE 'utf8mb4_uca1400_ai_ci',
	`operacion` ENUM('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Tipo de operación' COLLATE 'utf8mb4_uca1400_ai_ci',
	`total_operaciones` BIGINT(21) NOT NULL,
	`primera_operacion` DATETIME NULL COMMENT 'Fecha y hora exacta',
	`ultima_operacion` DATETIME NULL COMMENT 'Fecha y hora exacta',
	`ultimo_dia` DATE NULL
);

-- Volcando estructura para vista db_cbit_2.v_auditoria_solicitudes
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_auditoria_solicitudes` (
	`id_auditoria` INT(11) NOT NULL,
	`fecha_hora` DATETIME NOT NULL COMMENT 'Fecha y hora exacta',
	`operacion` ENUM('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Tipo de operación' COLLATE 'utf8mb4_uca1400_ai_ci',
	`id_solicitud` INT(11) NULL COMMENT 'PK del registro afectado',
	`campo` VARCHAR(1) NULL COMMENT 'Campo modificado (solo UPDATE)' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_anterior` TEXT NULL COMMENT 'Valor antes del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_nuevo` TEXT NULL COMMENT 'Valor después del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion` TEXT NULL COMMENT 'Descripción legible del evento' COLLATE 'utf8mb4_uca1400_ai_ci',
	`fecha_solicitud` DATE NULL,
	`hora_inicio` TIME NULL,
	`hora_fin` TIME NULL,
	`espacio` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`actividad` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci'
);

-- Volcando estructura para vista db_cbit_2.v_auditoria_usuarios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `v_auditoria_usuarios` (
	`id_auditoria` INT(11) NOT NULL,
	`fecha_hora` DATETIME NOT NULL COMMENT 'Fecha y hora exacta',
	`operacion` ENUM('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Tipo de operación' COLLATE 'utf8mb4_uca1400_ai_ci',
	`id_usuario` INT(11) NULL COMMENT 'PK del registro afectado',
	`campo` VARCHAR(1) NULL COMMENT 'Campo modificado (solo UPDATE)' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_anterior` TEXT NULL COMMENT 'Valor antes del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor_nuevo` TEXT NULL COMMENT 'Valor después del cambio' COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion` TEXT NULL COMMENT 'Descripción legible del evento' COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_usuario` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`roles` ENUM('Administrador','Docente') NULL COLLATE 'utf8mb4_uca1400_ai_ci'
);

-- Volcando estructura para vista db_cbit_2.vista_indicadores_mantenimiento_disponibilidad
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_indicadores_mantenimiento_disponibilidad` (
	`indicador` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`valor` DECIMAL(26,2) NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_actividades_educativas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_actividades_educativas` (
	`id_actividad` INT(11) NOT NULL,
	`nombre_actividad` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion_actividad` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`total_solicitudes` BIGINT(21) NOT NULL,
	`espacios_utilizados` BIGINT(21) NOT NULL,
	`total_estudiantes_participantes` BIGINT(21) NOT NULL,
	`primera_realizacion` DATE NULL,
	`ultima_realizacion` DATE NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_disponibilidad_equipos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_disponibilidad_equipos` (
	`id_equipos` INT(11) NOT NULL,
	`nombre_equipo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`serial` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estado_equipo` ENUM('Operativo','No operativo','En Reparacion','Dañado') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`ubicacion_fisica` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`disponibilidad` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`reservas_activas` BIGINT(21) NOT NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_equipos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_equipos` (
	`id_equipos` INT(11) NOT NULL,
	`nombre_equipo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`categoria` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`marca` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`modelo` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`serial` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estado_equipo` ENUM('Operativo','No operativo','En Reparacion','Dañado') NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`ubicacion_fisica` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`veces_prestado` BIGINT(21) NOT NULL,
	`veces_mantenimiento` BIGINT(21) NOT NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_fallas_tecnicas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_fallas_tecnicas` (
	`id_mantenimiento` INT(11) NOT NULL,
	`fecha_reporte` DATETIME NOT NULL,
	`nivel_prioridad` ENUM('Alta','Media','Baja') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion_fallas` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`id_equipos` INT(11) NOT NULL,
	`nombre_equipo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`categoria_equipo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`serial_equipo` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estado_actual` ENUM('Operativo','No operativo','En Reparacion','Dañado') NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`tecnico_nombre` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`tecnico_apellido` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`tecnico_especialidad` ENUM('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`dias_sin_resolver` INT(8) NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_mantenimiento_equipos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_mantenimiento_equipos` (
	`id_equipos` INT(11) NOT NULL,
	`nombre_equipo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`categoria` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`total_mantenimientos` BIGINT(21) NOT NULL,
	`mantenimientos_alta` BIGINT(21) NOT NULL,
	`mantenimientos_media` BIGINT(21) NOT NULL,
	`mantenimientos_baja` BIGINT(21) NOT NULL,
	`primer_mantenimiento` DATETIME NULL,
	`ultimo_mantenimiento` DATETIME NULL,
	`fallas_reportadas` MEDIUMTEXT NULL COLLATE 'utf8mb4_uca1400_ai_ci'
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_maquinas_mas_usadas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_maquinas_mas_usadas` (
	`id_equipos` INT(11) NOT NULL,
	`nombre_equipo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`categoria` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`serial` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`total_reservas` BIGINT(21) NOT NULL,
	`total_uso_completado` BIGINT(21) NOT NULL,
	`horas_totales_uso` DECIMAL(42,0) NULL,
	`ranking_uso` BIGINT(21) NOT NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_notificaciones
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_notificaciones` (
	`id_notificacion` INT(11) NOT NULL,
	`titulo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`mensaje` TEXT NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`fecha_envio` DATETIME NOT NULL,
	`usuario_nombre` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`usuario_apellido` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_usuario` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`correo_usuario` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`rol_usuario` ENUM('Administrador','Docente') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`fecha` DATE NULL,
	`hora_envio` INT(3) NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_reservas_equipos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_reservas_equipos` (
	`id_solicitud` INT(11) NOT NULL,
	`fecha` DATE NOT NULL,
	`hora_inicio` TIME NOT NULL,
	`hora_fin` TIME NOT NULL,
	`estado` ENUM('Aprobado','Pendiente','Cancelado','Completado') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`usuario_nombre` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`usuario_apellido` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`rol_usuario` ENUM('Administrador','Docente') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_equipo` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`serial_equipo` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`actividad_realizada` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci'
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_reservas_espacios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_reservas_espacios` (
	`id_solicitud` INT(11) NOT NULL,
	`fecha` DATE NOT NULL,
	`hora_inicio` TIME NOT NULL,
	`hora_fin` TIME NOT NULL,
	`estado` ENUM('Aprobado','Pendiente','Cancelado','Completado') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`descripcion` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_espacio` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`capacidad` INT(11) NOT NULL,
	`usuario_nombre` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`usuario_apellido` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`rol_usuario` ENUM('Administrador','Docente') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`actividad_realizada` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`asistentes_registrados` BIGINT(21) NOT NULL
);

-- Volcando estructura para vista db_cbit_2.vista_reporte_usuarios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vista_reporte_usuarios` 
);

-- Volcando estructura para disparador db_cbit_2.aud_asistencia_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_asistencia_delete`
AFTER DELETE ON `asistencia` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('asistencia', 'DELETE', OLD.id_asistencia, NULL,
            CONCAT('estudiante_id:', OLD.id_estudiante, ' asistio:', OLD.asistio), NULL,
            NOW(), CONCAT('Registro de asistencia #', OLD.id_asistencia, ' eliminado'));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_asistencia_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_asistencia_insert`
AFTER INSERT ON `asistencia` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('asistencia', 'INSERT', NEW.id_asistencia, NULL, NULL,
            CONCAT('estudiante_id:', NEW.id_estudiante, ' | solicitud_id:', NEW.id_solicitud, ' | asistio:', NEW.asistio),
            NOW(), CONCAT('Asistencia registrada — Estudiante #', NEW.id_estudiante,
                         ' en solicitud #', NEW.id_solicitud, ': ', NEW.asistio));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_categoria_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_categoria_delete`
AFTER DELETE ON `categoria` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('categoria', 'DELETE', OLD.id_categoria, NULL, OLD.nombre, NULL, NOW(),
            CONCAT('Categoría eliminada: ', OLD.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_categoria_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_categoria_insert`
AFTER INSERT ON `categoria` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('categoria', 'INSERT', NEW.id_categoria, NULL, NULL, NEW.nombre, NOW(),
            CONCAT('Nueva categoría registrada: ', NEW.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_equipos_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_equipos_delete`
AFTER DELETE ON `equipos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('equipos', 'DELETE', OLD.id_equipos, NULL, OLD.nombre, NULL,
            NOW(), CONCAT('Equipo eliminado del catálogo: ', OLD.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_equipos_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_equipos_insert`
AFTER INSERT ON `equipos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('equipos', 'INSERT', NEW.id_equipos, NULL, NULL,
            CONCAT('nombre:', NEW.nombre),
            NOW(), CONCAT('Nuevo equipo registrado en catálogo: ', NEW.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_equipos_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_equipos_update`
AFTER UPDATE ON `equipos` FOR EACH ROW
BEGIN
    IF OLD.nombre != NEW.nombre THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('equipos', 'UPDATE', NEW.id_equipos, 'nombre', OLD.nombre, NEW.nombre, NOW(), 'Nombre de equipo modificado');
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_espacio_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_espacio_delete`
AFTER DELETE ON `espacio` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('espacio', 'DELETE', OLD.id_espacio, NULL,
            CONCAT(OLD.nombre, ' | cap:', OLD.capacidad), NULL,
            NOW(), CONCAT('Espacio eliminado: ', OLD.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_espacio_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_espacio_insert`
AFTER INSERT ON `espacio` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('espacio', 'INSERT', NEW.id_espacio, NULL, NULL,
            CONCAT('nombre:', NEW.nombre, ' | capacidad:', NEW.capacidad),
            NOW(), CONCAT('Nuevo espacio registrado: ', NEW.nombre, ' (Cap: ', NEW.capacidad, ')'));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_espacio_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_espacio_update`
AFTER UPDATE ON `espacio` FOR EACH ROW
BEGIN
    IF OLD.nombre != NEW.nombre OR OLD.capacidad != NEW.capacidad THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('espacio', 'UPDATE', NEW.id_espacio, 'datos',
                CONCAT(OLD.nombre, ' cap:', OLD.capacidad),
                CONCAT(NEW.nombre, ' cap:', NEW.capacidad),
                NOW(), CONCAT('Espacio modificado: ', NEW.nombre));
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_inventario_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_inventario_delete`
AFTER DELETE ON `inventario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('inventario', 'DELETE', OLD.id_inventario, NULL,
            CONCAT('serial:', OLD.serial, ' | estado:', OLD.estado), NULL,
            NOW(), CONCAT('Equipo eliminado del inventario — Serial: ', OLD.serial));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_inventario_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_inventario_insert`
AFTER INSERT ON `inventario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('inventario', 'INSERT', NEW.id_inventario, NULL, NULL,
            CONCAT('serial:', NEW.serial, ' | estado:', NEW.estado),
            NOW(), CONCAT('Equipo agregado al inventario — Serial: ', NEW.serial, ' | Estado: ', NEW.estado));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_inventario_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_inventario_update`
AFTER UPDATE ON `inventario` FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('inventario', 'UPDATE', NEW.id_inventario, 'estado', OLD.estado, NEW.estado, NOW(),
                CONCAT('Estado del equipo ', NEW.serial, ' cambió: ', OLD.estado, ' → ', NEW.estado));
    END IF;
    IF OLD.id_ubicacion_fisica != NEW.id_ubicacion_fisica THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('inventario', 'UPDATE', NEW.id_inventario, 'id_ubicacion_fisica',
                OLD.id_ubicacion_fisica, NEW.id_ubicacion_fisica, NOW(),
                CONCAT('Equipo ', NEW.serial, ' cambió de ubicación'));
    END IF;
    IF OLD.serial != NEW.serial THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('inventario', 'UPDATE', NEW.id_inventario, 'serial', OLD.serial, NEW.serial, NOW(),
                CONCAT('Serial modificado: ', OLD.serial, ' → ', NEW.serial));
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_mantenimiento_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_mantenimiento_delete`
AFTER DELETE ON `mantenimiento` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('mantenimiento', 'DELETE', OLD.id_mantenimiento, NULL,
            CONCAT('prioridad:', OLD.nivel_prioridad, ' | fecha:', OLD.fecha_reporte), NULL,
            NOW(), CONCAT('Reporte de mantenimiento #', OLD.id_mantenimiento, ' eliminado'));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_mantenimiento_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_mantenimiento_insert`
AFTER INSERT ON `mantenimiento` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('mantenimiento', 'INSERT', NEW.id_mantenimiento, NULL, NULL,
            CONCAT('tecnico_id:', NEW.id_tecnicos, ' | prioridad:', NEW.nivel_prioridad),
            NOW(), CONCAT('Reporte de mantenimiento #', NEW.id_mantenimiento, ' creado — Prioridad: ', NEW.nivel_prioridad));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_marca_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_marca_delete`
AFTER DELETE ON `marca` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('marca', 'DELETE', OLD.id_marca, NULL, OLD.nombre, NULL, NOW(),
            CONCAT('Marca eliminada: ', OLD.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_marca_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_marca_insert`
AFTER INSERT ON `marca` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('marca', 'INSERT', NEW.id_marca, NULL, NULL, NEW.nombre, NOW(),
            CONCAT('Nueva marca registrada: ', NEW.nombre));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_persona_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_persona_delete`
AFTER DELETE ON `persona` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('persona', 'DELETE', OLD.id_persona, NULL,
            CONCAT(OLD.nombre, ' ', OLD.apellido, ' | cedula:', OLD.cedula), NULL,
            NOW(), CONCAT('Persona eliminada: ', OLD.nombre, ' ', OLD.apellido));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_persona_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_persona_insert`
AFTER INSERT ON `persona` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('persona', 'INSERT', NEW.id_persona, NULL, NULL,
            CONCAT('nombre:', NEW.nombre, ' ', NEW.apellido, ' | cedula:', NEW.cedula),
            NOW(), CONCAT('Nueva persona registrada: ', NEW.nombre, ' ', NEW.apellido, ' — C.I.: ', NEW.cedula));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_persona_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_persona_update`
AFTER UPDATE ON `persona` FOR EACH ROW
BEGIN
    IF OLD.nombre != NEW.nombre OR OLD.apellido != NEW.apellido THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('persona', 'UPDATE', NEW.id_persona, 'nombre_completo',
                CONCAT(OLD.nombre, ' ', OLD.apellido), CONCAT(NEW.nombre, ' ', NEW.apellido),
                NOW(), 'Nombre de persona modificado');
    END IF;
    IF OLD.cedula != NEW.cedula THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('persona', 'UPDATE', NEW.id_persona, 'cedula', OLD.cedula, NEW.cedula, NOW(), 'Cédula modificada');
    END IF;
    IF OLD.telefono != NEW.telefono THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('persona', 'UPDATE', NEW.id_persona, 'telefono', OLD.telefono, NEW.telefono, NOW(), 'Teléfono modificado');
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_solicitud_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_solicitud_delete`
AFTER DELETE ON `solicitud` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('solicitud', 'DELETE', OLD.id_solicitud, NULL,
            CONCAT('fecha:', OLD.fecha, ' | estado:', OLD.estado), NULL,
            NOW(), CONCAT('Solicitud #', OLD.id_solicitud, ' eliminada (estado previo: ', OLD.estado, ')'));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_solicitud_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_solicitud_insert`
AFTER INSERT ON `solicitud` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('solicitud', 'INSERT', NEW.id_solicitud, NULL, NULL,
            CONCAT('fecha:', NEW.fecha, ' | horario:', NEW.hora_inicio, '-', NEW.hora_fin, ' | estado:', NEW.estado),
            NOW(), CONCAT('Nueva solicitud #', NEW.id_solicitud, ' creada con estado ', NEW.estado));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_solicitud_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_solicitud_update`
AFTER UPDATE ON `solicitud` FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('solicitud', 'UPDATE', NEW.id_solicitud, 'estado', OLD.estado, NEW.estado, NOW(),
                CONCAT('Solicitud #', NEW.id_solicitud, ' cambió de ', OLD.estado, ' a ', NEW.estado));
    END IF;
    IF OLD.fecha != NEW.fecha OR OLD.hora_inicio != NEW.hora_inicio OR OLD.hora_fin != NEW.hora_fin THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('solicitud', 'UPDATE', NEW.id_solicitud, 'horario',
                CONCAT(OLD.fecha, ' ', OLD.hora_inicio, '-', OLD.hora_fin),
                CONCAT(NEW.fecha, ' ', NEW.hora_inicio, '-', NEW.hora_fin),
                NOW(), CONCAT('Horario modificado en solicitud #', NEW.id_solicitud));
    END IF;
    IF OLD.id_espacio != NEW.id_espacio THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('solicitud', 'UPDATE', NEW.id_solicitud, 'id_espacio',
                OLD.id_espacio, NEW.id_espacio, NOW(), CONCAT('Espacio cambiado en solicitud #', NEW.id_solicitud));
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_tecnicos_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_tecnicos_delete`
AFTER DELETE ON `tecnicos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('tecnicos', 'DELETE', OLD.id_tecnicos, NULL,
            CONCAT('especialidad:', OLD.especialidad), NULL,
            NOW(), CONCAT('Técnico #', OLD.id_tecnicos, ' eliminado'));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_tecnicos_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_tecnicos_insert`
AFTER INSERT ON `tecnicos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('tecnicos', 'INSERT', NEW.id_tecnicos, NULL, NULL,
            CONCAT('persona_id:', NEW.id_persona, ' | especialidad:', NEW.especialidad),
            NOW(), CONCAT('Nuevo técnico registrado — Especialidad: ', NEW.especialidad));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_usuario_delete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_usuario_delete`
AFTER DELETE ON `usuario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('usuario', 'DELETE', OLD.id_usuario, NULL,
            CONCAT('usuario:', OLD.nombre_usuario, ' | rol:', OLD.roles), NULL,
            NOW(), CONCAT('Usuario eliminado: ', OLD.nombre_usuario));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_usuario_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_usuario_insert`
AFTER INSERT ON `usuario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('usuario', 'INSERT', NEW.id_usuario, NULL, NULL,
            CONCAT('usuario:', NEW.nombre_usuario, ' | rol:', NEW.roles, ' | estado:', NEW.estado),
            NOW(), CONCAT('Nuevo usuario registrado: ', NEW.nombre_usuario, ' (', NEW.roles, ')'));
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador db_cbit_2.aud_usuario_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `aud_usuario_update`
AFTER UPDATE ON `usuario` FOR EACH ROW
BEGIN
    IF OLD.nombre_usuario != NEW.nombre_usuario THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('usuario', 'UPDATE', NEW.id_usuario, 'nombre_usuario', OLD.nombre_usuario, NEW.nombre_usuario, NOW(), 'Cambio de nombre de usuario');
    END IF;
    IF OLD.roles != NEW.roles THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('usuario', 'UPDATE', NEW.id_usuario, 'roles', OLD.roles, NEW.roles, NOW(), CONCAT('Cambio de rol: ', OLD.roles, ' → ', NEW.roles));
    END IF;
    IF OLD.estado != NEW.estado THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('usuario', 'UPDATE', NEW.id_usuario, 'estado', OLD.estado, NEW.estado, NOW(), CONCAT('Cambio de estado usuario: ', OLD.estado, ' → ', NEW.estado));
    END IF;
    IF OLD.correo != NEW.correo THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('usuario', 'UPDATE', NEW.id_usuario, 'correo', OLD.correo, NEW.correo, NOW(), 'Cambio de correo electrónico');
    END IF;
    IF OLD.contrasena_usuario != NEW.contrasena_usuario THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('usuario', 'UPDATE', NEW.id_usuario, 'contrasena_usuario', '***', '***', NOW(), 'Cambio de contraseña');
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_auditoria_completa`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_completa` AS SELECT
    a.id_auditoria,
    a.fecha_hora,
    a.tabla,
    a.operacion,
    a.id_registro,
    a.campo,
    a.valor_anterior,
    a.valor_nuevo,
    a.descripcion,
    u.nombre_usuario,
    CONCAT(p.nombre, ' ', IFNULL(p.apellido,'')) AS nombre_completo,
    u.roles
FROM auditoria a
LEFT JOIN usuario u ON a.id_usuario = u.id_usuario
LEFT JOIN persona p ON u.id_persona = p.id_persona
ORDER BY a.fecha_hora DESC 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_auditoria_inventario`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_inventario` AS SELECT
    a.id_auditoria,
    a.fecha_hora,
    a.operacion,
    a.id_registro AS id_inventario,
    a.campo,
    a.valor_anterior,
    a.valor_nuevo,
    a.descripcion,
    i.serial,
    eq.nombre AS equipo
FROM auditoria a
LEFT JOIN inventario i ON a.id_registro = i.id_inventario AND a.tabla = 'inventario'
LEFT JOIN equipos eq   ON i.id_equipos = eq.id_equipos
WHERE a.tabla = 'inventario'
ORDER BY a.fecha_hora DESC 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_auditoria_resumen`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_resumen` AS SELECT
    tabla,
    operacion,
    COUNT(*)                        AS total_operaciones,
    MIN(fecha_hora)                 AS primera_operacion,
    MAX(fecha_hora)                 AS ultima_operacion,
    DATE(MAX(fecha_hora))           AS ultimo_dia
FROM auditoria
GROUP BY tabla, operacion
ORDER BY tabla, operacion 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_auditoria_solicitudes`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_solicitudes` AS SELECT
    a.id_auditoria,
    a.fecha_hora,
    a.operacion,
    a.id_registro AS id_solicitud,
    a.campo,
    a.valor_anterior,
    a.valor_nuevo,
    a.descripcion,
    s.fecha        AS fecha_solicitud,
    s.hora_inicio,
    s.hora_fin,
    esp.nombre     AS espacio,
    act.nombre     AS actividad
FROM auditoria a
LEFT JOIN solicitud s   ON a.id_registro = s.id_solicitud AND a.tabla = 'solicitud'
LEFT JOIN espacio esp   ON s.id_espacio = esp.id_espacio
LEFT JOIN actividad act ON s.id_actividad = act.id_actividad
WHERE a.tabla = 'solicitud'
ORDER BY a.fecha_hora DESC 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `v_auditoria_usuarios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_usuarios` AS SELECT
    a.id_auditoria,
    a.fecha_hora,
    a.operacion,
    a.id_registro AS id_usuario,
    a.campo,
    a.valor_anterior,
    a.valor_nuevo,
    a.descripcion,
    u.nombre_usuario,
    u.roles
FROM auditoria a
LEFT JOIN usuario u ON a.id_registro = u.id_usuario AND a.tabla = 'usuario'
WHERE a.tabla = 'usuario'
ORDER BY a.fecha_hora DESC 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_indicadores_mantenimiento_disponibilidad`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_indicadores_mantenimiento_disponibilidad` AS SELECT 
    'Total de equipos' AS indicador,
    COUNT(*) AS valor
FROM equipos
UNION ALL
SELECT 
    'Equipos Operativos' AS indicador,
    COUNT(*) AS valor
FROM inventario WHERE estado = 'Operativo'
UNION ALL
SELECT 
    'Equipos en mantenimiento' AS indicador,
    COUNT(*) AS valor
FROM inventario WHERE estado = 'En Reparacion'
UNION ALL
SELECT 
    'Equipos Dañados' AS indicador,
    COUNT(*) AS valor
FROM inventario WHERE estado = 'Dañado'
UNION ALL
SELECT 
    'Mantenimientos realizados' AS indicador,
    COUNT(*) AS valor
FROM mantenimiento
UNION ALL
SELECT 
    'Tasa de disponibilidad' AS indicador,
    ROUND((SELECT COUNT(*) FROM inventario WHERE estado = 'Operativo') * 100.0 / 
          NULLIF((SELECT COUNT(*) FROM inventario), 0), 2) AS valor
UNION ALL
SELECT 
    'Solicitudes aprobadas' AS indicador,
    COUNT(*) AS valor
FROM solicitud WHERE estado = 'Aprobado' 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_actividades_educativas`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_actividades_educativas` AS SELECT 
    a.id_actividad,
    a.nombre AS nombre_actividad,
    a.descripcion_actividad,
    COUNT(DISTINCT s.id_solicitud) AS total_solicitudes,
    COUNT(DISTINCT s.id_espacio) AS espacios_utilizados,
    COUNT(DISTINCT ast.id_estudiante) AS total_estudiantes_participantes,
    MIN(s.fecha) AS primera_realizacion,
    MAX(s.fecha) AS ultima_realizacion
FROM actividad a
LEFT JOIN solicitud s ON s.id_actividad = a.id_actividad AND s.estado = 'Completado'
LEFT JOIN asistencia ast ON ast.id_solicitud = s.id_solicitud
GROUP BY a.id_actividad 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_disponibilidad_equipos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_disponibilidad_equipos` AS SELECT 
    eq.id_equipos,
    eq.nombre AS nombre_equipo,
    i.serial,
    i.estado AS estado_equipo,
    uf.nombre AS ubicacion_fisica,
    CASE 
        WHEN i.estado = 'Operativo' THEN 'Disponible'
        WHEN i.estado = 'En Reparacion' THEN 'En mantenimiento'
        WHEN i.estado = 'No operativo' THEN 'No disponible'
        WHEN i.estado = 'Dañado' THEN 'Fuera de servicio'
    END AS disponibilidad,
    COUNT(DISTINCT s.id_solicitud) AS reservas_activas
FROM equipos eq
INNER JOIN inventario i ON i.id_equipos = eq.id_equipos
LEFT JOIN ubicacion_fisica uf ON i.id_ubicacion_fisica = uf.id_ubicacion_fisica
LEFT JOIN detalle_solicitud ds ON ds.id_inventario = i.id_inventario
LEFT JOIN solicitud s ON s.id_solicitud = ds.id_solicitud 
    AND s.estado IN ('Aprobado', 'Pendiente')
GROUP BY eq.id_equipos 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_equipos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_equipos` AS SELECT 
    eq.id_equipos,
    eq.nombre AS nombre_equipo,
    c.nombre AS categoria,
    m.nombre AS marca,
    md.nombre AS modelo,
    i.serial,
    i.estado AS estado_equipo,
    uf.nombre AS ubicacion_fisica,
    COUNT(DISTINCT ds.id_solicitud) AS veces_prestado,
    COUNT(DISTINCT me.id_mantenimiento) AS veces_mantenimiento
FROM equipos eq
LEFT JOIN categoria c ON eq.id_categoria = c.id_categoria
LEFT JOIN marca m ON eq.id_marca = m.id_marca
LEFT JOIN modelo md ON eq.id_modelo = md.id_modelo
LEFT JOIN inventario i ON i.id_equipos = eq.id_equipos
LEFT JOIN ubicacion_fisica uf ON i.id_ubicacion_fisica = uf.id_ubicacion_fisica
LEFT JOIN detalle_solicitud ds ON ds.id_inventario = i.id_inventario
LEFT JOIN mantenimiento_equipos me ON me.id_equipos = eq.id_equipos
GROUP BY eq.id_equipos 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_fallas_tecnicas`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_fallas_tecnicas` AS SELECT 
    m.id_mantenimiento,
    m.fecha_reporte,
    m.nivel_prioridad,
    me.descripcion_fallas,
    eq.id_equipos,
    eq.nombre AS nombre_equipo,
    c.nombre AS categoria_equipo,
    i.serial AS serial_equipo,
    i.estado AS estado_actual,
    p.nombre AS tecnico_nombre,
    p.apellido AS tecnico_apellido,
    t.especialidad AS tecnico_especialidad,
    DATEDIFF(CURDATE(), DATE(m.fecha_reporte)) AS dias_sin_resolver
FROM mantenimiento m
INNER JOIN mantenimiento_equipos me ON me.id_mantenimiento = m.id_mantenimiento
INNER JOIN equipos eq ON me.id_equipos = eq.id_equipos
INNER JOIN categoria c ON eq.id_categoria = c.id_categoria
LEFT JOIN inventario i ON i.id_equipos = eq.id_equipos
INNER JOIN tecnicos t ON m.id_tecnicos = t.id_tecnicos
INNER JOIN persona p ON t.id_persona = p.id_persona 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_mantenimiento_equipos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_mantenimiento_equipos` AS SELECT 
    eq.id_equipos,
    eq.nombre AS nombre_equipo,
    c.nombre AS categoria,
    COUNT(m.id_mantenimiento) AS total_mantenimientos,
    COUNT(CASE WHEN m.nivel_prioridad = 'Alta' THEN 1 END) AS mantenimientos_alta,
    COUNT(CASE WHEN m.nivel_prioridad = 'Media' THEN 1 END) AS mantenimientos_media,
    COUNT(CASE WHEN m.nivel_prioridad = 'Baja' THEN 1 END) AS mantenimientos_baja,
    MIN(m.fecha_reporte) AS primer_mantenimiento,
    MAX(m.fecha_reporte) AS ultimo_mantenimiento,
    GROUP_CONCAT(DISTINCT me.descripcion_fallas SEPARATOR ' | ') AS fallas_reportadas
FROM equipos eq
LEFT JOIN categoria c ON eq.id_categoria = c.id_categoria
LEFT JOIN mantenimiento_equipos me ON me.id_equipos = eq.id_equipos
LEFT JOIN mantenimiento m ON m.id_mantenimiento = me.id_mantenimiento
GROUP BY eq.id_equipos 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_maquinas_mas_usadas`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_maquinas_mas_usadas` AS SELECT 
    eq.id_equipos,
    eq.nombre AS nombre_equipo,
    c.nombre AS categoria,
    i.serial,
    COUNT(DISTINCT ds.id_solicitud) AS total_reservas,
    COUNT(DISTINCT s.id_solicitud) AS total_uso_completado,
    SUM(TIMESTAMPDIFF(HOUR, s.hora_inicio, s.hora_fin)) AS horas_totales_uso,
    RANK() OVER (ORDER BY COUNT(DISTINCT ds.id_solicitud) DESC) AS ranking_uso
FROM equipos eq
INNER JOIN inventario i ON i.id_equipos = eq.id_equipos
LEFT JOIN categoria c ON eq.id_categoria = c.id_categoria
LEFT JOIN detalle_solicitud ds ON ds.id_inventario = i.id_inventario
LEFT JOIN solicitud s ON s.id_solicitud = ds.id_solicitud 
    AND s.estado = 'Completado'
GROUP BY eq.id_equipos
ORDER BY total_reservas DESC 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_notificaciones`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_notificaciones` AS SELECT 
    n.id_notificacion,
    n.titulo,
    n.mensaje,
    n.fecha_envio,
    p.nombre AS usuario_nombre,
    p.apellido AS usuario_apellido,
    u.nombre_usuario,
    u.correo AS correo_usuario,
    u.roles AS rol_usuario,
    DATE(n.fecha_envio) AS fecha,
    HOUR(n.fecha_envio) AS hora_envio
FROM notificacion n
INNER JOIN usuario u ON n.id_usuario = u.id_usuario
INNER JOIN persona p ON u.id_persona = p.id_persona 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_reservas_equipos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_reservas_equipos` AS SELECT 
    s.id_solicitud,
    s.fecha,
    s.hora_inicio,
    s.hora_fin,
    s.estado,
    s.descripcion,
    p.nombre AS usuario_nombre,
    p.apellido AS usuario_apellido,
    u.roles AS rol_usuario,
    eq.nombre AS nombre_equipo,
    i.serial AS serial_equipo,
    a.nombre AS actividad_realizada
FROM solicitud s
INNER JOIN usuario u ON s.id_usuario = u.id_usuario
INNER JOIN persona p ON u.id_persona = p.id_persona
LEFT JOIN actividad a ON s.id_actividad = a.id_actividad
LEFT JOIN detalle_solicitud ds ON ds.id_solicitud = s.id_solicitud
LEFT JOIN inventario i ON ds.id_inventario = i.id_inventario
LEFT JOIN equipos eq ON i.id_equipos = eq.id_equipos 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_reservas_espacios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_reservas_espacios` AS SELECT 
    s.id_solicitud,
    s.fecha,
    s.hora_inicio,
    s.hora_fin,
    s.estado,
    s.descripcion,
    e.nombre AS nombre_espacio,
    e.capacidad,
    p.nombre AS usuario_nombre,
    p.apellido AS usuario_apellido,
    u.roles AS rol_usuario,
    a.nombre AS actividad_realizada,
    COUNT(ast.id_asistencia) AS asistentes_registrados
FROM solicitud s
INNER JOIN usuario u ON s.id_usuario = u.id_usuario
INNER JOIN persona p ON u.id_persona = p.id_persona
INNER JOIN espacio e ON s.id_espacio = e.id_espacio
LEFT JOIN actividad a ON s.id_actividad = a.id_actividad
LEFT JOIN asistencia ast ON ast.id_solicitud = s.id_solicitud
GROUP BY s.id_solicitud 
;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vista_reporte_usuarios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_usuarios` AS SELECT 
    u.id_usuario,
    p.nombre,
    p.apellido,
    p.cedula,
    p.telefono,
    u.nombre_usuario,
    u.correo,
    u.estado,
    u.roles,
    CASE 
        WHEN e.id_estudiante IS NOT NULL THEN 'Estudiante'
        WHEN t.id_tecnicos IS NOT NULL THEN 'Técnico'
        ELSE 'Usuario general'
    END AS tipo_usuario,
    e.seccion AS estudiante_seccion,
    e.año AS estudiante_año,
    e.estado AS estudiante_estado,
    t.especialidad AS tecnico_especialidad
FROM usuario u
INNER JOIN persona p ON u.id_persona = p.id_persona
LEFT JOIN estudiante e ON e.id_persona = p.id_persona
LEFT JOIN tecnicos t ON t.id_persona = p.id_persona 
;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
