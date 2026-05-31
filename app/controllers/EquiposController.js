const Equipo = require('../models/Equipo');
const Categoria = require('../models/Categoria');
const Marca = require('../models/Marca');
const Modelo = require('../models/Modelo');

const EquiposController = {
    async listar(req, res) {
        try {
            const [equipos, categorias, marcas, modelos] = await Promise.all([Equipo.findAll(), Categoria.findAll(), Marca.findAll(), Modelo.findAll()]);
            res.json({ ok: true, equipos, categorias, marcas, modelos });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, id_categoria, id_marca, id_modelo } = req.body;
        if (!nombre || !id_categoria || !id_marca) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Equipo.create({ nombre, id_categoria, id_marca, id_modelo: id_modelo || null }); res.json({ ok: true, id, msg: 'Equipo registrado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, id_categoria, id_marca, id_modelo } = req.body;
        if (!nombre || !id_categoria || !id_marca) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { await Equipo.update(req.params.id, { nombre, id_categoria, id_marca, id_modelo: id_modelo || null }); res.json({ ok: true, msg: 'Equipo actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Equipo.delete(req.params.id); res.json({ ok: true, msg: 'Equipo eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = EquiposController;
