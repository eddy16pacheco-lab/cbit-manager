const Inventario = require('../models/Inventario');
const Equipo = require('../models/Equipo');
const UbicacionFisica = require('../models/UbicacionFisica');
const { requerido, esNumeroPositivo, esCodigoValido, esCodigoBienNacional, enumValido } = require('../helpers/validators');

// Estados que se pueden elegir en el formulario. "Desincorporado" solo se asigna con la acción de desincorporar.
const ESTADOS_VALIDOS = ['Operativo', 'No operativo', 'En Reparacion', 'Dañado'];

function validarInventario({ codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado }) {
    if (!requerido(codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado)) return 'Complete todos los campos';
    if (!esCodigoBienNacional(codigo_bien_nacional)) return 'El código de Bienes Nacionales debe tener entre 2 y 30 caracteres (letras, números, guiones)';
    if (!esNumeroPositivo(id_equipos)) return 'Seleccione un equipo válido';
    if (!esNumeroPositivo(id_ubicacion_fisica)) return 'Seleccione una ubicación válida';
    if (!esCodigoValido(serial)) return 'El serial debe tener entre 2 y 50 caracteres (letras, números, guiones)';
    if (!enumValido(estado, ESTADOS_VALIDOS)) return 'El estado seleccionado no es válido';
    return null;
}

const norm = v => String(v).trim().toLowerCase();

// Devuelve un mensaje si el serial o el código de Bienes Nacionales ya existen en otra unidad
async function buscarDuplicado({ serial, codigo_bien_nacional }, idExcluido) {
    const todos = await Inventario.findAll();
    const otros = todos.filter(i => String(i.id_inventario) !== String(idExcluido));
    if (otros.some(i => i.codigo_bien_nacional && norm(i.codigo_bien_nacional) === norm(codigo_bien_nacional)))
        return 'Ya existe un equipo con ese código de Bienes Nacionales';
    if (otros.some(i => norm(i.serial) === norm(serial)))
        return 'Ya existe un equipo en inventario con ese serial';
    return null;
}

const InventarioController = {
    async listar(req, res) {
        try {
            const [inventario, equipos, ubicaciones] = await Promise.all([Inventario.findAll(), Equipo.findAll(), UbicacionFisica.findAll()]);
            res.json({ ok: true, inventario, equipos, ubicaciones });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    },
    async crear(req, res) {
        const datos = leerCampos(req.body);
        const error = validarInventario(datos);
        if (error) return res.json({ ok: false, msg: error });
        try {
            const dup = await buscarDuplicado(datos, null);
            if (dup) return res.json({ ok: false, msg: dup });
            const id = await Inventario.create(datos);
            res.json({ ok: true, id, msg: 'Equipo agregado al inventario' });
        } catch (e) { res.json({ ok: false, msg: mensajeError(e) }); }
    },
    async actualizar(req, res) {
        const datos = leerCampos(req.body);
        const error = validarInventario(datos);
        if (error) return res.json({ ok: false, msg: error });
        try {
            const actual = await Inventario.findById(req.params.id);
            if (!actual) return res.json({ ok: false, msg: 'Equipo no encontrado' });
            if (actual.estado === 'Desincorporado')
                return res.json({ ok: false, msg: 'Este equipo fue desincorporado y no puede modificarse' });
            const dup = await buscarDuplicado(datos, req.params.id);
            if (dup) return res.json({ ok: false, msg: dup });
            await Inventario.update(req.params.id, datos);
            res.json({ ok: true, msg: 'Registro actualizado' });
        } catch (e) { res.json({ ok: false, msg: mensajeError(e) }); }
    },
    // Desincorporación (reemplaza a la eliminación): conserva el equipo con fecha y motivo.
    async desincorporar(req, res) {
        const motivo = String(req.body?.motivo ?? '').trim();
        if (motivo.length < 5 || motivo.length > 255)
            return res.json({ ok: false, msg: 'Indique el motivo de la desincorporación (entre 5 y 255 caracteres)' });
        try {
            const equipo = await Inventario.findById(req.params.id);
            if (!equipo) return res.json({ ok: false, msg: 'Equipo no encontrado' });
            if (equipo.estado === 'Desincorporado') return res.json({ ok: false, msg: 'El equipo ya fue desincorporado' });
            const vigentes = await Inventario.reservasVigentes(req.params.id);
            if (vigentes > 0)
                return res.json({ ok: false, msg: `No se puede desincorporar: el equipo tiene ${vigentes} reserva(s) pendiente(s) o aprobada(s). Cancélelas o reasígnelas primero.` });
            await Inventario.desincorporar(req.params.id, motivo);
            res.json({ ok: true, msg: 'Equipo desincorporado' });
        } catch (e) { res.json({ ok: false, msg: e.message }); }
    }
};

function leerCampos(b = {}) {
    return {
        codigo_bien_nacional: typeof b.codigo_bien_nacional === 'string' ? b.codigo_bien_nacional.trim() : b.codigo_bien_nacional,
        id_equipos: b.id_equipos, id_ubicacion_fisica: b.id_ubicacion_fisica,
        serial: typeof b.serial === 'string' ? b.serial.trim() : b.serial,
        estado: b.estado,
    };
}
// La restricción UNIQUE de la base es la última defensa ante dos altas simultáneas
function mensajeError(e) {
    if (e.code === 'ER_DUP_ENTRY') return /codigo_bien_nacional/.test(e.message)
        ? 'Ya existe un equipo con ese código de Bienes Nacionales' : 'Ya existe un equipo en inventario con ese serial';
    return e.message;
}

module.exports = InventarioController;
