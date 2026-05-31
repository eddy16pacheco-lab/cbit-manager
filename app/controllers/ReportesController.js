const db = require('../../config/database');
const Inventario = require('../models/Inventario');
const Solicitud = require('../models/Solicitud');
const Mantenimiento = require('../models/Mantenimiento');
const DetalleSolicitud = require('../models/DetalleSolicitud');
const Usuario = require('../models/Usuario');
const Actividad = require('../models/Actividad');

const ReportesController = {
    async resumenGeneral(req, res) {
        try {
            const [inventario, solicitudes, mantenimientos] = await Promise.all([
                Inventario.findAll(), Solicitud.findAll(), Mantenimiento.findAll()
            ]);
            const inv_stats = {
                total: inventario.length,
                operativo: inventario.filter(i=>i.estado==='Operativo').length,
                en_reparacion: inventario.filter(i=>i.estado==='En Reparacion').length,
                no_operativo: inventario.filter(i=>i.estado==='No operativo').length,
                daniado: inventario.filter(i=>i.estado==='Dañado').length,
            };
            const sol_stats = {
                total: solicitudes.length,
                aprobadas: solicitudes.filter(s=>s.estado==='Aprobado').length,
                pendientes: solicitudes.filter(s=>s.estado==='Pendiente').length,
                canceladas: solicitudes.filter(s=>s.estado==='Cancelado').length,
                completadas: solicitudes.filter(s=>s.estado==='Completado').length,
            };
            const espacioCount = {};
            solicitudes.forEach(s => { const k=s.espacio_nombre||'N/A'; espacioCount[k]=(espacioCount[k]||0)+1; });
            const top_espacios = Object.entries(espacioCount).sort((a,b)=>b[1]-a[1]).slice(0,5).map(([nombre,total])=>({nombre,total}));
            const actCount = {};
            solicitudes.forEach(s => { const k=s.actividad_nombre||'N/A'; actCount[k]=(actCount[k]||0)+1; });
            const top_actividades = Object.entries(actCount).sort((a,b)=>b[1]-a[1]).slice(0,5).map(([nombre,total])=>({nombre,total}));
            const man_stats = {
                total: mantenimientos.length,
                alta: mantenimientos.filter(m=>m.nivel_prioridad==='Alta').length,
                media: mantenimientos.filter(m=>m.nivel_prioridad==='Media').length,
                baja: mantenimientos.filter(m=>m.nivel_prioridad==='Baja').length,
            };
            res.json({ ok: true, inv_stats, sol_stats, top_espacios, top_actividades, man_stats, inventario, solicitudes, mantenimientos });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async disponibilidadEquipos(req, res) {
        try { const inventario = await Inventario.findAll(); res.json({ ok: true, inventario }); }
        catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async usuariosGeneral(req, res) {
        try {
            const [rows] = await db.execute(
                `SELECT u.id_usuario, u.nombre_usuario, u.correo, u.estado, u.roles,
                        p.nombre, p.apellido, p.cedula, p.telefono,
                        (SELECT COUNT(*) FROM solicitud s WHERE s.id_usuario=u.id_usuario) AS total_solicitudes
                 FROM usuario u LEFT JOIN persona p ON u.id_persona=p.id_persona
                 ORDER BY u.roles, p.apellido`
            );
            res.json({ ok: true, usuarios: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async equiposTecnologicos(req, res) {
        try {
            const [rows] = await db.execute(
                `SELECT i.id_inventario, i.serial, i.estado,
                        e.nombre AS equipo_nombre, c.nombre AS categoria,
                        ma.nombre AS marca, mo.nombre AS modelo,
                        u.nombre AS ubicacion
                 FROM inventario i
                 LEFT JOIN equipos e ON i.id_equipos=e.id_equipos
                 LEFT JOIN categoria c ON e.id_categoria=c.id_categoria
                 LEFT JOIN marca ma ON e.id_marca=ma.id_marca
                 LEFT JOIN modelo mo ON e.id_modelo=mo.id_modelo
                 LEFT JOIN ubicacion_fisica u ON i.id_ubicacion_fisica=u.id_ubicacion_fisica
                 ORDER BY c.nombre, e.nombre, i.serial`
            );
            res.json({ ok: true, equipos: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async reservasEquipos(req, res) {
        try {
            const rows = await DetalleSolicitud.reservasEquipos();
            res.json({ ok: true, reservas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async reservasEspacios(req, res) {
        try {
            const rows = await Solicitud.reservasEspacios();
            res.json({ ok: true, reservas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async actividadesEducativas(req, res) {
        try {
            const [rows] = await db.execute(
                `SELECT a.id_actividad, a.nombre, a.descripcion_actividad,
                        COUNT(s.id_solicitud) AS total_solicitudes,
                        SUM(CASE WHEN s.estado='Aprobado' THEN 1 ELSE 0 END) AS aprobadas,
                        SUM(CASE WHEN s.estado='Completado' THEN 1 ELSE 0 END) AS completadas,
                        MAX(s.fecha) AS ultima_fecha
                 FROM actividad a LEFT JOIN solicitud s ON a.id_actividad=s.id_actividad
                 GROUP BY a.id_actividad ORDER BY total_solicitudes DESC`
            );
            res.json({ ok: true, actividades: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async fallasTecnicas(req, res) {
        try {
            const [rows] = await db.execute(
                `SELECT m.id_mantenimiento, m.fecha_reporte, m.nivel_prioridad,
                        e.nombre AS equipo_nombre, c.nombre AS categoria,
                        inv.serial, me.descripcion_fallas,
                        p.nombre AS tec_nombre, p.apellido AS tec_apellido,
                        t.especialidad
                 FROM mantenimiento m
                 LEFT JOIN tecnicos t ON m.id_tecnicos=t.id_tecnicos
                 LEFT JOIN persona p ON t.id_persona=p.id_persona
                 LEFT JOIN mantenimiento_equipos me ON m.id_mantenimiento=me.id_mantenimiento
                 LEFT JOIN equipos e ON me.id_equipos=e.id_equipos
                 LEFT JOIN categoria c ON e.id_categoria=c.id_categoria
                 LEFT JOIN inventario inv ON inv.id_equipos=e.id_equipos
                 ORDER BY m.nivel_prioridad='Alta' DESC, m.fecha_reporte DESC`
            );
            res.json({ ok: true, fallas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async mantenimientoEquipos(req, res) {
        try {
            const mantenimientos = await Mantenimiento.findAll();
            res.json({ ok: true, mantenimientos });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async maquinasMasUsadas(req, res) {
        try {
            const rows = await DetalleSolicitud.maquinasMasUsadas();
            res.json({ ok: true, maquinas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = ReportesController;
