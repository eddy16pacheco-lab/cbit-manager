const HistorialActividad = require('../models/HistorialActividad');
const Usuario = require('../models/Usuario');

const HistorialController = {
    // Solo Administrador (protegido por adminOnly en las rutas)
    async listar(req, res) {
        try {
            const { modulo, id_usuario, desde, hasta, limite } = req.query;
            const [historial, usuarios, modulos] = await Promise.all([
                HistorialActividad.findAll({ modulo, id_usuario, desde, hasta, limite }),
                Usuario.findAll(),
                HistorialActividad.modulosDistintos()
            ]);
            res.json({ ok: true, historial, usuarios, modulos });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = HistorialController;
