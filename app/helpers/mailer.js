const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
    host:   process.env.MAIL_HOST   || 'smtp.gmail.com',
    port:   parseInt(process.env.MAIL_PORT || '587'),
    secure: process.env.MAIL_SECURE === 'true',
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS
    }
});

function plantillaCorreo({ estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos }) {
    const aprobado = estado === 'Aprobado';
    const color    = aprobado ? '#10B981' : '#EF4444';
    const icono    = aprobado ? 'aprobada' : 'rechazada';
    const titulo   = aprobado ? 'Solicitud Aprobada' : 'Solicitud No Aprobada';
    const mensaje  = aprobado
        ? 'Tu solicitud de uso del espacio ha sido <strong>aprobada</strong>. La reserva queda confirmada en el calendario del CBIT.'
        : 'Lamentablemente tu solicitud de uso del espacio ha sido <strong>rechazada</strong>. Puedes realizar una nueva solicitud con otro horario.';
    const equiposHTML = equipos && equipos.length
        ? '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px">Equipos asignados</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;font-size:14px">' + equipos.map(e => e.equipo_nombre + ' - Serial: ' + e.serial).join('<br>') + '</td></tr>'
        : '<tr><td style="padding:10px 0;color:#6b7280;font-size:14px">Equipos</td><td style="padding:10px 0;font-size:14px">Sin equipos asignados</td></tr>';

    return '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,sans-serif">'
        + '<table width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:30px 0"><tr><td align="center">'
        + '<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08)">'
        + '<tr><td style="background:linear-gradient(135deg,#4F46E5,#7C3AED);padding:32px;text-align:center">'
        + '<h1 style="margin:0;color:#fff;font-size:22px">CBIT Francisco de Miranda</h1>'
        + '<p style="margin:8px 0 0;color:rgba(255,255,255,0.8);font-size:14px">Sistema de Gestión de Reservas</p>'
        + '</td></tr>'
        + '<tr><td style="padding:24px 32px 0;text-align:center">'
        + '<div style="display:inline-block;background:' + color + '15;border:2px solid ' + color + ';border-radius:50px;padding:10px 28px">'
        + '<span style="color:' + color + ';font-size:18px;font-weight:700">' + titulo + '</span></div></td></tr>'
        + '<tr><td style="padding:24px 32px 0">'
        + '<p style="margin:0;color:#374151;font-size:15px">Estimado/a <strong>' + docente + '</strong>,</p>'
        + '<p style="margin:12px 0 0;color:#6b7280;font-size:14px;line-height:1.6">' + mensaje + '</p>'
        + '</td></tr>'
        + '<tr><td style="padding:24px 32px">'
        + '<div style="background:#f9fafb;border-radius:8px;padding:20px;border:1px solid #e5e7eb">'
        + '<h3 style="margin:0 0 16px;color:#111827;font-size:15px">Detalle de la Solicitud</h3>'
        + '<table width="100%" cellpadding="0" cellspacing="0">'
        + '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px;width:40%">Actividad</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;font-size:14px;font-weight:600">' + actividad + '</td></tr>'
        + '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px">Espacio</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;font-size:14px">' + espacio + '</td></tr>'
        + '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px">Fecha</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;font-size:14px">' + fecha + '</td></tr>'
        + '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px">Horario</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;font-size:14px">' + hora_inicio + ' - ' + hora_fin + '</td></tr>'
        + '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px">Descripcion</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;font-size:14px">' + (descripcion || 'Sin descripcion') + '</td></tr>'
        + '<tr><td style="padding:10px 0;border-bottom:1px solid #e5e7eb;color:#6b7280;font-size:14px">Estado</td><td style="padding:10px 0;border-bottom:1px solid #e5e7eb"><span style="background:' + color + ';color:#fff;padding:3px 12px;border-radius:50px;font-size:13px;font-weight:600">' + estado + '</span></td></tr>'
        + equiposHTML
        + '</table></div></td></tr>'
        + '<tr><td style="background:#f9fafb;padding:20px 32px;text-align:center;border-top:1px solid #e5e7eb">'
        + '<p style="margin:0;color:#9ca3af;font-size:12px">Este correo fue generado automaticamente por CBIT Manager.<br>Por favor no responda a este correo.</p>'
        + '</td></tr></table></td></tr></table></body></html>';
}

async function enviarCorreoSolicitud({ correo, estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos }) {
    if (!process.env.MAIL_USER || !process.env.MAIL_PASS) {
        console.warn('Correo no configurado. Agrega MAIL_USER y MAIL_PASS en el .env');
        return { ok: false, msg: 'Correo no configurado' };
    }
    try {
        const asunto = estado === 'Aprobado'
            ? 'Tu solicitud fue aprobada - CBIT Francisco de Miranda'
            : 'Tu solicitud no fue aprobada - CBIT Francisco de Miranda';
        await transporter.sendMail({
            from:    '"CBIT Manager" <' + process.env.MAIL_USER + '>',
            to:      correo,
            subject: asunto,
            html:    plantillaCorreo({ estado, docente, actividad, espacio, fecha, hora_inicio, hora_fin, descripcion, equipos })
        });
        console.log('Correo enviado a ' + correo + ' - Estado: ' + estado);
        return { ok: true };
    } catch (e) {
        console.error('Error enviando correo:', e.message);
        return { ok: false, msg: e.message };
    }
}

module.exports = { enviarCorreoSolicitud };
