-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         12.1.2-MariaDB - MariaDB Server
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.11.0.7065
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

-- Volcando datos para la tabla db_cbit_2.alerta_prestamo: ~3 rows (aproximadamente)
INSERT INTO `alerta_prestamo` (`id_alerta`, `id_solicitud`, `id_usuario`, `tipo_alerta`, `mensaje`, `fecha_alerta`, `leida`) VALUES
	(1, 1, 2, 'Proximo a vencer', 'La solicitud #1 está próxima a vencer (2 días)', '2026-07-20 08:00:00', 'No'),
	(2, 4, 2, 'Devuelto', 'La solicitud #4 ha sido completada exitosamente', '2026-07-24 11:30:00', 'No'),
	(3, 3, 4, 'Vencido', 'La solicitud #3 ha vencido, favor devolver equipos', '2026-07-25 09:00:00', 'No');

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.asistencia: ~10 rows (aproximadamente)
INSERT INTO `asistencia` (`id_asistencia`, `id_estudiante`, `id_solicitud`, `asistio`) VALUES
	(1, 1, 1, 'Si'),
	(2, 2, 1, 'Si'),
	(3, 3, 1, 'No'),
	(4, 1, 4, 'Si'),
	(5, 3, 4, 'Si'),
	(6, 4, 4, 'Si'),
	(7, 2, 6, 'Si'),
	(8, 3, 6, 'Si'),
	(9, 1, 10, 'Si'),
	(10, 4, 10, 'No');

-- Volcando estructura para tabla db_cbit_2.categoria
CREATE TABLE IF NOT EXISTS `categoria` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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
	(10, 'Seguridad', 'Equipos de seguridad y vigilancia');

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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.detalle_solicitud: ~12 rows (aproximadamente)
INSERT INTO `detalle_solicitud` (`id_detalle_solicitud`, `id_solicitud`, `id_inventario`) VALUES
	(1, 1, 1),
	(2, 1, 3),
	(3, 2, 5),
	(4, 2, 6),
	(5, 3, 7),
	(6, 4, 2),
	(7, 4, 3),
	(8, 6, 11),
	(9, 7, 9),
	(10, 8, 1),
	(11, 8, 5),
	(12, 10, 12);

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.equipos: ~10 rows (aproximadamente)
INSERT INTO `equipos` (`id_equipos`, `id_categoria`, `id_modelo`, `id_marca`, `nombre`) VALUES
	(1, 1, 1, 1, 'Laptop HP EliteBook 840'),
	(2, 1, 2, 2, 'Laptop Dell Latitude 7420'),
	(3, 1, 3, 3, 'Laptop Lenovo ThinkPad T14'),
	(4, 1, 4, 4, 'MacBook Air M2'),
	(5, 2, 6, 6, 'Proyector Epson PowerLite'),
	(6, 3, 7, 7, 'Impresora Canon Multifuncional'),
	(7, 4, 8, 8, 'Switch Cisco Catalyst'),
	(8, 5, 5, 5, 'Tablet Samsung Galaxy Tab S7'),
	(9, 1, 10, 10, 'Microsoft Surface Pro 8'),
	(10, 6, 9, 9, 'Monitor Sony Bravia Pro');

-- Volcando estructura para tabla db_cbit_2.espacio
CREATE TABLE IF NOT EXISTS `espacio` (
  `id_espacio` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `capacidad` int(11) NOT NULL,
  PRIMARY KEY (`id_espacio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.espacio: ~4 rows (aproximadamente)
INSERT INTO `espacio` (`id_espacio`, `nombre`, `capacidad`) VALUES
	(1, 'Auditorio Principal', 200),
	(2, 'Laboratorio de Cómputo 1', 30),
	(3, 'Aula Magna', 80),
	(4, 'Sala de Conferencias', 50);

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
	(1, 1, 1, 'HP-ELITE-001', 'Operativo'),
	(2, 1, 2, 'HP-ELITE-002', 'Operativo'),
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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
	(10, 'Microsoft', 'Microsoft Corporation');

-- Volcando estructura para tabla db_cbit_2.modelo
CREATE TABLE IF NOT EXISTS `modelo` (
  `id_modelo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_modelo`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.persona: ~10 rows (aproximadamente)
INSERT INTO `persona` (`id_persona`, `nombre`, `apellido`, `cedula`, `telefono`) VALUES
	(1, 'Eddy', 'Pacheco', '31394074', '04129574257'),
	(2, 'Ana', 'Ramírez', '7654321', '555-0102'),
	(3, 'Luis', 'Torres', '11223344', '555-0103'),
	(4, 'María', 'Flores', '44332211', '555-0104'),
	(5, 'Jorge', 'Díaz', '556677', '555-0105'),
	(6, 'Laura', 'García', '776655', '555-0106'),
	(7, 'Roberto', 'Sánchez', '7766', '555-0107'),
	(8, 'Patricia', 'López', '3344566', '555-0108'),
	(9, 'Miguel', 'Hernández', '66778899', '555-0109'),
	(10, 'Carmen', 'Jiménez', '22334455', '555-0110');

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.solicitud: ~10 rows (aproximadamente)
INSERT INTO `solicitud` (`id_solicitud`, `id_espacio`, `id_actividad`, `id_usuario`, `fecha`, `hora_inicio`, `hora_fin`, `estado`, `descripcion`) VALUES
	(1, 2, 1, 2, '2026-07-22', '08:00:00', '10:00:00', 'Aprobado', 'Clase de Programación para estudiantes'),
	(2, 2, 2, 3, '2026-07-22', '10:30:00', '12:30:00', 'Pendiente', 'Taller de Robótica'),
	(3, 1, 3, 4, '2026-07-23', '14:00:00', '16:00:00', 'Aprobado', 'Presentación de proyectos finales'),
	(4, 3, 4, 2, '2026-07-24', '09:00:00', '11:00:00', 'Completado', 'Examen práctico de programación'),
	(5, 4, 5, 6, '2026-07-24', '13:00:00', '15:00:00', 'Cancelado', 'Prácticas de laboratorio - cancelado por mantenimiento'),
	(6, 2, 6, 8, '2026-07-25', '08:30:00', '10:30:00', 'Aprobado', 'Clase de inglés técnico'),
	(7, 1, 7, 3, '2026-07-25', '11:00:00', '13:00:00', 'Pendiente', 'Taller de diseño gráfico'),
	(8, 3, 8, 4, '2026-07-26', '10:00:00', '12:00:00', 'Aprobado', 'Seminario de investigación'),
	(9, 4, 9, 2, '2026-07-26', '14:30:00', '16:30:00', 'Aprobado', 'Clase de matemáticas aplicadas'),
	(10, 2, 10, 8, '2026-07-27', '09:00:00', '11:00:00', 'Completado', 'Taller de electrónica básica');

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

-- Volcando datos para la tabla db_cbit_2.solicitud_horario: ~4 rows (aproximadamente)
INSERT INTO `solicitud_horario` (`id_solicitud_horario`, `codigo_horario`, `id_solicitud`, `id_horario`) VALUES
	(1, 'HOR-001-2026', 1, 1),
	(2, 'HOR-002-2026', 2, 2),
	(3, 'HOR-003-2026', 3, 3),
	(4, 'HOR-004-2026', 4, 4);

-- Volcando estructura para tabla db_cbit_2.tecnicos
CREATE TABLE IF NOT EXISTS `tecnicos` (
  `id_tecnicos` int(11) NOT NULL AUTO_INCREMENT,
  `especialidad` enum('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_tecnicos`),
  KEY `puede_ser` (`id_persona`),
  CONSTRAINT `puede_ser` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.tecnicos: ~3 rows (aproximadamente)
INSERT INTO `tecnicos` (`id_tecnicos`, `especialidad`, `id_persona`) VALUES
	(1, 'Hardware', 1),
	(2, 'Redes', 7),
	(3, 'Soporte técnico', 10);

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
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  UNIQUE KEY `correo` (`correo`),
  KEY `tiene_un` (`id_persona`),
  CONSTRAINT `tiene_un` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla db_cbit_2.usuario: ~10 rows (aproximadamente)
INSERT INTO `usuario` (`id_usuario`, `id_persona`, `nombre_usuario`, `contrasena_usuario`, `correo`, `estado`, `roles`) VALUES
	(1, 1, 'admin', 'admin123', 'eddy.pacheco@gmail.com', 'Activo', 'Administrador'),
	(2, 2, 'docente', 'docente123', 'ana.ramirez@instituto.edu', 'Activo', 'Docente'),
	(3, 3, 'ltorres', 'hash345678', 'luis.torres@instituto.edu', 'Activo', 'Docente'),
	(4, 4, 'mflores', 'hash456789', 'maria.flores@instituto.edu', 'Activo', 'Docente'),
	(5, 5, 'jdiaz', 'hash567890', 'jorge.diaz@instituto.edu', 'Inactivo', 'Docente'),
	(6, 6, 'lgarcia', 'hash678901', 'laura.garcia@instituto.edu', 'Activo', 'Docente'),
	(7, 7, 'rsanchez', 'hash789012', 'roberto.sanchez@instituto.edu', 'Activo', 'Administrador'),
	(8, 8, 'plopez', 'hash890123', 'patricia.lopez@instituto.edu', 'Activo', 'Docente'),
	(9, 9, 'mhernandez', 'hash901234', 'miguel.hernandez@instituto.edu', 'Bloqueado', 'Docente'),
	(10, 10, 'cjimenez', 'hash012345', 'carmen.jimenez@instituto.edu', 'Activo', 'Docente');

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
