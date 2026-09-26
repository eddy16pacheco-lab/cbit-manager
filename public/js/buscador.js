// ================================================================
//  buscador.js v2 — Búsqueda + Filtros + ID→Código
// ================================================================

const MODULOS_CONFIG = {
    categorias:    { columnas: ['Código','Categoría','Equipos'],                          ordenables: ['Categoría','Equipos'],              placeholder: 'Buscar categoría...' },
    marcas:        { columnas: ['Código','Marca','Equipos'],                              ordenables: ['Marca','Equipos'],                  placeholder: 'Buscar marca...' },
    equipos:       { columnas: ['Código','Equipo','Modelo','Categoría','Marca'],          ordenables: ['Equipo','Modelo','Categoría','Marca'], placeholder: 'Buscar por nombre, modelo, categoría...' },
    inventario:    { columnas: ['Serial','Equipo','Ubicación','Estado'],                  ordenables: ['Serial','Equipo','Ubicación','Estado'], placeholder: 'Buscar por serial, equipo o estado...' },
    actividades:   { columnas: ['Código','Nombre','Descripción','Solicitudes'],           ordenables: ['Nombre','Solicitudes'],             placeholder: 'Buscar actividad...' },
    solicitudes:   { columnas: ['Código','Docente','Espacio','Actividad','Fecha','Horario','Equipos','Estado'], ordenables: ['Fecha','Estado','Espacio','Actividad'], placeholder: 'Buscar por docente, espacio, actividad...' },
    reservas:      { columnas: ['Código','Actividad / Espacio','Docente','Fecha y Horario','Equipos','Estado'], ordenables: ['Fecha y Horario','Estado'],            placeholder: 'Buscar reserva...' },
    mantenimiento: { columnas: ['Código','Equipo / Descripción','Serial','Prioridad','Técnico','Fecha'],       ordenables: ['Prioridad','Fecha','Técnico'],         placeholder: 'Buscar por equipo, técnico o prioridad...' },
    tecnicos:      { columnas: ['Código','Técnico','Especialidad','Teléfono'],            ordenables: ['Técnico','Especialidad'],           placeholder: 'Buscar técnico...' },
    asistencias:   { columnas: ['Código','Estudiante','Año/Sección','Solicitud','Asistencia'], ordenables: ['Año/Sección','Asistencia'],   placeholder: 'Buscar estudiante...' },
    personas:      { columnas: ['Código','Nombre','Apellido','Cédula','Teléfono'],        ordenables: ['Nombre','Apellido','Cédula'],       placeholder: 'Buscar por nombre, apellido o cédula...' },
    usuarios:      { columnas: ['Código','Usuario','Persona','Correo','Estado','Rol'],    ordenables: ['Usuario','Rol','Estado'],           placeholder: 'Buscar usuario...' }
};

let _sortEstado  = { columna: -1, direccion: 'asc' };
let _vistaActual = '';

// ── RENOMBRAR ID → CÓDIGO EN TODA LA TABLA ───────────────────────
function renombrarIDaCodigo() {
    // Cabeceras de tabla
    document.querySelectorAll('.premium-table thead th').forEach(th => {
        if (/^\s*id\s*$/i.test(th.textContent)) {
            th.textContent = 'Código';
        }
    });

    // Celdas del cuerpo que contengan patrones tipo ID (ej: CAT-01, EQ-02, MAN-01)
    // Solo renombramos el TEXTO de cabecera, no los valores de celda
    // Para las tags tipo "CAT-01" ya son códigos — no se tocan

    // También renombrar en section-metrics y otros chips que digan "ID"
    document.querySelectorAll('.metric-chip .metric-label, .table-tag').forEach(el => {
        if (/^\s*id\s*$/i.test(el.textContent)) {
            el.textContent = 'Código';
        }
    });
}

// ── BARRA DE BÚSQUEDA ─────────────────────────────────────────────
function generarBarraBusqueda(modulo) {
    const cfg = MODULOS_CONFIG[modulo];
    if (!cfg) return '';

    const opOrdenar = cfg.ordenables.map(col =>
        `<option value="${col}">↕ ${col}</option>`
    ).join('');

    return `
    <div id="barra-busqueda" style="
        display:flex;flex-wrap:wrap;gap:0.6rem;align-items:center;
        padding:0.75rem 1rem;
        background:rgba(79,70,229,0.04);
        border:1px solid rgba(79,70,229,0.12);
        border-radius:10px;margin-bottom:1rem">

        <div style="position:relative;flex:1;min-width:200px">
            <i class="fas fa-search" style="position:absolute;left:.75rem;top:50%;
               transform:translateY(-50%);color:var(--text-secondary);
               font-size:.85rem;pointer-events:none"></i>
            <input type="text" id="input-busqueda"
                placeholder="${cfg.placeholder}"
                oninput="buscarEnTabla(this.value)"
                style="width:100%;padding:.45rem .75rem .45rem 2.2rem;
                       border-radius:8px;border:1px solid rgba(79,70,229,0.2);
                       background:var(--bg-surface);color:var(--text-primary);
                       font-size:.85rem;outline:none;box-sizing:border-box;
                       transition:border-color .2s">
        </div>

        <select id="sel-ordenar" onchange="ordenarTabla(this.value)"
            style="padding:.45rem .75rem;border-radius:8px;
                   border:1px solid rgba(79,70,229,0.2);
                   background:var(--bg-surface);color:var(--text-primary);
                   font-size:.82rem;cursor:pointer;min-width:150px">
            <option value="">Ordenar por...</option>
            ${opOrdenar}
        </select>

        <button id="btn-direccion" onclick="toggleDireccion()" title="Cambiar dirección"
            style="padding:.45rem .75rem;border-radius:8px;
                   border:1px solid rgba(79,70,229,0.2);
                   background:var(--bg-surface);color:var(--text-primary);
                   cursor:pointer;font-size:.82rem;
                   display:flex;align-items:center;gap:.35rem;white-space:nowrap">
            <i class="fas fa-arrow-up" id="icono-direccion"></i>
            <span id="texto-direccion">A → Z</span>
        </button>

        <button onclick="limpiarBusqueda()"
            style="padding:.45rem .75rem;border-radius:8px;
                   border:1px solid rgba(255,255,255,0.1);
                   background:none;color:var(--text-secondary);
                   cursor:pointer;font-size:.82rem">
            <i class="fas fa-times"></i> Limpiar
        </button>

        <span id="contador-resultados"
            style="font-size:.78rem;color:var(--text-secondary);
                   white-space:nowrap;margin-left:auto"></span>
    </div>`;
}

// ── BUSCAR EN TABLA ───────────────────────────────────────────────
function buscarEnTabla(texto) {
    const tabla = document.querySelector('.premium-table tbody');
    if (!tabla) return;

    const termino  = texto.toLowerCase().trim();
    const filas    = tabla.querySelectorAll('tr:not(.sin-resultados-busqueda)');
    let   visibles = 0;

    filas.forEach(fila => {
        const mostrar = termino === '' || fila.textContent.toLowerCase().includes(termino);
        fila.style.display = mostrar ? '' : 'none';
        if (mostrar) visibles++;
    });

    const contador = document.getElementById('contador-resultados');
    if (contador) {
        contador.textContent  = termino === '' ? `${filas.length} registros` : `${visibles} de ${filas.length} resultados`;
        contador.style.color  = (termino !== '' && visibles === 0) ? '#EF4444' : 'var(--text-secondary)';
    }

    let sinRes = tabla.querySelector('.sin-resultados-busqueda');
    if (visibles === 0 && termino !== '') {
        if (!sinRes) {
            sinRes = document.createElement('tr');
            sinRes.className = 'sin-resultados-busqueda';
            sinRes.innerHTML = `<td colspan="20" style="text-align:center;padding:2rem;
                color:var(--text-secondary);font-size:.875rem">
                <i class="fas fa-search" style="display:block;font-size:1.5rem;
                   margin-bottom:.5rem;opacity:.4"></i>
                Sin resultados para "<strong>${texto}</strong>"
            </td>`;
            tabla.appendChild(sinRes);
        }
    } else if (sinRes) {
        sinRes.remove();
    }
}

// ── ORDENAR TABLA ─────────────────────────────────────────────────
function ordenarTabla(nombreColumna) {
    if (!nombreColumna) return;
    const tabla = document.querySelector('.premium-table');
    if (!tabla) return;

    let colIndex = -1;
    tabla.querySelectorAll('thead th').forEach((th, i) => {
        if (th.textContent.trim().replace(/ ↑| ↓/g,'') === nombreColumna) colIndex = i;
    });
    if (colIndex === -1) return;

    if (_sortEstado.columna === colIndex) {
        _sortEstado.direccion = _sortEstado.direccion === 'asc' ? 'desc' : 'asc';
    } else {
        _sortEstado.columna   = colIndex;
        _sortEstado.direccion = 'asc';
    }
    actualizarBotonDireccion();
    aplicarOrdenamiento(tabla, colIndex, _sortEstado.direccion);
}

function aplicarOrdenamiento(tabla, colIndex, direccion) {
    const tbody = tabla.querySelector('tbody');
    const filas = Array.from(tbody.querySelectorAll('tr:not(.sin-resultados-busqueda)'));

    filas.sort((a, b) => {
        const tA  = a.cells[colIndex]?.textContent?.trim().toLowerCase() || '';
        const tB  = b.cells[colIndex]?.textContent?.trim().toLowerCase() || '';
        const nA  = parseFloat(tA.replace(/[^0-9.-]/g,''));
        const nB  = parseFloat(tB.replace(/[^0-9.-]/g,''));
        const num = !isNaN(nA) && !isNaN(nB);
        const cmp = num ? nA - nB : tA.localeCompare(tB,'es');
        return direccion === 'desc' ? -cmp : cmp;
    });

    filas.forEach(f => tbody.appendChild(f));

    // Marcar cabecera activa
    tabla.querySelectorAll('thead th').forEach((th, i) => {
        // Limpiar icono anterior
        th.innerHTML = th.innerHTML.replace(/\s*<i class="fas fa-sort-(up|down)"[^>]*><\/i>/g,'');
        th.style.color = '';
        if (i === colIndex) {
            th.innerHTML += ` <i class="fas fa-sort-${direccion === 'asc' ? 'up' : 'down'}"
                style="font-size:.7rem;color:#4F46E5"></i>`;
            th.style.color = '#4F46E5';
        }
    });
}

function toggleDireccion() {
    _sortEstado.direccion = _sortEstado.direccion === 'asc' ? 'desc' : 'asc';
    actualizarBotonDireccion();
    if (_sortEstado.columna >= 0) {
        const tabla = document.querySelector('.premium-table');
        if (tabla) aplicarOrdenamiento(tabla, _sortEstado.columna, _sortEstado.direccion);
    }
}

function actualizarBotonDireccion() {
    const icono = document.getElementById('icono-direccion');
    const texto = document.getElementById('texto-direccion');
    if (!icono || !texto) return;
    icono.className   = `fas fa-arrow-${_sortEstado.direccion === 'asc' ? 'up' : 'down'}`;
    texto.textContent = _sortEstado.direccion === 'asc' ? 'A → Z' : 'Z → A';
}

function limpiarBusqueda() {
    const input = document.getElementById('input-busqueda');
    const sel   = document.getElementById('sel-ordenar');
    if (input) { input.value = ''; buscarEnTabla(''); }
    if (sel)   sel.value = '';
    _sortEstado = { columna: -1, direccion: 'asc' };
    actualizarBotonDireccion();
    document.querySelectorAll('.premium-table thead th').forEach(th => {
        th.innerHTML = th.innerHTML.replace(/\s*<i class="fas fa-sort-(up|down)"[^>]*><\/i>/g,'');
        th.style.color = '';
    });
}

// ── INYECTAR BUSCADOR + RENOMBRAR ID ─────────────────────────────
function inyectarBuscador(modulo) {
    _vistaActual = modulo;
    _sortEstado  = { columna: -1, direccion: 'asc' };

    requestAnimationFrame(() => {
        const tableWrapper = document.querySelector('.table-responsive');
        if (!tableWrapper) return;

        const existente = document.getElementById('barra-busqueda');
        if (existente) existente.remove();

        tableWrapper.insertAdjacentHTML('beforebegin', generarBarraBusqueda(modulo));

        // Contador inicial
        const filas    = document.querySelectorAll('.premium-table tbody tr');
        const contador = document.getElementById('contador-resultados');
        if (contador) contador.textContent = `${filas.length} registros`;

        // Foco en buscador
        setTimeout(() => document.getElementById('input-busqueda')?.focus(), 150);

        // Renombrar ID → Código (visual)
        setTimeout(() => renombrarIDaCodigo(), 50);
    });
}

// ── INTERCEPTAR cargarVista ───────────────────────────────────────
const _cargarVistaOriginal = window.cargarVista;
window.cargarVista = function(vista) {
    _cargarVistaOriginal(vista);
    const modulosConBuscador = [
        'categorias','marcas','equipos','inventario','actividades',
        'solicitudes','reservas','mantenimiento','tecnicos',
        'asistencias','personas','usuarios'
    ];
    if (modulosConBuscador.includes(vista)) {
        setTimeout(() => inyectarBuscador(vista), 650);
    }
};

// Exponer globales
Object.assign(window, {
    buscarEnTabla, ordenarTabla, toggleDireccion,
    limpiarBusqueda, inyectarBuscador, renombrarIDaCodigo
});