const { registrar } = require('../helpers/auditLog');

const ACCIONES = { POST: 'Creación', PUT: 'Actualización', DELETE: 'Eliminación' };

const NOMBRES_MODULO = {
    categorias: 'Categorías', marcas: 'Marcas', modelos: 'Modelos', equipos: 'Equipos', inventario: 'Inventario',
    actividades: 'Actividades', solicitudes: 'Solicitudes', reservas: 'Reservas',
    mantenimiento: 'Mantenimiento', tecnicos: 'Técnicos', asistencias: 'Asistencia',
    usuarios: 'Usuarios', personas: 'Personas', espacios: 'Espacios', auth: 'Autenticación'
};

// Deriva el nombre del módulo a partir de la URL: /api/usuarios/5 -> usuarios
function claveModuloDesdeRuta(url) {
    const partes = url.split('?')[0].split('/').filter(Boolean); // ['api','usuarios','5']
    return partes[1] || 'sistema';
}
function moduloDesdeRuta(url) {
    const clave = claveModuloDesdeRuta(url);
    return NOMBRES_MODULO[clave] || clave;
}

/**
 * Intercepta res.json() en las peticiones que mutan datos (POST/PUT/DELETE).
 * Si la operación fue exitosa (body.ok === true):
 *   1) Registra la acción en el historial (si hay usuario en sesión).
 *   2) Emite un evento por Socket.IO para que TODOS los clientes conectados
 *      (incluido quien hizo el cambio) actualicen su vista en tiempo real,
 *      sin recargar la página.
 */
function auditMiddleware(req, res, next) {
    if (!['POST', 'PUT', 'DELETE'].includes(req.method)) return next();

    const originalJson = res.json.bind(res);
    res.json = (body) => {
        try {
            const modulo = moduloDesdeRuta(req.originalUrl);
            const exito = body && body.ok;

            if (exito && req.session && req.session.usuario && modulo !== 'Autenticación') {
                registrar({
                    id_usuario: req.session.usuario.id_usuario,
                    usuario: `${req.session.usuario.nombre || ''} ${req.session.usuario.apellido || ''}`.trim() || req.session.usuario.nombre_usuario,
                    accion: ACCIONES[req.method] || req.method,
                    modulo,
                    detalle: body.msg || '',
                    ip: req.ip
                });
            }

            if (exito && modulo !== 'Autenticación') {
                const io = req.app.get('io');
                if (io) {
                    io.emit('data:changed', {
                        modulo: claveModuloDesdeRuta(req.originalUrl),
                        moduloLabel: modulo,
                        accion: ACCIONES[req.method] || req.method,
                        usuario: req.session?.usuario ? `${req.session.usuario.nombre || ''} ${req.session.usuario.apellido || ''}`.trim() : 'Alguien',
                        detalle: body.msg || '',
                        fecha: new Date().toISOString()
                    });
                }
            }
        } catch (e) {
            console.error('⚠️  auditMiddleware:', e.message);
        }
        return originalJson(body);
    };
    next();
}

module.exports = auditMiddleware;
