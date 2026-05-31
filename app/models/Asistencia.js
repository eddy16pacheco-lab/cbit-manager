const db = require('../../config/database');
// La tabla 'asistencia' de la BD almacena presencia de estudiante en solicitud.
// El módulo de "ingresos al CBIT" se gestiona como registro de persona visitante
// usando los datos de persona. Aquí manejamos ambos casos.
class Asistencia {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT a.*, e.seccion, e.año,
                    p.nombre, p.apellido, p.cedula,
                    s.fecha, s.hora_inicio
             FROM asistencia a
             LEFT JOIN estudiante e ON a.id_estudiante=e.id_estudiante
             LEFT JOIN persona p ON e.id_persona=p.id_persona
             LEFT JOIN solicitud s ON a.id_solicitud=s.id_solicitud
             ORDER BY a.id_asistencia DESC`
        );
        return rows;
    }
    static async create({ id_estudiante, id_solicitud, asistio }) {
        const [result] = await db.execute(
            'INSERT INTO asistencia (id_estudiante, id_solicitud, asistio) VALUES (?,?,?)',
            [id_estudiante, id_solicitud, asistio]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM asistencia WHERE id_asistencia=?', [id]);
    }
}
module.exports = Asistencia;
