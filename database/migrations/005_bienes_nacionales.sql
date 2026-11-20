-- 005: Código de Bienes Nacionales y Desincorporación de equipos
--
--  * codigo_bien_nacional: identificador oficial de cada unidad (lo asigna Bienes
--    Nacionales; se registra manualmente). Reemplaza al antiguo "#id" autoincremental
--    en la interfaz. id_inventario se conserva como llave interna (lo usan
--    detalle_solicitud y la auditoría) y ya no se muestra.
--  * Desincorporado: nuevo estado que sustituye a la eliminación del registro.
--    Se conserva el equipo con la fecha y el motivo de la desincorporación.
--
-- Las unidades existentes quedan con codigo_bien_nacional = NULL ("Sin código") hasta
-- que se edite cada una; UNIQUE admite varios NULL.

ALTER TABLE inventario
    ADD COLUMN codigo_bien_nacional   VARCHAR(30)  NULL AFTER id_inventario,
    ADD COLUMN fecha_desincorporacion DATE         NULL,
    ADD COLUMN motivo_desincorporacion VARCHAR(255) NULL,
    ADD UNIQUE KEY uq_inventario_codigo_bien_nacional (codigo_bien_nacional),
    MODIFY COLUMN estado ENUM('Operativo','No operativo','En Reparacion','Dañado','Desincorporado') NOT NULL;
