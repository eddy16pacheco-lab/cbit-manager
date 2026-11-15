const db = require('../../config/database');
class Actividad {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM actividad ORDER BY id_actividad');
        return rows;
    }
    static async create({ nombre, descripcion_actividad }) {
        const [result] = await db.execute(
            'INSERT INTO actividad (nombre, descripcion_actividad) VALUES (?,?)',
            [nombre, descripcion_actividad]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute('DELETE FROM actividad WHERE id_actividad=?', [id]);
    }
}
module.exports = Actividad;

Actividad.update = async function(id, { nombre, descripcion_actividad }) {
    await db.execute(
        'UPDATE actividad SET nombre=?, descripcion_actividad=? WHERE id_actividad=?',
        [nombre, descripcion_actividad, id]
    );
};
