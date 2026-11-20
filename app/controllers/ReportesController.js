const db = require('../../config/database');
const Inventario = require('../models/Inventario');
const Solicitud = require('../models/Solicitud');
const Mantenimiento = require('../models/Mantenimiento');
const DetalleSolicitud = require('../models/DetalleSolicitud');
const Usuario = require('../models/Usuario');
const Actividad = require('../models/Actividad');
const { ENUMS, leerFiltros, estadoPermitido, Where } = require('../helpers/reportFilters');

// Fecha (Date o 'YYYY-MM-DD...') dentro del rango [desde, hasta] inclusivo
const _iso = d => (d instanceof Date ? d.toISOString() : String(d ?? '')).slice(0, 10);
const enRango = (d, f) => { const x = _iso(d); return x >= f.desde && x <= f.hasta; };

// Lee filtros de la petición; el rango de fechas es obligatorio en TODOS los reportes.
// Si es inválido o falta, responde el error y devuelve null.
function filtrosDe(req, res) {
    const { filtros, error } = leerFiltros(req.query);
    if (error) { res.json({ ok: false, msg: error }); return null; }
    return filtros;
}

// Consulta compartida por "Fallas Técnicas" y "Mantenimiento".
// OJO: la tabla `mantenimiento` no tiene columna de estado propia; el "estado"
// que se filtra/muestra es el estado ACTUAL del equipo en inventario (se edita en el
// módulo Inventario; reportar una avería NO lo cambia por sí solo).
async function consultaMantenimiento(f, prioridadPrimero) {
    const w = new Where();
    w.rangoFecha('m.fecha_reporte', f);
    if (f.prioridad)  w.add('m.nivel_prioridad = ?', f.prioridad);
    if (f.id_tecnico) w.add('m.id_tecnicos = ?', f.id_tecnico);
    if (f.estado)     w.add('inv.estado = ?', f.estado);
    const orden = prioridadPrimero
        ? "m.nivel_prioridad='Alta' DESC, m.fecha_reporte DESC"
        : 'm.fecha_reporte DESC';
    const [rows] = await db.execute(
        `SELECT m.id_mantenimiento, m.fecha_reporte, m.nivel_prioridad, m.id_tecnicos,
                e.nombre AS equipo_nombre, c.nombre AS categoria,
                inv.serial, inv.estado AS estado_equipo, me.descripcion_fallas,
                p.nombre AS tec_nombre, p.apellido AS tec_apellido, t.especialidad
         FROM mantenimiento m
         LEFT JOIN tecnicos t ON m.id_tecnicos=t.id_tecnicos
         LEFT JOIN persona p ON t.id_persona=p.id_persona
         LEFT JOIN mantenimiento_equipos me ON m.id_mantenimiento=me.id_mantenimiento
         LEFT JOIN equipos e ON me.id_equipos=e.id_equipos
         LEFT JOIN categoria c ON e.id_categoria=c.id_categoria
         LEFT JOIN inventario inv ON inv.id_equipos=e.id_equipos
         ${w.sql()}
         ORDER BY ${orden}`,
        w.params
    );
    return rows;
}

const ReportesController = {
    // Solicitudes y mantenimientos se limitan al rango de fechas; el estado del inventario es el actual.
    async resumenGeneral(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            const [inventario, todasSol, todosMant] = await Promise.all([
                Inventario.findAll(), Solicitud.findAll(), Mantenimiento.findAll()
            ]);
            const solicitudes = todasSol.filter(s => enRango(s.fecha, f));
            const mantenimientos = todosMant.filter(m => enRango(m.fecha_reporte, f));
            const inv_stats = {
                total: inventario.filter(i=>i.estado!=='Desincorporado').length,
                operativo: inventario.filter(i=>i.estado==='Operativo').length,
                en_reparacion: inventario.filter(i=>i.estado==='En Reparacion').length,
                no_operativo: inventario.filter(i=>i.estado==='No operativo').length,
                daniado: inventario.filter(i=>i.estado==='Dañado').length,
                desincorporado: inventario.filter(i=>i.estado==='Desincorporado').length,
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
            res.json({ ok: true, rango: { desde: f.desde, hasta: f.hasta }, inv_stats, sol_stats, top_espacios, top_actividades, man_stats, inventario, solicitudes, mantenimientos });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async disponibilidadEquipos(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoEquipo)) return res.json({ ok: false, msg: 'Estado de equipo no válido.' });
            let inventario = await Inventario.findAll();
            if (f.estado) inventario = inventario.filter(i => i.estado === f.estado);
            // Reservas de cada unidad dentro del rango (excluye canceladas)
            const w = new Where().rangoFecha('s.fecha', f);
            const [usos] = await db.execute(
                `SELECT ds.id_inventario, COUNT(*) AS total
                 FROM detalle_solicitud ds JOIN solicitud s ON s.id_solicitud = ds.id_solicitud
                 WHERE s.estado <> 'Cancelado' AND ${w.cond.join(' AND ')}
                 GROUP BY ds.id_inventario`, w.params
            );
            const mapa = new Map(usos.map(u => [u.id_inventario, u.total]));
            inventario = inventario.map(i => ({ ...i, reservas_periodo: mapa.get(i.id_inventario) || 0 }));
            res.json({ ok: true, inventario });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Filtros: rol, estado (Activo/Inactivo/Bloqueado)
    async usuariosGeneral(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoUsuario)) return res.json({ ok: false, msg: 'Estado de usuario no válido.' });
            const w = new Where();
            if (f.rol)    w.add('u.roles = ?', f.rol);
            if (f.estado) w.add('u.estado = ?', f.estado);
            // total_solicitudes = solicitudes del usuario DENTRO del rango de fechas
            const sub = new Where().rangoFecha('s.fecha', f);
            const [rows] = await db.execute(
                `SELECT u.id_usuario, u.nombre_usuario, u.correo, u.estado, u.roles,
                        p.nombre, p.apellido, p.cedula, p.telefono,
                        (SELECT COUNT(*) FROM solicitud s WHERE s.id_usuario=u.id_usuario AND ${sub.cond.join(' AND ')}) AS total_solicitudes
                 FROM usuario u LEFT JOIN persona p ON u.id_persona=p.id_persona
                 ${w.sql()}
                 ORDER BY u.roles, p.apellido`,
                [...sub.params, ...w.params]
            );
            res.json({ ok: true, usuarios: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Filtro: estado del equipo
    async equiposTecnologicos(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoEquipo)) return res.json({ ok: false, msg: 'Estado de equipo no válido.' });
            const w = new Where();
            if (f.estado) w.add('i.estado = ?', f.estado);
            // reservas_periodo = reservas (no canceladas) de la unidad dentro del rango de fechas
            const sub = new Where().rangoFecha('s.fecha', f);
            const [rows] = await db.execute(
                `SELECT i.id_inventario, i.codigo_bien_nacional, i.serial, i.estado,
                        (SELECT COUNT(*) FROM detalle_solicitud ds JOIN solicitud s ON s.id_solicitud = ds.id_solicitud
                          WHERE ds.id_inventario = i.id_inventario AND s.estado <> 'Cancelado' AND ${sub.cond.join(' AND ')}) AS reservas_periodo,
                        e.nombre AS equipo_nombre, c.nombre AS categoria,
                        ma.nombre AS marca, mo.nombre AS modelo,
                        u.nombre AS ubicacion
                 FROM inventario i
                 LEFT JOIN equipos e ON i.id_equipos=e.id_equipos
                 LEFT JOIN categoria c ON e.id_categoria=c.id_categoria
                 LEFT JOIN marca ma ON e.id_marca=ma.id_marca
                 LEFT JOIN modelo mo ON e.id_modelo=mo.id_modelo
                 LEFT JOIN ubicacion_fisica u ON i.id_ubicacion_fisica=u.id_ubicacion_fisica
                 ${w.sql()}
                 ORDER BY c.nombre, e.nombre, i.serial`,
                [...sub.params, ...w.params]
            );
            res.json({ ok: true, equipos: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Filtros: desde, hasta, estado (solicitud)
    async reservasEquipos(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoSolicitud)) return res.json({ ok: false, msg: 'Estado de reserva no válido.' });
            const rows = await DetalleSolicitud.reservasEquipos(f);
            res.json({ ok: true, reservas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async reservasEspacios(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoSolicitud)) return res.json({ ok: false, msg: 'Estado de reserva no válido.' });
            const rows = await Solicitud.reservasEspacios(f);
            res.json({ ok: true, reservas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Filtros: desde, hasta (aplican sobre la fecha de las solicitudes de cada actividad)
    async actividadesEducativas(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            const w = new Where().rangoFecha('s.fecha', f);
            const extra = w.cond.length ? ' AND ' + w.cond.join(' AND ') : '';
            const [rows] = await db.execute(
                `SELECT a.id_actividad, a.nombre, a.descripcion_actividad,
                        COUNT(s.id_solicitud) AS total_solicitudes,
                        SUM(CASE WHEN s.estado='Aprobado' THEN 1 ELSE 0 END) AS aprobadas,
                        SUM(CASE WHEN s.estado='Completado' THEN 1 ELSE 0 END) AS completadas,
                        MAX(s.fecha) AS ultima_fecha
                 FROM actividad a LEFT JOIN solicitud s ON a.id_actividad=s.id_actividad${extra}
                 GROUP BY a.id_actividad ORDER BY total_solicitudes DESC`,
                w.params
            );
            res.json({ ok: true, actividades: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Filtros: desde, hasta, prioridad, estado (del equipo), id_tecnico
    async fallasTecnicas(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoEquipo)) return res.json({ ok: false, msg: 'Estado no válido.' });
            res.json({ ok: true, fallas: await consultaMantenimiento(f, true) });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    async mantenimientoEquipos(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            if (!estadoPermitido(f, ENUMS.estadoEquipo)) return res.json({ ok: false, msg: 'Estado no válido.' });
            res.json({ ok: true, mantenimientos: await consultaMantenimiento(f, false) });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Filtros: desde, hasta, orden (desc = más usadas / asc = menos usadas), limite (5|10|todos)
    async maquinasMasUsadas(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            const rows = await DetalleSolicitud.maquinasMasUsadas(f);
            res.json({ ok: true, maquinas: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // RF: reporte de asistencia ordenado por los datos del docente, mostrando
    // también la actividad realizada en cada evento. Filtros: desde, hasta.
    async asistenciaReporte(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            const usuarioSesion = req.session.usuario;
            const esAdmin = usuarioSesion?.roles === 'Administrador';
            const w = new Where().rangoFecha('s.fecha', f);
            if (!esAdmin) w.add('u.id_usuario = ?', usuarioSesion.id_usuario);

            const [rows] = await db.execute(
                `SELECT
                    a.id_asistencia, a.asistio,
                    s.id_solicitud, s.fecha, s.hora_inicio, s.hora_fin,
                    act.nombre AS actividad_nombre,
                    esp.nombre AS espacio_nombre,
                    pdoc.nombre AS docente_nombre, pdoc.apellido AS docente_apellido, pdoc.cedula AS docente_cedula,
                    pest.nombre AS estudiante_nombre, pest.apellido AS estudiante_apellido, pest.cedula AS estudiante_cedula,
                    est.año, est.seccion
                 FROM asistencia a
                 JOIN estudiante est ON a.id_estudiante = est.id_estudiante
                 JOIN persona pest ON est.id_persona = pest.id_persona
                 JOIN solicitud s ON a.id_solicitud = s.id_solicitud
                 JOIN usuario u ON s.id_usuario = u.id_usuario
                 JOIN persona pdoc ON u.id_persona = pdoc.id_persona
                 LEFT JOIN actividad act ON s.id_actividad = act.id_actividad
                 LEFT JOIN espacio esp ON s.id_espacio = esp.id_espacio
                 ${w.sql()}
                 ORDER BY pdoc.apellido ASC, pdoc.nombre ASC, s.fecha DESC, s.hora_inicio ASC`,
                w.params
            );
            res.json({ ok: true, asistencia: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // RF-20 — Reporte personalizado: combina Fecha + Equipo + Usuario.
    // Cada filtro es opcional; los presentes se combinan con AND.
    // Un docente solo puede consultar sus propias reservas (id_usuario se fuerza a la sesión).
    async personalizado(req, res) {
        try {
            const f = filtrosDe(req, res); if (!f) return;
            const sesion = req.session.usuario;
            const esAdmin = sesion?.roles === 'Administrador';
            const idUsuario = esAdmin ? f.id_usuario : sesion.id_usuario;

            const w = new Where().rangoFecha('s.fecha', f);
            if (f.id_equipo) w.add('e.id_equipos = ?', f.id_equipo);
            if (idUsuario)   w.add('s.id_usuario = ?', idUsuario);

            const [rows] = await db.execute(
                `SELECT s.id_solicitud, s.fecha, s.hora_inicio, s.hora_fin, s.estado,
                        p.nombre AS docente_nombre, p.apellido AS docente_apellido, p.cedula AS docente_cedula,
                        e.nombre AS equipo_nombre, i.serial, i.codigo_bien_nacional,
                        a.nombre AS actividad_nombre, esp.nombre AS espacio_nombre
                 FROM solicitud s
                 LEFT JOIN usuario u ON s.id_usuario = u.id_usuario
                 LEFT JOIN persona p ON u.id_persona = p.id_persona
                 LEFT JOIN actividad a ON s.id_actividad = a.id_actividad
                 LEFT JOIN espacio esp ON s.id_espacio = esp.id_espacio
                 LEFT JOIN detalle_solicitud ds ON ds.id_solicitud = s.id_solicitud
                 LEFT JOIN inventario i ON ds.id_inventario = i.id_inventario
                 LEFT JOIN equipos e ON i.id_equipos = e.id_equipos
                 ${w.sql()}
                 ORDER BY s.fecha DESC, s.hora_inicio, s.id_solicitud`,
                w.params
            );
            res.json({ ok: true, registros: rows, restringidoAUsuario: !esAdmin });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },
    // Catálogos para llenar los selectores de la barra de filtros.
    // Los usuarios solo se listan completos al Administrador; un docente solo se ve a sí mismo.
    async opcionesFiltros(req, res) {
        try {
            const sesion = req.session.usuario;
            const esAdmin = sesion?.roles === 'Administrador';
            const [tecnicos] = await db.execute(
                `SELECT t.id_tecnicos AS id, CONCAT(p.nombre,' ',p.apellido) AS nombre, t.especialidad
                 FROM tecnicos t LEFT JOIN persona p ON t.id_persona=p.id_persona
                 ORDER BY p.apellido, p.nombre`
            );
            const [equipos] = await db.execute(
                `SELECT id_equipos AS id, nombre FROM equipos ORDER BY nombre`
            );
            const [usuarios] = await db.execute(
                `SELECT u.id_usuario AS id,
                        CONCAT(COALESCE(p.nombre,''),' ',COALESCE(p.apellido,''),' (',u.nombre_usuario,')') AS nombre
                 FROM usuario u LEFT JOIN persona p ON u.id_persona=p.id_persona
                 ${esAdmin ? '' : 'WHERE u.id_usuario = ?'}
                 ORDER BY p.apellido, p.nombre`,
                esAdmin ? [] : [sesion.id_usuario]
            );
            res.json({
                ok: true, tecnicos, equipos, usuarios, esAdmin,
                estados: {
                    solicitud: ENUMS.estadoSolicitud, equipo: ENUMS.estadoEquipo,
                    usuario: ENUMS.estadoUsuario, rol: ENUMS.rol, prioridad: ENUMS.prioridad,
                }
            });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = ReportesController;
