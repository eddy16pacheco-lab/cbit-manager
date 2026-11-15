const db = require('../../config/database');
class Notificacion {
    static async findByUsuario(id_usuario) {
        const [rows] = await db.execute(
            'SELECT * FROM notificacion WHERE id_usuario=? ORDER BY fecha_envio DESC',
            [id_usuario]
        );
        return rows;
    }
    static async create({ id_usuario, titulo, mensaje }) {
        const [result] = await db.execute(
            'INSERT INTO notificacion (id_usuario, titulo, mensaje, fecha_envio) VALUES (?,?,?,NOW())',
            [id_usuario, titulo, mensaje]
        );
        return result.insertId;
    }
}
module.exports = Notificacion;
