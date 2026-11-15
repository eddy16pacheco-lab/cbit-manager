const Tecnico = require('../models/Tecnico');
const Persona = require('../models/Persona');
const { requerido, esNumeroPositivo, enumValido } = require('../helpers/validators');

const ESPECIALIDADES_VALIDAS = ['Hardware', 'Software', 'Redes', 'Seguridad', 'Soporte técnico', 'Recuperación de datos', 'Mantenimiento preventivo', 'Instalación de sistemas', 'otros'];
function especialidadValida(v) {
    return typeof v === 'string' && ESPECIALIDADES_VALIDAS.some(e => e.toLowerCase() === v.toLowerCase());
}

const TecnicosController = {
    async listar(req, res) {
        try {
            const [tecnicos, personas] = await Promise.all([Tecnico.findAll(), Persona.findAll()]);
            res.json({ ok: true, tecnicos, personas });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_persona, especialidad } = req.body;
        if (!requerido(id_persona, especialidad)) return res.json({ ok: false, msg: 'Complete todos los campos' });
        if (!esNumeroPositivo(id_persona)) return res.json({ ok: false, msg: 'Seleccione una persona válida' });
        if (!especialidadValida(especialidad)) return res.json({ ok: false, msg: 'Seleccione una especialidad válida' });
        try {
            const yaEsTecnico = (await Tecnico.findAll()).some(t => String(t.id_persona) === String(id_persona));
            if (yaEsTecnico) return res.json({ ok: false, msg: 'Esta persona ya está registrada como técnico' });
            const id = await Tecnico.create({ id_persona, especialidad }); res.json({ ok: true, id, msg: 'Técnico registrado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { especialidad } = req.body;
        if (!requerido(especialidad)) return res.json({ ok: false, msg: 'Indique la especialidad' });
        if (!especialidadValida(especialidad)) return res.json({ ok: false, msg: 'Seleccione una especialidad válida' });
        try { await Tecnico.update(req.params.id, { especialidad }); res.json({ ok: true, msg: 'Técnico actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Tecnico.delete(req.params.id); res.json({ ok: true, msg: 'Técnico eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = TecnicosController;
