const db = require('../../config/database');
class Horario {
    static async findAll() {
        const [rows] = await db.execute('SELECT * FROM horario ORDER BY id_horario');
        return rows;
    }
    static async create({ dias, hora_inicio, hora_final }) {
        const [result] = await db.execute(
            'INSERT INTO horario (dias, hora_inicio, hora_final) VALUES (?,?,?)',
            [dias, hora_inicio, hora_final]
        );
        return result.insertId;
    }
}
module.exports = Horario;
