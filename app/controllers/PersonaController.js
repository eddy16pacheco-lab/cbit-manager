const Persona = require('../models/Persona');

const PersonaController = {
    async listar(req, res) {
        try { const personas = await Persona.findAll(); res.json({ ok: true, personas }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, apellido, cedula, telefono } = req.body;
        if (!nombre || !apellido || !cedula || !telefono) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Persona.create({ nombre, apellido, cedula, telefono }); res.json({ ok: true, id, msg: 'Persona registrada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, apellido, cedula, telefono } = req.body;
        if (!nombre || !apellido || !cedula || !telefono) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { await Persona.update(req.params.id, { nombre, apellido, cedula, telefono }); res.json({ ok: true, msg: 'Persona actualizada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Persona.delete(req.params.id); res.json({ ok: true, msg: 'Persona eliminada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = PersonaController;
