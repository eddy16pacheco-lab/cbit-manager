const db = require('../../config/database');
class UbicacionFisica {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM ubicacion_fisica ORDER BY id_ubicacion_fisica');
        return rows;
    }
    static async create({ nombre }) {
        const [result] = await db.execute('INSERT INTO ubicacion_fisica (nombre) VALUES (?)', [nombre]);
        return result.insertId;
    }
}
module.exports = UbicacionFisica;
