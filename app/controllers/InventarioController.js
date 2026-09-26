const Inventario = require('../models/Inventario');
const Equipo = require('../models/Equipo');
const UbicacionFisica = require('../models/UbicacionFisica');
const { requerido, esNumeroPositivo, esCodigoValido, enumValido } = require('../helpers/validators');

const ESTADOS_VALIDOS = ['Operativo', 'No operativo', 'En Reparacion', 'Dañado'];

function validarInventario({ id_equipos, id_ubicacion_fisica, serial, estado }) {
    if (!requerido(id_equipos, id_ubicacion_fisica, serial, estado)) return 'Complete todos los campos';
    if (!esNumeroPositivo(id_equipos)) return 'Seleccione un equipo válido';
    if (!esNumeroPositivo(id_ubicacion_fisica)) return 'Seleccione una ubicación válida';
    if (!esCodigoValido(serial)) return 'El serial debe tener entre 2 y 50 caracteres (letras, números, guiones)';
    if (!enumValido(estado, ESTADOS_VALIDOS)) return 'El estado seleccionado no es válido';
    return null;
}

const InventarioController = {
    async listar(req, res) {
        try {
            const [inventario, equipos, ubicaciones] = await Promise.all([Inventario.findAll(), Equipo.findAll(), UbicacionFisica.findAll()]);
            res.json({ ok: true, inventario, equipos, ubicaciones });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_equipos, id_ubicacion_fisica, serial, estado } = req.body;
        const error = validarInventario({ id_equipos, id_ubicacion_fisica, serial, estado });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const dup = (await Inventario.findAll()).some(i => i.serial.trim().toLowerCase() === serial.trim().toLowerCase());
            if (dup) return res.json({ ok: false, msg: 'Ya existe un equipo en inventario con ese serial' });
            const id = await Inventario.create({ id_equipos, id_ubicacion_fisica, serial: serial.trim(), estado }); res.json({ ok: true, id, msg: 'Equipo agregado al inventario' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { id_equipos, id_ubicacion_fisica, serial, estado } = req.body;
        const error = validarInventario({ id_equipos, id_ubicacion_fisica, serial, estado });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const dup = (await Inventario.findAll()).some(i => i.serial.trim().toLowerCase() === serial.trim().toLowerCase() && String(i.id_inventario) !== String(req.params.id));
            if (dup) return res.json({ ok: false, msg: 'Ya existe otro equipo en inventario con ese serial' });
            await Inventario.update(req.params.id, { id_equipos, id_ubicacion_fisica, serial: serial.trim(), estado }); res.json({ ok: true, msg: 'Registro actualizado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Inventario.delete(req.params.id); res.json({ ok: true, msg: 'Registro eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = InventarioController;
