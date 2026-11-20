const Usuario = require('../models/Usuario');
const Persona = require('../models/Persona');
const { requerido, esEmail, esNumeroPositivo, enumValido, longitudValida } = require('../helpers/validators');

const ROLES_VALIDOS = ['Administrador', 'Docente'];

function validarNombreUsuario(v) {
    return typeof v === 'string' && /^[A-Za-z0-9_.]{4,30}$/.test(v.trim());
}
function validarPassword(v) {
    // Mínimo 6 caracteres, al menos una letra y un número
    return typeof v === 'string' && v.length >= 6 && /[A-Za-z]/.test(v) && /\d/.test(v);
}

const UsuariosController = {
    async listar(req, res) {
        try {
            const [usuarios, personas] = await Promise.all([Usuario.findAll(), Persona.findAll()]);
            res.json({ ok: true, usuarios, personas });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_persona, nombre_usuario, contrasena_usuario, correo, roles } = req.body;
        if (!requerido(id_persona, nombre_usuario, contrasena_usuario, correo, roles))
            return res.json({ ok: false, msg: 'Complete todos los campos' });
        if (!esNumeroPositivo(id_persona)) return res.json({ ok: false, msg: 'Seleccione una persona válida' });
        if (!validarNombreUsuario(nombre_usuario)) return res.json({ ok: false, msg: 'El usuario debe tener entre 4 y 30 caracteres (letras, números, punto o guion bajo)' });
        if (!validarPassword(contrasena_usuario)) return res.json({ ok: false, msg: 'La contraseña debe tener al menos 6 caracteres, con letras y números' });
        if (!esEmail(correo)) return res.json({ ok: false, msg: 'Ingrese un correo electrónico válido' });
        if (!enumValido(roles, ROLES_VALIDOS)) return res.json({ ok: false, msg: 'Seleccione un rol válido (Administrador o Docente)' });
        try {
            const existentes = await Usuario.findAll();
            if (existentes.some(u => u.nombre_usuario.trim().toLowerCase() === nombre_usuario.trim().toLowerCase()))
                return res.json({ ok: false, msg: 'Ese nombre de usuario ya está en uso' });
            if (existentes.some(u => u.correo && u.correo.trim().toLowerCase() === correo.trim().toLowerCase()))
                return res.json({ ok: false, msg: 'Ese correo ya está registrado' });
            if (existentes.some(u => String(u.id_persona) === String(id_persona)))
                return res.json({ ok: false, msg: 'Esta persona ya tiene un usuario asociado' });
            const id = await Usuario.create({ id_persona, nombre_usuario: nombre_usuario.trim(), contrasena_usuario, correo: correo.trim(), roles });
            res.json({ ok: true, id, msg: 'Usuario registrado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { correo, roles, contrasena_usuario } = req.body;
        if (!requerido(correo, roles)) return res.json({ ok: false, msg: 'Complete los campos requeridos' });
        if (!esEmail(correo)) return res.json({ ok: false, msg: 'Ingrese un correo electrónico válido' });
        if (!enumValido(roles, ROLES_VALIDOS)) return res.json({ ok: false, msg: 'Seleccione un rol válido (Administrador o Docente)' });
        if (contrasena_usuario && !validarPassword(contrasena_usuario))
            return res.json({ ok: false, msg: 'La contraseña debe tener al menos 6 caracteres, con letras y números' });
        try {
            const existentes = await Usuario.findAll();
            if (existentes.some(u => u.correo && u.correo.trim().toLowerCase() === correo.trim().toLowerCase() && String(u.id_usuario) !== String(req.params.id)))
                return res.json({ ok: false, msg: 'Ese correo ya está registrado en otro usuario' });
            await Usuario.update(req.params.id, { correo: correo.trim(), roles, contrasena_usuario });
            res.json({ ok: true, msg: 'Usuario actualizado' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async inhabilitar(req, res) {
        try { await Usuario.inhabilitar(req.params.id); res.json({ ok: true, msg: 'Usuario inhabilitado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async activar(req, res) {
        try { await Usuario.activar(req.params.id); res.json({ ok: true, msg: 'Usuario activado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = UsuariosController;
