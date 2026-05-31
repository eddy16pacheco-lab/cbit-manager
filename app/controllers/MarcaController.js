const Marca = require('../models/Marca');
const Equipo = require('../models/Equipo');

const MarcaController = {
    async listar(req, res) {
        try {
            const marcas = await Marca.findAll();
            const equipos = await Equipo.findAll();
            const data = marcas.map(m => ({ ...m, total_equipos: equipos.filter(e => e.id_marca === m.id_marca).length }));
            res.json({ ok: true, data });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre } = req.body;
        if (!nombre) return res.json({ ok: false, msg: 'El nombre es requerido' });
        try { const id = await Marca.create({ nombre }); res.json({ ok: true, id, msg: 'Marca registrada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre } = req.body;
        if (!nombre) return res.json({ ok: false, msg: 'El nombre es requerido' });
        try { await Marca.update(req.params.id, { nombre }); res.json({ ok: true, msg: 'Marca actualizada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Marca.delete(req.params.id); res.json({ ok: true, msg: 'Marca eliminada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = MarcaController;
