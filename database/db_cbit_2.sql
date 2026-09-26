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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.categoria
CREATE TABLE IF NOT EXISTS `categoria` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.espacio
CREATE TABLE IF NOT EXISTS `espacio` (
  `id_espacio` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `capacidad` int(11) NOT NULL,
  PRIMARY KEY (`id_espacio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.estudiante
CREATE TABLE IF NOT EXISTS `estudiante` (
  `id_estudiante` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) DEFAULT NULL,
  `seccion` enum('A','B','C','D','U') DEFAULT NULL,
  `año` enum('1er año','2er año','3er año','4er año','5er año','6er año') NOT NULL,
  `estado` enum('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  PRIMARY KEY (`id_estudiante`),
  KEY `es` (`id_persona`),
  CONSTRAINT `es` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.horario
CREATE TABLE IF NOT EXISTS `horario` (
  `id_horario` int(11) NOT NULL AUTO_INCREMENT,
  `dias` enum('Lunes','Martes','Miercoles','Jueves','Viernes') NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_final` time NOT NULL,
  PRIMARY KEY (`id_horario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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

-- La exportación de datos fue deseleccionada.

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

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.marca
CREATE TABLE IF NOT EXISTS `marca` (
  `id_marca` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_marca`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.modelo
CREATE TABLE IF NOT EXISTS `modelo` (
  `id_modelo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_modelo`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.tecnicos
CREATE TABLE IF NOT EXISTS `tecnicos` (
  `id_tecnicos` int(11) NOT NULL AUTO_INCREMENT,
  `especialidad` enum('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_tecnicos`),
  KEY `puede_ser` (`id_persona`),
  CONSTRAINT `puede_ser` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla db_cbit_2.ubicacion_fisica
CREATE TABLE IF NOT EXISTS `ubicacion_fisica` (
  `id_ubicacion_fisica` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) NOT NULL,
  PRIMARY KEY (`id_ubicacion_fisica`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- La exportación de datos fue deseleccionada.

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
CREATE TABLE `vista_reporte_usuarios` (
	`id_usuario` INT(11) NOT NULL,
	`nombre` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`apellido` VARCHAR(1) NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`cedula` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`telefono` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`nombre_usuario` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`correo` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estado` ENUM('Activo','Inactivo','Bloqueado') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`roles` ENUM('Administrador','Docente') NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`tipo_usuario` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estudiante_seccion` ENUM('A','B','C','D','U') NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estudiante_año` ENUM('1er año','2er año','3er año','4er año','5er año','6er año') NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`estudiante_estado` ENUM('Activo','Inactivo') NULL COLLATE 'utf8mb4_uca1400_ai_ci',
	`tecnico_especialidad` ENUM('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NULL COLLATE 'utf8mb4_uca1400_ai_ci'
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
