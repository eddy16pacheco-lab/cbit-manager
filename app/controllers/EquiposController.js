const Equipo = require('../models/Equipo');
const Categoria = require('../models/Categoria');
const Marca = require('../models/Marca');
const Modelo = require('../models/Modelo');
const Inventario = require('../models/Inventario');
const { requerido, esNumeroPositivo, esNombreCatalogoValido } = require('../helpers/validators');

function validarEquipo({ nombre, id_categoria, id_marca }) {
    if (!requerido(nombre, id_categoria, id_marca)) return 'Complete todos los campos requeridos';
    if (!esNombreCatalogoValido(nombre)) return 'El nombre del equipo debe tener entre 3 y 40 caracteres';
    if (!esNumeroPositivo(id_categoria)) return 'Seleccione una categoría válida';
    if (!esNumeroPositivo(id_marca)) return 'Seleccione una marca válida';
    return null;
}

const EquiposController = {
    async listar(req, res) {
        try {
            const [equipos, categorias, marcas, modelos] = await Promise.all([Equipo.findAll(), Categoria.findAll(), Marca.findAll(), Modelo.findAll()]);
            res.json({ ok: true, equipos, categorias, marcas, modelos });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, id_categoria, id_marca, id_modelo } = req.body;
        const error = validarEquipo({ nombre, id_categoria, id_marca });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const categorias = await Categoria.findAll();
            const marcas = await Marca.findAll();
            if (!categorias.some(c => String(c.id_categoria) === String(id_categoria))) return res.json({ ok: false, msg: 'La categoría seleccionada no existe' });
            if (!marcas.some(m => String(m.id_marca) === String(id_marca))) return res.json({ ok: false, msg: 'La marca seleccionada no existe' });
            const id = await Equipo.create({ nombre: nombre.trim(), id_categoria, id_marca, id_modelo: id_modelo || null }); res.json({ ok: true, id, msg: 'Equipo registrado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, id_categoria, id_marca, id_modelo } = req.body;
        const error = validarEquipo({ nombre, id_categoria, id_marca });
        if (error) return res.json({ ok: false, msg: error });
        try { await Equipo.update(req.params.id, { nombre: nombre.trim(), id_categoria, id_marca, id_modelo: id_modelo || null }); res.json({ ok: true, msg: 'Equipo actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try {
            const enUso = (await Inventario.findAll()).some(i => String(i.id_equipos) === String(req.params.id));
            if (enUso) return res.json({ ok: false, msg: 'No se puede eliminar: el equipo tiene unidades en inventario' });
            await Equipo.delete(req.params.id); res.json({ ok: true, msg: 'Equipo eliminado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = EquiposController;
