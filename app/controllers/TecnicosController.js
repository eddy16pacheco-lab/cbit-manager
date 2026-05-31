const Tecnico = require('../models/Tecnico');
const Persona = require('../models/Persona');

const TecnicosController = {
    async listar(req, res) {
        try {
            const [tecnicos, personas] = await Promise.all([Tecnico.findAll(), Persona.findAll()]);
            res.json({ ok: true, tecnicos, personas });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_persona, especialidad } = req.body;
        if (!id_persona || !especialidad) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Tecnico.create({ id_persona, especialidad }); res.json({ ok: true, id, msg: 'Técnico registrado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { especialidad } = req.body;
        if (!especialidad) return res.json({ ok: false, msg: 'Indique la especialidad' });
        try { await Tecnico.update(req.params.id, { especialidad }); res.json({ ok: true, msg: 'Técnico actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Tecnico.delete(req.params.id); res.json({ ok: true, msg: 'Técnico eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = TecnicosController;
