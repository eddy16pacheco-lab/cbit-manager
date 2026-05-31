const db = require('../../config/database');
class Modelo {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM modelo ORDER BY id_modelo');
        return rows;
    }
    static async create({ nombre }) {
        const [result] = await db.execute('INSERT INTO modelo (nombre) VALUES (?)', [nombre]);
        return result.insertId;
    }
}
module.exports = Modelo;
