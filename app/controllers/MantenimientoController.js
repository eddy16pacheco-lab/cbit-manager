const Mantenimiento = require('../models/Mantenimiento');
const Tecnico = require('../models/Tecnico');
const Equipo = require('../models/Equipo');
const Inventario = require('../models/Inventario');
const { requerido, esNumeroPositivo, enumValido, longitudValida } = require('../helpers/validators');

const PRIORIDADES_VALIDAS = ['Alta', 'Media', 'Baja'];

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
        if (!requerido(id_tecnicos, nivel_prioridad, id_equipos, descripcion_fallas))
            return res.json({ ok: false, msg: 'Complete todos los campos requeridos' });
        if (!esNumeroPositivo(id_tecnicos)) return res.json({ ok: false, msg: 'Seleccione un técnico válido' });
        if (!esNumeroPositivo(id_equipos)) return res.json({ ok: false, msg: 'Seleccione un equipo válido' });
        if (!enumValido(nivel_prioridad, PRIORIDADES_VALIDAS)) return res.json({ ok: false, msg: 'El nivel de prioridad debe ser Alta, Media o Baja' });
        if (!longitudValida(descripcion_fallas, 5, 200)) return res.json({ ok: false, msg: 'La descripción de la falla debe tener entre 5 y 200 caracteres' });
        try {
            const id = await Mantenimiento.create({ id_tecnicos, nivel_prioridad, id_equipos, descripcion_fallas: descripcion_fallas.trim() });
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
