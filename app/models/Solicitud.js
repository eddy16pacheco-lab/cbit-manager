const db = require('../../config/database');
class Solicitud {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT s.*,
                    e.nombre AS espacio_nombre,
                    a.nombre AS actividad_nombre,
                    p.nombre AS persona_nombre,
                    p.apellido AS persona_apellido,
                    p.cedula AS persona_cedula,
                    u.roles AS docente_rol,
                    (SELECT COUNT(*) FROM detalle_solicitud ds WHERE ds.id_solicitud=s.id_solicitud) AS total_equipos
             FROM solicitud s
             LEFT JOIN espacio e ON s.id_espacio=e.id_espacio
             LEFT JOIN actividad a ON s.id_actividad=a.id_actividad
             LEFT JOIN usuario u ON s.id_usuario=u.id_usuario
             LEFT JOIN persona p ON u.id_persona=p.id_persona
             ORDER BY s.fecha DESC, s.hora_inicio`
        );
        return rows;
    }
    static async findById(id) {
        const [rows] = await db.execute(
            `SELECT s.*, e.nombre AS espacio_nombre, a.nombre AS actividad_nombre,
                    p.nombre AS persona_nombre, p.apellido AS persona_apellido,
                    p.cedula AS persona_cedula
             FROM solicitud s
             LEFT JOIN espacio e ON s.id_espacio=e.id_espacio
             LEFT JOIN actividad a ON s.id_actividad=a.id_actividad
             LEFT JOIN usuario u ON s.id_usuario=u.id_usuario
             LEFT JOIN persona p ON u.id_persona=p.id_persona
             WHERE s.id_solicitud=?`, [id]
        );
        return rows[0] || null;
    }
    static async create({ id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, descripcion, estado = 'Pendiente' }) {
        const [result] = await db.execute(
            `INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
             VALUES (?,?,?,?,?,?,?,?)`,
            [id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion || '']
        );
        return result.insertId;
    }
    static async updateEstado(id, estado) {
        await db.execute('UPDATE solicitud SET estado=? WHERE id_solicitud=?', [estado, id]);
    }
    static async update(id, { id_espacio, id_actividad, fecha, hora_inicio, hora_fin, descripcion }) {
        await db.execute(
            'UPDATE solicitud SET id_espacio=?, id_actividad=?, fecha=?, hora_inicio=?, hora_fin=?, descripcion=? WHERE id_solicitud=?',
            [id_espacio, id_actividad, fecha, hora_inicio, hora_fin, descripcion, id]
        );
    }
    static async cancelar(id) {
        await db.execute("UPDATE solicitud SET estado='Cancelado' WHERE id_solicitud=?", [id]);
    }
    static async delete(id) {
        await db.execute('DELETE FROM solicitud WHERE id_solicitud=?', [id]);
    }
    static async checkDisponibilidad(id_espacio, fecha, hora_inicio, hora_fin, excluir_id = 0) {
        const [rows] = await db.execute(
            `SELECT id_solicitud FROM solicitud
             WHERE id_espacio=? AND fecha=? AND estado='Aprobado' AND id_solicitud != ?
             AND (hora_inicio < ? AND hora_fin > ?)`,
            [id_espacio, fecha, excluir_id, hora_fin, hora_inicio]
        );
        return rows.length === 0;
    }
    // Para reportes
    static async reservasEspacios() {
        const [rows] = await db.execute(
            `SELECT s.id_solicitud, e.nombre AS espacio, a.nombre AS actividad,
                    p.nombre AS docente_nombre, p.apellido AS docente_apellido,
                    s.fecha, s.hora_inicio, s.hora_fin, s.estado, s.descripcion
             FROM solicitud s
             LEFT JOIN espacio e ON s.id_espacio=e.id_espacio
             LEFT JOIN actividad a ON s.id_actividad=a.id_actividad
             LEFT JOIN usuario u ON s.id_usuario=u.id_usuario
             LEFT JOIN persona p ON u.id_persona=p.id_persona
             ORDER BY s.fecha DESC`
        );
        return rows;
    }
}
module.exports = Solicitud;
