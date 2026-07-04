-- RF-57: tabla para histórico de reportes programados
-- (usa la tabla notificacion existente con tipo='reporte')

-- RF-58: agregar constraints de formato en la BD
ALTER TABLE persona
    ADD CONSTRAINT chk_cedula    CHECK (cedula REGEXP '^[VEve]-?[0-9]{6,8}$'),
    ADD CONSTRAINT chk_telefono  CHECK (telefono REGEXP '^0(412|414|416|424|426|212)[0-9]{7}$');

-- RF-54: índice para cancelar reservas al inhabilitar usuario
CREATE INDEX IF NOT EXISTS idx_solicitud_usuario_estado
    ON solicitud(id_usuario, estado);

-- RF-55: índice para contar reservas activas por usuario
CREATE INDEX IF NOT EXISTS idx_solicitud_usuario_activo
    ON solicitud(id_usuario, estado);
