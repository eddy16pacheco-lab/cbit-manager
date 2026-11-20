-- 006: Reglas de validación de cédula y teléfono (Venezuela) a nivel de base de datos
--
--  * Cédula:   prefijo V/E + guion + 7 u 8 dígitos        (antes: 6 a 8 dígitos)
--  * Teléfono: 11 dígitos, solo números, operadora 0412 | 0414 | 0416 | 0422 | 0424 | 0426
--              (antes se aceptaba también 0212 y no se admitía 0422)
--
-- PASO 1 (recomendado): ver si hay registros que NO cumplen las nuevas reglas.
-- Si esta consulta devuelve filas, corríjalas (desde el módulo Personas) ANTES del paso 3,
-- de lo contrario el ALTER fallará y no se aplicará ningún cambio.
--
--   SELECT id_persona, nombre, apellido, cedula, telefono FROM persona
--   WHERE NOT (REGEXP_REPLACE(cedula,   '[^0-9]', '') REGEXP '^[0-9]{7,8}$')
--      OR NOT (REGEXP_REPLACE(telefono, '[^0-9]', '') REGEXP '^0(412|414|416|422|424|426)[0-9]{7}$');

-- PASO 2: normaliza el formato de los datos existentes
--   * teléfono: solo dígitos (quita guiones, espacios y paréntesis)
--   * cédula:   "V12345678" / "v-12345678" -> "V-12345678"
UPDATE persona SET telefono = REGEXP_REPLACE(telefono, '[^0-9]', '')
WHERE telefono REGEXP '[^0-9]';

UPDATE persona SET cedula = CONCAT(UPPER(LEFT(cedula, 1)), '-', SUBSTRING(REGEXP_REPLACE(cedula, '-', ''), 2))
WHERE cedula REGEXP '^[VEve]-?[0-9]+$' AND cedula NOT REGEXP '^[VE]-[0-9]+$';

-- PASO 3: reemplaza las restricciones (un solo ALTER: se aplica completo o no se aplica)
ALTER TABLE persona
    DROP CONSTRAINT IF EXISTS chk_cedula,
    DROP CONSTRAINT IF EXISTS chk_telefono,
    ADD CONSTRAINT chk_cedula   CHECK (cedula   REGEXP '^[VE]-[0-9]{7,8}$'),
    ADD CONSTRAINT chk_telefono CHECK (telefono REGEXP '^0(412|414|416|422|424|426)[0-9]{7}$');
