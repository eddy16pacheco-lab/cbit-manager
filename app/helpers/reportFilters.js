/**
 * reportFilters.js — Lectura segura de filtros para el módulo de Reportes.
 *
 * Todos los endpoints /api/reportes/* aceptan filtros por query string
 * (?desde=2026-01-01&hasta=2026-03-31&prioridad=Alta ...). Este helper:
 *   1. Valida cada valor contra listas permitidas / formatos estrictos.
 *   2. Devuelve un objeto limpio (solo claves con valor válido).
 *   3. Provee un pequeño constructor de cláusulas WHERE con parámetros
 *      preparados, para que ningún valor del usuario se concatene al SQL.
 */

const ENUMS = {
    prioridad:     ['Alta', 'Media', 'Baja'],
    estadoSolicitud: ['Aprobado', 'Pendiente', 'Cancelado', 'Completado'],
    estadoEquipo:  ['Operativo', 'No operativo', 'En Reparacion', 'Dañado', 'Desincorporado'],
    estadoUsuario: ['Activo', 'Inactivo', 'Bloqueado'],
    rol:           ['Administrador', 'Docente'],
    orden:         ['asc', 'desc'],
};

// Valores permitidos para el límite de ranking. "todos" => sin LIMIT.
const LIMITES = { '5': 5, '10': 10, 'todos': 0 };

const RE_FECHA = /^\d{4}-\d{2}-\d{2}$/;

function fechaValida(v) {
    if (!RE_FECHA.test(v)) return false;
    const d = new Date(v + 'T00:00:00Z');
    return !isNaN(d.getTime()) && d.toISOString().slice(0, 10) === v;
}

function enteroPositivo(v) {
    return /^\d{1,10}$/.test(String(v)) && Number(v) > 0 ? Number(v) : null;
}

/**
 * Valida el rango de fechas de un reporte (Fecha de Inicio / Fecha de Fin).
 * Ambas son obligatorias, deben ser fechas reales (AAAA-MM-DD) y el inicio no puede
 * ser mayor al fin. Devuelve null si es válido o el mensaje de error.
 */
function validarRango(desde, hasta) {
    if (!desde) return 'La Fecha de Inicio es obligatoria.';
    if (!hasta) return 'La Fecha de Fin es obligatoria.';
    if (!fechaValida(desde)) return 'La Fecha de Inicio no es válida (use AAAA-MM-DD).';
    if (!fechaValida(hasta)) return 'La Fecha de Fin no es válida (use AAAA-MM-DD).';
    if (desde > hasta) return 'La Fecha de Inicio no puede ser mayor a la Fecha de Fin.';
    return null;
}

/**
 * Lee y valida los filtros de req.query.
 * El rango de fechas es OBLIGATORIO por defecto: ningún reporte se genera sin él.
 * @returns {{ filtros: object, error: string|null }}
 */
function leerFiltros(query = {}, { rangoObligatorio = true } = {}) {
    const f = {};
    const q = (k) => (typeof query[k] === 'string' ? query[k].trim() : '');

    if (rangoObligatorio) {
        const err = validarRango(q('desde'), q('hasta'));
        if (err) return { filtros: {}, error: err };
        f.desde = q('desde'); f.hasta = q('hasta');
    }

    // Enumerados: se ignoran silenciosamente si vienen vacíos, error si son inválidos
    const mapaEnum = {
        prioridad: ENUMS.prioridad,
        rol:       ENUMS.rol,
        orden:     ENUMS.orden,
    };
    for (const [k, lista] of Object.entries(mapaEnum)) {
        if (!q(k)) continue;
        if (!lista.includes(q(k))) return { filtros: {}, error: `Valor no permitido para "${k}".` };
        f[k] = q(k);
    }

    // "estado" es contextual (solicitud / equipo / usuario). Se acepta si pertenece a
    // CUALQUIER enum conocido; cada endpoint vuelve a validarlo contra el suyo.
    if (q('estado')) {
        const todos = [...ENUMS.estadoSolicitud, ...ENUMS.estadoEquipo, ...ENUMS.estadoUsuario];
        if (!todos.includes(q('estado'))) return { filtros: {}, error: 'Valor no permitido para "estado".' };
        f.estado = q('estado');
    }

    for (const k of ['id_tecnico', 'id_equipo', 'id_usuario']) {
        if (!q(k)) continue;
        const n = enteroPositivo(q(k));
        if (!n) return { filtros: {}, error: `El filtro "${k}" no es válido.` };
        f[k] = n;
    }

    if (q('limite')) {
        if (!(q('limite') in LIMITES)) return { filtros: {}, error: 'Límite no permitido (use 5, 10 o todos).' };
        f.limite = LIMITES[q('limite')];       // número; 0 = sin límite
    }

    return { filtros: f, error: null };
}

/** Verifica que el filtro "estado" pertenezca al enum del endpoint; si no, error. */
function estadoPermitido(filtros, lista) {
    return !filtros.estado || lista.includes(filtros.estado);
}

/**
 * Constructor mínimo de WHERE con parámetros preparados.
 *   const w = new Where();
 *   w.add('s.estado = ?', 'Aprobado');
 *   w.rangoFecha('s.fecha', f);
 *   db.execute(`SELECT ... ${w.sql()}`, w.params);
 */
class Where {
    constructor() { this.cond = []; this.params = []; }
    add(condicion, ...valores) { this.cond.push(condicion); this.params.push(...valores); return this; }
    /** Rango inclusivo sobre una columna DATE o DATETIME. */
    rangoFecha(columna, f) {
        if (f.desde) this.add(`${columna} >= ?`, f.desde);
        if (f.hasta) this.add(`${columna} < DATE_ADD(?, INTERVAL 1 DAY)`, f.hasta);
        return this;
    }
    sql(prefijo = 'WHERE') { return this.cond.length ? `${prefijo} ${this.cond.join(' AND ')}` : ''; }
}

module.exports = { ENUMS, LIMITES, leerFiltros, validarRango, estadoPermitido, Where };
