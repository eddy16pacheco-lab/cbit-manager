const db = require('../../config/database');
class Persona {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM persona ORDER BY id_persona');
        return rows;
    }
    static async create({ nombre, apellido, cedula, telefono }) {
        const [result] = await db.execute(
            'INSERT INTO persona (nombre, apellido, cedula, telefono) VALUES (?,?,?,?)',
            [nombre, apellido, cedula, telefono]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM persona WHERE id_persona=?', [id]);
    }
}
module.exports = Persona;

Persona.update = async function(id, { nombre, apellido, cedula, telefono }) {
    await db.execute(
        'UPDATE persona SET nombre=?, apellido=?, cedula=?, telefono=? WHERE id_persona=?',
        [nombre, apellido, cedula, telefono, id]
    );
};
