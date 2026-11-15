const Usuario = require('../models/Usuario');
const { registrar } = require('../helpers/auditLog');
const { enviarCorreoPassword } = require('../helpers/mailer');
const { requerido, esCedula, esEmail } = require('../helpers/validators');

const AuthController = {
    async login(req, res) {
        const { nombre_usuario, contrasena_usuario } = req.body;
        if (!requerido(nombre_usuario, contrasena_usuario))
            return res.json({ ok: false, msg: 'Ingrese usuario y contraseña' });
        try {
            const user = await Usuario.findByCredentials(nombre_usuario, contrasena_usuario);
            if (!user) {
                registrar({ id_usuario: null, usuario: nombre_usuario, accion: 'Inicio de sesión fallido', modulo: 'Autenticación', detalle: 'Usuario o contraseña incorrectos', ip: req.ip });
                return res.json({ ok: false, msg: 'Usuario o contraseña incorrectos' });
            }
            req.session.usuario = {
                id_usuario: user.id_usuario,
                nombre_usuario: user.nombre_usuario,
                roles: user.roles,
                nombre: user.nombre,
                apellido: user.apellido,
                id_persona: user.id_persona
            };
            const nombreCompleto = `${user.nombre} ${user.apellido}`.trim();
            registrar({ id_usuario: user.id_usuario, usuario: nombreCompleto, accion: 'Inicio de sesión', modulo: 'Autenticación', detalle: 'Acceso exitoso al sistema', ip: req.ip });
            _notificarSesion(req, { usuario: nombreCompleto, mensaje: `${nombreCompleto} ha iniciado sesión` });
            res.json({ ok: true, usuario: req.session.usuario });
        } catch (e) {
            console.error(e);
            res.json({ ok: false, msg: 'Error en el servidor' });
        }
    },
    async logout(req, res) {
        const u = req.session.usuario;
        if (u) {
            const nombreCompleto = `${u.nombre} ${u.apellido}`.trim();
            registrar({ id_usuario: u.id_usuario, usuario: nombreCompleto, accion: 'Cierre de sesión', modulo: 'Autenticación', detalle: 'Sesión finalizada', ip: req.ip });
            _notificarSesion(req, { usuario: nombreCompleto, mensaje: `${nombreCompleto} ha finalizado su sesión` });
        }
        req.session.destroy();
        res.json({ ok: true });
    },
    // RF: envía la contraseña actual del usuario directamente al correo
    // registrado (en vez de un enlace de restablecimiento).
    async recuperar(req, res) {
        const { cedula, correo } = req.body;
        if (!requerido(cedula, correo)) return res.json({ ok: false, msg: 'Ingrese cédula y correo' });
        if (!esCedula(cedula)) return res.json({ ok: false, msg: 'La cédula debe tener el formato V-12345678 o E-12345678' });
        if (!esEmail(correo)) return res.json({ ok: false, msg: 'Ingrese un correo electrónico válido' });
        try {
            const user = await Usuario.findByCredencialesRecuperacion(cedula, correo);
            if (!user) return res.json({ ok: false, msg: 'No se encontró una cuenta activa con esa cédula y correo' });

            const envio = await enviarCorreoPassword({
                correo,
                nombre: `${user.nombre || ''} ${user.apellido || ''}`.trim() || user.nombre_usuario,
                nombre_usuario: user.nombre_usuario,
                contrasena: user.contrasena_usuario
            });
            if (!envio.ok) {
                console.error('No se pudo enviar el correo de recuperación:', envio.msg);
                return res.json({ ok: false, msg: 'No se pudo enviar el correo. Intente más tarde o contacte al administrador.' });
            }

            registrar({ id_usuario: user.id_usuario, usuario: user.nombre_usuario, accion: 'Solicitud de recuperación', modulo: 'Autenticación', detalle: 'Se envió la contraseña actual al correo registrado', ip: req.ip });
            res.json({ ok: true, msg: `Hemos enviado su contraseña al correo ${correo}. Revise su bandeja de entrada (y spam).` });
        } catch (e) {
            console.error(e);
            res.json({ ok: false, msg: 'Error en el servidor' });
        }
    },
    sesionActual(req, res) {
        if (req.session.usuario) res.json({ ok: true, usuario: req.session.usuario });
        else res.json({ ok: false });
    }
};

// ── Helper interno: emite por Socket.IO el aviso de inicio/cierre de sesión
// con el texto exacto que debe verse en pantalla, a todos los demás usuarios
// conectados en ese momento. ──────────────────────────────────────────────
function _notificarSesion(req, { usuario, mensaje }) {
    try {
        const io = req.app.get('io');
        if (!io) return;
        io.emit('data:changed', {
            modulo: 'auth',
            moduloLabel: 'Autenticación',
            tipo: 'sesion',
            accion: mensaje.includes('iniciado') ? 'Inicio de sesión' : 'Cierre de sesión',
            usuario,
            detalle: mensaje,
            fecha: new Date().toISOString()
        });
    } catch (e) {
        console.error('⚠️  No se pudo notificar la sesión en tiempo real:', e.message);
    }
}

module.exports = AuthController;
