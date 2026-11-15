const Solicitud = require('../models/Solicitud');

const ReservasController = {
    async listar(req, res) {
        try {
            const solicitudes = await Solicitud.findAll();
            const reservas = solicitudes.filter(s => s.estado === 'Aprobado');
            res.json({ ok: true, reservas });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async finalizar(req, res) {
        try {
            await Solicitud.updateEstado(req.params.id, 'Completado');
            res.json({ ok: true, msg: 'Reserva finalizada' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = ReservasController;
