const db = require('../../config/database');
class Espacio {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM espacio ORDER BY id_espacio');
        return rows;
    }
    static async create({ nombre, capacidad }) {
        const [result] = await db.execute(
            'INSERT INTO espacio (nombre, capacidad) VALUES (?,?)',
            [nombre, capacidad]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM espacio WHERE id_espacio=?', [id]);
    }
}
module.exports = Espacio;

Espacio.update = async function(id, { nombre, capacidad }) {
    await db.execute('UPDATE espacio SET nombre=?, capacidad=? WHERE id_espacio=?', [nombre, capacidad, id]);
};
