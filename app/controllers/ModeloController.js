const Modelo = require('../models/Modelo');
const Equipo = require('../models/Equipo');
const { requerido, esNombreCatalogoValido, longitudValida } = require('../helpers/validators');

function validarModelo({ nombre, descripcion }) {
    if (!requerido(nombre)) return 'El nombre del modelo es requerido';
    if (!esNombreCatalogoValido(nombre)) return 'El nombre debe tener entre 3 y 40 caracteres';
    if (descripcion && !longitudValida(descripcion, 0, 255)) return 'La descripción no debe exceder 255 caracteres';
    return null;
}

const ModeloController = {
    async listar(req, res) {
        try {
            const modelos = await Modelo.findAll();
            const equipos = await Equipo.findAll();
            const data = modelos.map(m => ({ ...m, total_equipos: equipos.filter(e => String(e.id_modelo) === String(m.id_modelo)).length }));
            res.json({ ok: true, modelos: data });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, descripcion } = req.body;
        const error = validarModelo({ nombre, descripcion });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const dup = await Modelo.findByNombre(nombre.trim());
            if (dup) return res.json({ ok: false, msg: 'Ya existe un modelo con ese nombre' });
            const id = await Modelo.create({ nombre: nombre.trim(), descripcion: descripcion?.trim() });
            res.json({ ok: true, id, msg: 'Modelo registrado' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, descripcion } = req.body;
        const error = validarModelo({ nombre, descripcion });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const dup = await Modelo.findByNombre(nombre.trim(), req.params.id);
            if (dup) return res.json({ ok: false, msg: 'Ya existe otro modelo con ese nombre' });
            await Modelo.update(req.params.id, { nombre: nombre.trim(), descripcion: descripcion?.trim() });
            res.json({ ok: true, msg: 'Modelo actualizado' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try {
            const enUso = (await Equipo.findAll()).some(e => String(e.id_modelo) === String(req.params.id));
            if (enUso) return res.json({ ok: false, msg: 'No se puede eliminar: hay equipos asociados a este modelo' });
            await Modelo.delete(req.params.id);
            res.json({ ok: true, msg: 'Modelo eliminado' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = ModeloController;
