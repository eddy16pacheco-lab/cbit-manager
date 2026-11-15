const db = require('../../config/database');
class Mantenimiento {
    static async findAll() {
        const [rows] = await db.execute(
            `SELECT m.*, t.especialidad,
                    p.nombre AS tec_nombre, p.apellido AS tec_apellido,
                    me.descripcion_fallas, me.id_equipos,
                    eq.nombre AS equipo_nombre,
                    inv.serial
             FROM mantenimiento m
             LEFT JOIN tecnicos t ON m.id_tecnicos=t.id_tecnicos
             LEFT JOIN persona p ON t.id_persona=p.id_persona
             LEFT JOIN mantenimiento_equipos me ON m.id_mantenimiento=me.id_mantenimiento
             LEFT JOIN equipos eq ON me.id_equipos=eq.id_equipos
             LEFT JOIN inventario inv ON inv.id_equipos=eq.id_equipos
             ORDER BY m.fecha_reporte DESC`
        );
        return rows;
    }
    static async create({ id_tecnicos, nivel_prioridad, id_equipos, descripcion_fallas }) {
        const conn = await require('../../config/database').getConnection();
        try {
            await conn.beginTransaction();
            const [r1] = await conn.execute(
                'INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad) VALUES (?,NOW(),?)',
                [id_tecnicos, nivel_prioridad]
            );
            const id_mantenimiento = r1.insertId;
            await conn.execute(
                'INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas) VALUES (?,?,?)',
                [id_mantenimiento, id_equipos, descripcion_fallas]
            );
            await conn.commit();
            return id_mantenimiento;
        } catch (e) {
            await conn.rollback();
            throw e;
        } finally {
            conn.release();
        }
    }
    static async delete(id) {
        await require('../../config/database').execute('DELETE FROM mantenimiento WHERE id_mantenimiento=?', [id]);
    }
}
module.exports = Mantenimiento;
