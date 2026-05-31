const Categoria = require('../models/Categoria');
const Equipo = require('../models/Equipo');

const CategoriaController = {
    async listar(req, res) {
        try {
            const categorias = await Categoria.findAll();
            const equipos = await Equipo.findAll();
            const data = categorias.map(c => ({ ...c, total_equipos: equipos.filter(e => e.id_categoria === c.id_categoria).length }));
            res.json({ ok: true, data });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre } = req.body;
        if (!nombre) return res.json({ ok: false, msg: 'El nombre es requerido' });
        try { const id = await Categoria.create({ nombre }); res.json({ ok: true, id, msg: 'Categoría registrada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre } = req.body;
        if (!nombre) return res.json({ ok: false, msg: 'El nombre es requerido' });
        try { await Categoria.update(req.params.id, { nombre }); res.json({ ok: true, msg: 'Categoría actualizada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Categoria.delete(req.params.id); res.json({ ok: true, msg: 'Categoría eliminada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = CategoriaController;
