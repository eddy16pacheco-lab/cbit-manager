// ══════════════════════════════════════════════════════════════════════════
//  reportes.js — Módulo "Reportes e Informes"
//
//  Se carga DESPUÉS de app.js (comparte sus globals: api, showToast, kpi, etc.).
//  Contiene:
//    1. Pestañas de reportes.
//    2. Barra de filtros contextual (cambia según la pestaña activa) + panel
//       colapsable avanzado para el reporte personalizado (RF-20).
//    3. Renderizadores de cada pestaña.
//    4. Vista previa (modal) previa a la exportación a Excel / PDF.
// ══════════════════════════════════════════════════════════════════════════

// ==================== ESTADO ====================
const REPORTE = {
    tab: 'resumen',
    filtros: {},            // filtros APLICADOS por pestaña: { [tab]: { clave: valor } }
    opciones: null,         // catálogos (técnicos, equipos, usuarios, estados) del backend
    opcionesPromise: null,
    token: 0,               // evita que una respuesta lenta pise a una más reciente
    avanzadoAbierto: true,  // estado del panel colapsable de RF-20
    rango: null,            // { desde, hasta } APLICADO y validado; compartido por todas las pestañas
};
// Reporte que se exportará: lo que hay actualmente en pantalla
let _reporteActual = { tab: '', titulo: '', columnas: [], filas: [], filtros: [] };

// ==================== UTILIDADES ====================
function _esc(v) {
    return String(v ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}
// 'YYYY-MM-DD' → 'DD/MM/YYYY' sin pasar por Date (evita desfases de zona horaria)
function _fechaLegible(iso) {
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso || '');
    return m ? `${m[3]}/${m[2]}/${m[1]}` : (iso || '');
}

// ==================== PESTAÑAS ====================
const TABS_REPORTE = [
    { key:'resumen',           label:'Resumen',              icon:'fas fa-chart-pie',      admin:false },
    { key:'usuarios',          label:'Usuarios',             icon:'fas fa-users',           admin:true  },
    { key:'equipos',           label:'Equipos Tecnológicos', icon:'fas fa-laptop',          admin:false },
    { key:'disponibilidad',    label:'Disponibilidad',       icon:'fas fa-microchip',       admin:false },
    { key:'reservas-equipos',  label:'Reservas Equipos',     icon:'fas fa-hdd',             admin:false },
    { key:'reservas-espacios', label:'Reservas Espacio',     icon:'fas fa-door-open',       admin:false },
    { key:'actividades',       label:'Actividades',          icon:'fas fa-chalkboard',      admin:false },
    { key:'fallas',            label:'Fallas Técnicas',      icon:'fas fa-exclamation-triangle', admin:false },
    { key:'mantenimiento',     label:'Mantenimiento',        icon:'fas fa-tools',           admin:false },
    { key:'asistencia',        label:'Asistencia',           icon:'fas fa-clipboard-user',  admin:false },
    { key:'maquinas-usadas',   label:'Máquinas más usadas',  icon:'fas fa-fire',            admin:false },
    { key:'personalizado',     label:'Personalizado', icon:'fas fa-sliders',        admin:false },
];

function tabsHTML(activo) {
    const esAdmin = usuarioActual?.roles === 'Administrador';
    return `<div id="tabs-reporte" style="display:flex;gap:.4rem;flex-wrap:wrap;margin-bottom:1.25rem;padding-bottom:.75rem;border-bottom:1px solid var(--glass-border)">
        ${TABS_REPORTE.filter(t => !t.admin || esAdmin).map(t => `
        <button class="reporte-tab${t.key===activo?' active':''}" data-tab="${t.key}"
            onclick="cargarTabReporte('${t.key}')"
            style="background:${t.key===activo?'var(--primary,#4F46E5)':'var(--bg-main)'};
                   color:${t.key===activo?'#fff':'var(--text-primary)'};border:1px solid var(--glass-border);padding:.4rem .85rem;
                   border-radius:8px;cursor:pointer;font-size:.8rem;display:flex;
                   align-items:center;gap:.35rem;white-space:nowrap;transition:background .2s,color .2s">
            <i class="${t.icon}"></i>${t.label}
        </button>`).join('')}
    </div>`;
}

function botonExportar() {
    return `<div class="rf-export">
        <span style="font-size:.78rem;opacity:.5">Exportar:</span>
        <button class="btn btn-outline" style="padding:.35rem .8rem;font-size:.8rem" onclick="exportarExcel()">
            <i class="fas fa-file-excel" style="color:#21a366;margin-right:.3rem"></i>Excel</button>
        <button class="btn btn-outline" style="padding:.35rem .8rem;font-size:.8rem" onclick="exportarPDF()">
            <i class="fas fa-file-pdf" style="color:#e53e3e;margin-right:.3rem"></i>PDF</button>
    </div>`;
}

// ==================== COMPONENTES VISUALES ====================
function kpi(label, valor, icon, color) {
    return `<div class="stat-card glass-panel" style="flex:1;min-width:130px">
        <div class="stat-icon ${color}"><i class="${icon}"></i></div>
        <div class="stat-info"><h3 style="font-size:.78rem">${_esc(label)}</h3><h2>${_esc(valor)}</h2></div>
    </div>`;
}

function barraH(items, max, color) {
    if (!items?.length) return '<p style="opacity:.4;text-align:center;padding:1rem">Sin datos</p>';
    return items.map(item => `
        <div style="margin-bottom:.8rem">
            <div style="display:flex;justify-content:space-between;margin-bottom:.25rem">
                <span style="font-size:.84rem">${_esc(item.nombre)}</span>
                <strong style="font-size:.84rem">${_esc(item.total)}</strong>
            </div>
            <div style="background:rgba(255,255,255,.08);border-radius:99px;height:8px">
                <div style="width:${Math.round((item.total/max)*100)}%;background:${color};border-radius:99px;height:8px;transition:width .6s"></div>
            </div>
        </div>`).join('');
}

function tablaHTML(columnas, filas) {
    if (!filas?.length) return '<p style="opacity:.4;text-align:center;padding:1.5rem">Sin registros para los filtros seleccionados</p>';
    return `<div class="table-responsive" style="max-height:440px;overflow-y:auto;margin-top:.75rem">
        <table class="premium-table" style="font-size:.82rem">
            <thead><tr>${columnas.map(c=>`<th>${_esc(c)}</th>`).join('')}</tr></thead>
            <tbody>${filas.map(f=>`<tr>${f.map(c=>`<td>${_esc(c ?? '—')}</td>`).join('')}</tr>`).join('')}</tbody>
        </table>
    </div>`;
}

// ══════════════════════════════════════════════════════════════════════════
//  FILTROS CONTEXTUALES
//  Cada pestaña declara qué campos usa. La barra se construye a partir de
//  esta configuración, así agregar un filtro nuevo es solo declararlo aquí
//  (y leerlo en el controlador del backend).
// ══════════════════════════════════════════════════════════════════════════
const ESTADOS_RESPALDO = {
    prioridad: ['Alta', 'Media', 'Baja'],
    rol:       ['Administrador', 'Docente'],
    solicitud: ['Aprobado', 'Pendiente', 'Cancelado', 'Completado'],
    equipo:    ['Operativo', 'No operativo', 'En Reparacion', 'Dañado', 'Desincorporado'],
    usuario:   ['Activo', 'Inactivo', 'Bloqueado'],
};

// Rango de fechas OBLIGATORIO en todos los reportes (el backend también lo exige)
const F_RANGO = [
    { key:'desde', label:'Fecha de Inicio', tipo:'date', requerido:true },
    { key:'hasta', label:'Fecha de Fin',    tipo:'date', requerido:true },
];
const F_PRIORIDAD = { key:'prioridad', label:'Nivel de prioridad', tipo:'select', lista:'prioridad', todos:'Todas' };
const F_TECNICO   = { key:'id_tecnico', label:'Técnico asignado',  tipo:'select', lista:'tecnicos',  todos:'Todos' };
const F_ROL       = { key:'rol',        label:'Rol',               tipo:'select', lista:'rol',       todos:'Todos' };
const F_EQUIPO    = { key:'id_equipo',  label:'Equipo',            tipo:'select', lista:'equipos',   todos:'Todos los equipos' };
const F_USUARIO   = { key:'id_usuario', label:'Usuario',           tipo:'select', lista:'usuarios',  todos:'Todos los usuarios' };
const F_ORDEN     = { key:'orden',      label:'Ordenar por',       tipo:'select', fijo:[['desc','Más usadas'], ['asc','Menos usadas']] };
const F_LIMITE    = { key:'limite',     label:'Mostrar',           tipo:'select', fijo:[['5','Top 5'], ['10','Top 10'], ['todos','Todos']] };
const F_ESTADO = (lista, label) => ({ key:'estado', label, tipo:'select', lista, todos:'Todos' });

// La tabla `mantenimiento` no guarda un estado propio: el sistema actualiza el estado
// del equipo en inventario al reportar la avería, y ese es el estado que se filtra.
const AYUDA_MANTENIMIENTO = 'El estado corresponde al estado actual del equipo en el inventario.';

const CONFIG_FILTROS = {
    'resumen':           { campos: [...F_RANGO], ayuda: 'Las solicitudes y los mantenimientos corresponden al período elegido; el estado del inventario es el actual.' },
    'usuarios':          { campos: [...F_RANGO, F_ROL, F_ESTADO('usuario', 'Estado del usuario')], ayuda: 'La columna de solicitudes cuenta las realizadas dentro del período.' },
    'equipos':           { campos: [...F_RANGO, F_ESTADO('equipo', 'Estado del equipo')], ayuda: 'La columna de reservas cuenta las reservas (no canceladas) de cada unidad dentro del período.' },
    'disponibilidad':    { campos: [...F_RANGO, F_ESTADO('equipo', 'Estado del equipo')], ayuda: 'La disponibilidad es la actual; las reservas corresponden al período elegido.' },
    'reservas-equipos':  { campos: [...F_RANGO, F_ESTADO('solicitud', 'Estado de la reserva')] },
    'reservas-espacios': { campos: [...F_RANGO, F_ESTADO('solicitud', 'Estado de la reserva')] },
    'actividades':       { campos: [...F_RANGO], ayuda: 'Solo se cuentan las solicitudes realizadas dentro del período elegido.' },
    'fallas':            { campos: [...F_RANGO, F_PRIORIDAD, F_ESTADO('equipo', 'Estado del equipo'), F_TECNICO], ayuda: AYUDA_MANTENIMIENTO },
    'mantenimiento':     { campos: [...F_RANGO, F_PRIORIDAD, F_ESTADO('equipo', 'Estado del equipo'), F_TECNICO], ayuda: AYUDA_MANTENIMIENTO },
    'asistencia':        { campos: [...F_RANGO] },
    'maquinas-usadas':   { campos: [...F_RANGO, F_ORDEN, F_LIMITE], defaults: { orden: 'desc', limite: '10' },
                           ayuda: 'En "Menos usadas" también aparecen los equipos que nunca se han reservado.' },
    'personalizado':     { campos: [...F_RANGO, F_EQUIPO, F_USUARIO], avanzado: true,
                           titulo: 'Filtros avanzados',
                           ayuda: 'Combine fecha, equipo y usuario. Los filtros que deje vacíos no restringen el resultado.' },
};

// Lista de pares [valor, etiqueta] para un campo de tipo select
function _opcionesDe(campo) {
    if (campo.fijo) return campo.fijo;
    const o = REPORTE.opciones;
    let pares = [];
    if (['prioridad', 'rol', 'solicitud', 'equipo', 'usuario'].includes(campo.lista)) {
        const lista = o?.estados?.[campo.lista] || ESTADOS_RESPALDO[campo.lista] || [];
        pares = lista.map(v => [v, v]);
    } else if (campo.lista === 'tecnicos') {
        pares = (o?.tecnicos || []).map(t => [String(t.id), t.especialidad ? `${t.nombre} (${t.especialidad})` : t.nombre]);
    } else if (campo.lista === 'equipos') {
        pares = (o?.equipos || []).map(e => [String(e.id), e.nombre]);
    } else if (campo.lista === 'usuarios') {
        pares = (o?.usuarios || []).map(u => [String(u.id), u.nombre]);
    }
    return [['', campo.todos || 'Todos'], ...pares];
}

function _campoHTML(campo, valor) {
    const id = `rf-${campo.key}`;
    let control;
    if (campo.tipo === 'date') {
        control = `<input type="date" id="${id}" data-rf="${campo.key}" class="form-control" value="${_esc(valor || '')}"${campo.requerido ? ' required aria-required="true"' : ''} onchange="_sincronizarRango()">`;
    } else {
        // Un docente solo puede consultar sus propias reservas: el selector de usuario se bloquea
        const bloqueado = campo.key === 'id_usuario' && REPORTE.opciones && !REPORTE.opciones.esAdmin;
        const opts = _opcionesDe(campo);
        const sel = bloqueado ? (opts.find(p => p[0] !== '') || opts[0])[0] : (valor ?? '');
        control = `<select id="${id}" data-rf="${campo.key}" class="form-control"${bloqueado ? ' disabled title="Solo puede consultar sus propias reservas"' : ''}>
            ${opts.map(([v, l]) => `<option value="${_esc(v)}"${String(v) === String(sel) ? ' selected' : ''}>${_esc(l)}</option>`).join('')}
        </select>`;
    }
    return `<div class="rf-campo"><label for="${id}">${_esc(campo.label)}${campo.requerido ? ' <span class="req" title="Obligatorio">*</span>' : ''}</label>${control}</div>`;
}

// Mantiene coherente el rango de fechas (desde ≤ hasta) directamente en los inputs
function _sincronizarRango() {
    const d = document.getElementById('rf-desde'), h = document.getElementById('rf-hasta');
    if (!d || !h) return;
    h.min = d.value || '';
    d.max = h.value || '';
}

function _valorLegible(campo, valor) {
    if (campo.tipo === 'date') return _fechaLegible(valor);
    const par = _opcionesDe(campo).find(p => String(p[0]) === String(valor));
    return par ? par[1] : valor;
}

// Filtros aplicados en forma legible: [{ label, valor }]. Se usa en chips, vista previa y exportaciones.
function describirFiltros(tab, filtros) {
    const cfg = CONFIG_FILTROS[tab];
    if (!cfg) return [];
    return cfg.campos
        .filter(c => filtros?.[c.key])
        .map(c => ({ label: c.label, valor: _valorLegible(c, filtros[c.key]) }));
}

function _chipsHTML(lista) {
    return lista.map(f => `<span class="rf-chip"><b>${_esc(f.label)}:</b> ${_esc(f.valor)}</span>`).join('');
}

// Filtros APLICADOS de una pestaña: los propios + el rango de fechas compartido
function _filtrosAplicados(tab) {
    return { ...(REPORTE.filtros[tab] || {}), ...(REPORTE.rango || {}) };
}
// Misma regla que el backend (validarRango): ambas fechas obligatorias y Inicio <= Fin
function _errorRango(desde, hasta) {
    if (!desde) return 'La Fecha de Inicio es obligatoria';
    if (!hasta) return 'La Fecha de Fin es obligatoria';
    if (desde > hasta) return 'La Fecha de Inicio no puede ser mayor a la Fecha de Fin';
    return null;
}
function _periodoTexto() {
    const f = _filtrosAplicados(REPORTE.tab);
    return f.desde && f.hasta ? `${_fechaLegible(f.desde)} al ${_fechaLegible(f.hasta)}` : '';
}
// Marca los campos de fecha con error y muestra el mensaje bajo la barra
function _marcarErrorRango(mensaje) {
    ['rf-desde', 'rf-hasta'].forEach(id => {
        const el = document.getElementById(id);
        if (!el) return;
        el.classList.toggle('input-invalida', !!mensaje);
        el.setAttribute('aria-invalid', mensaje ? 'true' : 'false');
    });
    const e = document.getElementById('rf-error-rango');
    if (e) e.textContent = mensaje || '';
}

// Lee lo que hay actualmente en los controles de la barra (aún sin aplicar)
function _leerFiltrosForm() {
    const out = {};
    document.querySelectorAll('#reporte-filtros [data-rf]').forEach(el => {
        const v = el.value.trim();
        if (v && !el.disabled) out[el.dataset.rf] = v;
    });
    return out;
}
function _filtrosIguales(a, b) {
    const ka = Object.keys(a || {}).sort(), kb = Object.keys(b || {}).sort();
    return ka.length === kb.length && ka.every((k, i) => k === kb[i] && String(a[k]) === String(b[k]));
}
function hayFiltrosPendientes() {
    const cfg = CONFIG_FILTROS[REPORTE.tab];
    if (!cfg?.campos.length) return false;
    return !_filtrosIguales(_leerFiltrosForm(), _filtrosAplicados(REPORTE.tab));
}

function renderBarraFiltros(tab) {
    const cont = document.getElementById('reporte-filtros');
    if (!cont) return;
    const cfg = CONFIG_FILTROS[tab];
    const aplicados = _filtrosAplicados(tab);

    if (!cfg.campos.length) {
        cont.innerHTML = `<div class="rf-bar rf-bar-info"><i class="fas fa-circle-info"></i><span>${_esc(cfg.ayuda || '')}</span></div>`;
        return;
    }

    const chips = describirFiltros(tab, aplicados);
    const formulario = `
        <div class="rf-form">
            ${cfg.campos.map(c => _campoHTML(c, aplicados[c.key])).join('')}
            <div class="rf-actions">
                <button class="btn btn-primary" onclick="aplicarFiltrosReporte()"><i class="fas fa-filter"></i> Generar reporte</button>
                <button class="btn btn-outline" onclick="limpiarFiltrosReporte()" title="Restablece los demás filtros; el rango de fechas es obligatorio y se conserva"><i class="fas fa-rotate"></i> Limpiar</button>
            </div>
        </div>
        <p class="field-hint" id="rf-error-rango" role="alert"></p>
        ${cfg.ayuda ? `<p class="rf-ayuda"><i class="fas fa-circle-info"></i> ${_esc(cfg.ayuda)}</p>` : ''}`;

    const activos = chips.length
        ? `<div class="rf-activos"><span class="rf-label">Aplicados:</span>${_chipsHTML(chips)}</div>` : '';

    if (cfg.avanzado) {
        const abierto = REPORTE.avanzadoAbierto;
        cont.innerHTML = `
            <div class="rf-bar rf-avanzado${abierto ? '' : ' cerrado'}">
                <button type="button" class="rf-toggle" aria-expanded="${abierto}" aria-controls="rf-cuerpo" onclick="toggleFiltrosAvanzados()">
                    <span><i class="fas fa-sliders"></i> ${_esc(cfg.titulo)}</span>
                    <span class="rf-toggle-der">${chips.length ? `<span class="rf-badge">${chips.length} activo${chips.length > 1 ? 's' : ''}</span>` : ''}<i class="fas fa-chevron-down rf-chevron"></i></span>
                </button>
                <div class="rf-colapsable" id="rf-cuerpo"><div class="rf-colapsable-inner">${formulario}</div></div>
                ${activos}
            </div>`;
    } else {
        cont.innerHTML = `<div class="rf-bar">${formulario}${activos}</div>`;
    }
    cont.onkeydown = e => { if (e.key === 'Enter' && e.target.matches('input, select')) aplicarFiltrosReporte(); };
    _sincronizarRango();
}

function toggleFiltrosAvanzados() {
    REPORTE.avanzadoAbierto = !REPORTE.avanzadoAbierto;
    const bar = document.querySelector('#reporte-filtros .rf-avanzado');
    bar?.classList.toggle('cerrado', !REPORTE.avanzadoAbierto);
    bar?.querySelector('.rf-toggle')?.setAttribute('aria-expanded', String(REPORTE.avanzadoAbierto));
}

function aplicarFiltrosReporte() {
    const tab = REPORTE.tab;
    const f = _leerFiltrosForm();
    // Ningún reporte se genera sin rango de fechas válido
    const err = _errorRango(f.desde, f.hasta);
    if (err) {
        _marcarErrorRango(err);
        showToast(err, 'error');
        document.getElementById(!f.desde ? 'rf-desde' : !f.hasta ? 'rf-hasta' : 'rf-desde')?.focus();
        return;
    }
    _marcarErrorRango('');
    REPORTE.rango = { desde: f.desde, hasta: f.hasta };
    const { desde, hasta, ...resto } = f;
    REPORTE.filtros[tab] = resto;
    renderBarraFiltros(tab);
    _cargarDatosReporte(tab, ++REPORTE.token);
}

// Restablece los filtros opcionales; el rango de fechas es obligatorio y se conserva
function limpiarFiltrosReporte() {
    const tab = REPORTE.tab;
    REPORTE.filtros[tab] = { ...(CONFIG_FILTROS[tab].defaults || {}) };
    renderBarraFiltros(tab);
    _cargarDatosReporte(tab, ++REPORTE.token);
}

// Estado inicial de cada pestaña: no se genera nada hasta tener un rango de fechas aplicado
function _mostrarSinRango() {
    _reporteActual = { tab: REPORTE.tab, titulo: '', columnas: [], filas: [], filtros: [] };
    const c = document.getElementById('reporte-contenido');
    if (c) c.innerHTML = `<div class="rf-vacio"><i class="fas fa-calendar-days"></i>
        <p><strong>Seleccione un rango de fechas para generar el reporte.</strong></p>
        <p>Indique la Fecha de Inicio y la Fecha de Fin y pulse «Generar reporte».</p></div>`;
}

// Catálogos para los selectores. Se piden una vez por visita al módulo.
function _asegurarOpciones() {
    if (!REPORTE.opcionesPromise) {
        REPORTE.opcionesPromise = api('GET', '/reportes/opciones-filtros')
            .then(r => { if (r.ok) REPORTE.opciones = r; })
            .catch(() => { REPORTE.opcionesPromise = null; });
    }
    return REPORTE.opcionesPromise;
}

// ==================== VISTA PRINCIPAL ====================
async function renderReportes() {
    setContainer(loadingPanel('Reportes e Informes', 'view-reportes'));
    REPORTE.opcionesPromise = null;     // refresca catálogos (equipos/técnicos nuevos)
    REPORTE.opciones = null;
    REPORTE.rango = null;               // cada visita exige elegir el rango de fechas
    REPORTE.filtros = {};
    _construirVistaReportes('resumen');
    await cargarTabReporte('resumen');
}

function _construirVistaReportes(tabActivo) {
    document.getElementById('views-container').innerHTML = `
        <div id="view-reportes" class="view-section active">
            <div class="section-header" style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:1rem">
                <div><h1 class="page-title">Reportes e Informes</h1><p class="page-subtitle">CBIT Francisco de Miranda — ${new Date().toLocaleDateString('es-ES',{weekday:'long',year:'numeric',month:'long',day:'numeric'})}</p></div>
                <div id="btn-export-wrap">${botonExportar()}</div>
            </div>
            <div class="glass-panel">
                ${tabsHTML(tabActivo)}
                <div id="reporte-filtros"></div>
                <div id="reporte-contenido"><div style="text-align:center;padding:2rem;opacity:.4"><i class="fas fa-spinner fa-spin fa-2x"></i></div></div>
            </div>
        </div>`;
}

function _marcarTabActiva(tab) {
    document.querySelectorAll('.reporte-tab').forEach(t => {
        const isActive = t.dataset.tab === tab;
        t.classList.toggle('active', isActive);
        t.style.background = isActive ? 'var(--primary,#4F46E5)' : 'var(--bg-main)';
        t.style.color = isActive ? '#fff' : 'var(--text-primary)';
    });
}

async function cargarTabReporte(tab) {
    if (!CONFIG_FILTROS[tab]) return;
    REPORTE.tab = tab;
    const token = ++REPORTE.token;
    _marcarTabActiva(tab);
    const cont = document.getElementById('reporte-contenido');
    if (cont) cont.innerHTML = '<div style="text-align:center;padding:2rem;opacity:.4"><i class="fas fa-spinner fa-spin fa-2x"></i> Cargando...</div>';

    await _asegurarOpciones();
    if (token !== REPORTE.token) return;
    if (!REPORTE.filtros[tab]) REPORTE.filtros[tab] = { ...(CONFIG_FILTROS[tab].defaults || {}) };
    renderBarraFiltros(tab);
    if (!REPORTE.rango) return _mostrarSinRango();
    await _cargarDatosReporte(tab, token);
}

async function _cargarDatosReporte(tab, token) {
    const cont = document.getElementById('reporte-contenido');
    if (!cont) return;
    if (!REPORTE.rango) return _mostrarSinRango();
    cont.innerHTML = '<div style="text-align:center;padding:2rem;opacity:.4"><i class="fas fa-spinner fa-spin fa-2x"></i> Cargando...</div>';

    const qs = new URLSearchParams(_filtrosAplicados(tab)).toString();
    let r;
    try { r = await api('GET', `/reportes/${tab}${qs ? '?' + qs : ''}`); }
    catch (e) { r = { ok: false, msg: 'No se pudo conectar con el servidor.' }; }
    if (token !== REPORTE.token) return;          // el usuario ya cambió de pestaña o de filtros
    if (!r.ok) {
        cont.innerHTML = `<p style="color:#f87171;padding:1rem">${_esc(r.msg || 'Error al cargar el reporte')}</p>`;
        _reporteActual = { tab, titulo: '', columnas: [], filas: [], filtros: [] };
        return;
    }

    const fecha = _periodoTexto();      // "DD/MM/AAAA al DD/MM/AAAA": va en el título de cada reporte
    switch (tab) {
        case 'resumen':            _renderTabResumen(r, fecha); break;
        case 'usuarios':           _renderTabUsuarios(r, fecha); break;
        case 'equipos':            _renderTabEquipos(r, fecha); break;
        case 'disponibilidad':     _renderTabDisponibilidad(r, fecha); break;
        case 'reservas-equipos':   _renderTabReservasEquipos(r, fecha); break;
        case 'reservas-espacios':  _renderTabReservasEspacios(r, fecha); break;
        case 'actividades':        _renderTabActividades(r, fecha); break;
        case 'fallas':             _renderTabFallas(r, fecha); break;
        case 'mantenimiento':      _renderTabMantenimiento(r, fecha); break;
        case 'asistencia':         _renderTabAsistencia(r, fecha); break;
        case 'maquinas-usadas':    _renderTabMaquinas(r, fecha); break;
        case 'personalizado':      _renderTabPersonalizado(r, fecha); break;
    }
}

// Fija el reporte actual (lo que se exporta) junto con los filtros con que se generó
function _fijarReporte(titulo, columnas, filas) {
    _reporteActual = {
        tab: REPORTE.tab, titulo, columnas, filas,
        filtros: describirFiltros(REPORTE.tab, _filtrosAplicados(REPORTE.tab)),
    };
}

// ==================== RENDERIZADORES POR PESTAÑA ====================
function _renderTabResumen(r, fecha) {
    const {inv_stats:i, sol_stats:s, man_stats:m, top_espacios, top_actividades} = r;
    const maxE = Math.max(...(top_espacios||[{total:1}]).map(e=>e.total), 1);
    const maxA = Math.max(...(top_actividades||[{total:1}]).map(a=>a.total), 1);
    document.getElementById('reporte-contenido').innerHTML = `
        <h4 style="margin-bottom:.75rem;opacity:.7">Inventario de Equipos <small>(estado actual)</small></h4>
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.5rem">
            ${kpi('Total',i.total,'fas fa-layer-group','purple')}
            ${kpi('Operativos',i.operativo,'fas fa-check-circle','green')}
            ${kpi('En Reparación',i.en_reparacion,'fas fa-tools','orange')}
            ${kpi('No Operativo',i.no_operativo,'fas fa-ban','blue')}
            ${kpi('Dañados',i.daniado,'fas fa-exclamation-triangle','orange')}
            ${kpi('Desincorporados',i.desincorporado||0,'fas fa-box-archive','purple')}
        </div>
        <h4 style="margin-bottom:.75rem;opacity:.7">Solicitudes y Reservas <small>(del período)</small></h4>
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.5rem">
            ${kpi('Total',s.total,'fas fa-list','purple')}
            ${kpi('Aprobadas',s.aprobadas,'fas fa-calendar-check','green')}
            ${kpi('Pendientes',s.pendientes,'fas fa-clock','orange')}
            ${kpi('Completadas',s.completadas,'fas fa-check-double','blue')}
            ${kpi('Canceladas',s.canceladas,'fas fa-times-circle','orange')}
        </div>
        <h4 style="margin-bottom:.75rem;opacity:.7">Mantenimiento <small>(del período)</small></h4>
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.5rem">
            ${kpi('Total',m.total,'fas fa-clipboard-list','purple')}
            ${kpi('Alta Prioridad',m.alta,'fas fa-fire','orange')}
            ${kpi('Media Prioridad',m.media,'fas fa-minus-circle','blue')}
            ${kpi('Baja Prioridad',m.baja,'fas fa-arrow-down','green')}
        </div>
        <div class="dashboard-content-grid">
            <div><h4 style="margin-bottom:.75rem;opacity:.7"><i class="fas fa-door-open" style="margin-right:.3rem"></i>Espacios más solicitados</h4>
            ${barraH(top_espacios, maxE, 'linear-gradient(90deg,#4F46E5,#7C3AED)')}</div>
            <div><h4 style="margin-bottom:.75rem;opacity:.7"><i class="fas fa-chalkboard" style="margin-right:.3rem"></i>Actividades más frecuentes</h4>
            ${barraH(top_actividades, maxA, 'linear-gradient(90deg,#EC4899,#F59E0B)')}</div>
        </div>`;
    _fijarReporte(`Resumen General CBIT — ${fecha}`, ['Módulo','Indicador','Valor'], [
            ...['total','operativo','en_reparacion','no_operativo','daniado','desincorporado'].map(k=>['Inventario (actual)',k,i[k]]),
            ...['total','aprobadas','pendientes','completadas','canceladas'].map(k=>['Solicitudes',k,s[k]]),
            ...['total','alta','media','baja'].map(k=>['Mantenimiento',k,m[k]]),
            ...(top_espacios||[]).map(e=>['Top Espacios',e.nombre,e.total]),
            ...(top_actividades||[]).map(a=>['Top Actividades',a.nombre,a.total]),
        ]);
}

function _renderTabUsuarios(r, fecha) {
    const cols = ['ID','Usuario','Nombre','Apellido','Cédula','Correo','Rol','Estado','Solicitudes en el período'];
    const filas = (r.usuarios||[]).map(u=>[u.id_usuario,u.nombre_usuario,u.nombre||'—',u.apellido||'—',u.cedula||'—',u.correo,u.roles,u.estado,u.total_solicitudes]);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total usuarios', r.usuarios.length,'fas fa-users','purple')}
            ${kpi('Activos', r.usuarios.filter(u=>u.estado==='Activo').length,'fas fa-user-check','green')}
            ${kpi('Inactivos', r.usuarios.filter(u=>u.estado!=='Activo').length,'fas fa-user-slash','orange')}
            ${kpi('Administradores', r.usuarios.filter(u=>u.roles==='Administrador').length,'fas fa-user-shield','blue')}
            ${kpi('Docentes', r.usuarios.filter(u=>u.roles==='Docente').length,'fas fa-chalkboard-teacher','green')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte General de Usuarios — ${fecha}`, cols, filas);
}

function _renderTabEquipos(r, fecha) {
    const cols = ['Cód. Bienes Nacionales','Serial','Equipo','Categoría','Marca','Modelo','Ubicación','Estado','Reservas en el período'];
    const filas = (r.equipos||[]).map(e=>[e.codigo_bien_nacional||'Sin código',e.serial,e.equipo_nombre,e.categoria||'—',e.marca||'—',e.modelo||'—',(e.ubicacion||'N/A').split(' - ').pop(),e.estado,e.reservas_periodo??0]);
    const porEstado = {};
    (r.equipos||[]).forEach(e=>{ porEstado[e.estado]=(porEstado[e.estado]||0)+1; });
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total',r.equipos.length,'fas fa-laptop','purple')}
            ${Object.entries(porEstado).map(([est,n])=>kpi(est,n,'fas fa-circle',est==='Operativo'?'green':est==='En Reparacion'?'orange':'blue')).join('')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Equipos Tecnológicos — ${fecha}`, cols, filas);
}

function _renderTabDisponibilidad(r, fecha) {
    const cols = ['Cód. Bienes Nacionales','Serial','Equipo','Modelo','Ubicación','Estado','Disponibilidad','Reservas en el período'];
    const filas = (r.inventario||[]).map(i=>[i.codigo_bien_nacional||'Sin código',i.serial,i.equipo_nombre||'N/A',i.modelo_nombre||'—',(i.ubicacion_nombre||'N/A').split(' - ').pop(),i.estado,i.estado==='Operativo'?'Disponible':'No disponible',i.reservas_periodo??0]);
    const disp = (r.inventario||[]).filter(i=>i.estado==='Operativo').length;
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total',r.inventario.length,'fas fa-boxes','purple')}
            ${kpi('Disponibles',disp,'fas fa-check-circle','green')}
            ${kpi('No disponibles',r.inventario.length-disp,'fas fa-times-circle','orange')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Disponibilidad de Equipos — ${fecha}`, cols, filas);
}

function _renderTabReservasEquipos(r, fecha) {
    const cols = ['Cód. Bienes Nacionales','Serial','Equipo','Modelo','Docente','Actividad','Fecha','Hora Inicio','Hora Fin','Estado'];
    const filas = (r.reservas||[]).map(x=>[x.codigo_bien_nacional||'Sin código',x.serial,x.equipo_nombre||'N/A',x.modelo_nombre||'—',`${x.docente_nombre||''} ${x.docente_apellido||''}`.trim()||'—',x.actividad_nombre||'N/A',new Date(x.fecha).toLocaleDateString('es-ES'),String(x.hora_inicio).slice(0,5),String(x.hora_fin).slice(0,5),x.estado]);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total reservas equipos',r.reservas.length,'fas fa-hdd','purple')}
            ${kpi('Aprobadas',r.reservas.filter(x=>x.estado==='Aprobado').length,'fas fa-check','green')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Reservas de Equipos — ${fecha}`, cols, filas);
}

function _renderTabReservasEspacios(r, fecha) {
    const cols = ['ID','Docente','Espacio','Actividad','Fecha','Hora Inicio','Hora Fin','Estado','Descripción'];
    const filas = (r.reservas||[]).map(s=>[s.id_solicitud,`${s.docente_nombre||''} ${s.docente_apellido||''}`.trim()||'—',s.espacio||'N/A',s.actividad||'N/A',new Date(s.fecha).toLocaleDateString('es-ES'),String(s.hora_inicio).slice(0,5),String(s.hora_fin).slice(0,5),s.estado,s.descripcion||'—']);
    const stats = {aprobadas:(r.reservas||[]).filter(s=>s.estado==='Aprobado').length, pendientes:(r.reservas||[]).filter(s=>s.estado==='Pendiente').length};
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total solicitudes',r.reservas.length,'fas fa-door-open','purple')}
            ${kpi('Aprobadas',stats.aprobadas,'fas fa-check-circle','green')}
            ${kpi('Pendientes',stats.pendientes,'fas fa-clock','orange')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Reservas de Espacio — ${fecha}`, cols, filas);
}

function _renderTabActividades(r, fecha) {
    const cols = ['ID','Actividad','Descripción','Total Solicitudes','Aprobadas','Completadas','Última Fecha'];
    const filas = (r.actividades||[]).map(a=>[a.id_actividad,a.nombre,a.descripcion_actividad||'—',a.total_solicitudes||0,a.aprobadas||0,a.completadas||0,a.ultima_fecha?new Date(a.ultima_fecha).toLocaleDateString('es-ES'):'—']);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total actividades',r.actividades.length,'fas fa-chalkboard','purple')}
            ${kpi('Con solicitudes',r.actividades.filter(a=>a.total_solicitudes>0).length,'fas fa-file-alt','green')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Actividades Educativas — ${fecha}`, cols, filas);
}

function _renderTabFallas(r, fecha) {
    const cols = ['ID','Equipo','Categoría','Serial','Descripción Falla','Prioridad','Estado equipo','Técnico','Especialidad','Fecha Reporte'];
    const filas = (r.fallas||[]).map(f=>[
        `MAN-${String(f.id_mantenimiento).padStart(2,'0')}`,
        f.equipo_nombre||'N/A', f.categoria||'—', f.serial||'—',
        f.descripcion_fallas||'—', f.nivel_prioridad, f.estado_equipo||'—',
        `${f.tec_nombre||''} ${f.tec_apellido||''}`.trim()||'—',
        f.especialidad||'—',
        new Date(f.fecha_reporte).toLocaleDateString('es-ES')
    ]);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total fallas',r.fallas.length,'fas fa-exclamation-triangle','orange')}
            ${kpi('Alta prioridad',r.fallas.filter(f=>f.nivel_prioridad==='Alta').length,'fas fa-fire','orange')}
            ${kpi('Media prioridad',r.fallas.filter(f=>f.nivel_prioridad==='Media').length,'fas fa-minus-circle','blue')}
            ${kpi('Baja prioridad',r.fallas.filter(f=>f.nivel_prioridad==='Baja').length,'fas fa-arrow-down','green')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Fallas Técnicas — ${fecha}`, cols, filas);
}

function _renderTabMantenimiento(r, fecha) {
    const cols = ['ID','Equipo','Serial','Descripción','Prioridad','Estado equipo','Técnico','Especialidad','Fecha'];
    const filas = (r.mantenimientos||[]).map(m=>[
        `MAN-${String(m.id_mantenimiento).padStart(2,'0')}`,
        m.equipo_nombre||'N/A', m.serial||'—',
        m.descripcion_fallas||'—', m.nivel_prioridad, m.estado_equipo||'—',
        `${m.tec_nombre||''} ${m.tec_apellido||''}`.trim()||'—',
        m.especialidad||'—',
        new Date(m.fecha_reporte).toLocaleDateString('es-ES')
    ]);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total reportes',r.mantenimientos.length,'fas fa-clipboard-list','purple')}
            ${kpi('Alta',r.mantenimientos.filter(m=>m.nivel_prioridad==='Alta').length,'fas fa-fire','orange')}
            ${kpi('Media',r.mantenimientos.filter(m=>m.nivel_prioridad==='Media').length,'fas fa-minus','blue')}
            ${kpi('Baja',r.mantenimientos.filter(m=>m.nivel_prioridad==='Baja').length,'fas fa-arrow-down','green')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Mantenimiento de Equipos — ${fecha}`, cols, filas);
}

// RF: reporte de asistencia ordenado con los datos del docente y las actividades realizadas.
function _renderTabAsistencia(r, fecha) {
    const cols = ['Docente','Cédula Docente','Fecha','Actividad Realizada','Espacio','Estudiante','Año/Sección','Asistió'];
    const datos = r.asistencia || [];
    const filas = datos.map(a=>[
        `${a.docente_nombre||''} ${a.docente_apellido||''}`.trim()||'—',
        a.docente_cedula||'—',
        a.fecha?new Date(a.fecha).toLocaleDateString('es-ES'):'—',
        a.actividad_nombre||'—',
        a.espacio_nombre||'—',
        `${a.estudiante_nombre||''} ${a.estudiante_apellido||''}`.trim()||'—',
        `${a.año||'—'} ${a.seccion||''}`.trim(),
        a.asistio==='Si'?'Presente':'Ausente'
    ]);
    const presentes = datos.filter(a=>a.asistio==='Si').length;
    // Agrupar cantidad de registros por docente, ya para un resumen visual rápido
    const porDocente = {};
    datos.forEach(a => { const k = `${a.docente_nombre||''} ${a.docente_apellido||''}`.trim()||'—'; porDocente[k]=(porDocente[k]||0)+1; });
    const topDocentes = Object.entries(porDocente).sort((a,b)=>b[1]-a[1]).slice(0,5).map(([nombre,total])=>({nombre,total}));
    const maxD = Math.max(...topDocentes.map(d=>d.total), 1);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total registros',datos.length,'fas fa-clipboard-user','purple')}
            ${kpi('Presentes',presentes,'fas fa-check-circle','green')}
            ${kpi('Ausentes',datos.length-presentes,'fas fa-times-circle','orange')}
        </div>
        ${topDocentes.length ? `<h4 style="margin-bottom:.75rem;opacity:.7"><i class="fas fa-chalkboard-teacher" style="margin-right:.3rem"></i>Registros por docente</h4>
        ${barraH(topDocentes, maxD, 'linear-gradient(90deg,#4F46E5,#7C3AED)')}` : ''}
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Asistencia por Docente — ${fecha}`, cols, filas);
}

function _renderTabMaquinas(r, fecha) {
    const asc = REPORTE.filtros['maquinas-usadas']?.orden === 'asc';
    const maquinas = r.maquinas || [];
    const cols = ['Equipo','Marca','Modelo','Total Usos'];
    const filas = maquinas.map(m=>[m.equipo_nombre,m.marca||'—',m.modelo_nombre||'—',m.total_usos]);
    const max = Math.max(...maquinas.map(m=>m.total_usos), 1);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.25rem">
            ${kpi('Equipos listados',maquinas.length,'fas fa-fire','orange')}
            ${kpi(asc?'Menos usado':'Más usado', maquinas[0]?.equipo_nombre||'—', asc?'fas fa-arrow-down':'fas fa-trophy','green')}
            ${kpi('Total usos registrados', maquinas.reduce((a,m)=>a+m.total_usos,0),'fas fa-chart-bar','purple')}
        </div>
        <div class="dashboard-content-grid" style="margin-bottom:1rem">
            <div>
                <h4 style="margin-bottom:.75rem;opacity:.7;font-size:.9rem"><i class="fas fa-fire" style="margin-right:.3rem;color:#F59E0B"></i>${asc?'Ranking de menor uso':'Ranking de uso'}</h4>
                ${barraH(maquinas.map(m=>({nombre:m.equipo_nombre,total:m.total_usos})), max, 'linear-gradient(90deg,#F59E0B,#EC4899)')}
            </div>
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte de Máquinas ${asc?'menos':'más'} usadas — ${fecha}`, cols, filas);
}

// RF-20: reporte personalizado — combina Fecha + Equipo + Usuario
function _renderTabPersonalizado(r, fecha) {
    const regs = r.registros || [];
    const cols = ['ID','Fecha','Horario','Docente','Cédula','Equipo','Cód. Bienes Nacionales','Serial','Actividad','Espacio','Estado'];
    const filas = regs.map(x=>[
        x.id_solicitud,
        x.fecha ? new Date(x.fecha).toLocaleDateString('es-ES') : '—',
        `${String(x.hora_inicio).slice(0,5)} - ${String(x.hora_fin).slice(0,5)}`,
        `${x.docente_nombre||''} ${x.docente_apellido||''}`.trim()||'—',
        x.docente_cedula||'—',
        x.equipo_nombre||'—', x.codigo_bien_nacional||(x.serial?'Sin código':'—'), x.serial||'—',
        x.actividad_nombre||'—', x.espacio_nombre||'—', x.estado
    ]);
    const solicitudes = new Set(regs.map(x=>x.id_solicitud)).size;
    const equipos = new Set(regs.filter(x=>x.equipo_nombre).map(x=>x.equipo_nombre)).size;
    const docentes = new Set(regs.map(x=>`${x.docente_nombre||''} ${x.docente_apellido||''}`.trim()).filter(Boolean)).size;
    document.getElementById('reporte-contenido').innerHTML = `
        ${r.restringidoAUsuario ? '<p class="rf-ayuda" style="margin-bottom:.75rem"><i class="fas fa-lock"></i> Se muestran únicamente sus propias reservas.</p>' : ''}
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Solicitudes',solicitudes,'fas fa-list','purple')}
            ${kpi('Equipos distintos',equipos,'fas fa-laptop','green')}
            ${kpi('Docentes',docentes,'fas fa-chalkboard-teacher','blue')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _fijarReporte(`Reporte Personalizado — ${fecha}`, cols, filas);
}

// ══════════════════════════════════════════════════════════════════════════
//  EXPORTACIÓN CON VISTA PREVIA
//  Los botones "Excel" / "PDF" ya no descargan directamente: abren primero un
//  modal con el membrete, los filtros aplicados y una tabla paginada. Solo al
//  pulsar "Confirmar y Descargar" se genera el archivo real.
// ══════════════════════════════════════════════════════════════════════════
const PREVIEW = { formato: 'excel', pagina: 1, porPagina: 10, retorno: null };

function exportarExcel() { abrirVistaPrevia('excel'); }
function exportarPDF()   { abrirVistaPrevia('pdf'); }

function _textoFiltros() {
    return _reporteActual.filtros.length
        ? _reporteActual.filtros.map(f => `${f.label}: ${f.valor}`).join('  |  ')
        : 'Sin filtros (todos los registros)';
}
function _nombreArchivo(ext) {
    // sin acentos ni símbolos: "Reporte de Fallas Técnicas — 01/10/2026 al 31/10/2026" -> "Reporte de Fallas Tecnicas 01-10-2026 al 31-10-2026"
    const base = _reporteActual.titulo.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\//g, '-').replace(/[^a-zA-Z0-9_\- ]/g, '').replace(/\s+/g, ' ').trim();
    return base + '.' + ext;
}
const _pdfHorizontal = () => _reporteActual.columnas.length > 5;

function abrirVistaPrevia(formato) {
    // Nada se exporta sin un rango de fechas aplicado (y vigente para la pestaña actual)
    const ap = _filtrosAplicados(REPORTE.tab);
    if (_errorRango(ap.desde, ap.hasta) || _reporteActual.tab !== REPORTE.tab)
        return showToast('Seleccione la Fecha de Inicio y la Fecha de Fin y genere el reporte antes de exportar', 'error');
    if (!_reporteActual.filas.length) return showToast('No hay datos para exportar', 'error');
    cerrarVistaPrevia();
    PREVIEW.formato = formato;
    PREVIEW.pagina = 1;
    PREVIEW.retorno = document.activeElement;

    const esExcel = formato === 'excel';
    const ahora = new Date();
    const usuario = usuarioActual ? (`${usuarioActual.nombre || ''} ${usuarioActual.apellido || ''}`.trim() || usuarioActual.nombre_usuario || '') : '';
    const total = _reporteActual.filas.length;
    const formatoInfo = esExcel
        ? `Se generará un archivo <b>.xlsx</b> con una hoja “Reporte” (${total} fila${total !== 1 ? 's' : ''} de datos).`
        : `Se generará un <b>PDF</b> tamaño A4 en orientación <b>${_pdfHorizontal() ? 'horizontal' : 'vertical'}</b>.`;
    const pendientes = hayFiltrosPendientes();

    const overlay = document.createElement('div');
    overlay.id = 'modal-preview-reporte';
    overlay.className = 'modal-overlay active rp-overlay';
    overlay.innerHTML = `
        <div class="modal-card modal-wide rp-card" role="dialog" aria-modal="true" aria-labelledby="rp-titulo-modal">
            <div class="modal-header">
                <h3 id="rp-titulo-modal"><i class="fas ${esExcel ? 'fa-file-excel' : 'fa-file-pdf'}"></i> Vista previa — ${esExcel ? 'Exportar a Excel' : 'Exportar a PDF'}</h3>
                <button class="modal-close" aria-label="Cerrar vista previa" onclick="cerrarVistaPrevia()"><i class="fas fa-times"></i></button>
            </div>
            <div class="rp-body">
                ${pendientes ? `<div class="rp-aviso"><i class="fas fa-triangle-exclamation"></i>
                    <span>Hay cambios en los filtros que todavía no se han aplicado. Este reporte usa los filtros ya aplicados que se muestran abajo.</span></div>` : ''}
                <div class="rp-hoja">
                    <div class="rp-membrete">
                        <div class="rp-logo"><i class="fas fa-microchip"></i></div>
                        <div class="rp-inst"><strong>CBIT Manager</strong><span>${_esc(ubicacionPrincipal)}</span></div>
                        <div class="rp-meta">
                            <span><i class="fas fa-calendar-day"></i> ${ahora.toLocaleString('es-ES')}</span>
                            ${usuario ? `<span><i class="fas fa-user"></i> ${_esc(usuario)}</span>` : ''}
                        </div>
                    </div>
                    <h4 class="rp-titulo-reporte">${_esc(_reporteActual.titulo)}</h4>
                    <p class="rp-periodo"><i class="fas fa-calendar-days"></i> Período: <strong>${_esc(_periodoTexto())}</strong></p>
                    <div class="rp-filtros">
                        <span class="rf-label">Filtros aplicados</span>
                        ${_reporteActual.filtros.length ? _chipsHTML(_reporteActual.filtros) : '<span class="rf-chip rf-chip-vacio">Sin filtros — todos los registros</span>'}
                    </div>
                    <div class="rp-resumen"><i class="fas fa-table-list"></i> <b>${total}</b> registro${total !== 1 ? 's' : ''} · <b>${_reporteActual.columnas.length}</b> columnas</div>
                    <div id="rp-tabla"></div>
                    <div id="rp-paginacion" class="rp-paginacion"></div>
                </div>
                <p class="rp-formato-info"><i class="fas fa-circle-info"></i> ${formatoInfo} La vista previa muestra una parte de los registros; el archivo incluirá todos.</p>
            </div>
            <div class="rp-footer">
                <button class="btn btn-outline" onclick="volverAFiltros()"><i class="fas fa-arrow-left"></i> Volver / Modificar filtros</button>
                <button class="btn btn-primary" id="rp-confirmar" onclick="confirmarDescarga()"><i class="fas fa-download"></i> Confirmar y Descargar</button>
            </div>
        </div>`;
    document.body.appendChild(overlay);
    document.body.classList.add('rp-modal-abierto');
    overlay.addEventListener('mousedown', e => { if (e.target === overlay) cerrarVistaPrevia(); });
    document.addEventListener('keydown', _teclasVistaPrevia);
    _renderPreviewTabla();
    document.getElementById('rp-confirmar')?.focus();
}

function _renderPreviewTabla() {
    const { filas, columnas } = _reporteActual;
    const paginas = Math.max(1, Math.ceil(filas.length / PREVIEW.porPagina));
    PREVIEW.pagina = Math.min(Math.max(1, PREVIEW.pagina), paginas);
    const ini = (PREVIEW.pagina - 1) * PREVIEW.porPagina;
    const fin = Math.min(ini + PREVIEW.porPagina, filas.length);

    document.getElementById('rp-tabla').innerHTML = `
        <div class="table-responsive rp-tabla-scroll">
            <table class="premium-table" style="font-size:.8rem">
                <thead><tr>${columnas.map(c => `<th>${_esc(c)}</th>`).join('')}</tr></thead>
                <tbody>${filas.slice(ini, fin).map(f => `<tr>${f.map(c => `<td>${_esc(c ?? '—')}</td>`).join('')}</tr>`).join('')}</tbody>
            </table>
        </div>`;
    document.getElementById('rp-paginacion').innerHTML = `
        <span>Mostrando ${ini + 1}–${fin} de ${filas.length}</span>
        <div class="rp-pag-botones">
            <button class="btn btn-outline" onclick="previewPagina(-1)" ${PREVIEW.pagina <= 1 ? 'disabled' : ''} aria-label="Página anterior"><i class="fas fa-chevron-left"></i></button>
            <span>Página ${PREVIEW.pagina} de ${paginas}</span>
            <button class="btn btn-outline" onclick="previewPagina(1)" ${PREVIEW.pagina >= paginas ? 'disabled' : ''} aria-label="Página siguiente"><i class="fas fa-chevron-right"></i></button>
        </div>`;
}

function previewPagina(delta) {
    PREVIEW.pagina += delta;
    _renderPreviewTabla();
}

// Esc cierra; Tab queda atrapado dentro del modal
function _teclasVistaPrevia(e) {
    const modal = document.querySelector('#modal-preview-reporte .rp-card');
    if (!modal) return;
    if (e.key === 'Escape') { cerrarVistaPrevia(); return; }
    if (e.key !== 'Tab') return;
    const foco = [...modal.querySelectorAll('button:not([disabled]), [href], input, select, [tabindex]:not([tabindex="-1"])')];
    if (!foco.length) return;
    const primero = foco[0], ultimo = foco[foco.length - 1];
    if (e.shiftKey && document.activeElement === primero) { e.preventDefault(); ultimo.focus(); }
    else if (!e.shiftKey && document.activeElement === ultimo) { e.preventDefault(); primero.focus(); }
}

function cerrarVistaPrevia() {
    const m = document.getElementById('modal-preview-reporte');
    if (!m) return;
    m.remove();
    document.body.classList.remove('rp-modal-abierto');
    document.removeEventListener('keydown', _teclasVistaPrevia);
    PREVIEW.retorno?.focus?.();
    PREVIEW.retorno = null;
}

// "Volver / Modificar filtros": cierra el modal y lleva al usuario a la barra de filtros
function volverAFiltros() {
    cerrarVistaPrevia();
    const cfg = CONFIG_FILTROS[REPORTE.tab];
    if (cfg?.avanzado && !REPORTE.avanzadoAbierto) toggleFiltrosAvanzados();
    const barra = document.getElementById('reporte-filtros');
    barra?.scrollIntoView?.({ behavior: 'smooth', block: 'center' });
    barra?.querySelector('input, select')?.focus({ preventScroll: true });
}

function confirmarDescarga() {
    const formato = PREVIEW.formato;
    cerrarVistaPrevia();
    PREVIEW.retorno = null;
    if (formato === 'excel') _descargarExcel(); else _descargarPDF();
}

// ── Generación real de archivos ─────────────────────────────────────────────
function _descargarExcel() {
    try {
        const { titulo, columnas, filas } = _reporteActual;
        const encabezado = [
            [titulo],
            [`${ubicacionPrincipal} — Generado: ${new Date().toLocaleString('es-ES')}`],
            [`Período: ${_periodoTexto()}`],
            [`Filtros: ${_textoFiltros()}`],
            [],
        ];
        const tabla = [columnas, ...filas];
        const ws = XLSX.utils.aoa_to_sheet([...encabezado, ...tabla]);
        ws['!cols'] = columnas.map((_, ci) =>
            ({ wch: Math.min(Math.max(...tabla.map(r => String(r[ci] ?? '').length), 10) + 2, 60) }));
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, 'Reporte');
        XLSX.writeFile(wb, _nombreArchivo('xlsx'));
        showToast('Excel descargado ✅', 'success');
    } catch (e) { console.error(e); showToast('Error al generar el Excel', 'error'); }
}

function _descargarPDF() {
    try {
        const { jsPDF } = window.jspdf;
        const { titulo, columnas, filas } = _reporteActual;
        const doc = new jsPDF({ orientation: _pdfHorizontal() ? 'landscape' : 'portrait', unit: 'mm', format: 'a4' });
        const pw = doc.internal.pageSize.getWidth();

        // Membrete institucional
        doc.setFillColor(79, 70, 229);
        doc.rect(0, 0, pw, 22, 'F');
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(13); doc.setFont(undefined, 'bold');
        doc.text('CBIT Manager', 14, 10);
        doc.setFontSize(9); doc.setFont(undefined, 'normal');
        doc.text(`${ubicacionPrincipal}   |   ${new Date().toLocaleString('es-ES')}`, pw - 14, 10, { align: 'right' });
        doc.text(titulo, 14, 17);

        // Filtros aplicados
        doc.setTextColor(60);
        doc.setFontSize(8);
        const lineas = doc.splitTextToSize(`Período: ${_periodoTexto()}   |   Filtros: ${_textoFiltros()}`, pw - 28);
        doc.text(lineas, 14, 28);

        doc.autoTable({
            startY: 28 + lineas.length * 4 + 2,
            head: [columnas],
            body: filas,
            styles: { fontSize: 8, cellPadding: 2.5, overflow: 'linebreak' },
            headStyles: { fillColor: [79, 70, 229], textColor: [255, 255, 255], fontStyle: 'bold' },
            alternateRowStyles: { fillColor: [245, 245, 250] },
            margin: { left: 14, right: 14 },
        });

        const total = doc.getNumberOfPages();
        for (let i = 1; i <= total; i++) {
            doc.setPage(i); doc.setFontSize(7); doc.setTextColor(150);
            doc.text(`Página ${i} de ${total}`, pw - 14, doc.internal.pageSize.getHeight() - 8, { align: 'right' });
        }
        doc.save(_nombreArchivo('pdf'));
        showToast('PDF descargado ✅', 'success');
    } catch (e) { console.error(e); showToast('Error al generar el PDF', 'error'); }
}

