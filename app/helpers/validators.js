// ============================================================================
// Helpers de validación reutilizables para todos los controladores.
// Cada función retorna un booleano; los controladores arman el mensaje
// de error específico para el campo que falló.
// ============================================================================

/** Todos los valores deben existir y no ser cadenas vacías (tras trim) */
function requerido(...valores) {
    return valores.every(v => v !== undefined && v !== null && String(v).trim() !== '');
}

/** La hora de inicio debe ser estrictamente menor que la hora de fin (HH:MM) */
function horaValida(inicio, fin) {
    return typeof inicio === 'string' && typeof fin === 'string' && inicio < fin;
}

/**
 * Cédula venezolana: prefijo V o E + 7 u 8 dígitos numéricos (sin puntos, espacios ni letras).
 * Devuelve null si es válida o el mensaje de error claro para mostrar al usuario.
 * El prefijo puede venir como "V-12345678" o "V12345678".
 */
function validarCedula(v) {
    if (typeof v !== 'string' || v === '') return 'Ingrese la cédula de identidad';
    const m = /^([VEve])-?(.*)$/.exec(v);
    if (!m) return 'La cédula debe iniciar con el prefijo V o E';
    const numero = m[2];
    if (!/^\d+$/.test(numero)) return 'La cédula solo debe contener números (sin puntos, espacios ni letras)';
    if (numero.length < 7) return `La cédula debe tener mínimo 7 dígitos (ingresó ${numero.length})`;
    if (numero.length > 8) return `La cédula debe tener máximo 8 dígitos (ingresó ${numero.length})`;
    return null;
}
/** Forma canónica que se guarda en la base de datos: "V-12345678" (o null si es inválida) */
function normalizarCedula(v) {
    if (validarCedula(v) !== null) return null;
    const m = /^([VEve])-?(\d+)$/.exec(v);
    return `${m[1].toUpperCase()}-${m[2]}`;
}
function esCedula(v) { return validarCedula(v) === null; }

/** Formato de correo electrónico básico */
function esEmail(v) {
    if (v === undefined || v === null) return false;
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v).trim());
}

/** Códigos de operadora móvil válidos en Venezuela */
const OPERADORAS = ['0412', '0414', '0416', '0422', '0424', '0426'];

/**
 * Teléfono venezolano: exactamente 11 dígitos numéricos = operadora (4) + número (7).
 * No admite espacios, guiones, signos ni letras (tampoco al inicio o al final).
 * Devuelve null si es válido o el mensaje de error para mostrar al usuario.
 */
function validarTelefono(v) {
    if (typeof v !== 'string' || v === '') return 'Ingrese el número de teléfono';
    if (!/^\d+$/.test(v)) return 'El teléfono solo debe contener números (sin espacios, guiones, signos ni letras)';
    if (v.length !== 11) return `El teléfono debe tener exactamente 11 dígitos (ingresó ${v.length})`;
    if (!OPERADORAS.includes(v.slice(0, 4))) return 'El teléfono debe comenzar con 0412, 0414, 0416, 0422, 0424 o 0426';
    return null;
}
function esTelefono(v) { return validarTelefono(v) === null; }

/** Solo letras (con acentos/ñ), espacios, apóstrofes y guiones — para nombres */
function esSoloTexto(v) {
    if (v === undefined || v === null) return false;
    return /^[A-Za-zÁÉÍÓÚÑáéíóúñÜü'\-\s]+$/.test(String(v).trim());
}

/** Validación estándar para nombres de PERSONAS (solo texto) en cualquier
 *  módulo: entre 3 y 40 caracteres. */
function esNombrePersonaValido(v) {
    return esSoloTexto(v) && longitudValida(v, 3, 40);
}

/** Validación estándar para nombres de CATÁLOGO (categorías, marcas, equipos,
 *  modelos, espacios, actividades, etc.): letras, números y puntuación básica,
 *  entre 3 y 40 caracteres. */
function esNombreCatalogoValido(v) {
    if (v === undefined || v === null) return false;
    const ok = /^[A-Za-z0-9ÁÉÍÓÚÑáéíóúñÜü'\-\.\,\s]+$/.test(String(v).trim());
    return ok && longitudValida(v, 3, 40);
}

/** Longitud de cadena dentro de un rango (inclusive) */
function longitudValida(v, min, max) {
    if (v === undefined || v === null) return false;
    const len = String(v).trim().length;
    return len >= min && len <= max;
}

/** Fecha en formato parseable y realmente válida (no NaN) */
function esFechaValida(v) {
    if (!v) return false;
    const d = new Date(v);
    return !isNaN(d.getTime());
}

/** Fecha (YYYY-MM-DD) mayor o igual a hoy — evita reservar/registrar en el pasado */
function esFechaFuturaOHoy(v) {
    if (!esFechaValida(v)) return false;
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    const d = new Date(v + 'T00:00:00');
    return d.getTime() >= hoy.getTime();
}

/** Número entero positivo (>0), acepta strings numéricos */
function esNumeroPositivo(v) {
    if (v === undefined || v === null || v === '') return false;
    const n = Number(v);
    return Number.isFinite(n) && n > 0 && Number.isInteger(n);
}

/** El valor debe pertenecer a la lista de opciones permitidas (para ENUMs) */
function enumValido(v, opciones) {
    return opciones.includes(v);
}

/** Serial/código alfanumérico simple (letras, números, guiones), 2 a 50 caracteres */
// Código de Bienes Nacionales: 2 a 30 caracteres (letras, números, guion, punto, barra)
function esCodigoBienNacional(v) {
    if (v === undefined || v === null) return false;
    return /^[A-Za-z0-9][A-Za-z0-9\-\.\/]{1,29}$/.test(String(v).trim());
}

function esCodigoValido(v) {
    if (v === undefined || v === null) return false;
    return /^[A-Za-z0-9\-_\.\/]{2,50}$/.test(String(v).trim());
}

module.exports = {
    requerido,
    horaValida,
    esCedula,
    validarCedula,
    normalizarCedula,
    esEmail,
    esTelefono,
    validarTelefono,
    OPERADORAS,
    esSoloTexto,
    esNombrePersonaValido,
    esNombreCatalogoValido,
    longitudValida,
    esFechaValida,
    esFechaFuturaOHoy,
    esNumeroPositivo,
    enumValido,
    esCodigoValido,
    esCodigoBienNacional
};
