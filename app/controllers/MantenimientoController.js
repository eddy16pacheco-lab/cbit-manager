const Mantenimiento = require('../models/Mantenimiento');
const Tecnico = require('../models/Tecnico');
const Equipo = require('../models/Equipo');
const Inventario = require('../models/Inventario');

const MantenimientoController = {
    async listar(req, res) {
        try {
            const [mantenimientos, tecnicos, equipos, inventario] = await Promise.all([
                Mantenimiento.findAll(), Tecnico.findAll(), Equipo.findAll(), Inventario.findAll()
            ]);
            res.json({ ok: true, mantenimientos, tecnicos, equipos, inventario });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_tecnicos, nivel_prioridad, id_equipos, descripcion_fallas } = req.body;
        if (!id_tecnicos || !nivel_prioridad || !id_equipos || !descripcion_fallas)
            return res.json({ ok: false, msg: 'Complete todos los campos requeridos' });
        try {
            const id = await Mantenimiento.create({ id_tecnicos, nivel_prioridad, id_equipos, descripcion_fallas });
            res.json({ ok: true, id, msg: 'Reporte de mantenimiento registrado' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try {
            await Mantenimiento.delete(req.params.id);
            res.json({ ok: true, msg: 'Reporte eliminado' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = MantenimientoController;
