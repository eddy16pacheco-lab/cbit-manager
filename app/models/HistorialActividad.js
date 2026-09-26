const db = require('../../config/database');

class HistorialActividad {
    static async registrar({ id_usuario, usuario, accion, modulo, detalle, ip }) {
        await db.execute(
            `INSERT INTO historial_actividad (id_usuario, usuario, accion, modulo, detalle, ip, fecha)
             VALUES (?,?,?,?,?,?,NOW())`,
            [id_usuario || null, usuario || null, accion, modulo, detalle || null, ip || null]
        );
    }

    /**
     * Devuelve el historial más reciente primero, con filtros opcionales.
     * @param {{modulo?: string, id_usuario?: number, desde?: string, hasta?: string, limite?: number}} filtros
     */
    static async findAll(filtros = {}) {
        const condiciones = [];
        const params = [];

        if (filtros.modulo) { condiciones.push('modulo = ?'); params.push(filtros.modulo); }
        if (filtros.id_usuario) { condiciones.push('id_usuario = ?'); params.push(filtros.id_usuario); }
        if (filtros.desde) { condiciones.push('fecha >= ?'); params.push(filtros.desde + ' 00:00:00'); }
        if (filtros.hasta) { condiciones.push('fecha <= ?'); params.push(filtros.hasta + ' 23:59:59'); }

        const where = condiciones.length ? `WHERE ${condiciones.join(' AND ')}` : '';
        const limite = Math.min(Number(filtros.limite) || 500, 2000);

        const [rows] = await db.execute(
            `SELECT * FROM historial_actividad ${where} ORDER BY fecha DESC LIMIT ${limite}`,
            params
        );
        return rows;
    }

    static async modulosDistintos() {
        const [rows] = await db.execute('SELECT DISTINCT modulo FROM historial_actividad ORDER BY modulo');
        return rows.map(r => r.modulo);
    }
}

module.exports = HistorialActividad;
