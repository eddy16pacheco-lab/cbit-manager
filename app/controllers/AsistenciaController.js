const Asistencia = require('../models/Asistencia');
const Solicitud = require('../models/Solicitud');
const Estudiante = require('../models/Estudiante');
const Persona = require('../models/Persona');

const AsistenciaController = {
    async listar(req, res) {
        try {
            const [asistencias, solicitudes, estudiantes, personas] = await Promise.all([
                Asistencia.findAll(), Solicitud.findAll(), Estudiante.findAll(), Persona.findAll()
            ]);
            res.json({ ok: true, asistencias, solicitudes, estudiantes, personas });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_estudiante, id_solicitud, asistio } = req.body;
        if (!id_estudiante || !id_solicitud || !asistio) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Asistencia.create({ id_estudiante, id_solicitud, asistio }); res.json({ ok: true, id, msg: 'Asistencia registrada' }); }
        catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async registrarEstudiante(req, res) {
        const { nombre, apellido, cedula, telefono, seccion, año } = req.body;
        if (!nombre || !apellido || !cedula || !año) return res.json({ ok: false, msg: 'Complete los campos requeridos' });
        try {
            const id_persona = await Persona.create({ nombre, apellido, cedula, telefono: telefono || '' });
            const id_est = await Estudiante.create({ id_persona, seccion: seccion || 'A', año });
            res.json({ ok: true, id_persona, id_estudiante: id_est, msg: `Estudiante ${nombre} ${apellido} registrado` });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Asistencia.delete(req.params.id); res.json({ ok: true, msg: 'Registro eliminado' }); }
        catch(e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = AsistenciaController;
