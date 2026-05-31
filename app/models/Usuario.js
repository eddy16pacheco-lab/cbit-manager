const db = require('../../config/database');

class Usuario {
    static async findByCredentials(nombre_usuario, contrasena_usuario) {
        const [rows] = await db.execute(
            `SELECT u.*, p.nombre, p.apellido, p.cedula, p.telefono
             FROM usuario u
             JOIN persona p ON u.id_persona = p.id_persona
             WHERE u.nombre_usuario = ? AND u.contrasena_usuario = ? AND u.estado = 'Activo'`,
            [nombre_usuario, contrasena_usuario]
        );
        return rows[0] || null;
    }
    static async findByPersona(id_persona) {
        const [rows] = await db.execute(
            `SELECT u.*, p.nombre, p.apellido FROM usuario u JOIN persona p ON u.id_persona=p.id_persona WHERE u.id_persona=?`,
            [id_persona]
        );
        return rows[0] || null;
    }
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT u.*, p.nombre, p.apellido, p.cedula
             FROM usuario u JOIN persona p ON u.id_persona=p.id_persona ORDER BY u.id_usuario`
        );
        return rows;
    }
    static async create({ id_persona, nombre_usuario, contrasena_usuario, correo, roles }) {
        const [result] = await db.execute(
            `INSERT INTO usuario (id_persona, nombre_usuario, contrasena_usuario, correo, estado, roles)
             VALUES (?, ?, ?, ?, 'Activo', ?)`,
            [id_persona, nombre_usuario, contrasena_usuario, correo, roles]
        );
        return result.insertId;
    }
    static async delete(id) {
        await db.execute(`UPDATE usuario SET estado='Inactivo' WHERE id_usuario=?`, [id]);
    }
    static async findByCredencialesRecuperacion(cedula, correo) {
        const [rows] = await db.execute(
            `SELECT u.correo FROM usuario u JOIN persona p ON u.id_persona=p.id_persona
             WHERE p.cedula=? AND u.correo=?`,
            [cedula, correo]
        );
        return rows[0] || null;
    }
}
module.exports = Usuario;

Usuario.inhabilitar = async function(id) {
    await db.execute("UPDATE usuario SET estado='Inactivo' WHERE id_usuario=?", [id]);
};
Usuario.activar = async function(id) {
    await db.execute("UPDATE usuario SET estado='Activo' WHERE id_usuario=?", [id]);
};
Usuario.update = async function(id, { correo, roles, contrasena_usuario }) {
    if (contrasena_usuario) {
        await db.execute('UPDATE usuario SET correo=?, roles=?, contrasena_usuario=? WHERE id_usuario=?', [correo, roles, contrasena_usuario, id]);
    } else {
        await db.execute('UPDATE usuario SET correo=?, roles=? WHERE id_usuario=?', [correo, roles, id]);
    }
};
