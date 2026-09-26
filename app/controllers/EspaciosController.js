const Espacio = require('../models/Espacio');
const { requerido, esNumeroPositivo, esNombreCatalogoValido } = require('../helpers/validators');

function validarEspacio({ nombre, capacidad }) {
    if (!requerido(nombre, capacidad)) return 'Complete todos los campos';
    if (!esNombreCatalogoValido(nombre)) return 'El nombre debe tener entre 3 y 40 caracteres';
    if (!esNumeroPositivo(capacidad)) return 'La capacidad debe ser un número entero mayor a 0';
    if (Number(capacidad) > 1000) return 'La capacidad indicada parece demasiado alta, verifique el dato';
    return null;
}

const EspaciosController = {
    async listar(req, res) {
        try { const espacios = await Espacio.findAll(); res.json({ ok: true, espacios }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, capacidad } = req.body;
        const error = validarEspacio({ nombre, capacidad });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const dup = (await Espacio.findAll()).some(e => e.nombre.trim().toLowerCase() === nombre.trim().toLowerCase());
            if (dup) return res.json({ ok: false, msg: 'Ya existe un espacio con ese nombre' });
            const id = await Espacio.create({ nombre: nombre.trim(), capacidad }); res.json({ ok: true, id, msg: 'Espacio registrado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, capacidad } = req.body;
        const error = validarEspacio({ nombre, capacidad });
        if (error) return res.json({ ok: false, msg: error });
        try { await Espacio.update(req.params.id, { nombre: nombre.trim(), capacidad }); res.json({ ok: true, msg: 'Espacio actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Espacio.delete(req.params.id); res.json({ ok: true, msg: 'Espacio eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = EspaciosController;
