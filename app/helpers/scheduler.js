/**
 * RF-57: Generación programada de reportes (diario/semanal)
 * Se ejecuta automáticamente al iniciar el servidor
 * Guarda el histórico en la tabla notificacion para el admin
 */
const db = require('../../config/database');
const { validarRango } = require('./reportFilters');
const _iso = d => (d instanceof Date ? d.toISOString() : String(d)).slice(0, 10);

// Período que cubre cada reporte programado (todo reporte lleva Fecha de Inicio y Fecha de Fin):
//   diario  -> el día de hoy
//   semanal -> los 7 días anteriores (de hace 7 días a ayer)
const PERIODOS = {
    diario:  { desde: 'CURDATE()',                         hasta: 'CURDATE()' },
    semanal: { desde: 'DATE_SUB(CURDATE(), INTERVAL 7 DAY)', hasta: 'DATE_SUB(CURDATE(), INTERVAL 1 DAY)' },
};
const fmt = d => (d instanceof Date ? d.toISOString() : String(d)).slice(0, 10).split('-').reverse().join('/');

async function generarReporteProgramado(tipo) {
    try {
        const p = PERIODOS[tipo];
        if (!p) throw new Error(`Tipo de reporte programado no válido: ${tipo}`);
        const [[rango]] = await db.execute(`SELECT ${p.desde} AS desde, ${p.hasta} AS hasta`);
        const error = validarRango(_iso(rango.desde), _iso(rango.hasta));
        if (error) throw new Error(error);

        // Reporte de máquinas más usadas dentro del período
        const [maquinas] = await db.execute(
            `SELECT e.nombre AS equipo, COUNT(ds.id_detalle_solicitud) AS usos
             FROM detalle_solicitud ds
             JOIN solicitud s ON ds.id_solicitud=s.id_solicitud
             JOIN inventario i ON ds.id_inventario=i.id_inventario
             JOIN equipos e ON i.id_equipos=e.id_equipos
             WHERE s.fecha BETWEEN ? AND ?
             GROUP BY e.id_equipos ORDER BY usos DESC LIMIT 5`,
            [rango.desde, rango.hasta]
        );

        // Reporte de disponibilidad (estado actual del inventario)
        const [disponibilidad] = await db.execute(
            `SELECT i.estado, COUNT(*) AS total
             FROM inventario i GROUP BY i.estado`
        );

        const periodo = `${fmt(rango.desde)} al ${fmt(rango.hasta)}`;
        const resumenMaquinas = maquinas.map(m => `${m.equipo}: ${m.usos} usos`).join(', ');
        const resumenDisp = disponibilidad.map(d => `${d.estado}: ${d.total}`).join(', ');

        // notificacion.titulo admite solo 30 caracteres: el período completo va en el mensaje
        const corto = d => fmt(d).slice(0, 5);
        const titulo = (_iso(rango.desde) === _iso(rango.hasta)
            ? `Reporte ${tipo} ${fmt(rango.hasta)}`
            : `Reporte ${tipo} ${corto(rango.desde)} al ${corto(rango.hasta)}`).slice(0, 30);
        const mensaje = `Período: ${periodo}. Máquinas más usadas: ${resumenMaquinas || 'Sin datos'}. Estado actual del inventario: ${resumenDisp}`;

        // Guardar en notificaciones para todos los admins
        const [admins] = await db.execute(
            "SELECT id_usuario FROM usuario WHERE roles='Administrador' AND estado='Activo'"
        );
        for (const admin of admins) {
            await db.execute(
                'INSERT INTO notificacion (id_usuario, titulo, mensaje, fecha_envio, leida, tipo) VALUES (?,?,?,NOW(),0,?)',
                [admin.id_usuario, titulo, mensaje, 'reporte']
            );
        }
        console.log(`📊 Reporte ${tipo} generado: ${new Date().toLocaleString('es-ES')}`);
    } catch(e) {
        console.error('Error en reporte programado:', e.message);
    }
}

function iniciarScheduler() {
    // Reporte diario a las 23:00
    function programarDiario() {
        const ahora   = new Date();
        const mañana  = new Date(ahora);
        mañana.setDate(mañana.getDate() + 1);
        mañana.setHours(23, 0, 0, 0);
        const ms = mañana - ahora;
        setTimeout(async () => {
            await generarReporteProgramado('diario');
            setInterval(() => generarReporteProgramado('diario'), 24 * 60 * 60 * 1000);
        }, ms);
    }

    // Reporte semanal los lunes a las 8:00
    function programarSemanal() {
        const ahora  = new Date();
        const lunes  = new Date(ahora);
        const diasHastaLunes = (8 - lunes.getDay()) % 7 || 7;
        lunes.setDate(lunes.getDate() + diasHastaLunes);
        lunes.setHours(8, 0, 0, 0);
        const ms = lunes - ahora;
        setTimeout(async () => {
            await generarReporteProgramado('semanal');
            setInterval(() => generarReporteProgramado('semanal'), 7 * 24 * 60 * 60 * 1000);
        }, ms);
    }

    programarDiario();
    programarSemanal();
    console.log('⏰ Scheduler RF-57 iniciado: reportes diarios (23:00) y semanales (lunes 08:00)');
}

module.exports = { iniciarScheduler, generarReporteProgramado };
