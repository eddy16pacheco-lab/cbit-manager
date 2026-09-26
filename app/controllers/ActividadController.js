const Actividad = require('../models/Actividad');
const Solicitud = require('../models/Solicitud');
const { requerido, longitudValida, esNombreCatalogoValido } = require('../helpers/validators');

function validarActividad({ nombre, descripcion_actividad }) {
    if (!requerido(nombre, descripcion_actividad)) return 'Complete todos los campos';
    if (!esNombreCatalogoValido(nombre)) return 'El nombre debe tener entre 3 y 40 caracteres';
    if (!longitudValida(descripcion_actividad, 5, 500)) return 'La descripción debe tener entre 5 y 500 caracteres';
    return null;
}

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
        const error = validarActividad({ nombre, descripcion_actividad });
        if (error) return res.json({ ok: false, msg: error });
        try { const id = await Actividad.create({ nombre: nombre.trim(), descripcion_actividad: descripcion_actividad.trim() }); res.json({ ok: true, id, msg: 'Actividad registrada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, descripcion_actividad } = req.body;
        const error = validarActividad({ nombre, descripcion_actividad });
        if (error) return res.json({ ok: false, msg: error });
        try { await Actividad.update(req.params.id, { nombre: nombre.trim(), descripcion_actividad: descripcion_actividad.trim() }); res.json({ ok: true, msg: 'Actividad actualizada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try {
            const enUso = (await Solicitud.findAll()).some(s => String(s.id_actividad) === String(req.params.id));
            if (enUso) return res.json({ ok: false, msg: 'No se puede eliminar: hay solicitudes asociadas a esta actividad' });
            await Actividad.delete(req.params.id); res.json({ ok: true, msg: 'Actividad eliminada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = ActividadController;
