const Solicitud      = require('../models/Solicitud');
const Espacio        = require('../models/Espacio');
const Actividad      = require('../models/Actividad');
const DetalleSolicitud = require('../models/DetalleSolicitud');
const Usuario        = require('../models/Usuario');
const { enviarCorreoSolicitud } = require('../helpers/mailer');

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
        if (!fecha || !hora_inicio || !hora_fin)
            return res.json({ ok: false, msg: 'Indique fecha y horario' });
        try {
            const equipos = await DetalleSolicitud.equiposDisponibles(fecha, hora_inicio, hora_fin);
            res.json({ ok: true, equipos });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },

    async crear(req, res) {
        const { id_espacio, id_actividad, fecha, hora_inicio, hora_fin, descripcion, aprobar_directo, equipos_ids } = req.body;
        const id_usuario = req.session.usuario?.id_usuario;
        const esAdmin    = req.session.usuario?.roles === 'Administrador';
        if (!id_espacio || !id_actividad || !fecha || !hora_inicio || !hora_fin)
            return res.json({ ok: false, msg: 'Complete todos los campos requeridos' });
        if (hora_inicio >= hora_fin)
            return res.json({ ok: false, msg: 'La hora de inicio debe ser menor que la hora de fin' });
        try {
            const disponible = await Solicitud.checkDisponibilidad(id_espacio, fecha, hora_inicio, hora_fin);
            if (!disponible)
                return res.json({ ok: false, msg: 'El espacio ya está reservado en ese horario' });

            const estado = (esAdmin && aprobar_directo) ? 'Aprobado' : 'Pendiente';
            const id = await Solicitud.create({ id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, descripcion, estado });

            if (equipos_ids && equipos_ids.length)
                await DetalleSolicitud.createBulk(id, equipos_ids);

            // Si se aprueba directo, enviar correo al docente
            if (estado === 'Aprobado') {
                await _enviarNotificacion(id, 'Aprobado');
            }

            const msg = estado === 'Aprobado'
                ? 'Solicitud creada y aprobada. Correo enviado al docente ✅'
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
            if (!disponible)
                return res.json({ ok: false, msg: 'No se puede aprobar: el espacio ya tiene una reserva en ese horario' });

            await Solicitud.updateEstado(id, 'Aprobado');

            // Enviar correo de aprobación
            await _enviarNotificacion(id, 'Aprobado');

            res.json({ ok: true, msg: 'Solicitud aprobada. Correo enviado al docente ✅' });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },

    async cancelar(req, res) {
        const { id } = req.params;
        try {
            const sol = await Solicitud.findById(id);
            await Solicitud.cancelar(id);

            // Enviar correo de rechazo/cancelación
            if (sol) await _enviarNotificacion(id, 'No Aprobado');

            res.json({ ok: true, msg: 'Solicitud cancelada. Correo enviado al docente.' });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
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

// ── Helper interno: busca correo del docente y envía notificación ───────────
async function _enviarNotificacion(id_solicitud, estado) {
    try {
        const [sol, equipos] = await Promise.all([
            Solicitud.findById(id_solicitud),
            DetalleSolicitud.findBySolicitud(id_solicitud)
        ]);
        if (!sol) return;

        // Obtener correo del usuario que hizo la solicitud
        const usuario = await Usuario.findByPersona(sol.id_persona || sol.id_usuario);
        const correo  = usuario?.correo;
        if (!correo) {
            console.warn('No se encontró correo para el docente de la solicitud #' + id_solicitud);
            return;
        }

        const docente    = sol.persona_nombre + ' ' + sol.persona_apellido;
        const fecha      = new Date(sol.fecha).toLocaleDateString('es-ES', { weekday:'long', year:'numeric', month:'long', day:'numeric' });
        const hora_inicio = String(sol.hora_inicio).slice(0, 5);
        const hora_fin    = String(sol.hora_fin).slice(0, 5);

        await enviarCorreoSolicitud({
            correo,
            estado,
            docente,
            actividad:   sol.actividad_nombre  || 'N/A',
            espacio:     sol.espacio_nombre     || 'N/A',
            fecha,
            hora_inicio,
            hora_fin,
            descripcion: sol.descripcion,
            equipos
        });
    } catch(e) {
        console.error('Error en _enviarNotificacion:', e.message);
    }
}

module.exports = SolicitudesController;
