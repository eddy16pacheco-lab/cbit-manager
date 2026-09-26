const Asistencia = require('../models/Asistencia');
const Solicitud = require('../models/Solicitud');
const Estudiante = require('../models/Estudiante');
const Persona = require('../models/Persona');
const { requerido, esNumeroPositivo, enumValido, esCedula, esNombrePersonaValido } = require('../helpers/validators');

const AÑOS_VALIDOS = ['1er año', '2er año', '3er año', '4er año', '5er año', '6er año'];
const SECCIONES_VALIDAS = ['A', 'B', 'C', 'D', 'U'];

const AsistenciaController = {
    // RF: los docentes solo pueden ver la asistencia de los eventos (solicitudes) que ellos crearon.
    // El administrador ve la asistencia de todos los eventos.
    async listar(req, res) {
        try {
            const usuarioSesion = req.session.usuario;
            const esAdmin = usuarioSesion?.roles === 'Administrador';

            const [asistencias, solicitudes, estudiantes, personas] = await Promise.all([
                Asistencia.findAll(),
                Solicitud.findAll(),
                Estudiante.findAll(),
                Persona.findAll()
            ]);

            if (esAdmin) {
                return res.json({ ok: true, asistencias, solicitudes, estudiantes, personas });
            }

            // Docente: solo sus propias solicitudes/eventos y la asistencia asociada a ellos
            const idsPropios = new Set(
                solicitudes.filter(s => String(s.id_usuario) === String(usuarioSesion.id_usuario)).map(s => s.id_solicitud)
            );
            const solicitudesPropias = solicitudes.filter(s => idsPropios.has(s.id_solicitud));
            const asistenciasPropias = asistencias.filter(a => idsPropios.has(a.id_solicitud));

            res.json({ ok: true, asistencias: asistenciasPropias, solicitudes: solicitudesPropias, estudiantes, personas });
        } catch(e) {
            console.error('Error en AsistenciaController.listar:', e.message);
            res.json({ ok: false, msg: e.message });
        }
    },
    async crear(req, res) {
        const { id_estudiante, id_solicitud, asistio } = req.body;
        if (!requerido(id_estudiante, id_solicitud, asistio)) return res.json({ ok: false, msg: 'Complete todos los campos' });
        if (!esNumeroPositivo(id_estudiante)) return res.json({ ok: false, msg: 'Seleccione un estudiante válido' });
        if (!esNumeroPositivo(id_solicitud)) return res.json({ ok: false, msg: 'Seleccione un evento/solicitud válido' });
        if (!enumValido(asistio, ['Si', 'No'])) return res.json({ ok: false, msg: 'El valor de asistencia debe ser Si o No' });
        try {
            const usuarioSesion = req.session.usuario;
            const esAdmin = usuarioSesion?.roles === 'Administrador';
            if (!esAdmin) {
                const sol = await Solicitud.findById(id_solicitud);
                if (!sol || String(sol.id_usuario) !== String(usuarioSesion.id_usuario)) {
                    return res.json({ ok: false, msg: 'Solo puede registrar asistencia de los eventos que usted mismo creó' });
                }
            }
            const id = await Asistencia.create({ id_estudiante, id_solicitud, asistio });
            res.json({ ok: true, id, msg: 'Asistencia registrada' });
        }
        catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async registrarEstudiante(req, res) {
        const { id_persona_existente, nombre, apellido, cedula, telefono, seccion, año } = req.body;

        if (!enumValido(año, AÑOS_VALIDOS)) return res.json({ ok: false, msg: 'Seleccione un año válido' });
        if (seccion && !enumValido(seccion, SECCIONES_VALIDAS)) return res.json({ ok: false, msg: 'La sección debe ser A, B, C, D o U' });

        try {
            // Caso 1: el estudiante ya existe como Persona registrada (RF: el registro
            // de estudiante puede estar asociado a una persona ya existente en el sistema).
            if (id_persona_existente) {
                if (!esNumeroPositivo(id_persona_existente)) return res.json({ ok: false, msg: 'Seleccione una persona válida' });
                const persona = (await Persona.findAll()).find(p => String(p.id_persona) === String(id_persona_existente));
                if (!persona) return res.json({ ok: false, msg: 'La persona seleccionada no existe' });
                const yaEsEstudiante = await Estudiante.findByPersona(id_persona_existente);
                if (yaEsEstudiante) return res.json({ ok: false, msg: 'Esta persona ya está registrada como estudiante' });
                const id_est = await Estudiante.create({ id_persona: id_persona_existente, seccion: seccion || 'A', año });
                return res.json({ ok: true, id_persona: id_persona_existente, id_estudiante: id_est, msg: `${persona.nombre} ${persona.apellido} vinculado(a) como estudiante` });
            }

            // Caso 2: se registra una persona nueva y luego se crea el estudiante.
            if (!requerido(nombre, apellido, cedula)) return res.json({ ok: false, msg: 'Complete los campos requeridos' });
            if (!esNombrePersonaValido(nombre)) return res.json({ ok: false, msg: 'El nombre solo debe contener letras (3 a 40 caracteres)' });
            if (!esNombrePersonaValido(apellido)) return res.json({ ok: false, msg: 'El apellido solo debe contener letras (3 a 40 caracteres)' });
            if (!esCedula(cedula)) return res.json({ ok: false, msg: 'La cédula debe tener el formato V-12345678 o E-12345678' });

            const existente = await Persona.findByCedula(cedula.trim());
            if (existente) return res.json({ ok: false, msg: 'Ya existe una persona registrada con esa cédula. Selecciónela de la lista de personas existentes.' });
            const id_persona = await Persona.create({ nombre: nombre.trim(), apellido: apellido.trim(), cedula: cedula.trim(), telefono: telefono || '' });
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
