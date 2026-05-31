const Inventario = require('../models/Inventario');
const Equipo = require('../models/Equipo');
const UbicacionFisica = require('../models/UbicacionFisica');

const InventarioController = {
    async listar(req, res) {
        try {
            const [inventario, equipos, ubicaciones] = await Promise.all([Inventario.findAll(), Equipo.findAll(), UbicacionFisica.findAll()]);
            res.json({ ok: true, inventario, equipos, ubicaciones });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_equipos, id_ubicacion_fisica, serial, estado } = req.body;
        if (!id_equipos || !id_ubicacion_fisica || !serial || !estado) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Inventario.create({ id_equipos, id_ubicacion_fisica, serial, estado }); res.json({ ok: true, id, msg: 'Equipo agregado al inventario' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { id_equipos, id_ubicacion_fisica, serial, estado } = req.body;
        if (!id_equipos || !id_ubicacion_fisica || !serial || !estado) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { await Inventario.update(req.params.id, { id_equipos, id_ubicacion_fisica, serial, estado }); res.json({ ok: true, msg: 'Registro actualizado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Inventario.delete(req.params.id); res.json({ ok: true, msg: 'Registro eliminado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = InventarioController;
