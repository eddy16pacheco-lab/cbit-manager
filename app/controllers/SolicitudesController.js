const Solicitud = require('../models/Solicitud');
const Espacio = require('../models/Espacio');
const Actividad = require('../models/Actividad');
const DetalleSolicitud = require('../models/DetalleSolicitud');

const SolicitudesController = {
    async listar(req, res) {
        try {
            const [solicitudes, espacios, actividades] = await Promise.all([
                Solicitud.findAll(), Espacio.findAll(), Actividad.findAll()
            ]);
            res.json({ ok: true, solicitudes, espacios, actividades });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async equiposDisponibles(req, res) {
        const { fecha, hora_inicio, hora_fin } = req.query;
        if (!fecha || !hora_inicio || !hora_fin) return res.json({ ok: false, msg: 'Indique fecha y horario' });
        try {
            const equipos = await DetalleSolicitud.equiposDisponibles(fecha, hora_inicio, hora_fin);
            res.json({ ok: true, equipos });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_espacio, id_actividad, fecha, hora_inicio, hora_fin, descripcion, aprobar_directo, equipos_ids } = req.body;
        const id_usuario = req.session.usuario?.id_usuario;
        const esAdmin = req.session.usuario?.roles === 'Administrador';
        if (!id_espacio || !id_actividad || !fecha || !hora_inicio || !hora_fin)
            return res.json({ ok: false, msg: 'Complete todos los campos requeridos' });
        if (hora_inicio >= hora_fin)
            return res.json({ ok: false, msg: 'La hora de inicio debe ser menor que la hora de fin' });
        try {
            const disponible = await Solicitud.checkDisponibilidad(id_espacio, fecha, hora_inicio, hora_fin);
            if (!disponible) return res.json({ ok: false, msg: 'El espacio ya está reservado en ese horario' });
            // Solo admin puede aprobar al crear
            const estado = (esAdmin && aprobar_directo) ? 'Aprobado' : 'Pendiente';
            const id = await Solicitud.create({ id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, descripcion, estado });
            // Registrar equipos solicitados
            if (equipos_ids && equipos_ids.length) {
                await DetalleSolicitud.createBulk(id, equipos_ids);
            }
            const msg = estado === 'Aprobado'
                ? 'Solicitud creada y aprobada. Ya aparece en el calendario ✅'
                : 'Solicitud registrada. Esperando aprobación.';
            res.json({ ok: true, id, msg, estado });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { id_espacio, id_actividad, fecha, hora_inicio, hora_fin, descripcion, equipos_ids } = req.body;
        if (!id_espacio || !id_actividad || !fecha || !hora_inicio || !hora_fin)
            return res.json({ ok: false, msg: 'Complete todos los campos' });
        try {
            await Solicitud.update(req.params.id, { id_espacio, id_actividad, fecha, hora_inicio, hora_fin, descripcion });
            if (equipos_ids !== undefined) {
                await DetalleSolicitud.deleteBySolicitud(req.params.id);
                if (equipos_ids.length) await DetalleSolicitud.createBulk(req.params.id, equipos_ids);
            }
            res.json({ ok: true, msg: 'Solicitud actualizada' });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async aprobar(req, res) {
        const { id } = req.params;
        try {
            const sol = await Solicitud.findById(id);
            if (!sol) return res.json({ ok: false, msg: 'Solicitud no encontrada' });
            const disponible = await Solicitud.checkDisponibilidad(sol.id_espacio, sol.fecha, sol.hora_inicio, sol.hora_fin, id);
            if (!disponible) return res.json({ ok: false, msg: 'No se puede aprobar: el espacio ya tiene una reserva aprobada en ese horario' });
            await Solicitud.updateEstado(id, 'Aprobado');
            res.json({ ok: true, msg: 'Solicitud aprobada y visible en el calendario ✅' });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async cancelar(req, res) {
        try { await Solicitud.cancelar(req.params.id); res.json({ ok: true, msg: 'Solicitud cancelada' }); }
        catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Solicitud.delete(req.params.id); res.json({ ok: true, msg: 'Solicitud eliminada' }); }
        catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async calendario(req, res) {
        try {
            const solicitudes = await Solicitud.findAll();
            res.json({ ok: true, solicitudes: solicitudes.filter(s => s.estado === 'Aprobado') });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async detalle(req, res) {
        try {
            const [sol, equipos] = await Promise.all([
                Solicitud.findById(req.params.id),
                DetalleSolicitud.findBySolicitud(req.params.id)
            ]);
            if (!sol) return res.json({ ok: false, msg: 'No encontrado' });
            res.json({ ok: true, solicitud: sol, equipos });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = SolicitudesController;
