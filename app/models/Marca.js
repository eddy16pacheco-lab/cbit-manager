const db = require('../../config/database');
class Marca {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM marca ORDER BY id_marca');
        return rows;
    }
    static async create({ nombre }) {
        const [result] = await db.execute('INSERT INTO marca (nombre) VALUES (?)', [nombre]);
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM marca WHERE id_marca=?', [id]);
    }
}
module.exports = Marca;

Marca.update = async function(id, { nombre }) {
    await db.execute('UPDATE marca SET nombre=? WHERE id_marca=?', [nombre, id]);
};
