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
    static async findById(id) {
        const [rows] = await db.execute('SELECT * FROM inventario WHERE id_inventario=?', [id]);
        return rows[0] || null;
    }
    static async create({ codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado }) {
        const [result] = await db.execute(
            'INSERT INTO inventario (codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado) VALUES (?,?,?,?,?)',
            [codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado]
        );
        return result.insertId;
    }
    static async updateEstado(id, estado) {
        await db.execute('UPDATE inventario SET estado=? WHERE id_inventario=?', [estado, id]);
    }
    static async update(id, { codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado }) {
        await db.execute(
            'UPDATE inventario SET codigo_bien_nacional=?, id_equipos=?, id_ubicacion_fisica=?, serial=?, estado=? WHERE id_inventario=?',
            [codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado, id]
        );
    }
    // Desincorporación: el equipo se conserva (con fecha y motivo) en lugar de eliminarse.
    static async desincorporar(id, motivo) {
        await db.execute(
            `UPDATE inventario SET estado='Desincorporado', fecha_desincorporacion=CURDATE(), motivo_desincorporacion=?
             WHERE id_inventario=? AND estado<>'Desincorporado'`,
            [motivo, id]
        );
    }
    // Reservas Pendientes/Aprobadas de hoy en adelante que usan esta unidad
    static async reservasVigentes(id) {
        const [rows] = await db.execute(
            `SELECT COUNT(*) AS total
             FROM detalle_solicitud ds JOIN solicitud s ON ds.id_solicitud=s.id_solicitud
             WHERE ds.id_inventario=? AND s.estado IN ('Pendiente','Aprobado') AND s.fecha>=CURDATE()`,
            [id]
        );
        return rows[0].total;
    }
}
module.exports = Inventario;
