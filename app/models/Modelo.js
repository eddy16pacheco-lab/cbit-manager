const db = require('../../config/database');
class Modelo {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM modelo ORDER BY id_modelo');
        return rows;
    }
    static async create({ nombre, descripcion }) {
        const [result] = await db.execute(
            'INSERT INTO modelo (nombre, descripcion) VALUES (?,?)',
            [nombre, descripcion || null]
        );
        return result.insertId;
    }
    static async update(id, { nombre, descripcion }) {
        await db.execute(
            'UPDATE modelo SET nombre=?, descripcion=? WHERE id_modelo=?',
            [nombre, descripcion || null, id]
        );
    }
    static async delete(id) {
        await db.execute('DELETE FROM modelo WHERE id_modelo=?', [id]);
    }
    static async findByNombre(nombre, excluirId = 0) {
        const [rows] = await db.execute(
            'SELECT * FROM modelo WHERE nombre=? AND id_modelo != ?',
            [nombre, excluirId]
        );
        return rows[0] || null;
    }
}
module.exports = Modelo;
