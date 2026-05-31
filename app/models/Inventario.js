const db = require('../../config/database');
class Inventario {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT i.*, e.nombre AS equipo_nombre, m.nombre AS modelo_nombre,
                    u.nombre AS ubicacion_nombre
             FROM inventario i
             LEFT JOIN equipos e ON i.id_equipos=e.id_equipos
             LEFT JOIN modelo m ON e.id_modelo=m.id_modelo
             LEFT JOIN ubicacion_fisica u ON i.id_ubicacion_fisica=u.id_ubicacion_fisica
             ORDER BY i.id_inventario`
        );
        return rows;
    }
    static async create({ id_equipos, id_ubicacion_fisica, serial, estado }) {
        const [result] = await db.execute(
            'INSERT INTO inventario (id_equipos, id_ubicacion_fisica, serial, estado) VALUES (?,?,?,?)',
            [id_equipos, id_ubicacion_fisica, serial, estado]
        );
        return result.insertId;
    }
    static async updateEstado(id, estado) {
        await db.execute('UPDATE inventario SET estado=? WHERE id_inventario=?', [estado, id]);
    }
    static async delete(id) {
        await db.execute('DELETE FROM inventario WHERE id_inventario=?', [id]);
    }
}
module.exports = Inventario;

Inventario.update = async function(id, { id_equipos, id_ubicacion_fisica, serial, estado }) {
    await db.execute(
        'UPDATE inventario SET id_equipos=?, id_ubicacion_fisica=?, serial=?, estado=? WHERE id_inventario=?',
        [id_equipos, id_ubicacion_fisica, serial, estado, id]
    );
};
