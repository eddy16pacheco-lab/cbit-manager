/**
 * RF-57: Generación programada de reportes (diario/semanal)
 * Se ejecuta automáticamente al iniciar el servidor
 * Guarda el histórico en la tabla notificacion para el admin
 */
const db = require('../../config/database');

async function generarReporteProgramado(tipo) {
    try {
        // Reporte de máquinas más usadas
        const [maquinas] = await db.execute(
            `SELECT e.nombre AS equipo, COUNT(ds.id_detalle_solicitud) AS usos
             FROM detalle_solicitud ds
             JOIN inventario i ON ds.id_inventario=i.id_inventario
             JOIN equipos e ON i.id_equipos=e.id_equipos
             GROUP BY e.id_equipos ORDER BY usos DESC LIMIT 5`
        );

        // Reporte de disponibilidad
        const [disponibilidad] = await db.execute(
            `SELECT i.estado, COUNT(*) AS total
             FROM inventario i GROUP BY i.estado`
        );

        const resumenMaquinas = maquinas.map(m => `${m.equipo}: ${m.usos} usos`).join(', ');
        const resumenDisp = disponibilidad.map(d => `${d.estado}: ${d.total}`).join(', ');

        const titulo  = `Reporte ${tipo} automático — ${new Date().toLocaleDateString('es-ES')}`;
        const mensaje = `Máquinas más usadas: ${resumenMaquinas || 'Sin datos'}. Estado inventario: ${resumenDisp}`;

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
