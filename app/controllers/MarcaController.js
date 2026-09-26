const Marca = require('../models/Marca');
const Equipo = require('../models/Equipo');
const { requerido, esNombreCatalogoValido } = require('../helpers/validators');

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
        if (!requerido(nombre)) return res.json({ ok: false, msg: 'El nombre es requerido' });
        if (!esNombreCatalogoValido(nombre)) return res.json({ ok: false, msg: 'El nombre debe tener entre 3 y 40 caracteres' });
        try {
            const dup = (await Marca.findAll()).some(m => m.nombre.trim().toLowerCase() === nombre.trim().toLowerCase());
            if (dup) return res.json({ ok: false, msg: 'Ya existe una marca con ese nombre' });
            const id = await Marca.create({ nombre: nombre.trim() }); res.json({ ok: true, id, msg: 'Marca registrada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre } = req.body;
        if (!requerido(nombre)) return res.json({ ok: false, msg: 'El nombre es requerido' });
        if (!esNombreCatalogoValido(nombre)) return res.json({ ok: false, msg: 'El nombre debe tener entre 3 y 40 caracteres' });
        try {
            const dup = (await Marca.findAll()).some(m => m.nombre.trim().toLowerCase() === nombre.trim().toLowerCase() && String(m.id_marca) !== String(req.params.id));
            if (dup) return res.json({ ok: false, msg: 'Ya existe otra marca con ese nombre' });
            await Marca.update(req.params.id, { nombre: nombre.trim() }); res.json({ ok: true, msg: 'Marca actualizada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try {
            const enUso = (await Equipo.findAll()).some(e => String(e.id_marca) === String(req.params.id));
            if (enUso) return res.json({ ok: false, msg: 'No se puede eliminar: hay equipos asociados a esta marca' });
            await Marca.delete(req.params.id); res.json({ ok: true, msg: 'Marca eliminada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = MarcaController;
