const Espacio = require('../models/Espacio');

const EspaciosController = {
    async listar(req, res) {
        try { const espacios = await Espacio.findAll(); res.json({ ok: true, espacios }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, capacidad } = req.body;
        if (!nombre || !capacidad) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Espacio.create({ nombre, capacidad }); res.json({ ok: true, id, msg: 'Espacio registrado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, capacidad } = req.body;
        if (!nombre || !capacidad) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { await Espacio.update(req.params.id, { nombre, capacidad }); res.json({ ok: true, msg: 'Espacio actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Espacio.delete(req.params.id); res.json({ ok: true, msg: 'Espacio eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = EspaciosController;
