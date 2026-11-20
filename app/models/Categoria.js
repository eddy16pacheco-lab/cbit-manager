const db = require('../../config/database');
class Categoria {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM categoria ORDER BY id_categoria');
        return rows;
    }
    static async create({ nombre }) {
        const [result] = await db.execute('INSERT INTO categoria (nombre) VALUES (?)', [nombre]);
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM categoria WHERE id_categoria=?', [id]);
    }
}
module.exports = Categoria;

Categoria.update = async function(id, { nombre }) {
    await db.execute('UPDATE categoria SET nombre=? WHERE id_categoria=?', [nombre, id]);
};
