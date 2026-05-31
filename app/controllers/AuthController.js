const Usuario = require('../models/Usuario');

const AuthController = {
    async login(req, res) {
        const { nombre_usuario, contrasena_usuario } = req.body;
        try {
            const user = await Usuario.findByCredentials(nombre_usuario, contrasena_usuario);
            if (!user) return res.json({ ok: false, msg: 'Usuario o contraseña incorrectos' });
            req.session.usuario = {
                id_usuario: user.id_usuario,
                nombre_usuario: user.nombre_usuario,
                roles: user.roles,
                nombre: user.nombre,
                apellido: user.apellido,
                id_persona: user.id_persona
            };
            res.json({ ok: true, usuario: req.session.usuario });
        } catch (e) {
            console.error(e);
            res.json({ ok: false, msg: 'Error en el servidor' });
        }
    },
    async logout(req, res) {
        req.session.destroy();
        res.json({ ok: true });
    },
    async recuperar(req, res) {
        const { cedula, correo } = req.body;
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
module.exports = AuthController;
