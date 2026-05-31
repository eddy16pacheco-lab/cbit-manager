function requerido(...valores) {
    return valores.every(v => v !== undefined && v !== null && String(v).trim() !== '');
}
function horaValida(inicio, fin) {
    return inicio < fin;
}
module.exports = { requerido, horaValida };
