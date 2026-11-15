const HistorialActividad = require('../models/HistorialActividad');

/**
 * Registra una entrada en el historial de actividades del sistema.
 * Nunca debe interrumpir el flujo principal de la petición: si falla,
 * solo se registra en consola.
 */
async function registrar({ id_usuario, usuario, accion, modulo, detalle, ip }) {
    try {
        await HistorialActividad.registrar({ id_usuario, usuario, accion, modulo, detalle, ip });
    } catch (e) {
        console.error('⚠️  No se pudo registrar en el historial de actividades:', e.message);
    }
}

module.exports = { registrar };
