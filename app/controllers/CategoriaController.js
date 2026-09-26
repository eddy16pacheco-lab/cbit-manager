const Categoria = require('../models/Categoria');
const Equipo = require('../models/Equipo');
const { requerido, esNombreCatalogoValido } = require('../helpers/validators');

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
        if (!requerido(nombre)) return res.json({ ok: false, msg: 'El nombre es requerido' });
        if (!esNombreCatalogoValido(nombre)) return res.json({ ok: false, msg: 'El nombre debe tener entre 3 y 40 caracteres' });
        try {
            const dup = (await Categoria.findAll()).some(c => c.nombre.trim().toLowerCase() === nombre.trim().toLowerCase());
            if (dup) return res.json({ ok: false, msg: 'Ya existe una categoría con ese nombre' });
            const id = await Categoria.create({ nombre: nombre.trim() }); res.json({ ok: true, id, msg: 'Categoría registrada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre } = req.body;
        if (!requerido(nombre)) return res.json({ ok: false, msg: 'El nombre es requerido' });
        if (!esNombreCatalogoValido(nombre)) return res.json({ ok: false, msg: 'El nombre debe tener entre 3 y 40 caracteres' });
        try {
            const dup = (await Categoria.findAll()).some(c => c.nombre.trim().toLowerCase() === nombre.trim().toLowerCase() && String(c.id_categoria) !== String(req.params.id));
            if (dup) return res.json({ ok: false, msg: 'Ya existe otra categoría con ese nombre' });
            await Categoria.update(req.params.id, { nombre: nombre.trim() }); res.json({ ok: true, msg: 'Categoría actualizada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try {
            const enUso = (await Equipo.findAll()).some(e => String(e.id_categoria) === String(req.params.id));
            if (enUso) return res.json({ ok: false, msg: 'No se puede eliminar: hay equipos asociados a esta categoría' });
            await Categoria.delete(req.params.id); res.json({ ok: true, msg: 'Categoría eliminada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = CategoriaController;
