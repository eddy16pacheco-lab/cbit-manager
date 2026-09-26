const nodemailer = require('nodemailer');
require('dotenv').config();

// ── Cola de correos pendientes ─────────────────────────────────────────────
const colaCorreos = [];
let procesandoCola = false;

// Configurar transporter UNA sola vez (conexión reutilizable)
const transporter = nodemailer.createTransport({
    host:   process.env.MAIL_HOST   || 'smtp.gmail.com',
    port:   parseInt(process.env.MAIL_PORT || '587'),
    secure: process.env.MAIL_SECURE === 'true',
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS
    },
    // Mantener conexión abierta para reutilizarla (evita reconectar cada vez)
    pool:            true,
    maxConnections:  2,
    maxMessages:     10,
    rateDelta:       1000,
    rateLimit:       3
});

// ── Procesar la cola en segundo plano ──────────────────────────────────────
async function procesarCola() {
    if (procesandoCola || colaCorreos.length === 0) return;
    procesandoCola = true;

    while (colaCorreos.length > 0) {
        const { opciones, resolve } = colaCorreos.shift();
        try {
            await transporter.sendMail(opciones);
            console.log(`📧 Correo enviado a ${opciones.to}`);
            resolve({ ok: true });
        } catch(e) {
            console.error(`❌ Error enviando correo a ${opciones.to}:`, e.message);
            resolve({ ok: false, msg: e.message });
        }
    }

    procesandoCola = false;
}

// ── Plantilla HTML ─────────────────────────────────────────────────────────
function plantillaCorreo({ estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos }) {
    const aprobado = estado === 'Aprobado';
    const color    = aprobado ? '#10B981' : '#EF4444';
    const titulo   = aprobado ? 'Solicitud Aprobada' : 'Solicitud No Aprobada';
    const mensaje  = aprobado
        ? 'Tu solicitud de uso del espacio ha sido <strong>aprobada</strong>. La reserva queda confirmada en el calendario del CBIT.'
        : 'Lamentablemente tu solicitud ha sido <strong>rechazada</strong>. Puedes realizar una nueva solicitud con otro horario.';

    const equiposHTML = equipos && equipos.length
        ? equipos.map(e => `<div style="padding:6px 0;border-bottom:1px solid #e5e7eb;font-size:13px">
              <strong>${e.equipo_nombre}</strong> — Serial: <code>${e.serial}</code></div>`).join('')
        : '<div style="font-size:13px;color:#6b7280">Sin equipos asignados</div>';

    return `<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:30px 0">
<tr><td align="center">
<table width="580" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08)">
  <!-- Header -->
  <tr><td style="background:linear-gradient(135deg,#4F46E5,#7C3AED);padding:28px 32px;text-align:center">
    <h1 style="margin:0;color:#fff;font-size:20px">🏫 CBIT Francisco de Miranda</h1>
    <p style="margin:6px 0 0;color:rgba(255,255,255,0.8);font-size:13px">Sistema de Gestión de Reservas</p>
  </td></tr>
  <!-- Estado -->
  <tr><td style="padding:24px 32px 0;text-align:center">
    <div style="display:inline-block;background:${color}18;border:2px solid ${color};border-radius:50px;padding:8px 24px">
      <span style="color:${color};font-size:16px;font-weight:700">${titulo}</span>
    </div>
  </td></tr>
  <!-- Saludo -->
  <tr><td style="padding:20px 32px 0">
    <p style="margin:0;color:#374151;font-size:15px">Estimado/a <strong>${docente}</strong>,</p>
    <p style="margin:10px 0 0;color:#6b7280;font-size:14px;line-height:1.6">${mensaje}</p>
  </td></tr>
  <!-- Detalle -->
  <tr><td style="padding:20px 32px">
    <div style="background:#f9fafb;border-radius:8px;padding:18px;border:1px solid #e5e7eb">
      <h3 style="margin:0 0 14px;color:#111827;font-size:14px">📋 Detalle de la Solicitud</h3>
      <table width="100%" cellpadding="0" cellspacing="0" style="font-size:13px">
        <tr><td style="padding:7px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;width:38%">Actividad</td>
            <td style="padding:7px 0;border-bottom:1px solid #e5e7eb;font-weight:600">${actividad}</td></tr>
        <tr><td style="padding:7px 0;border-bottom:1px solid #e5e7eb;color:#6b7280">Espacio</td>
            <td style="padding:7px 0;border-bottom:1px solid #e5e7eb">${espacio}</td></tr>
        <tr><td style="padding:7px 0;border-bottom:1px solid #e5e7eb;color:#6b7280">Fecha</td>
            <td style="padding:7px 0;border-bottom:1px solid #e5e7eb">${fecha}</td></tr>
        <tr><td style="padding:7px 0;border-bottom:1px solid #e5e7eb;color:#6b7280">Horario</td>
            <td style="padding:7px 0;border-bottom:1px solid #e5e7eb">${hora_inicio} — ${hora_fin}</td></tr>
        <tr><td style="padding:7px 0;border-bottom:1px solid #e5e7eb;color:#6b7280">Descripción</td>
            <td style="padding:7px 0;border-bottom:1px solid #e5e7eb">${descripcion || 'Sin descripción'}</td></tr>
        <tr><td style="padding:7px 0;border-bottom:1px solid #e5e7eb;color:#6b7280">Estado</td>
            <td style="padding:7px 0;border-bottom:1px solid #e5e7eb">
              <span style="background:${color};color:#fff;padding:2px 10px;border-radius:50px;font-size:12px">${estado}</span>
            </td></tr>
      </table>
      <div style="margin-top:12px">
        <p style="margin:0 0 8px;color:#6b7280;font-size:13px">Equipos asignados:</p>
        ${equiposHTML}
      </div>
    </div>
  </td></tr>
  <!-- Footer -->
  <tr><td style="background:#f9fafb;padding:16px 32px;text-align:center;border-top:1px solid #e5e7eb">
    <p style="margin:0;color:#9ca3af;font-size:11px">
      Correo generado automáticamente por CBIT Manager. No responda a este mensaje.
    </p>
  </td></tr>
</table>
</td></tr>
</table>
</body></html>`;
}

// ── Función principal: encola el correo y responde INMEDIATAMENTE ──────────
async function enviarCorreoSolicitud({ correo, estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos }) {
    if (!process.env.MAIL_USER || !process.env.MAIL_PASS) {
        console.warn('⚠️  Correo no configurado. Agrega MAIL_USER y MAIL_PASS en el .env');
        return { ok: false, msg: 'Correo no configurado' };
    }

    const asunto = estado === 'Aprobado'
        ? '✅ Tu solicitud fue aprobada — CBIT Francisco de Miranda'
        : '❌ Tu solicitud no fue aprobada — CBIT Francisco de Miranda';

    const opciones = {
        from:    `"CBIT Manager" <${process.env.MAIL_USER}>`,
        to:      correo,
        subject: asunto,
        html:    plantillaCorreo({ estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos })
    };

    // ✅ Encolar y responder de inmediato — sin await
    return new Promise(resolve => {
        colaCorreos.push({ opciones, resolve });
        // Disparar procesamiento en background (sin bloquear)
        setImmediate(procesarCola);
    }).then(() => ({ ok: true }))
      .catch(() => ({ ok: false }));
}

// Versión "fire and forget" para cuando no necesitas esperar la respuesta
function enviarCorreoBackground({ correo, estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos }) {
    if (!process.env.MAIL_USER || !process.env.MAIL_PASS) return;

    const asunto = estado === 'Aprobado'
        ? '✅ Tu solicitud fue aprobada — CBIT Francisco de Miranda'
        : '❌ Tu solicitud no fue aprobada — CBIT Francisco de Miranda';

    const opciones = {
        from:    `"CBIT Manager" <${process.env.MAIL_USER}>`,
        to:      correo,
        subject: asunto,
        html:    plantillaCorreo({ estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos })
    };

    // Encolar sin esperar resolución — el API responde al instante
    colaCorreos.push({ opciones, resolve: () => {} });
    setImmediate(procesarCola);
}

module.exports = { enviarCorreoSolicitud, enviarCorreoBackground };