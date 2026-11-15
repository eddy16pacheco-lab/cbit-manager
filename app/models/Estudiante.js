const db = require('../../config/database');
class Estudiante {
    static async findAll() {
    const [rows] = await db.execute(
        `SELECT 
            e.id_estudiante,
            e.id_persona,
            e.seccion,
            e.año,
            p.nombre,
            p.apellido,
            p.cedula,
            p.telefono
         FROM estudiante e
         LEFT JOIN persona p ON e.id_persona = p.id_persona
         ORDER BY p.apellido, p.nombre`
    );
    return rows;
}
    static async create({ id_persona, seccion, año }) {
        const [result] = await db.execute(
            'INSERT INTO estudiante (id_persona, seccion, año) VALUES (?,?,?)',
            [id_persona, seccion, año]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM estudiante WHERE id_estudiante=?', [id]);
    }
    static async findByPersona(id_persona) {
        const [rows] = await db.execute('SELECT * FROM estudiante WHERE id_persona=?', [id_persona]);
        return rows[0] || null;
    }
}
module.exports = Estudiante;
