const Usuario = require('../models/Usuario');
const Persona = require('../models/Persona');

const UsuariosController = {
    async listar(req, res) {
        try {
            const [usuarios, personas] = await Promise.all([Usuario.findAll(), Persona.findAll()]);
            res.json({ ok: true, usuarios, personas });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { id_persona, nombre_usuario, contrasena_usuario, correo, roles } = req.body;
        if (!id_persona || !nombre_usuario || !contrasena_usuario || !correo || !roles) return res.json({ ok: false, msg: 'Complete todos los campos' });
        try { const id = await Usuario.create({ id_persona, nombre_usuario, contrasena_usuario, correo, roles }); res.json({ ok: true, id, msg: 'Usuario registrado' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { correo, roles, contrasena_usuario } = req.body;
        if (!correo || !roles) return res.json({ ok: false, msg: 'Complete los campos requeridos' });
        try { await Usuario.update(req.params.id, { correo, roles, contrasena_usuario }); res.json({ ok: true, msg: 'Usuario actualizado' }); }
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
