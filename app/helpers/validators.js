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

/** Cédula venezolana: V-12345678, E-12345678, V12345678 o solo dígitos (6 a 9 dígitos) */
function esCedula(v) {
    if (v === undefined || v === null) return false;
    return /^[VEve]?-?\d{6,9}$/.test(String(v).trim());
}

/** Formato de correo electrónico básico */
function esEmail(v) {
    if (v === undefined || v === null) return false;
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v).trim());
}

/** Teléfono: acepta separadores comunes, valida 7 a 15 dígitos y rechaza
 *  números con el mismo dígito repetido (ej. 7777777777, 0000000000) */
function esTelefono(v) {
    if (v === undefined || v === null || String(v).trim() === '') return false;
    const soloDigitos = String(v).replace(/\D/g, '');
    if (soloDigitos.length < 7 || soloDigitos.length > 15) return false;
    if (/^(\d)\1+$/.test(soloDigitos)) return false; // todos los dígitos iguales
    return true;
}

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
function esCodigoValido(v) {
    if (v === undefined || v === null) return false;
    return /^[A-Za-z0-9\-_\.\/]{2,50}$/.test(String(v).trim());
}

module.exports = {
    requerido,
    horaValida,
    esCedula,
    esEmail,
    esTelefono,
    esSoloTexto,
    esNombrePersonaValido,
    esNombreCatalogoValido,
    longitudValida,
    esFechaValida,
    esFechaFuturaOHoy,
    esNumeroPositivo,
    enumValido,
    esCodigoValido
};
