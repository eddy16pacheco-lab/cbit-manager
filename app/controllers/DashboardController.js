const Inventario = require('../models/Inventario');
const Solicitud = require('../models/Solicitud');

const DashboardController = {
    async stats(req, res) {
        try {
            const inventario = await Inventario.findAll();
            const solicitudes = await Solicitud.findAll();
            res.json({
                ok: true,
                totalEquipos: inventario.length,
                enReparacion: inventario.filter(i => i.estado === 'En Reparacion').length,
                solicitudesPendientes: solicitudes.filter(s => s.estado === 'Pendiente').length,
                reservasAprobadas: solicitudes.filter(s => s.estado === 'Aprobado').length,
                proximasReservas: solicitudes.filter(s => s.estado === 'Aprobado').slice(0, 5)
            });
        } catch (e) {
            console.error(e);
            res.json({ ok: false, msg: 'Error cargando estadísticas' });
        }
    }
};
module.exports = DashboardController;
