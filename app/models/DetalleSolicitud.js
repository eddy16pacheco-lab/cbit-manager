const db = require('../../config/database');
class DetalleSolicitud {
    // Equipos disponibles en la fecha/hora solicitada
    static async equiposDisponibles(fecha, hora_inicio, hora_fin) {
        const [rows] = await db.execute(
            `SELECT i.id_inventario, i.serial, i.estado,
                    e.nombre AS equipo_nombre, m.nombre AS modelo_nombre,
                    c.nombre AS categoria, ma.nombre AS marca,
                    u.nombre AS ubicacion
             FROM inventario i
             LEFT JOIN equipos e ON i.id_equipos = e.id_equipos
             LEFT JOIN modelo m ON e.id_modelo = m.id_modelo
             LEFT JOIN categoria c ON e.id_categoria = c.id_categoria
             LEFT JOIN marca ma ON e.id_marca = ma.id_marca
             LEFT JOIN ubicacion_fisica u ON i.id_ubicacion_fisica = u.id_ubicacion_fisica
             WHERE i.estado = 'Operativo'
             AND i.id_inventario NOT IN (
                 SELECT ds.id_inventario FROM detalle_solicitud ds
                 JOIN solicitud s ON ds.id_solicitud = s.id_solicitud
                 WHERE s.fecha = ? AND s.estado IN ('Aprobado','Pendiente')
                 AND s.hora_inicio < ? AND s.hora_fin > ?
             )
             ORDER BY e.nombre, i.serial`,
            [fecha, hora_fin, hora_inicio]
        );
        return rows;
    }
    static async create(id_solicitud, id_inventario) {
        await db.execute(
            'INSERT INTO detalle_solicitud (id_solicitud, id_inventario) VALUES (?,?)',
            [id_solicitud, id_inventario]
        );
    }
    static async createBulk(id_solicitud, ids_inventario) {
        if (!ids_inventario || !ids_inventario.length) return;
        for (const id of ids_inventario) {
            await DetalleSolicitud.create(id_solicitud, id);
        }
    }
    static async findBySolicitud(id_solicitud) {
        const [rows] = await db.execute(
            `SELECT ds.*, i.serial, e.nombre AS equipo_nombre, m.nombre AS modelo_nombre
             FROM detalle_solicitud ds
             JOIN inventario i ON ds.id_inventario = i.id_inventario
             JOIN equipos e ON i.id_equipos = e.id_equipos
             LEFT JOIN modelo m ON e.id_modelo = m.id_modelo
             WHERE ds.id_solicitud = ?`,
            [id_solicitud]
        );
        return rows;
    }
    static async deleteBySolicitud(id_solicitud) {
        await db.execute('DELETE FROM detalle_solicitud WHERE id_solicitud=?', [id_solicitud]);
    }
    // Reporte de equipos más usados
    static async maquinasMasUsadas() {
        const [rows] = await db.execute(
            `SELECT e.nombre AS equipo_nombre, ma.nombre AS marca,
                    m.nombre AS modelo_nombre, COUNT(ds.id_detalle_solicitud) AS total_usos
             FROM detalle_solicitud ds
             JOIN inventario i ON ds.id_inventario = i.id_inventario
             JOIN equipos e ON i.id_equipos = e.id_equipos
             LEFT JOIN modelo m ON e.id_modelo = m.id_modelo
             LEFT JOIN marca ma ON e.id_marca = ma.id_marca
             GROUP BY e.id_equipos
             ORDER BY total_usos DESC LIMIT 20`
        );
        return rows;
    }
    // Reporte reservas de equipos
    static async reservasEquipos() {
        const [rows] = await db.execute(
            `SELECT s.id_solicitud, i.serial, e.nombre AS equipo_nombre,
                    m.nombre AS modelo_nombre, s.fecha,
                    s.hora_inicio, s.hora_fin, s.estado,
                    p.nombre AS docente_nombre, p.apellido AS docente_apellido,
                    a.nombre AS actividad_nombre
             FROM detalle_solicitud ds
             JOIN inventario i ON ds.id_inventario = i.id_inventario
             JOIN equipos e ON i.id_equipos = e.id_equipos
             LEFT JOIN modelo m ON e.id_modelo = m.id_modelo
             JOIN solicitud s ON ds.id_solicitud = s.id_solicitud
             LEFT JOIN actividad a ON s.id_actividad = a.id_actividad
             LEFT JOIN usuario u ON s.id_usuario = u.id_usuario
             LEFT JOIN persona p ON u.id_persona = p.id_persona
             ORDER BY s.fecha DESC, s.hora_inicio`
        );
        return rows;
    }
}
module.exports = DetalleSolicitud;
