const db = require('../../config/database');
class Estudiante {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT e.*, p.nombre, p.apellido, p.cedula, p.telefono
             FROM estudiante e JOIN persona p ON e.id_persona=p.id_persona
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
}
module.exports = Estudiante;
