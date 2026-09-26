const db = require('../../config/database');
class Tecnico {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT t.*, p.nombre, p.apellido, p.cedula, p.telefono
             FROM tecnicos t JOIN persona p ON t.id_persona=p.id_persona
             ORDER BY t.id_tecnicos`
        );
        return rows;
    }
    static async create({ id_persona, especialidad }) {
        const [result] = await db.execute(
            'INSERT INTO tecnicos (id_persona, especialidad) VALUES (?,?)',
            [id_persona, especialidad]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM tecnicos WHERE id_tecnicos=?', [id]);
    }
}
module.exports = Tecnico;

Tecnico.update = async function(id, { especialidad }) {
    await db.execute('UPDATE tecnicos SET especialidad=? WHERE id_tecnicos=?', [especialidad, id]);
};
