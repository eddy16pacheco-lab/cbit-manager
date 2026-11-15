-- ============================================================================
-- Migración 004: Recuperación de contraseña real (token + expiración)
-- Ejecutar sobre la misma base de datos ya creada por 001_create_tables.sql
-- ============================================================================

ALTER TABLE `usuario`
  ADD COLUMN `reset_token` VARCHAR(100) NULL DEFAULT NULL AFTER `roles`,
  ADD COLUMN `reset_expira` DATETIME NULL DEFAULT NULL AFTER `reset_token`;

ALTER TABLE `usuario` ADD KEY `idx_reset_token` (`reset_token`);
