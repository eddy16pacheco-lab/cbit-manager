const Actividad = require('../models/Actividad');
const Solicitud = require('../models/Solicitud');

const ActividadController = {
    async listar(req, res) {
        try {
            const [actividades, solicitudes] = await Promise.all([Actividad.findAll(), Solicitud.findAll()]);
            const data = actividades.map(a => ({ ...a, total_solicitudes: solicitudes.filter(s => s.id_actividad === a.id_actividad).length }));
            res.json({ ok: true, data });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, descripcion_actividad } = req.body;
        if (!nombre || !descripcion_actividad) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Actividad.create({ nombre, descripcion_actividad }); res.json({ ok: true, id, msg: 'Actividad registrada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, descripcion_actividad } = req.body;
        if (!nombre || !descripcion_actividad) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { await Actividad.update(req.params.id, { nombre, descripcion_actividad }); res.json({ ok: true, msg: 'Actividad actualizada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Actividad.delete(req.params.id); res.json({ ok: true, msg: 'Actividad eliminada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = ActividadController;
