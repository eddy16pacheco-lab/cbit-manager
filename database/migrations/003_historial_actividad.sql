-- ============================================================================
-- Migración 003: Historial de Actividades del Sistema (bitácora / auditoría)
-- Permite al Administrador ver quién hizo qué, cuándo y en qué módulo.
-- Ejecutar sobre la misma base de datos ya creada por 001_create_tables.sql
-- ============================================================================

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
