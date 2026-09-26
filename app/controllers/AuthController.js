const Usuario = require('../models/Usuario');
const { registrar } = require('../helpers/auditLog');
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
    async recuperar(req, res) {
        const { cedula, correo } = req.body;
        if (!requerido(cedula, correo)) return res.json({ ok: false, msg: 'Ingrese cédula y correo' });
        if (!esCedula(cedula)) return res.json({ ok: false, msg: 'La cédula debe tener el formato V-12345678 o E-12345678' });
        if (!esEmail(correo)) return res.json({ ok: false, msg: 'Ingrese un correo electrónico válido' });
        try {
            const found = await Usuario.findByCredencialesRecuperacion(cedula, correo);
            if (found) res.json({ ok: true, msg: `Correo de recuperación enviado a ${correo}` });
            else res.json({ ok: false, msg: 'No se encontró cuenta con esos datos' });
        } catch (e) {
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
