CREATE DATABASE IF NOT EXISTS `db_cbit_manager_definitivo` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `db_cbit_manager_definitivo`;

CREATE TABLE IF NOT EXISTS `actividad` (
  `id_actividad` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion_actividad` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_actividad`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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

CREATE TABLE IF NOT EXISTS `categoria` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `detalle_solicitud` (
  `id_detalle_solicitud` int(11) NOT NULL AUTO_INCREMENT,
  `id_solicitud` int(11) DEFAULT NULL,
  `id_inventario` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_detalle_solicitud`),
  KEY `puede_tener` (`id_solicitud`),
  KEY `puede_tener_` (`id_inventario`),
  CONSTRAINT `puede_tener` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `puede_tener_` FOREIGN KEY (`id_inventario`) REFERENCES `inventario` (`id_inventario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `espacio` (
  `id_espacio` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `capacidad` int(11) NOT NULL,
  PRIMARY KEY (`id_espacio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `estudiante` (
  `id_estudiante` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) DEFAULT NULL,
  `seccion` enum('A','B','C','D','U') DEFAULT NULL,
  `año` enum('1er año','2er año','3er año','4er año','5er año','6er año') NOT NULL,
  PRIMARY KEY (`id_estudiante`),
  KEY `es` (`id_persona`),
  CONSTRAINT `es` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `horario` (
  `id_horario` int(11) NOT NULL AUTO_INCREMENT,
  `dias` enum('Lunes','Martes','Miercoles','Jueves','Viernes') NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_final` time NOT NULL,
  PRIMARY KEY (`id_horario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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

CREATE TABLE IF NOT EXISTS `mantenimiento` (
  `id_mantenimiento` int(11) NOT NULL AUTO_INCREMENT,
  `id_tecnicos` int(11) DEFAULT NULL,
  `fecha_reporte` datetime NOT NULL,
  `nivel_prioridad` enum('Alta','Media','Baja') NOT NULL,
  PRIMARY KEY (`id_mantenimiento`),
  KEY `realiza_` (`id_tecnicos`),
  CONSTRAINT `realiza_` FOREIGN KEY (`id_tecnicos`) REFERENCES `tecnicos` (`id_tecnicos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `marca` (
  `id_marca` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`id_marca`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `modelo` (
  `id_modelo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`id_modelo`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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

CREATE TABLE IF NOT EXISTS `persona` (
  `id_persona` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) DEFAULT NULL,
  `cedula` varchar(30) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `cedula` (`cedula`),
  UNIQUE KEY `telefono` (`telefono`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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


CREATE TABLE IF NOT EXISTS `tecnicos` (
  `id_tecnicos` int(11) NOT NULL AUTO_INCREMENT,
  `especialidad` enum('Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','otros') NOT NULL,
  `id_persona` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_tecnicos`),
  KEY `puede_ser` (`id_persona`),
  CONSTRAINT `puede_ser` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `ubicacion_fisica` (
  `id_ubicacion_fisica` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) NOT NULL,
  PRIMARY KEY (`id_ubicacion_fisica`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


