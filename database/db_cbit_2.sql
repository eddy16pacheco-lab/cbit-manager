-- =====================================================================
-- Archivo: db_cbit_2_pulido.sql
-- Base de datos: db_cbit_2
-- Motor: Compatible con MySQL / MariaDB (Laragon / XAMPP)
-- Descripción: Script corregido con colación utf8mb4_unicode_ci
-- =====================================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- =====================================================================
-- 0. BASE DE DATOS
-- =====================================================================
DROP DATABASE IF EXISTS `db_cbit_2`;
CREATE DATABASE `db_cbit_2` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_cbit_2`;

-- =====================================================================
-- 1. TABLAS
-- =====================================================================

CREATE TABLE `actividad` (
  `id_actividad` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion_actividad` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_actividad`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `categoria` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `marca` (
  `id_marca` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_marca`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `modelo` (
  `id_modelo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_modelo`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `espacio` (
  `id_espacio` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `capacidad` int(11) NOT NULL,
  PRIMARY KEY (`id_espacio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `horario` (
  `id_horario` int(11) NOT NULL AUTO_INCREMENT,
  `dias` enum('Lunes','Martes','Miercoles','Jueves','Viernes') NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_final` time NOT NULL,
  PRIMARY KEY (`id_horario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ubicacion_fisica` (
  `id_ubicacion_fisica` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) NOT NULL,
  PRIMARY KEY (`id_ubicacion_fisica`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `persona` (
  `id_persona` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `cedula` varchar(30) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `cedula` (`cedula`),
  UNIQUE KEY `telefono` (`telefono`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `usuario` (
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `estudiante` (
  `id_estudiante` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) DEFAULT NULL,
  `seccion` enum('A','B','C','D','U') DEFAULT NULL,
  `año` enum('1er año','2er año','3er año','4er año','5er año','6er año') NOT NULL,
  PRIMARY KEY (`id_estudiante`),
  KEY `es` (`id_persona`),
  CONSTRAINT `fk_estudiante_persona` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tecnicos` (
  `id_tecnicos` int(11) NOT NULL AUTO_INCREMENT,
  `especialidad` enum('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_tecnicos`),
  KEY `puede_ser` (`id_persona`),
  CONSTRAINT `puede_ser` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `equipos` (
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `inventario` (
  `id_inventario` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_bien_nacional` varchar(30) DEFAULT NULL,
  `id_equipos` int(11) DEFAULT NULL,
  `id_ubicacion_fisica` int(11) DEFAULT NULL,
  `serial` varchar(30) NOT NULL,
  `estado` enum('Operativo','No operativo','En Reparacion','Dañado','Desincorporado') NOT NULL,
  `fecha_desincorporacion` date DEFAULT NULL,
  `motivo_desincorporacion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_inventario`),
  UNIQUE KEY `codigo_barra` (`serial`),
  UNIQUE KEY `uq_inventario_codigo_bien_nacional` (`codigo_bien_nacional`),
  KEY `tiene_registros` (`id_equipos`),
  KEY `tiene___` (`id_ubicacion_fisica`),
  CONSTRAINT `tiene___` FOREIGN KEY (`id_ubicacion_fisica`) REFERENCES `ubicacion_fisica` (`id_ubicacion_fisica`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tiene_registros` FOREIGN KEY (`id_equipos`) REFERENCES `equipos` (`id_equipos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `solicitud` (
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `alerta_prestamo` (
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `asistencia` (
  `id_asistencia` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) DEFAULT NULL,
  `id_solicitud` int(11) DEFAULT NULL,
  `asistio` enum('Si','No') NOT NULL,
  PRIMARY KEY (`id_asistencia`),
  KEY `tiene_` (`id_estudiante`),
  KEY `tiene` (`id_solicitud`),
  CONSTRAINT `tiene` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tiene_` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiante` (`id_estudiante`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `auditoria` (
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
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro de auditoría de todas las operaciones del sistema';

CREATE TABLE `detalle_solicitud` (
  `id_detalle_solicitud` int(11) NOT NULL AUTO_INCREMENT,
  `id_solicitud` int(11) DEFAULT NULL,
  `id_inventario` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_detalle_solicitud`),
  KEY `puede_tener` (`id_solicitud`),
  KEY `puede_tener_` (`id_inventario`),
  CONSTRAINT `puede_tener` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `puede_tener_` FOREIGN KEY (`id_inventario`) REFERENCES `inventario` (`id_inventario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `disponibilidad_calendario` (
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `historial_actividad` (
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mantenimiento` (
  `id_mantenimiento` int(11) NOT NULL AUTO_INCREMENT,
  `id_tecnicos` int(11) DEFAULT NULL,
  `fecha_reporte` datetime NOT NULL,
  `nivel_prioridad` enum('Alta','Media','Baja') NOT NULL,
  PRIMARY KEY (`id_mantenimiento`),
  KEY `realiza_` (`id_tecnicos`),
  CONSTRAINT `realiza_` FOREIGN KEY (`id_tecnicos`) REFERENCES `tecnicos` (`id_tecnicos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mantenimiento_equipos` (
  `id_mantenimiento_equipos` int(11) NOT NULL AUTO_INCREMENT,
  `id_mantenimiento` int(11) DEFAULT NULL,
  `id_equipos` int(11) DEFAULT NULL,
  `descripcion_fallas` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id_mantenimiento_equipos`),
  KEY `es_implementado` (`id_mantenimiento`),
  KEY `resiv` (`id_equipos`),
  CONSTRAINT `es_implementado` FOREIGN KEY (`id_mantenimiento`) REFERENCES `mantenimiento` (`id_mantenimiento`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `resiv` FOREIGN KEY (`id_equipos`) REFERENCES `equipos` (`id_equipos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notificacion` (
  `id_notificacion` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) DEFAULT NULL,
  `titulo` varchar(30) NOT NULL,
  `mensaje` text NOT NULL,
  `fecha_envio` datetime NOT NULL,
  PRIMARY KEY (`id_notificacion`),
  KEY `resive__` (`id_usuario`),
  CONSTRAINT `resive__` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `solicitud_horario` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 2. DATOS
-- =====================================================================

INSERT INTO `actividad` (`id_actividad`, `nombre`, `descripcion_actividad`) VALUES
	(1, 'Clase de Programación', 'Clase práctica de programación'),
	(2, 'Taller de Robótica', 'Taller de robótica educativa'),
	(3, 'Presentación de Proyectos', 'Presentación de proyectos finales'),
	(4, 'Examen Práctico', 'Evaluación práctica de habilidades'),
	(5, 'Laboratorio de Física', 'Prácticas de laboratorio de física'),
	(6, 'Clase de Inglés', 'Clase de inglés técnico'),
	(7, 'Taller de Diseño', 'Taller de diseño gráfico'),
	(8, 'Seminario de Investigación', 'Seminario de investigación académica');

INSERT INTO `categoria` (`id_categoria`, `nombre`, `descripcion`) VALUES
	(1, 'Computadoras', 'Equipos de cómputo y laptops'),
	(2, 'Proyectores', 'Proyectores multimedia'),
	(3, 'Impresoras', 'Impresoras y equipos de impresión'),
	(4, 'Redes', 'Equipos de red y conectividad'),
	(5, 'Periféricos', 'Teclados, mouse, monitores'),
	(6, 'Audio y Video', 'Equipos de audio y video');

INSERT INTO `marca` (`id_marca`, `nombre`, `descripcion`) VALUES
	(1, 'HP', 'Hewlett-Packard'),
	(2, 'Dell', 'Dell Technologies'),
	(3, 'Lenovo', 'Lenovo Group'),
	(4, 'Apple', 'Apple Inc.'),
	(5, 'Samsung', 'Samsung Electronics'),
	(6, 'Epson', 'Seiko Epson Corporation');

INSERT INTO `modelo` (`id_modelo`, `nombre`, `descripcion`) VALUES
	(1, 'EliteBook 840', 'Laptop HP EliteBook 840 G8'),
	(2, 'Latitude 7420', 'Laptop Dell Latitude 7420'),
	(3, 'ThinkPad T14', 'Laptop Lenovo ThinkPad T14'),
	(4, 'MacBook Air', 'Apple MacBook Air M2'),
	(5, 'Galaxy Tab S7', 'Samsung Galaxy Tab S7'),
	(6, 'PowerLite 5600', 'Proyector Epson PowerLite 5600');

INSERT INTO `espacio` (`id_espacio`, `nombre`, `capacidad`) VALUES
	(1, 'Salón del CBIT', 20);

INSERT INTO `horario` (`id_horario`, `dias`, `hora_inicio`, `hora_final`) VALUES
	(1, 'Lunes', '07:30:00', '15:30:00'),
	(2, 'Martes', '07:30:00', '15:30:00'),
	(3, 'Miercoles', '07:30:00', '15:30:00'),
	(4, 'Jueves', '07:30:00', '15:30:00'),
	(5, 'Viernes', '07:30:00', '14:00:00');

INSERT INTO `ubicacion_fisica` (`id_ubicacion_fisica`, `nombre`) VALUES
	(1, 'Laboratorio de Cómputo - Aula 101'),
	(2, 'Laboratorio de Cómputo - Aula 102'),
	(3, 'Biblioteca - Área de recursos'),
	(4, 'Sala de Profesores'),
	(5, 'Almacén General');

INSERT INTO `persona` (`id_persona`, `nombre`, `apellido`, `cedula`, `telefono`) VALUES
	(1, 'Eddy', 'Pacheco', 'V-31394074', '04129574257'),
	(2, 'Ana', 'Ramírez', 'V-7654321', '04141112233'),
	(3, 'Luis', 'Torres', 'V-11223344', '04242223344'),
	(4, 'María', 'Flores', 'V-44332211', '04163334455'),
	(5, 'Jorge', 'Díaz', 'V-556677', '04264445566'),
	(6, 'Laura', 'García', 'V-776655', '04125556677'),
	(7, 'Manuel', 'Pacheco', 'V-30937772', '04141527890'),
	(8, 'Daniel', 'Pacheco', 'V-32566687', '04269154122');

INSERT INTO `usuario` (`id_usuario`, `id_persona`, `nombre_usuario`, `contrasena_usuario`, `correo`, `estado`, `roles`, `reset_token`, `reset_expira`) VALUES
	(1, 1, 'admin', 'admin123', 'eddy15pacheco@gmail.com', 'Activo', 'Administrador', NULL, NULL),
	(2, 2, 'ana.ramirez', 'hash_ana', 'ana.ramirez@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(3, 3, 'luis.torres', 'hash_luis', 'luis.torres@instituto.edu', 'Activo', 'Docente', NULL, NULL),
	(4, 4, 'maria.flores', 'hash_maria', 'maria.flores@instituto.edu', 'Inactivo', 'Docente', NULL, NULL),
	(5, 7, 'manu123', 'manu123', 'manu123@gmail.com', 'Activo', 'Docente', NULL, NULL);

INSERT INTO `estudiante` (`id_estudiante`, `id_persona`, `seccion`, `año`) VALUES
	(1, 8, 'A', '2er año'),
	(2, 5, 'B', '3er año'),
	(3, 6, 'C', '4er año');

INSERT INTO `tecnicos` (`id_tecnicos`, `especialidad`, `id_persona`) VALUES
	(1, 'Hardware', 1),
	(2, 'Soporte técnico', 6);

INSERT INTO `equipos` (`id_equipos`, `id_categoria`, `id_modelo`, `id_marca`, `nombre`) VALUES
	(1, 1, 2, 2, 'Laptop Dell Latitude 7420'),
	(2, 1, 3, 3, 'Laptop Lenovo ThinkPad T14'),
	(3, 1, 4, 4, 'MacBook Air M2'),
	(4, 2, 6, 6, 'Proyector Epson PowerLite'),
	(5, 5, 5, 5, 'Tablet Samsung Galaxy Tab S7'),
	(6, 5, 1, 1, 'Monitor HP EliteDisplay');

INSERT INTO `inventario` (`id_inventario`, `codigo_bien_nacional`, `id_equipos`, `id_ubicacion_fisica`, `serial`, `estado`, `fecha_desincorporacion`, `motivo_desincorporacion`) VALUES
	(1, '000001', 1, 1, 'DELL-LAT-001', 'Operativo', NULL, NULL),
	(2, '000002', 1, 3, 'DELL-LAT-002', 'En Reparacion', NULL, NULL),
	(3, '000003', 2, 1, 'LEN-T14-001', 'Operativo', NULL, NULL),
	(4, '000004', 2, 2, 'LEN-T14-002', 'Operativo', NULL, NULL),
	(5, '000005', 3, 4, 'MAC-M2-001', 'Operativo', NULL, NULL),
	(6, '000006', 4, 5, 'EPS-POW-001', 'No operativo', NULL, NULL),
	(7, '000007', 5, 2, 'SAM-GAL-001', 'Operativo', NULL, NULL),
	(8, '000008', 6, 1, 'HP-ELD-001', 'Operativo', NULL, NULL);

INSERT INTO `solicitud` (`id_solicitud`, `id_espacio`, `id_actividad`, `id_usuario`, `fecha`, `hora_inicio`, `hora_fin`, `estado`, `descripcion`) VALUES
	(1, 1, 1, 1, '2026-11-23', '08:00:00', '09:30:00', 'Completado', 'Clase práctica de programación'),
	(2, 1, 2, 2, '2026-11-23', '10:00:00', '11:30:00', 'Aprobado', 'Taller de robótica educativa'),
	(3, 1, 3, 3, '2026-11-24', '08:00:00', '09:30:00', 'Aprobado', 'Presentación de proyectos finales'),
	(4, 1, 4, 1, '2026-11-24', '10:00:00', '12:00:00', 'Pendiente', 'Evaluación práctica de habilidades'),
	(5, 1, 5, 2, '2026-11-25', '08:00:00', '10:00:00', 'Aprobado', 'Prácticas de laboratorio de física'),
	(6, 1, 6, 3, '2026-11-25', '11:00:00', '12:30:00', 'Cancelado', 'Clase de inglés técnico'),
	(7, 1, 7, 1, '2026-11-26', '08:00:00', '10:00:00', 'Aprobado', 'Taller de diseño gráfico'),
	(8, 1, 8, 2, '2026-11-27', '08:00:00', '09:30:00', 'Pendiente', 'Seminario de investigación académica'),
	(9, 1, 1, 3, '2026-11-28', '10:00:00', '11:30:00', 'Aprobado', 'Clase de programación (refuerzo)');

INSERT INTO `asistencia` (`id_asistencia`, `id_estudiante`, `id_solicitud`, `asistio`) VALUES
	(1, 1, 1, 'Si'),
	(2, 2, 1, 'Si'),
	(3, 3, 1, 'No'),
	(4, 1, 2, 'Si'),
	(5, 2, 3, 'Si'),
	(6, 1, 5, 'Si'),
	(7, 3, 7, 'Si'),
	(8, 2, 9, 'Si');

INSERT INTO `detalle_solicitud` (`id_detalle_solicitud`, `id_solicitud`, `id_inventario`) VALUES
	(1, 1, 1), (2, 1, 3), (3, 2, 7), (4, 3, 5),
	(5, 4, 1), (6, 4, 4), (7, 5, 3), (8, 5, 4),
	(9, 6, 7), (10, 7, 5), (11, 8, 1), (12, 9, 3), (13, 9, 7);

INSERT INTO `disponibilidad_calendario` (`id_disponibilidad`, `tipo_recurso`, `id_recurso`, `fecha_inicio`, `fecha_fin`, `motivo`, `disponible`) VALUES
	(1, 'Equipo', 2, '2026-11-23 08:00:00', '2026-11-25 17:00:00', 'En reparación por falla de placa', 'No'),
	(2, 'Equipo', 6, '2026-11-26 08:00:00', '2026-11-27 18:00:00', 'Mantenimiento de proyector', 'No'),
	(3, 'Espacio', 1, '2026-11-27 14:00:00', '2026-11-27 18:00:00', 'Evento institucional', 'No'),
	(4, 'Equipo', 1, '2026-11-28 08:00:00', '2026-11-28 12:00:00', 'Revisión preventiva', 'No');

INSERT INTO `mantenimiento` (`id_mantenimiento`, `id_tecnicos`, `fecha_reporte`, `nivel_prioridad`) VALUES
	(1, 1, '2026-11-23 09:15:00', 'Alta'),
	(2, 2, '2026-11-26 10:00:00', 'Media');

INSERT INTO `mantenimiento_equipos` (`id_mantenimiento_equipos`, `id_mantenimiento`, `id_equipos`, `descripcion_fallas`) VALUES
	(1, 1, 1, 'Laptop Dell no enciende, posible falla de placa base'),
	(2, 2, 4, 'Proyector Epson con lámpara desgastada');

INSERT INTO `notificacion` (`id_notificacion`, `id_usuario`, `titulo`, `mensaje`, `fecha_envio`) VALUES
	(1, 2, 'Solicitud aprobada', 'Su solicitud #2 fue aprobada.', '2026-11-23 10:05:00'),
	(2, 3, 'Solicitud aprobada', 'Su solicitud #3 fue aprobada.', '2026-11-24 08:10:00'),
	(3, 1, 'Solicitud pendiente', 'La solicitud #4 está pendiente de aprobación.', '2026-11-24 10:05:00'),
	(4, 2, 'Solicitud cancelada', 'La solicitud #6 fue cancelada.', '2026-11-25 11:05:00'),
	(5, 1, 'Recordatorio', 'La solicitud #8 está pendiente.', '2026-11-27 09:00:00');

INSERT INTO `alerta_prestamo` (`id_alerta`, `id_solicitud`, `id_usuario`, `tipo_alerta`, `mensaje`, `fecha_alerta`, `leida`) VALUES
	(1, 1, 1, 'Devuelto', 'Equipos devueltos correctamente.', '2026-11-23 09:35:00', 'Si'),
	(2, 2, 2, 'Proximo a vencer', 'La reserva vence pronto.', '2026-11-23 11:00:00', 'No'),
	(3, 5, 2, 'Proximo a vencer', 'La reserva vence pronto.', '2026-11-25 09:45:00', 'No');

INSERT INTO `historial_actividad` (`id_historial`, `id_usuario`, `usuario`, `accion`, `modulo`, `detalle`, `ip`, `fecha`) VALUES
	(1, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-11-23 07:55:00'),
	(2, 1, 'Eddy Pacheco', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-11-23 08:00:00'),
	(3, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', '::1', '2026-11-23 08:05:00'),
	(4, 2, 'Ana Ramírez', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-11-23 09:55:00'),
	(5, 2, 'Ana Ramírez', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-11-23 10:00:00'),
	(6, 3, 'Luis Torres', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-11-24 07:55:00'),
	(7, 3, 'Luis Torres', 'Creación', 'Solicitudes', 'Solicitud registrada. Esperando aprobación.', '::1', '2026-11-24 08:00:00'),
	(8, 1, 'Eddy Pacheco', 'Actualización', 'Solicitudes', 'Solicitud aprobada. Correo enviado al docente ✅', '::1', '2026-11-24 08:10:00'),
	(9, 2, 'Ana Ramírez', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-11-25 12:35:00'),
	(10, 1, 'Eddy Pacheco', 'Cierre de sesión', 'Autenticación', 'Sesión finalizada', '::1', '2026-11-28 12:00:00'),
	(11, 1, 'Eddy Pacheco', 'Inicio de sesión', 'Autenticación', 'Acceso exitoso al sistema', '::1', '2026-11-20 18:24:38'),
	(12, 1, 'Eddy Pacheco', 'Actualización', 'Inventario', 'Registro actualizado', '::1', '2026-11-20 18:37:45'),
	(13, 1, 'Eddy Pacheco', 'Actualización', 'Inventario', 'Registro actualizado', '::1', '2026-11-20 18:37:51');

-- =====================================================================
-- 3. PROCEDIMIENTO
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_auditar`;
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

-- =====================================================================
-- 4. TRIGGERS DE AUDITORÍA
-- =====================================================================

DROP TRIGGER IF EXISTS `aud_asistencia_insert`;
DELIMITER //
CREATE TRIGGER `aud_asistencia_insert` AFTER INSERT ON `asistencia` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('asistencia', 'INSERT', NEW.id_asistencia, NULL, NULL,
            CONCAT('estudiante_id:', NEW.id_estudiante, ' | solicitud_id:', NEW.id_solicitud, ' | asistio:', NEW.asistio),
            NOW(), CONCAT('Asistencia registrada — Estudiante #', NEW.id_estudiante,
                         ' en solicitud #', NEW.id_solicitud, ': ', NEW.asistio));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_asistencia_delete`;
DELIMITER //
CREATE TRIGGER `aud_asistencia_delete` AFTER DELETE ON `asistencia` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('asistencia', 'DELETE', OLD.id_asistencia, NULL,
            CONCAT('estudiante_id:', OLD.id_estudiante, ' asistio:', OLD.asistio), NULL,
            NOW(), CONCAT('Registro de asistencia #', OLD.id_asistencia, ' eliminado'));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_categoria_insert`;
DELIMITER //
CREATE TRIGGER `aud_categoria_insert` AFTER INSERT ON `categoria` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('categoria', 'INSERT', NEW.id_categoria, NULL, NULL, NEW.nombre, NOW(),
            CONCAT('Nueva categoría registrada: ', NEW.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_categoria_delete`;
DELIMITER //
CREATE TRIGGER `aud_categoria_delete` AFTER DELETE ON `categoria` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('categoria', 'DELETE', OLD.id_categoria, NULL, OLD.nombre, NULL, NOW(),
            CONCAT('Categoría eliminada: ', OLD.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_equipos_insert`;
DELIMITER //
CREATE TRIGGER `aud_equipos_insert` AFTER INSERT ON `equipos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('equipos', 'INSERT', NEW.id_equipos, NULL, NULL,
            CONCAT('nombre:', NEW.nombre),
            NOW(), CONCAT('Nuevo equipo registrado en catálogo: ', NEW.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_equipos_update`;
DELIMITER //
CREATE TRIGGER `aud_equipos_update` AFTER UPDATE ON `equipos` FOR EACH ROW
BEGIN
    IF OLD.nombre != NEW.nombre THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
        VALUES ('equipos', 'UPDATE', NEW.id_equipos, 'nombre', OLD.nombre, NEW.nombre, NOW(), 'Nombre de equipo modificado');
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_equipos_delete`;
DELIMITER //
CREATE TRIGGER `aud_equipos_delete` AFTER DELETE ON `equipos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('equipos', 'DELETE', OLD.id_equipos, NULL, OLD.nombre, NULL,
            NOW(), CONCAT('Equipo eliminado del catálogo: ', OLD.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_espacio_insert`;
DELIMITER //
CREATE TRIGGER `aud_espacio_insert` AFTER INSERT ON `espacio` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('espacio', 'INSERT', NEW.id_espacio, NULL, NULL,
            CONCAT('nombre:', NEW.nombre, ' | capacidad:', NEW.capacidad),
            NOW(), CONCAT('Nuevo espacio registrado: ', NEW.nombre, ' (Cap: ', NEW.capacidad, ')'));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_espacio_update`;
DELIMITER //
CREATE TRIGGER `aud_espacio_update` AFTER UPDATE ON `espacio` FOR EACH ROW
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

DROP TRIGGER IF EXISTS `aud_espacio_delete`;
DELIMITER //
CREATE TRIGGER `aud_espacio_delete` AFTER DELETE ON `espacio` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('espacio', 'DELETE', OLD.id_espacio, NULL,
            CONCAT(OLD.nombre, ' | cap:', OLD.capacidad), NULL,
            NOW(), CONCAT('Espacio eliminado: ', OLD.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_inventario_insert`;
DELIMITER //
CREATE TRIGGER `aud_inventario_insert` AFTER INSERT ON `inventario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('inventario', 'INSERT', NEW.id_inventario, NULL, NULL,
            CONCAT('serial:', NEW.serial, ' | estado:', NEW.estado),
            NOW(), CONCAT('Equipo agregado al inventario — Serial: ', NEW.serial, ' | Estado: ', NEW.estado));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_inventario_update`;
DELIMITER //
CREATE TRIGGER `aud_inventario_update` AFTER UPDATE ON `inventario` FOR EACH ROW
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

DROP TRIGGER IF EXISTS `aud_inventario_delete`;
DELIMITER //
CREATE TRIGGER `aud_inventario_delete` AFTER DELETE ON `inventario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('inventario', 'DELETE', OLD.id_inventario, NULL,
            CONCAT('serial:', OLD.serial, ' | estado:', OLD.estado), NULL,
            NOW(), CONCAT('Equipo eliminado del inventario — Serial: ', OLD.serial));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_mantenimiento_insert`;
DELIMITER //
CREATE TRIGGER `aud_mantenimiento_insert` AFTER INSERT ON `mantenimiento` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('mantenimiento', 'INSERT', NEW.id_mantenimiento, NULL, NULL,
            CONCAT('tecnico_id:', NEW.id_tecnicos, ' | prioridad:', NEW.nivel_prioridad),
            NOW(), CONCAT('Reporte de mantenimiento #', NEW.id_mantenimiento, ' creado — Prioridad: ', NEW.nivel_prioridad));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_mantenimiento_delete`;
DELIMITER //
CREATE TRIGGER `aud_mantenimiento_delete` AFTER DELETE ON `mantenimiento` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('mantenimiento', 'DELETE', OLD.id_mantenimiento, NULL,
            CONCAT('prioridad:', OLD.nivel_prioridad, ' | fecha:', OLD.fecha_reporte), NULL,
            NOW(), CONCAT('Reporte de mantenimiento #', OLD.id_mantenimiento, ' eliminado'));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_marca_insert`;
DELIMITER //
CREATE TRIGGER `aud_marca_insert` AFTER INSERT ON `marca` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('marca', 'INSERT', NEW.id_marca, NULL, NULL, NEW.nombre, NOW(),
            CONCAT('Nueva marca registrada: ', NEW.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_marca_delete`;
DELIMITER //
CREATE TRIGGER `aud_marca_delete` AFTER DELETE ON `marca` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('marca', 'DELETE', OLD.id_marca, NULL, OLD.nombre, NULL, NOW(),
            CONCAT('Marca eliminada: ', OLD.nombre));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_persona_insert`;
DELIMITER //
CREATE TRIGGER `aud_persona_insert` AFTER INSERT ON `persona` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('persona', 'INSERT', NEW.id_persona, NULL, NULL,
            CONCAT('nombre:', NEW.nombre, ' ', NEW.apellido, ' | cedula:', NEW.cedula),
            NOW(), CONCAT('Nueva persona registrada: ', NEW.nombre, ' ', NEW.apellido, ' — C.I.: ', NEW.cedula));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_persona_update`;
DELIMITER //
CREATE TRIGGER `aud_persona_update` AFTER UPDATE ON `persona` FOR EACH ROW
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

DROP TRIGGER IF EXISTS `aud_persona_delete`;
DELIMITER //
CREATE TRIGGER `aud_persona_delete` AFTER DELETE ON `persona` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('persona', 'DELETE', OLD.id_persona, NULL,
            CONCAT(OLD.nombre, ' ', OLD.apellido, ' | cedula:', OLD.cedula), NULL,
            NOW(), CONCAT('Persona eliminada: ', OLD.nombre, ' ', OLD.apellido));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_solicitud_insert`;
DELIMITER //
CREATE TRIGGER `aud_solicitud_insert` AFTER INSERT ON `solicitud` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('solicitud', 'INSERT', NEW.id_solicitud, NULL, NULL,
            CONCAT('fecha:', NEW.fecha, ' | horario:', NEW.hora_inicio, '-', NEW.hora_fin, ' | estado:', NEW.estado),
            NOW(), CONCAT('Nueva solicitud #', NEW.id_solicitud, ' creada con estado ', NEW.estado));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_solicitud_update`;
DELIMITER //
CREATE TRIGGER `aud_solicitud_update` AFTER UPDATE ON `solicitud` FOR EACH ROW
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

DROP TRIGGER IF EXISTS `aud_solicitud_delete`;
DELIMITER //
CREATE TRIGGER `aud_solicitud_delete` AFTER DELETE ON `solicitud` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('solicitud', 'DELETE', OLD.id_solicitud, NULL,
            CONCAT('fecha:', OLD.fecha, ' | estado:', OLD.estado), NULL,
            NOW(), CONCAT('Solicitud #', OLD.id_solicitud, ' eliminada (estado previo: ', OLD.estado, ')'));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_tecnicos_insert`;
DELIMITER //
CREATE TRIGGER `aud_tecnicos_insert` AFTER INSERT ON `tecnicos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('tecnicos', 'INSERT', NEW.id_tecnicos, NULL, NULL,
            CONCAT('persona_id:', NEW.id_persona, ' | especialidad:', NEW.especialidad),
            NOW(), CONCAT('Nuevo técnico registrado — Especialidad: ', NEW.especialidad));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_tecnicos_delete`;
DELIMITER //
CREATE TRIGGER `aud_tecnicos_delete` AFTER DELETE ON `tecnicos` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('tecnicos', 'DELETE', OLD.id_tecnicos, NULL,
            CONCAT('especialidad:', OLD.especialidad), NULL,
            NOW(), CONCAT('Técnico #', OLD.id_tecnicos, ' eliminado'));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_usuario_insert`;
DELIMITER //
CREATE TRIGGER `aud_usuario_insert` AFTER INSERT ON `usuario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('usuario', 'INSERT', NEW.id_usuario, NULL, NULL,
            CONCAT('usuario:', NEW.nombre_usuario, ' | rol:', NEW.roles, ' | estado:', NEW.estado),
            NOW(), CONCAT('Nuevo usuario registrado: ', NEW.nombre_usuario, ' (', NEW.roles, ')'));
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `aud_usuario_update`;
DELIMITER //
CREATE TRIGGER `aud_usuario_update` AFTER UPDATE ON `usuario` FOR EACH ROW
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

DROP TRIGGER IF EXISTS `aud_usuario_delete`;
DELIMITER //
CREATE TRIGGER `aud_usuario_delete` AFTER DELETE ON `usuario` FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, operacion, id_registro, campo, valor_anterior, valor_nuevo, fecha_hora, descripcion)
    VALUES ('usuario', 'DELETE', OLD.id_usuario, NULL,
            CONCAT('usuario:', OLD.nombre_usuario, ' | rol:', OLD.roles), NULL,
            NOW(), CONCAT('Usuario eliminado: ', OLD.nombre_usuario));
END//
DELIMITER ;

-- =====================================================================
-- 5. VISTAS
-- =====================================================================

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_completa` AS
SELECT
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
LEFT JOIN persona p ON u.id_persona = p.id_persona;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_inventario` AS
SELECT
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
WHERE a.tabla = 'inventario';

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_resumen` AS
SELECT
    tabla,
    operacion,
    COUNT(*)                        AS total_operaciones,
    MIN(fecha_hora)                 AS primera_operacion,
    MAX(fecha_hora)                 AS ultima_operacion,
    DATE(MAX(fecha_hora))           AS ultimo_dia
FROM auditoria
GROUP BY tabla, operacion;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_solicitudes` AS
SELECT
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
WHERE a.tabla = 'solicitud';

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_auditoria_usuarios` AS
SELECT
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
WHERE a.tabla = 'usuario';

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_indicadores_mantenimiento_disponibilidad` AS
SELECT 'Total de equipos' AS indicador, COUNT(*) AS valor FROM equipos
UNION ALL
SELECT 'Equipos Operativos', COUNT(*) FROM inventario WHERE estado = 'Operativo'
UNION ALL
SELECT 'Equipos en mantenimiento', COUNT(*) FROM inventario WHERE estado = 'En Reparacion'
UNION ALL
SELECT 'Equipos Dañados', COUNT(*) FROM inventario WHERE estado = 'Dañado'
UNION ALL
SELECT 'Mantenimientos realizados', COUNT(*) FROM mantenimiento
UNION ALL
SELECT 'Tasa de disponibilidad',
    ROUND((SELECT COUNT(*) FROM inventario WHERE estado = 'Operativo') * 100.0 /
          NULLIF((SELECT COUNT(*) FROM inventario), 0), 2)
UNION ALL
SELECT 'Solicitudes aprobadas', COUNT(*) FROM solicitud WHERE estado = 'Aprobado';

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_actividades_educativas` AS
SELECT
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
GROUP BY a.id_actividad;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_disponibilidad_equipos` AS
SELECT
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
        WHEN i.estado = 'Desincorporado' THEN 'Desincorporado'
    END AS disponibilidad,
    COUNT(DISTINCT s.id_solicitud) AS reservas_activas
FROM equipos eq
INNER JOIN inventario i ON i.id_equipos = eq.id_equipos
LEFT JOIN ubicacion_fisica uf ON i.id_ubicacion_fisica = uf.id_ubicacion_fisica
LEFT JOIN detalle_solicitud ds ON ds.id_inventario = i.id_inventario
LEFT JOIN solicitud s ON s.id_solicitud = ds.id_solicitud
    AND s.estado IN ('Aprobado', 'Pendiente')
GROUP BY eq.id_equipos;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_equipos` AS
SELECT
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
GROUP BY eq.id_equipos;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_fallas_tecnicas` AS
SELECT
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
INNER JOIN persona p ON t.id_persona = p.id_persona;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_mantenimiento_equipos` AS
SELECT
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
GROUP BY eq.id_equipos;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_maquinas_mas_usadas` AS
SELECT
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
LEFT JOIN solicitud s ON s.id_solicitud = ds.id_solicitud AND s.estado = 'Completado'
GROUP BY eq.id_equipos;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_notificaciones` AS
SELECT
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
INNER JOIN persona p ON u.id_persona = p.id_persona;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_reservas_equipos` AS
SELECT
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
LEFT JOIN equipos eq ON i.id_equipos = eq.id_equipos;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_reservas_espacios` AS
SELECT
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
GROUP BY s.id_solicitud;

CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vista_reporte_usuarios` AS
SELECT
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
    (SELECT COUNT(*) FROM solicitud s WHERE s.id_usuario = u.id_usuario) AS total_solicitudes,
    (SELECT COUNT(*) FROM notificacion n WHERE n.id_usuario = u.id_usuario) AS total_notificaciones
FROM usuario u
INNER JOIN persona p ON u.id_persona = p.id_persona
LEFT JOIN estudiante e ON e.id_persona = p.id_persona
LEFT JOIN tecnicos t ON t.id_persona = p.id_persona;

-- =====================================================================
-- 6. RESTAURAR VARIABLES
-- =====================================================================
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;