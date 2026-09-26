const db = require('../../config/database');
class Equipo {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT e.*, c.nombre AS categoria, m.nombre AS marca, mo.nombre AS modelo_nombre
             FROM equipos e
             LEFT JOIN categoria c ON e.id_categoria=c.id_categoria
             LEFT JOIN marca m ON e.id_marca=m.id_marca
             LEFT JOIN modelo mo ON e.id_modelo=mo.id_modelo
             ORDER BY e.id_equipos`
        );
        return rows;
    }
    static async create({ nombre, id_categoria, id_marca, id_modelo }) {
        const [result] = await db.execute(
            'INSERT INTO equipos (nombre, id_categoria, id_marca, id_modelo) VALUES (?,?,?,?)',
            [nombre, id_categoria, id_marca, id_modelo]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM equipos WHERE id_equipos=?', [id]);
    }
}
module.exports = Equipo;

Equipo.update = async function(id, { nombre, id_categoria, id_marca, id_modelo }) {
    await db.execute(
        'UPDATE equipos SET nombre=?, id_categoria=?, id_marca=?, id_modelo=? WHERE id_equipos=?',
        [nombre, id_categoria, id_marca, id_modelo || null, id]
    );
};
