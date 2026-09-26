function obtenerFechaHoy() {
    return new Date().toISOString().split('T')[0];
}
function formatearFecha(fechaStr) {
    if (!fechaStr) return 'N/A';
    const d = new Date(fechaStr);
    return d.toLocaleDateString('es-ES', { year:'numeric', month:'long', day:'numeric' });
}
function formatearHora(horaStr) {
    if (!horaStr) return '';
    return String(horaStr).slice(0, 5);
}
function getStartOfWeek(date) {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1);
    return new Date(d.setDate(diff));
}
module.exports = { obtenerFechaHoy, formatearFecha, formatearHora, getStartOfWeek };
