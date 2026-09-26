const Persona = require('../models/Persona');
const { requerido, esCedula, esTelefono, esNombrePersonaValido } = require('../helpers/validators');

function validarPersona({ nombre, apellido, cedula, telefono }) {
    if (!requerido(nombre, apellido, cedula, telefono)) return 'Complete todos los campos';
    if (!esNombrePersonaValido(nombre)) return 'El nombre solo debe contener letras (3 a 40 caracteres)';
    if (!esNombrePersonaValido(apellido)) return 'El apellido solo debe contener letras (3 a 40 caracteres)';
    if (!esCedula(cedula)) return 'La cédula debe tener el formato V-12345678 o E-12345678';
    if (!esTelefono(telefono)) return 'El teléfono debe tener entre 7 y 15 dígitos y no puede ser un número repetido (ej. 7777777777)';
    return null;
}

const PersonaController = {
    async listar(req, res) {
        try { const personas = await Persona.findAll(); res.json({ ok: true, personas }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const { nombre, apellido, cedula, telefono } = req.body;
        const error = validarPersona({ nombre, apellido, cedula, telefono });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const existente = await Persona.findByCedula(cedula.trim());
            if (existente) return res.json({ ok: false, msg: 'Ya existe una persona registrada con esa cédula' });
            const id = await Persona.create({ nombre: nombre.trim(), apellido: apellido.trim(), cedula: cedula.trim(), telefono: telefono.trim() });
            res.json({ ok: true, id, msg: 'Persona registrada' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async actualizar(req, res) {
        const { nombre, apellido, cedula, telefono } = req.body;
        const error = validarPersona({ nombre, apellido, cedula, telefono });
        if (error) return res.json({ ok: false, msg: error });
        try {
            const existente = await Persona.findByCedula(cedula.trim(), req.params.id);
            if (existente) return res.json({ ok: false, msg: 'Ya existe otra persona registrada con esa cédula' });
            await Persona.update(req.params.id, { nombre: nombre.trim(), apellido: apellido.trim(), cedula: cedula.trim(), telefono: telefono.trim() }); res.json({ ok: true, msg: 'Persona actualizada' });
        }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async eliminar(req, res) {
        try { await Persona.delete(req.params.id); res.json({ ok: true, msg: 'Persona eliminada' }); }
        catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};
module.exports = PersonaController;
