const db = require('../config/database');

// Almacena los clientes SSE conectados (solo admins)
const adminsConectados = new Map();

const NotificacionesController = {

    // SSE: Admin se conecta para recibir notificaciones en tiempo real
    conectar(req, res) {
        if (req.session?.usuario?.roles !== 'Administrador') {
            return res.status(403).json({ ok: false, msg: 'Solo administradores' });
        }
        const id_usuario = req.session.usuario.id_usuario;

        // Configurar SSE
        res.setHeader('Content-Type',  'text/event-stream');
        res.setHeader('Cache-Control', 'no-cache');
        res.setHeader('Connection',    'keep-alive');
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.flushHeaders();

        // Guardar conexión
        adminsConectados.set(id_usuario, res);

        // Ping cada 25s para mantener viva la conexión
        const ping = setInterval(() => {
            res.write('event: ping\ndata: ok\n\n');
        }, 25000);

        // Limpiar al desconectar
        req.on('close', () => {
            clearInterval(ping);
            adminsConectados.delete(id_usuario);
        });
    },

    // Listar notificaciones del admin autenticado
    async listar(req, res) {
        const id_usuario = req.session?.usuario?.id_usuario;
        try {
            const [rows] = await db.execute(
                `SELECT n.*, s.estado AS sol_estado,
                        sp.nombre AS docente_nombre, sp.apellido AS docente_apellido,
                        e.nombre AS espacio_nombre, a.nombre AS actividad_nombre,
                        s.fecha, s.hora_inicio, s.hora_fin
                 FROM notificacion n
                 LEFT JOIN solicitud s ON n.id_solicitud = s.id_solicitud
                 LEFT JOIN usuario u ON s.id_usuario = u.id_usuario
                 LEFT JOIN persona sp ON u.id_persona = sp.id_persona
                 LEFT JOIN espacio e ON s.id_espacio = e.id_espacio
                 LEFT JOIN actividad a ON s.id_actividad = a.id_actividad
                 WHERE n.id_usuario = ?
                 ORDER BY n.fecha_envio DESC LIMIT 50`,
                [id_usuario]
            );
            res.json({ ok: true, notificaciones: rows });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },

    // Marcar una como leída
    async marcarLeida(req, res) {
        try {
            await db.execute('UPDATE notificacion SET leida=1 WHERE id_notificacion=?', [req.params.id]);
            res.json({ ok: true });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },

    // Marcar todas como leídas
    async marcarTodas(req, res) {
        const id_usuario = req.session?.usuario?.id_usuario;
        try {
            await db.execute('UPDATE notificacion SET leida=1 WHERE id_usuario=?', [id_usuario]);
            res.json({ ok: true });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    },

    // Contar no leídas
    async contarNoLeidas(req, res) {
        const id_usuario = req.session?.usuario?.id_usuario;
        try {
            const [rows] = await db.execute(
                'SELECT COUNT(*) AS total FROM notificacion WHERE id_usuario=? AND leida=0',
                [id_usuario]
            );
            res.json({ ok: true, total: rows[0].total });
        } catch(e) { res.json({ ok: false, msg: e.message }); }
    }
};

// ── Función global: emitir notificación a todos los admins conectados ───────
async function notificarAdmins({ titulo, mensaje, tipo, id_solicitud }) {
    try {
        // Obtener todos los admins activos
        const [admins] = await db.execute(
            "SELECT id_usuario FROM usuario WHERE roles='Administrador' AND estado='Activo'"
        );

        for (const admin of admins) {
            // Guardar en BD
            await db.execute(
                'INSERT INTO notificacion (id_usuario, titulo, mensaje, fecha_envio, leida, tipo, id_solicitud) VALUES (?,?,?,NOW(),0,?,?)',
                [admin.id_usuario, titulo, mensaje, tipo || 'info', id_solicitud || null]
            );

            // Enviar SSE si el admin está conectado
            const conn = adminsConectados.get(admin.id_usuario);
            if (conn) {
                const data = JSON.stringify({ titulo, mensaje, tipo, id_solicitud, hora: new Date().toISOString() });
                conn.write(`event: notificacion\ndata: ${data}\n\n`);
            }
        }
    } catch(e) {
        console.error('Error notificando admins:', e.message);
    }
}

module.exports = { NotificacionesController, notificarAdmins };
