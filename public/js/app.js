// ==================== ESTADO GLOBAL ====================
let usuarioActual = null;
const ubicacionPrincipal = "CBIT Francisco de Miranda";
let currentDate = new Date();
let currentWeekStart = getStartOfWeek(currentDate);

// ==================== API HELPER ====================
async function api(method, endpoint, data = null) {
    const opts = { method, headers: { 'Content-Type': 'application/json' }, credentials: 'include' };
    if (data) opts.body = JSON.stringify(data);
    const res = await fetch('/api' + endpoint, opts);
    return res.json();
}

// ==================== UI HELPERS ====================
function showToast(msg, type = 'success') {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.className = 'toast show ' + type;
    setTimeout(() => t.classList.remove('show'), 3500);
}
function showPanel(id) {
    document.querySelectorAll('#login-screen .panel').forEach(p => p.classList.remove('active'));
    document.getElementById(id).classList.add('active');
}
function ocultarFormulario(id) {
    const el = document.getElementById(id);
    if (el) { el.style.display = 'none'; el.dataset.editId = ''; }
}
function obtenerFechaHoy() { return new Date().toISOString().split('T')[0]; }
function getStartOfWeek(date) {
    const d = new Date(date), day = d.getDay();
    return new Date(d.setDate(d.getDate() - day + (day === 0 ? -6 : 1)));
}
function formatDate(date) { return date.toISOString().split('T')[0]; }
function getWeekDays(startDate) {
    return Array.from({length: 5}, (_, i) => {
        const date = new Date(startDate);
        date.setDate(startDate.getDate() + i);
        return { date: formatDate(date), dayName: date.toLocaleDateString('es-ES', {weekday:'long'}), dayNumber: date.getDate(), month: date.toLocaleDateString('es-ES', {month:'short'}) };
    });
}
function loadingPanel(titulo, id) {
    return `<div id="${id}" class="view-section active"><div class="section-header"><h1 class="page-title">${titulo}</h1></div><div class="glass-panel" style="padding:2rem;text-align:center;"><i class="fas fa-spinner fa-spin fa-2x"></i><p style="margin-top:1rem">Cargando datos...</p></div></div>`;
}
function setContainer(html) { document.getElementById('views-container').innerHTML = html; }

// ==================== BUSCADOR + FILTROS ====================
function barraBusqueda(placeholder, columnas) {
    const opOrdenar = columnas.map(c =>
        `<option value="${c.idx}">${c.label}</option>`
    ).join('');
    return `
    <div class="barra-busqueda-modulo" style="
        display:flex;flex-wrap:wrap;gap:.6rem;align-items:center;
        padding:.75rem 1rem;margin-bottom:1rem;
        background:rgba(79,70,229,0.04);
        border:1px solid rgba(79,70,229,0.12);border-radius:10px">
        <div style="position:relative;flex:1;min-width:180px">
            <i class="fas fa-search" style="position:absolute;left:.75rem;top:50%;
               transform:translateY(-50%);color:var(--text-secondary);
               font-size:.82rem;pointer-events:none"></i>
            <input type="text" placeholder="${placeholder}"
                oninput="filtrarTabla(this)"
                style="width:100%;padding:.42rem .75rem .42rem 2.1rem;
                       border-radius:8px;border:1px solid rgba(79,70,229,0.2);
                       background:var(--bg-surface);color:var(--text-primary);
                       font-size:.84rem;outline:none;box-sizing:border-box;
                       transition:border-color .2s">
        </div>
        <select onchange="ordenarTablaCol(this)"
            style="padding:.42rem .75rem;border-radius:8px;
                   border:1px solid rgba(79,70,229,0.2);
                   background:var(--bg-surface);color:var(--text-primary);
                   font-size:.82rem;cursor:pointer;min-width:145px">
            <option value="">Ordenar por...</option>
            ${opOrdenar}
        </select>
        <button onclick="toggleDirOrden(this)"
            data-dir="asc"
            style="padding:.42rem .75rem;border-radius:8px;
                   border:1px solid rgba(79,70,229,0.2);
                   background:var(--bg-surface);color:var(--text-primary);
                   cursor:pointer;font-size:.82rem;
                   display:flex;align-items:center;gap:.35rem;white-space:nowrap">
            <i class="fas fa-arrow-up"></i><span>A → Z</span>
        </button>
        <button onclick="limpiarBuscador(this)"
            style="padding:.42rem .75rem;border-radius:8px;
                   border:1px solid rgba(255,255,255,.1);
                   background:none;color:var(--text-secondary);
                   cursor:pointer;font-size:.82rem">
            <i class="fas fa-times"></i> Limpiar
        </button>
        <span class="buscador-contador"
            style="font-size:.77rem;color:var(--text-secondary);
                   margin-left:auto;white-space:nowrap"></span>
    </div>`;
}

function filtrarTabla(input) {
    const panel  = input.closest('.glass-panel');
    const tbody  = panel?.querySelector('.premium-table tbody');
    if (!tbody) return;
    const term   = input.value.toLowerCase().trim();
    const filas  = tbody.querySelectorAll('tr:not(.buscador-sin-res)');
    let vis = 0;
    filas.forEach(f => {
        const ok = !term || f.textContent.toLowerCase().includes(term);
        f.style.display = ok ? '' : 'none';
        if (ok) vis++;
    });
    // Contador
    const contador = input.closest('.barra-busqueda-modulo')?.querySelector('.buscador-contador');
    if (contador) {
        contador.textContent  = term ? `${vis} de ${filas.length} resultados` : `${filas.length} registros`;
        contador.style.color  = (term && vis===0) ? '#EF4444' : 'var(--text-secondary)';
    }
    // Sin resultados
    let sr = tbody.querySelector('.buscador-sin-res');
    if (vis===0 && term) {
        if (!sr) {
            sr = document.createElement('tr');
            sr.className = 'buscador-sin-res';
            sr.innerHTML = `<td colspan="20" style="text-align:center;padding:2rem;
                color:var(--text-secondary);font-size:.875rem">
                <i class="fas fa-search" style="display:block;font-size:1.5rem;
                   margin-bottom:.5rem;opacity:.35"></i>
                Sin resultados para "<strong>${input.value}</strong>"</td>`;
            tbody.appendChild(sr);
        }
    } else sr?.remove();
    // Actualizar contador con total si vacío
    if (!term && contador) {
        contador.textContent = `${filas.length} registros`;
    }
}

function ordenarTablaCol(sel) {
    const idx   = parseInt(sel.value);
    if (isNaN(idx)) return;
    const panel = sel.closest('.glass-panel');
    const tabla = panel?.querySelector('.premium-table');
    if (!tabla) return;
    const btn   = sel.closest('.barra-busqueda-modulo')?.querySelector('[data-dir]');
    const dir   = btn?.dataset.dir || 'asc';
    _aplicarOrden(tabla, idx, dir);
}

function toggleDirOrden(btn) {
    const dir   = btn.dataset.dir === 'asc' ? 'desc' : 'asc';
    btn.dataset.dir = dir;
    btn.querySelector('i').className = `fas fa-arrow-${dir==='asc'?'up':'down'}`;
    btn.querySelector('span').textContent = dir==='asc' ? 'A → Z' : 'Z → A';
    const sel   = btn.closest('.barra-busqueda-modulo')?.querySelector('select');
    const idx   = parseInt(sel?.value);
    if (!isNaN(idx)) {
        const panel = btn.closest('.glass-panel');
        const tabla = panel?.querySelector('.premium-table');
        if (tabla) _aplicarOrden(tabla, idx, dir);
    }
}

function _aplicarOrden(tabla, colIdx, dir) {
    const tbody = tabla.querySelector('tbody');
    const filas = Array.from(tbody.querySelectorAll('tr:not(.buscador-sin-res)'));
    filas.sort((a,b) => {
        const tA = a.cells[colIdx]?.textContent?.trim().toLowerCase()||'';
        const tB = b.cells[colIdx]?.textContent?.trim().toLowerCase()||'';
        const nA = parseFloat(tA.replace(/[^0-9.-]/g,''));
        const nB = parseFloat(tB.replace(/[^0-9.-]/g,''));
        const isNum = !isNaN(nA) && !isNaN(nB);
        const cmp = isNum ? nA-nB : tA.localeCompare(tB,'es');
        return dir==='desc' ? -cmp : cmp;
    });
    filas.forEach(f => tbody.appendChild(f));
    // Marcar cabecera
    tabla.querySelectorAll('thead th').forEach((th,i) => {
        th.innerHTML = th.innerHTML.replace(/\s*<i class="fas fa-sort.*?<\/i>/g,'');
        th.style.color = '';
        if (i===colIdx) {
            th.innerHTML += ` <i class="fas fa-sort-${dir==='asc'?'up':'down'}"
                style="font-size:.68rem;color:#4F46E5"></i>`;
            th.style.color = '#4F46E5';
        }
    });
}

function limpiarBuscador(btn) {
    const barra = btn.closest('.barra-busqueda-modulo');
    const input = barra?.querySelector('input');
    const sel   = barra?.querySelector('select');
    const dirBtn= barra?.querySelector('[data-dir]');
    if (input)  { input.value = ''; filtrarTabla(input); }
    if (sel)    sel.value = '';
    if (dirBtn) { dirBtn.dataset.dir='asc'; dirBtn.querySelector('i').className='fas fa-arrow-up'; dirBtn.querySelector('span').textContent='A → Z'; }
    // Limpiar marcas de orden en cabeceras
    const panel = btn.closest('.glass-panel');
    panel?.querySelectorAll('.premium-table thead th').forEach(th => {
        th.innerHTML = th.innerHTML.replace(/\s*<i class="fas fa-sort.*?<\/i>/g,'');
        th.style.color = '';
    });
}

// Inicializar contador al renderizar
function initContador(panel) {
    const filas   = panel?.querySelectorAll('.premium-table tbody tr');
    const contador = panel?.querySelector('.buscador-contador');
    if (contador && filas) contador.textContent = `${filas.length} registros`;
}

// ==================== MODAL EDICIÓN ====================
function mostrarModal(titulo, campos, onGuardar) {
    document.getElementById('modal-overlay')?.remove();
    const overlay = document.createElement('div');
    overlay.id = 'modal-overlay';
    overlay.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:1000;display:flex;align-items:center;justify-content:center;padding:1rem;';
    overlay.innerHTML = `
        <div style="background:var(--bg-secondary, #1e1e2e);border:1px solid var(--border-color,rgba(255,255,255,0.1));border-radius:16px;padding:2rem;width:480px;max-width:100%;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.5);">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
                <h3 style="margin:0;color:var(--text-primary,#fff)">${titulo}</h3>
                <button onclick="document.getElementById('modal-overlay').remove()" style="background:none;border:none;color:var(--text-secondary,#aaa);font-size:1.4rem;cursor:pointer;padding:0.2rem 0.5rem;">&times;</button>
            </div>
            <div id="modal-campos">${campos}</div>
            <div style="display:flex;gap:0.75rem;margin-top:1.5rem;justify-content:flex-end;">
                <button class="btn btn-outline" onclick="document.getElementById('modal-overlay').remove()">Cancelar</button>
                <button class="btn btn-primary" id="btn-modal-guardar"><i class="fas fa-save"></i> Guardar Cambios</button>
            </div>
        </div>`;
    document.body.appendChild(overlay);
    overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
    document.getElementById('btn-modal-guardar').onclick = onGuardar;
}
function inputModal(id, label, type='text', value='', opciones=null) {
    if (opciones) {
        return `<div class="form-group" style="margin-bottom:1rem;">
            <label style="display:block;margin-bottom:0.4rem;color:var(--text-secondary,#aaa);font-size:0.875rem;">${label}</label>
            <select id="${id}" class="form-control">${opciones.map(o=>`<option value="${o.value}" ${o.value==value?'selected':''}>${o.label}</option>`).join('')}</select>
        </div>`;
    }
    return `<div class="form-group" style="margin-bottom:1rem;">
        <label style="display:block;margin-bottom:0.4rem;color:var(--text-secondary,#aaa);font-size:0.875rem;">${label}</label>
        <input type="${type}" id="${id}" class="form-control" value="${value || ''}">
    </div>`;
}
function val(id) { return document.getElementById(id)?.value?.trim(); }

// ==================== AUTH ====================
async function iniciarSesion() {
    const nombre_usuario = document.getElementById('login-user').value.trim();
    const contrasena_usuario = document.getElementById('login-pass').value;
    if (!nombre_usuario || !contrasena_usuario) { showToast('Complete usuario y contraseña', 'error'); return; }
    const r = await api('POST', '/auth/login', { nombre_usuario, contrasena_usuario });
    if (r.ok) { usuarioActual = r.usuario; mostrarApp(); showToast(`Bienvenido, ${usuarioActual.nombre}`, 'success'); }
    else showToast(r.msg, 'error');
}
async function recuperarContrasena() {
    const cedula = document.getElementById('rec-cedula').value;
    const correo = document.getElementById('rec-email').value;
    const r = await api('POST', '/auth/recuperar', { cedula, correo });
    if (r.ok) { document.getElementById('success-text').textContent = r.msg; showPanel('panel-success'); }
    else showToast(r.msg, 'error');
}
function mostrarApp() {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('app-screen').style.display = 'flex';
    document.getElementById('btn-ayuda-flotante').style.display = 'flex';
    conectarSocket();
    const u = usuarioActual;
    const nombre = u.nombre && u.apellido ? `${u.nombre} ${u.apellido}` : u.nombre_usuario;
    const ini = (u.nombre || u.nombre_usuario).charAt(0).toUpperCase();
    ['user-name-display','sidebar-user'].forEach(id => document.getElementById(id).textContent = nombre);
    ['user-role-display','sidebar-role'].forEach(id => document.getElementById(id).textContent = u.roles);
    ['user-avatar','sidebar-avatar'].forEach(id => document.getElementById(id).textContent = ini);
    cargarVistaInicial();
    aplicarPermisosPorRol();
}

// ==================== NAVEGACIÓN ====================
function cargarVistaInicial() { cargarVista('dashboard'); configurarNavegacion(); }

function aplicarPermisosPorRol() {
    const esAdmin = usuarioActual?.roles === 'Administrador';
    // Items solo visibles para administrador. 'asistencias' se excluye de esta lista:
    // los docentes SÍ pueden verla, pero el backend la filtra a solo sus propios eventos.
    const soloAdmin = ['categorias','marcas','modelos','equipos','inventario','disponibilidad-equipos',
                       'actividades','mantenimiento','tecnicos','personas','usuarios','historial'];
    document.querySelectorAll('.nav-item[data-target]').forEach(item => {
        const target = item.getAttribute('data-target');
        if (soloAdmin.includes(target)) {
            item.style.display = esAdmin ? '' : 'none';
        }
    });
    // Ocultar labels vacíos si todos sus items están ocultos
    document.querySelectorAll('.nav-label').forEach(label => {
        let siguiente = label.nextElementSibling;
        let todosOcultos = true;
        while (siguiente && !siguiente.classList.contains('nav-label')) {
            if (siguiente.style.display !== 'none' && siguiente.classList.contains('nav-item')) {
                todosOcultos = false; break;
            }
            siguiente = siguiente.nextElementSibling;
        }
        label.style.display = todosOcultos ? 'none' : '';
    });
    // Si es docente, redirigir al calendario como vista principal
    if (!esAdmin) cargarVista('solicitudes');
}

let vistaActual = 'dashboard';
function cargarVista(vista) {
    vistaActual = vista;
    const mapa = { dashboard: renderDashboard, calendario: renderVistaCalendario, categorias: renderCategorias, marcas: renderMarcas, modelos: renderModelos, equipos: renderEquipos, inventario: renderInventario, actividades: renderActividades, solicitudes: renderSolicitudes, reservas: renderReservas, mantenimiento: renderMantenimiento, tecnicos: renderTecnicos, asistencias: renderAsistencias, personas: renderPersonas, usuarios: renderUsuarios, espacios: renderEspacios, 'disponibilidad-equipos': renderDisponibilidadEquipos, reportes: renderReportes, historial: renderHistorial };
    (mapa[vista] || renderDashboard)();
}
function configurarNavegacion() {
    document.querySelectorAll('.nav-item[data-target]').forEach(item => {
        item.addEventListener('click', e => {
            e.preventDefault();
            document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
            item.classList.add('active');
            cargarVista(item.getAttribute('data-target'));
            if (window.innerWidth <= 768) toggleSidebar(false);
        });
    });
}

// Abre/cierra el menú lateral en pantallas de celular/tablet.
function toggleSidebar(forzar) {
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    if (!sidebar) return;
    const abrir = typeof forzar === 'boolean' ? forzar : !sidebar.classList.contains('open');
    sidebar.classList.toggle('open', abrir);
    overlay?.classList.toggle('open', abrir);
    document.body.classList.toggle('sidebar-abierto', abrir);
}

// ==================== DASHBOARD ====================
async function renderDashboard() {
    setContainer(`<div id="view-dashboard" class="view-section active"><div class="section-header"><h1 class="page-title">Dashboard General</h1><p class="page-subtitle">${ubicacionPrincipal}</p></div><div class="stats-grid" id="stats-grid"><div class="stat-card glass-panel"><div class="stat-icon purple"><i class="fas fa-spinner fa-spin"></i></div><div class="stat-info"><h3>Cargando...</h3><h2>—</h2></div></div></div><div id="dashboard-body"></div></div>`);
    const r = await api('GET', '/dashboard/stats');
    if (!r.ok) return;
    document.getElementById('stats-grid').innerHTML = `
        <div class="stat-card glass-panel"><div class="stat-icon purple"><i class="fas fa-laptop"></i></div><div class="stat-info"><h3>Equipos Totales</h3><h2>${r.totalEquipos}</h2></div></div>
        <div class="stat-card glass-panel"><div class="stat-icon orange"><i class="fas fa-tools"></i></div><div class="stat-info"><h3>En Reparación</h3><h2>${r.enReparacion}</h2></div></div>
        <div class="stat-card glass-panel"><div class="stat-icon blue"><i class="fas fa-clock"></i></div><div class="stat-info"><h3>Solicitudes Pendientes</h3><h2>${r.solicitudesPendientes}</h2></div></div>
        <div class="stat-card glass-panel"><div class="stat-icon green"><i class="fas fa-calendar-check"></i></div><div class="stat-info"><h3>Reservas Aprobadas</h3><h2>${r.reservasAprobadas}</h2></div></div>`;
    document.getElementById('dashboard-body').innerHTML = `
        <div class="dashboard-content-grid">
            <div class="glass-panel main-panel">
                <h3>Próximas Reservas Aprobadas</h3>
                <div class="table-responsive"><table class="premium-table">
                    <thead><tr><th>Fecha</th><th>Horario</th><th>Espacio</th><th>Actividad</th><th>Solicitante</th></tr></thead>
                    <tbody>${(r.proximasReservas||[]).map(s=>`<tr><td>${new Date(s.fecha).toLocaleDateString('es-ES')}</td><td>${String(s.hora_inicio).slice(0,5)} - ${String(s.hora_fin).slice(0,5)}</td><td>${s.espacio_nombre||'N/A'}</td><td>${s.actividad_nombre||'N/A'}</td><td>${s.persona_nombre||''} ${s.persona_apellido||''}</td></tr>`).join('')||'<tr><td colspan="5" class="empty-state">No hay reservas aprobadas</td></tr>'}</tbody>
                </table></div>
            </div>
            <div class="glass-panel side-panel">
                <h3>Accesos Rápidos</h3>
                <div class="quick-links">
                    <button class="quick-btn" onclick="cargarVista('calendario')"><i class="fas fa-calendar-alt"></i> Ver Calendario</button>
                    <button class="quick-btn" onclick="cargarVista('solicitudes')"><i class="fas fa-plus"></i> Nueva Solicitud</button>
                    <button class="quick-btn" onclick="cargarVista('inventario')"><i class="fas fa-plus-circle"></i> Agregar Equipo</button>
                    <button class="quick-btn" onclick="cargarVista('mantenimiento')"><i class="fas fa-tools"></i> Reportar Avería</button>
                    <button class="quick-btn" onclick="cargarVista('reportes')"><i class="fas fa-chart-bar"></i> Ver Reportes</button>
                </div>
            </div>
        </div>`;
}

// ==================== CALENDARIO ====================
async function renderVistaCalendario() {
    setContainer(`<div id="view-calendario" class="view-section active"><div class="section-header"><h1 class="page-title">Calendario Semanal de Reservas</h1><p class="page-subtitle">${ubicacionPrincipal} — Solo reservas aprobadas</p></div><div class="glass-panel calendario-container" id="cal-container"><i class="fas fa-spinner fa-spin"></i> Cargando...</div></div>`);
    const r = await api('GET', '/calendario');
    if (!r.ok) return;
    document.getElementById('cal-container').innerHTML = renderCalendarioSemanal(r.solicitudes || []);
}
function renderCalendarioSemanal(solicitudes) {
    const weekDays = getWeekDays(currentWeekStart);
    const horarios = ['08:00-10:00','10:00-12:00','13:00-15:00','15:00-17:00'];
    const fi = formatDate(currentWeekStart);
    const ff = formatDate(new Date(currentWeekStart.getTime() + 4*86400000));
    let html = `
        <div class="calendar-header">
            <button class="btn-icon" onclick="semanaAnterior()"><i class="fas fa-chevron-left"></i></button>
            <h2>Semana del ${fi} al ${ff}</h2>
            <button class="btn-icon" onclick="semanaSiguiente()"><i class="fas fa-chevron-right"></i></button>
            <button class="btn-outline" style="margin-left:1rem;padding:0.5rem 1rem;" onclick="irSemanaActual()">Hoy</button>
        </div>
        <div class="calendar-wrapper"><div class="calendar-grid">
        <div class="cal-cell cal-header">Horario</div>`;
    weekDays.forEach(d => { html += `<div class="cal-cell cal-header" style="text-transform:capitalize">${d.dayName}<br><small>${d.dayNumber} ${d.month}</small></div>`; });
    horarios.forEach(horario => {
        const [hi, hf] = horario.split('-');
        html += `<div class="cal-cell cal-time">${horario}</div>`;
        weekDays.forEach(d => {
            const eventos = (solicitudes||[]).filter(s => {
                const fd = s.fecha ? String(s.fecha).slice(0,10) : '';
                return fd === d.date && String(s.hora_inicio).slice(0,5) < hf && String(s.hora_fin).slice(0,5) > hi;
            });
            if (eventos.length) {
                const e = eventos[0];
                html += `<div class="cal-cell has-reserva" onclick='verDetalleReserva(${JSON.stringify(e)})'>
                    <div class="cal-badge">
                        <strong>${e.actividad_nombre||'Actividad'}</strong>
                        <small>${(e.espacio_nombre||'').split(' - ').pop()}</small>
                        <small>${String(e.hora_inicio).slice(0,5)} - ${String(e.hora_fin).slice(0,5)}</small>
                        <small style="opacity:.7">${e.persona_nombre||''} ${e.persona_apellido||''}</small>
                    </div></div>`;
            } else {
                html += `<div class="cal-cell disponible"><div class="cal-badge disponible-badge">Disponible</div></div>`;
            }
        });
    });
    html += `</div></div>
        <div class="calendar-legend"><h4>Leyenda</h4>
        <div><span class="legend-color" style="background:linear-gradient(135deg,#4F46E5,#EC4899);"></span> Reserva Aprobada</div>
        <div><span class="legend-color" style="background:#10B981;"></span> Disponible</div></div>`;
    return html;
}
function semanaAnterior() { currentWeekStart.setDate(currentWeekStart.getDate()-7); renderVistaCalendario(); }
function semanaSiguiente() { currentWeekStart.setDate(currentWeekStart.getDate()+7); renderVistaCalendario(); }
function irSemanaActual() { currentDate = new Date(); currentWeekStart = getStartOfWeek(currentDate); renderVistaCalendario(); }
function verDetalleReserva(s) {
    mostrarModal('Detalle de Reserva',
        `<div style="display:grid;gap:0.75rem">
            ${[['Actividad', s.actividad_nombre||'N/A'],['Espacio', s.espacio_nombre||'N/A'],['Fecha', new Date(s.fecha).toLocaleDateString('es-ES',{weekday:'long',year:'numeric',month:'long',day:'numeric'})],['Horario', `${String(s.hora_inicio).slice(0,5)} — ${String(s.hora_fin).slice(0,5)}`],['Solicitante', `${s.persona_nombre||''} ${s.persona_apellido||''}`],['Descripción', s.descripcion||'—'],['Estado', s.estado]].map(([k,v])=>`<div style="display:flex;justify-content:space-between;padding:0.5rem 0;border-bottom:1px solid rgba(255,255,255,0.07)"><span style="color:var(--text-secondary,#aaa)">${k}</span><strong>${v}</strong></div>`).join('')}
        </div>`,
        () => document.getElementById('modal-overlay')?.remove()
    );
    document.getElementById('btn-modal-guardar').textContent = 'Cerrar';
}

// ==================== CATEGORÍAS ====================
async function renderCategorias() {
    setContainer(loadingPanel('Categorías de Equipos','view-categorias'));
    const r = await api('GET','/categorias');
    if (!r.ok) return;
    const filas = r.data.map(c=>`<tr>
        <td><span class="table-tag">CAT-${String(c.id_categoria).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${c.nombre}</span><span class="cell-subtitle">Clasifica equipos del inventario por tipo.</span></div></td>
        <td><span class="count-pill">${c.total_equipos} equipos</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" title="Editar" onclick='editarCategoria(${JSON.stringify(c)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" title="Eliminar" onclick="eliminarCategoria(${c.id_categoria})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML = `
        <div id="view-categorias" class="view-section active">
            <div class="section-header"><h1 class="page-title">Categorías de Equipos</h1><p class="page-subtitle">Organiza el inventario por tipo de equipo.</p></div>
            <div class="section-metrics"><div class="metric-chip"><span class="metric-label">Total</span><strong>${r.data.length}</strong></div></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><div class="table-section-intro"><h3>Lista de Categorías</h3></div>
                    <button class="btn btn-primary" onclick="mostrarFormularioCategoria()"><i class="fas fa-plus"></i> Nueva Categoría</button></div>
                <div id="form-categoria" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-cat-titulo">Registrar Nueva Categoría</h4>
                    <div class="form-row"><div class="form-group"><label>Nombre</label><input type="text" id="cat-nombre" class="form-control" placeholder="Ej: Monitor"></div></div>
                    <div class="form-actions">
                        <button class="btn btn-primary" onclick="guardarCategoria()"><i class="fas fa-save"></i> Guardar</button>
                        <button class="btn btn-outline" onclick="ocultarFormulario('form-categoria')">Cancelar</button>
                    </div>
                </div>
                ${barraBusqueda('Buscar categoría...',[{idx:1,label:'Categoría'},{idx:2,label:'Equipos'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Categoría</th><th>Equipos</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="4" class="empty-state">Sin registros</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarCategoria(c) {
    const form = document.getElementById('form-categoria');
    form.style.display = 'block'; form.dataset.editId = c.id_categoria;
    document.getElementById('form-cat-titulo').textContent = 'Editar Categoría';
    document.getElementById('cat-nombre').value = c.nombre;
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioCategoria() {
    const form = document.getElementById('form-categoria');
    form.style.display = 'block'; form.dataset.editId = '';
    document.getElementById('form-cat-titulo').textContent = 'Registrar Nueva Categoría';
    document.getElementById('cat-nombre').value = '';
}
async function guardarCategoria() {
    const nombre = val('cat-nombre');
    if (!nombre) return showToast('Complete el campo','error');
    const editId = document.getElementById('form-categoria').dataset.editId;
    const r = editId ? await api('PUT',`/categorias/${editId}`,{nombre}) : await api('POST','/categorias',{nombre});
    if (r.ok) { showToast(r.msg,'success'); renderCategorias(); } else showToast(r.msg,'error');
}
async function eliminarCategoria(id) {
    if (!confirm('¿Eliminar esta categoría?')) return;
    const r = await api('DELETE',`/categorias/${id}`);
    if (r.ok) { showToast(r.msg,'success'); renderCategorias(); } else showToast(r.msg,'error');
}

// ==================== MARCAS ====================
async function renderMarcas() {
    setContainer(loadingPanel('Marcas de Equipos','view-marcas'));
    const r = await api('GET','/marcas');
    if (!r.ok) return;
    const filas = r.data.map(m=>`<tr>
        <td><span class="table-tag">MAR-${String(m.id_marca).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${m.nombre}</span><span class="cell-subtitle">Fabricante del catálogo institucional.</span></div></td>
        <td><span class="count-pill">${m.total_equipos} equipos</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarMarca(${JSON.stringify(m)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarMarca(${m.id_marca})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML = `
        <div id="view-marcas" class="view-section active">
            <div class="section-header"><h1 class="page-title">Marcas de Equipos</h1></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><div class="table-section-intro"><h3>Lista de Marcas</h3></div>
                    <button class="btn btn-primary" onclick="mostrarFormularioMarca()"><i class="fas fa-plus"></i> Nueva Marca</button></div>
                <div id="form-marca" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-mar-titulo">Registrar Nueva Marca</h4>
                    <div class="form-row"><div class="form-group"><label>Nombre</label><input type="text" id="marca-nombre" class="form-control" placeholder="Ej: Asus"></div></div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarMarca()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-marca')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar marca...',[{idx:1,label:'Marca'},{idx:2,label:'Equipos'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Marca</th><th>Equipos</th><th>Acciones</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarMarca(m) {
    const form = document.getElementById('form-marca'); form.style.display='block'; form.dataset.editId=m.id_marca;
    document.getElementById('form-mar-titulo').textContent='Editar Marca';
    document.getElementById('marca-nombre').value=m.nombre;
}
function mostrarFormularioMarca() {
    const form=document.getElementById('form-marca'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-mar-titulo').textContent='Registrar Nueva Marca';
    document.getElementById('marca-nombre').value='';
}
async function guardarMarca() {
    const nombre=val('marca-nombre'); if(!nombre) return showToast('Complete el campo','error');
    const editId=document.getElementById('form-marca').dataset.editId;
    const r = editId ? await api('PUT',`/marcas/${editId}`,{nombre}) : await api('POST','/marcas',{nombre});
    if(r.ok){showToast(r.msg,'success');renderMarcas();}else showToast(r.msg,'error');
}
async function eliminarMarca(id) {
    if(!confirm('¿Eliminar esta marca?'))return;
    const r=await api('DELETE',`/marcas/${id}`);
    if(r.ok){showToast(r.msg,'success');renderMarcas();}else showToast(r.msg,'error');
}

// ==================== MODELOS ====================
async function renderModelos() {
    setContainer(loadingPanel('Modelos de Equipos','view-modelos'));
    const r = await api('GET','/modelos');
    if (!r.ok) return;
    const filas = r.modelos.map(m=>`<tr>
        <td><span class="table-tag">MOD-${String(m.id_modelo).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${m.nombre}</span><span class="cell-subtitle">${m.descripcion||'Sin descripción'}</span></div></td>
        <td><span class="count-pill">${m.total_equipos} equipos</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarModelo(${JSON.stringify(m)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarModelo(${m.id_modelo})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML = `
        <div id="view-modelos" class="view-section active">
            <div class="section-header"><h1 class="page-title">Modelos de Equipos</h1></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><div class="table-section-intro"><h3>Lista de Modelos</h3></div>
                    <button class="btn btn-primary" onclick="mostrarFormularioModelo()"><i class="fas fa-plus"></i> Nuevo Modelo</button></div>
                <div id="form-modelo" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-mod-titulo">Registrar Nuevo Modelo</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Nombre *</label><input type="text" id="modelo-nombre" class="form-control" placeholder="Ej: ProBook 450 G8" maxlength="40"></div>
                        <div class="form-group"><label>Descripción</label><input type="text" id="modelo-descripcion" class="form-control" placeholder="Opcional" maxlength="255"></div>
                    </div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarModelo()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-modelo')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar modelo...',[{idx:1,label:'Modelo'},{idx:2,label:'Equipos'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Modelo</th><th>Equipos</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="4" class="empty-state">Sin modelos registrados</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarModelo(m) {
    const form = document.getElementById('form-modelo'); form.style.display='block'; form.dataset.editId=m.id_modelo;
    document.getElementById('form-mod-titulo').textContent='Editar Modelo';
    document.getElementById('modelo-nombre').value=m.nombre;
    document.getElementById('modelo-descripcion').value=m.descripcion||'';
}
function mostrarFormularioModelo() {
    const form=document.getElementById('form-modelo'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-mod-titulo').textContent='Registrar Nuevo Modelo';
    document.getElementById('modelo-nombre').value='';
    document.getElementById('modelo-descripcion').value='';
}
async function guardarModelo() {
    const nombre=val('modelo-nombre'), descripcion=val('modelo-descripcion');
    if(!nombre) return showToast('Complete el nombre del modelo','error');
    const editId=document.getElementById('form-modelo').dataset.editId;
    const r = editId ? await api('PUT',`/modelos/${editId}`,{nombre,descripcion}) : await api('POST','/modelos',{nombre,descripcion});
    if(r.ok){showToast(r.msg,'success');renderModelos();}else showToast(r.msg,'error');
}
async function eliminarModelo(id) {
    if(!confirm('¿Eliminar este modelo?'))return;
    const r=await api('DELETE',`/modelos/${id}`);
    if(r.ok){showToast(r.msg,'success');renderModelos();}else showToast(r.msg,'error');
}

// ==================== EQUIPOS ====================
async function renderEquipos() {
    setContainer(loadingPanel('Catálogo de Equipos','view-equipos'));
    const r = await api('GET','/equipos'); if(!r.ok)return;
    const {equipos, categorias, marcas, modelos} = r;
    const opCat=categorias.map(c=>`<option value="${c.id_categoria}">${c.nombre}</option>`).join('');
    const opMar=marcas.map(m=>`<option value="${m.id_marca}">${m.nombre}</option>`).join('');
    const opMod=`<option value="">Sin modelo</option>`+modelos.map(m=>`<option value="${m.id_modelo}">${m.nombre}</option>`).join('');
    const filas=equipos.map(e=>`<tr>
        <td><span class="table-tag">EQ-${String(e.id_equipos).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${e.nombre}</span><span class="cell-subtitle">Equipo base del inventario.</span></div></td>
        <td>${e.modelo_nombre||'—'}</td>
        <td><span class="count-pill neutral">${e.categoria||'N/A'}</span></td>
        <td><span class="count-pill info">${e.marca||'N/A'}</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarEquipo(${JSON.stringify(e)},${JSON.stringify(categorias)},${JSON.stringify(marcas)},${JSON.stringify(modelos)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarEquipo(${e.id_equipos})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-equipos" class="view-section active">
            <div class="section-header"><h1 class="page-title">Catálogo de Equipos</h1><p class="page-subtitle">Administra el catálogo base por categoría, marca y modelo.</p></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Equipos</span><strong>${equipos.length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Categorías</span><strong>${categorias.length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Marcas</span><strong>${marcas.length}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><div class="table-section-intro"><h3>Equipos Registrados</h3></div>
                    <button class="btn btn-primary" onclick="mostrarFormularioEquipo()"><i class="fas fa-plus"></i> Nuevo Equipo</button></div>
                <div id="form-equipo" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-eq-titulo">Registrar Nuevo Equipo</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Nombre</label><input type="text" id="eq-nombre" class="form-control" placeholder="Ej: Monitor LED"></div>
                        <div class="form-group"><label>Modelo</label><select id="eq-modelo" class="form-control">${opMod}</select></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Categoría</label><select id="eq-categoria" class="form-control">${opCat}</select></div>
                        <div class="form-group"><label>Marca</label><select id="eq-marca" class="form-control">${opMar}</select></div>
                    </div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarEquipo()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-equipo')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar por nombre, modelo, categoría...',[{idx:1,label:'Equipo'},{idx:2,label:'Modelo'},{idx:3,label:'Categoría'},{idx:4,label:'Marca'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Equipo</th><th>Modelo</th><th>Categoría</th><th>Marca</th><th>Acciones</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarEquipo(e, cats, mars, mods) {
    const form=document.getElementById('form-equipo'); form.style.display='block'; form.dataset.editId=e.id_equipos;
    document.getElementById('form-eq-titulo').textContent='Editar Equipo';
    document.getElementById('eq-nombre').value=e.nombre;
    document.getElementById('eq-categoria').value=e.id_categoria;
    document.getElementById('eq-marca').value=e.id_marca;
    document.getElementById('eq-modelo').value=e.id_modelo||'';
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioEquipo() {
    const form=document.getElementById('form-equipo'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-eq-titulo').textContent='Registrar Nuevo Equipo';
    ['eq-nombre'].forEach(id=>document.getElementById(id).value='');
}
async function guardarEquipo() {
    const nombre=val('eq-nombre'),id_categoria=document.getElementById('eq-categoria')?.value,id_marca=document.getElementById('eq-marca')?.value,id_modelo=document.getElementById('eq-modelo')?.value||null;
    if(!nombre||!id_categoria||!id_marca)return showToast('Complete los campos requeridos','error');
    const editId=document.getElementById('form-equipo').dataset.editId;
    const r=editId?await api('PUT',`/equipos/${editId}`,{nombre,id_categoria,id_marca,id_modelo}):await api('POST','/equipos',{nombre,id_categoria,id_marca,id_modelo});
    if(r.ok){showToast(r.msg,'success');renderEquipos();}else showToast(r.msg,'error');
}
async function eliminarEquipo(id) {
    if(!confirm('¿Eliminar este equipo?'))return;
    const r=await api('DELETE',`/equipos/${id}`);
    if(r.ok){showToast(r.msg,'success');renderEquipos();}else showToast(r.msg,'error');
}

// ==================== INVENTARIO ====================
async function renderInventario() {
    setContainer(loadingPanel('Inventario','view-inventario'));
    const r=await api('GET','/inventario'); if(!r.ok)return;
    const {inventario, equipos, ubicaciones}=r;
    const opEq=equipos.map(e=>`<option value="${e.id_equipos}">${e.nombre} — ${e.modelo_nombre||''}</option>`).join('');
    const opUb=ubicaciones.map(u=>`<option value="${u.id_ubicacion_fisica}">${u.nombre}</option>`).join('');
    const opEst='<option>Operativo</option><option>En Reparacion</option><option>No operativo</option><option>Dañado</option>';
    const totalOp=inventario.filter(i=>i.estado==='Operativo').length;
    const totalRep=inventario.filter(i=>i.estado==='En Reparacion').length;
    const filas=inventario.map(i=>{
        const cls=i.estado==='Operativo'?'success':i.estado==='En Reparacion'?'warning':'danger';
        return `<tr>
            <td><div class="cell-stack"><code class="cell-code">${i.serial}</code><span class="cell-subtitle">#${i.id_inventario}</span></div></td>
            <td><div class="cell-stack"><span class="cell-title">${i.equipo_nombre||'N/A'}</span><span class="cell-subtitle">${i.modelo_nombre||'—'}</span></div></td>
            <td>${(i.ubicacion_nombre||'N/A').split(' - ').pop()}</td>
            <td><span class="status-badge ${cls}">${i.estado}</span></td>
            <td><div class="table-actions">
                <button class="btn-icon-small" onclick='editarInventario(${JSON.stringify(i)})'><i class="fas fa-edit"></i></button>
                <button class="btn-icon-small" onclick="eliminarInventario(${i.id_inventario})"><i class="fas fa-trash"></i></button>
            </div></td></tr>`;}).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-inventario" class="view-section active">
            <div class="section-header"><h1 class="page-title">Inventario — ${ubicacionPrincipal}</h1></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Total</span><strong>${inventario.length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Operativos</span><strong>${totalOp}</strong></div>
                <div class="metric-chip warning"><span class="metric-label">En reparación</span><strong>${totalRep}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><div class="table-section-intro"><h3>Equipos Físicos</h3></div>
                    <button class="btn btn-primary" onclick="mostrarFormularioInventario()"><i class="fas fa-plus"></i> Agregar</button></div>
                <div id="form-inventario" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-inv-titulo">Agregar al Inventario</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Equipo</label><select id="inv-equipo" class="form-control">${opEq}</select></div>
                        <div class="form-group"><label>Ubicación</label><select id="inv-ubicacion" class="form-control">${opUb}</select></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Serial</label><input type="text" id="inv-serial" class="form-control" placeholder="Ej: SN-001"></div>
                        <div class="form-group"><label>Estado</label><select id="inv-estado" class="form-control">${opEst}</select></div>
                    </div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarInventario()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-inventario')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar por serial, equipo o estado...',[{idx:0,label:'Serial'},{idx:1,label:'Equipo'},{idx:2,label:'Ubicación'},{idx:3,label:'Estado'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Serial</th><th>Equipo</th><th>Ubicación</th><th>Estado</th><th>Acciones</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarInventario(i) {
    const form=document.getElementById('form-inventario'); form.style.display='block'; form.dataset.editId=i.id_inventario;
    document.getElementById('form-inv-titulo').textContent='Editar Registro de Inventario';
    document.getElementById('inv-equipo').value=i.id_equipos;
    document.getElementById('inv-ubicacion').value=i.id_ubicacion_fisica;
    document.getElementById('inv-serial').value=i.serial;
    document.getElementById('inv-estado').value=i.estado;
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioInventario() {
    const form=document.getElementById('form-inventario'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-inv-titulo').textContent='Agregar al Inventario';
    document.getElementById('inv-serial').value='';
}
async function guardarInventario() {
    const id_equipos=document.getElementById('inv-equipo')?.value,id_ubicacion_fisica=document.getElementById('inv-ubicacion')?.value,serial=val('inv-serial'),estado=document.getElementById('inv-estado')?.value;
    if(!id_equipos||!id_ubicacion_fisica||!serial||!estado)return showToast('Complete todos los campos','error');
    const editId=document.getElementById('form-inventario').dataset.editId;
    const r=editId?await api('PUT',`/inventario/${editId}`,{id_equipos,id_ubicacion_fisica,serial,estado}):await api('POST','/inventario',{id_equipos,id_ubicacion_fisica,serial,estado});
    if(r.ok){showToast(r.msg,'success');renderInventario();}else showToast(r.msg,'error');
}
async function eliminarInventario(id) {
    if(!confirm('¿Eliminar este registro?'))return;
    const r=await api('DELETE',`/inventario/${id}`);
    if(r.ok){showToast(r.msg,'success');renderInventario();}else showToast(r.msg,'error');
}

// ==================== ACTIVIDADES ====================
async function renderActividades() {
    setContainer(loadingPanel('Actividades','view-actividades'));
    const r=await api('GET','/actividades'); if(!r.ok)return;
    const filas=r.data.map(a=>`<tr>
        <td>${a.id_actividad}</td><td><div class="cell-stack"><span class="cell-title">${a.nombre}</span></div></td>
        <td>${a.descripcion_actividad||'—'}</td><td>${a.total_solicitudes}</td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarActividad(${JSON.stringify(a)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarActividad(${a.id_actividad})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-actividades" class="view-section active">
            <div class="section-header"><h1 class="page-title">Actividades</h1></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Tipos de Actividades</h3><button class="btn btn-primary" onclick="mostrarFormularioActividad()"><i class="fas fa-plus"></i> Nueva</button></div>
                <div id="form-actividad" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-act-titulo">Registrar Actividad</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Nombre</label><input type="text" id="act-nombre" class="form-control"></div>
                        <div class="form-group"><label>Descripción</label><input type="text" id="act-descripcion" class="form-control"></div>
                    </div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarActividad()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-actividad')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar actividad...',[{idx:1,label:'Nombre'},{idx:3,label:'Solicitudes'}])}
                <div class="table-responsive"><table class="premium-table">
                    <thead><tr><th>Código</th><th>Nombre</th><th>Descripción</th><th>Solicitudes</th><th>Acciones</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarActividad(a) {
    const form=document.getElementById('form-actividad'); form.style.display='block'; form.dataset.editId=a.id_actividad;
    document.getElementById('form-act-titulo').textContent='Editar Actividad';
    document.getElementById('act-nombre').value=a.nombre;
    document.getElementById('act-descripcion').value=a.descripcion_actividad||'';
}
function mostrarFormularioActividad() {
    const form=document.getElementById('form-actividad'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-act-titulo').textContent='Registrar Actividad';
    ['act-nombre','act-descripcion'].forEach(id=>document.getElementById(id).value='');
}
async function guardarActividad() {
    const nombre=val('act-nombre'),descripcion_actividad=val('act-descripcion');
    if(!nombre||!descripcion_actividad)return showToast('Complete los campos','error');
    const editId=document.getElementById('form-actividad').dataset.editId;
    const r=editId?await api('PUT',`/actividades/${editId}`,{nombre,descripcion_actividad}):await api('POST','/actividades',{nombre,descripcion_actividad});
    if(r.ok){showToast(r.msg,'success');renderActividades();}else showToast(r.msg,'error');
}
async function eliminarActividad(id) {
    if(!confirm('¿Eliminar esta actividad?'))return;
    const r=await api('DELETE',`/actividades/${id}`);
    if(r.ok){showToast(r.msg,'success');renderActividades();}else showToast(r.msg,'error');
}

// ==================== SOLICITUDES ====================

// ==================== SOLICITUDES ====================
async function renderSolicitudes() {
    setContainer(loadingPanel('Solicitudes de Uso','view-solicitudes'));
    const r = await api('GET','/solicitudes'); if(!r.ok) return;
    const {solicitudes, espacios, actividades} = r;
    const esAdmin = usuarioActual?.roles === 'Administrador';
    const hoy = obtenerFechaHoy();
    const opEsp = espacios.map(e=>`<option value="${e.id_espacio}">${e.nombre} (Cap.${e.capacidad})</option>`).join('');
    const opAct = actividades.map(a=>`<option value="${a.id_actividad}">${a.nombre}</option>`).join('');

    const filas = solicitudes.map(s => {
        const cls = s.estado==='Aprobado'?'success':s.estado==='Completado'?'info':s.estado==='Cancelado'?'danger':'warning';
        const puedeAprobar = esAdmin && s.estado === 'Pendiente';
        const puedeEditar  = s.estado === 'Pendiente';
        return `<tr>
            <td>${s.id_solicitud}</td>
            <td><div class="cell-stack">
                <span class="cell-title">${s.persona_nombre||''} ${s.persona_apellido||''}</span>
                <span class="cell-subtitle">${s.docente_rol||''} — ${s.persona_cedula||''}</span>
            </div></td>
            <td>${s.espacio_nombre||'N/A'}</td>
            <td>${s.actividad_nombre||'N/A'}</td>
            <td>${new Date(s.fecha).toLocaleDateString('es-ES')}</td>
            <td>${String(s.hora_inicio).slice(0,5)} — ${String(s.hora_fin).slice(0,5)}</td>
            <td><span class="count-pill ${s.total_equipos>0?'info':'neutral'}">${s.total_equipos||0} equipos</span></td>
            <td><span class="status-badge ${cls}">${s.estado}</span></td>
            <td><div class="table-actions">
                <button class="btn-icon-small" title="Ver detalle" onclick="verDetalleSolicitud(${s.id_solicitud})"><i class="fas fa-eye"></i></button>
                ${puedeEditar?`<button class="btn-icon-small" title="Editar" onclick='editarSolicitud(${JSON.stringify(s)},${JSON.stringify(espacios)},${JSON.stringify(actividades)})'><i class="fas fa-edit"></i></button>`:''}
                ${puedeAprobar?`<button class="btn-icon-small" title="Aprobar" onclick="aprobarSolicitud(${s.id_solicitud})" style="color:#10B981"><i class="fas fa-check-circle"></i></button>`:''}
                ${s.estado==='Pendiente'?`<button class="btn-icon-small" title="Cancelar" onclick="cancelarSolicitud(${s.id_solicitud})" style="color:#f59e0b"><i class="fas fa-ban"></i></button>`:''}
                <button class="btn-icon-small" title="Eliminar" onclick="eliminarSolicitud(${s.id_solicitud})"><i class="fas fa-trash"></i></button>
            </div></td></tr>`;
    }).join('');

    document.getElementById('views-container').innerHTML = `
        <div id="view-solicitudes" class="view-section active">
            <div class="section-header"><h1 class="page-title">Solicitudes de Uso — CBIT</h1></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Total</span><strong>${solicitudes.length}</strong></div>
                <div class="metric-chip warning"><span class="metric-label">Pendientes</span><strong>${solicitudes.filter(s=>s.estado==='Pendiente').length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Aprobadas</span><strong>${solicitudes.filter(s=>s.estado==='Aprobado').length}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Historial de Solicitudes</h3>
                    <button class="btn btn-primary" onclick="mostrarFormularioSolicitud()"><i class="fas fa-plus"></i> Nueva Solicitud</button></div>

                <!-- FORMULARIO SOLICITUD -->
                <div id="form-solicitud" style="display:none;margin-bottom:1.5rem;padding:1.25rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-sol-titulo">Nueva Solicitud de Uso</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Espacio *</label><select id="sol-espacio" class="form-control">${opEsp}</select></div>
                        <div class="form-group"><label>Actividad *</label><select id="sol-actividad" class="form-control">${opAct}</select></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Fecha *</label><input type="date" id="sol-fecha" class="form-control" min="${hoy}" onchange="buscarEquiposDisponibles()"></div>
                        <div class="form-group"><label>Hora Inicio *</label><input type="time" id="sol-hora-inicio" class="form-control" onchange="buscarEquiposDisponibles()"></div>
                        <div class="form-group"><label>Hora Fin *</label><input type="time" id="sol-hora-fin" class="form-control" onchange="buscarEquiposDisponibles()"></div>
                    </div>
                    <div class="form-group"><label>Descripción / Motivo</label>
                        <input type="text" id="sol-descripcion" class="form-control" placeholder="Indique el propósito de la solicitud">
                    </div>

                    <!-- EQUIPOS DISPONIBLES -->
                    <div id="equipos-disponibles-section" style="margin-top:1rem;display:none">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:.6rem">
                            <label style="font-weight:600"><i class="fas fa-laptop" style="margin-right:.4rem;color:#4F46E5"></i>Equipos disponibles en ese horario</label>
                            <span id="eq-disp-count" style="font-size:.8rem;opacity:.6"></span>
                        </div>
                        <div id="equipos-disponibles-lista" style="max-height:220px;overflow-y:auto;display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:.5rem;padding:.5rem;background:rgba(0,0,0,.15);border-radius:8px;border:1px solid rgba(255,255,255,.08)">
                            <p style="opacity:.5;font-size:.85rem;padding:.5rem">Complete fecha y horario para ver disponibilidad</p>
                        </div>
                        <p style="font-size:.78rem;opacity:.5;margin-top:.4rem">Marque los equipos que necesita. Si no selecciona ninguno se registra sin equipos.</p>
                    </div>

                    ${esAdmin ? `
                    <div style="margin-top:1rem;padding:.75rem;background:rgba(79,70,229,.1);border-radius:8px;border:1px solid rgba(79,70,229,.3)">
                        <label style="display:flex;align-items:center;gap:.6rem;cursor:pointer;font-size:.9rem">
                            <input type="checkbox" id="sol-aprobar-directo" style="width:16px;height:16px">
                            <span><i class="fas fa-check-circle" style="color:#10B981;margin-right:.3rem"></i><strong>Aprobar inmediatamente</strong> — La reserva quedará activa y visible en el calendario al guardar</span>
                        </label>
                    </div>` : ''}

                    <div class="form-actions" style="margin-top:1rem">
                        <button class="btn btn-primary" onclick="guardarSolicitud()"><i class="fas fa-save"></i> Guardar Solicitud</button>
                        <button class="btn btn-outline" onclick="ocultarFormulario('form-solicitud')">Cancelar</button>
                    </div>
                </div>

                ${barraBusqueda('Buscar por docente, espacio, actividad o estado...',[{idx:1,label:'Docente'},{idx:2,label:'Espacio'},{idx:3,label:'Actividad'},{idx:4,label:'Fecha'},{idx:7,label:'Estado'}])}
                <div class="table-responsive"><table class="premium-table">
                    <thead><tr><th>Código</th><th>Docente</th><th>Espacio</th><th>Actividad</th><th>Fecha</th><th>Horario</th><th>Equipos</th><th>Estado</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="9" class="empty-state">Sin solicitudes registradas</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}

async function buscarEquiposDisponibles() {
    const fecha = document.getElementById('sol-fecha')?.value;
    const hi    = document.getElementById('sol-hora-inicio')?.value;
    const hf    = document.getElementById('sol-hora-fin')?.value;
    if (!fecha || !hi || !hf || hi >= hf) return;
    const section = document.getElementById('equipos-disponibles-section');
    const lista   = document.getElementById('equipos-disponibles-lista');
    section.style.display = 'block';
    lista.innerHTML = '<p style="opacity:.5;font-size:.85rem;padding:.5rem"><i class="fas fa-spinner fa-spin"></i> Buscando equipos disponibles...</p>';
    const r = await api('GET', `/solicitudes/equipos-disponibles?fecha=${fecha}&hora_inicio=${hi}&hora_fin=${hf}`);
    if (!r.ok) { lista.innerHTML = `<p style="color:#f87171;font-size:.85rem">${r.msg}</p>`; return; }
    document.getElementById('eq-disp-count').textContent = `${r.equipos.length} disponibles`;
    if (!r.equipos.length) {
        lista.innerHTML = '<p style="opacity:.5;font-size:.85rem;padding:.5rem">No hay equipos operativos disponibles en ese horario</p>';
        return;
    }
    lista.innerHTML = r.equipos.map(e => `
        <label style="display:flex;align-items:flex-start;gap:.5rem;padding:.5rem .6rem;background:rgba(255,255,255,.04);border-radius:6px;cursor:pointer;border:1px solid rgba(255,255,255,.07);font-size:.82rem">
            <input type="checkbox" name="eq-sel" value="${e.id_inventario}" style="margin-top:2px;flex-shrink:0">
            <div>
                <div style="font-weight:600">${e.equipo_nombre} <span style="opacity:.6;font-weight:400">${e.modelo_nombre||''}</span></div>
                <div style="opacity:.55">Serial: ${e.serial} | ${e.categoria||''} ${e.marca?'— '+e.marca:''}</div>
                <div style="opacity:.4">${(e.ubicacion||'').split(' - ').pop()}</div>
            </div>
        </label>`).join('');
}

function obtenerEquiposSeleccionados() {
    return Array.from(document.querySelectorAll('input[name="eq-sel"]:checked')).map(cb => parseInt(cb.value));
}

function mostrarFormularioSolicitud() {
    const form = document.getElementById('form-solicitud'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-sol-titulo').textContent = 'Nueva Solicitud de Uso';
    ['sol-fecha','sol-hora-inicio','sol-hora-fin','sol-descripcion'].forEach(id => document.getElementById(id).value = '');
    const secEq = document.getElementById('equipos-disponibles-section');
    if (secEq) secEq.style.display = 'none';
    const cb = document.getElementById('sol-aprobar-directo'); if (cb) cb.checked = false;
    form.scrollIntoView({behavior:'smooth'});
}

function editarSolicitud(s, espacios, actividades) {
    const form = document.getElementById('form-solicitud'); form.style.display='block'; form.dataset.editId=s.id_solicitud;
    document.getElementById('form-sol-titulo').textContent = 'Editar Solicitud';
    document.getElementById('sol-espacio').value   = s.id_espacio;
    document.getElementById('sol-actividad').value = s.id_actividad;
    document.getElementById('sol-fecha').value     = String(s.fecha).slice(0,10);
    document.getElementById('sol-hora-inicio').value = String(s.hora_inicio).slice(0,5);
    document.getElementById('sol-hora-fin').value    = String(s.hora_fin).slice(0,5);
    document.getElementById('sol-descripcion').value = s.descripcion||'';
    form.scrollIntoView({behavior:'smooth'});
    buscarEquiposDisponibles();
}

async function guardarSolicitud() {
    const id_espacio    = document.getElementById('sol-espacio')?.value;
    const id_actividad  = document.getElementById('sol-actividad')?.value;
    const fecha         = document.getElementById('sol-fecha')?.value;
    const hora_inicio   = document.getElementById('sol-hora-inicio')?.value;
    const hora_fin      = document.getElementById('sol-hora-fin')?.value;
    const descripcion   = document.getElementById('sol-descripcion')?.value;
    const aprobar_directo = document.getElementById('sol-aprobar-directo')?.checked || false;
    const equipos_ids   = obtenerEquiposSeleccionados();

    if (!id_espacio||!id_actividad||!fecha||!hora_inicio||!hora_fin)
        return showToast('Complete todos los campos requeridos','error');

    const editId = document.getElementById('form-solicitud').dataset.editId;
    if (editId) {
        const r = await api('PUT',`/solicitudes/${editId}`,{id_espacio,id_actividad,fecha,hora_inicio,hora_fin,descripcion,equipos_ids});
        if (r.ok) { showToast(r.msg,'success'); renderSolicitudes(); } else showToast(r.msg,'error');
        return;
    }

    let r = await api('POST','/solicitudes',{id_espacio,id_actividad,fecha,hora_inicio,hora_fin,descripcion,aprobar_directo,equipos_ids});

    // RF: si el backend detecta una solicitud igual en la misma fecha/horario,
    // se avisa al usuario y se le da la opción de continuar de todas formas.
    if (!r.ok && r.duplicado) {
        const continuar = confirm(`⚠️ ${r.msg}`);
        if (!continuar) { showToast('Registro cancelado por el usuario','info'); return; }
        r = await api('POST','/solicitudes',{id_espacio,id_actividad,fecha,hora_inicio,hora_fin,descripcion,aprobar_directo,equipos_ids,confirmar_duplicado:true});
    }

    if (r.ok) { showToast(r.msg,'success'); renderSolicitudes(); }
    else showToast(r.msg,'error');
}

async function aprobarSolicitud(id) {
    const r = await api('PUT',`/solicitudes/${id}/aprobar`);
    if(r.ok){showToast(r.msg,'success');renderSolicitudes();}else showToast(r.msg,'error');
}
async function cancelarSolicitud(id) {
    if(!confirm('¿Cancelar esta solicitud?'))return;
    const r = await api('PUT',`/solicitudes/${id}/cancelar`);
    if(r.ok){showToast(r.msg,'success');renderSolicitudes();}else showToast(r.msg,'error');
}
async function eliminarSolicitud(id) {
    if(!confirm('¿Eliminar esta solicitud permanentemente?'))return;
    const r = await api('DELETE',`/solicitudes/${id}`);
    if(r.ok){showToast(r.msg,'success');renderSolicitudes();}else showToast(r.msg,'error');
}
async function verDetalleSolicitud(id) {
    const r = await api('GET',`/solicitudes/${id}/detalle`);
    if(!r.ok) return showToast('No se pudo cargar el detalle','error');
    const s = r.solicitud;
    const equiposHTML = r.equipos.length
        ? r.equipos.map(e=>`<div style="padding:.3rem 0;border-bottom:1px solid rgba(255,255,255,.05)">${e.equipo_nombre} <span style="opacity:.5">${e.modelo_nombre||''}</span> — Serial: <code>${e.serial}</code></div>`).join('')
        : '<span style="opacity:.4">Sin equipos asignados</span>';
    mostrarModal(`Detalle Solicitud #${id}`,
        `<div style="display:grid;gap:.5rem">
            ${[['Docente',`${s.persona_nombre||''} ${s.persona_apellido||''} (${s.persona_cedula||''})`],
               ['Espacio', s.espacio_nombre||'N/A'],
               ['Actividad', s.actividad_nombre||'N/A'],
               ['Fecha', new Date(s.fecha).toLocaleDateString('es-ES',{weekday:'long',year:'numeric',month:'long',day:'numeric'})],
               ['Horario',`${String(s.hora_inicio).slice(0,5)} — ${String(s.hora_fin).slice(0,5)}`],
               ['Descripción', s.descripcion||'—'],
               ['Estado', s.estado]
            ].map(([k,v])=>`<div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid rgba(255,255,255,.07)"><span style="opacity:.6">${k}</span><strong>${v}</strong></div>`).join('')}
            <div style="margin-top:.5rem"><strong>Equipos asignados (${r.equipos.length}):</strong><div style="margin-top:.4rem;font-size:.85rem">${equiposHTML}</div></div>
        </div>`,
        () => document.getElementById('modal-overlay')?.remove()
    );
    document.getElementById('btn-modal-guardar').textContent = 'Cerrar';
}

// ==================== ASISTENCIAS ====================
async function renderAsistencias() {
    setContainer(loadingPanel('Control de Asistencia','view-asistencias'));
    const r = await api('GET','/asistencias'); if(!r.ok) return;
    const {asistencias, solicitudes, estudiantes, personas} = r;
    const esAdmin = usuarioActual?.roles === 'Administrador';

    const opEst = estudiantes.map(e=>`<option value="${e.id_estudiante}">${e.nombre} ${e.apellido} — ${e.cedula} (${e.año} ${e.seccion||''})</option>`).join('');
    const opSol = solicitudes.filter(s=>s.estado==='Aprobado').map(s=>`<option value="${s.id_solicitud}">#${s.id_solicitud} — ${s.actividad_nombre} (${new Date(s.fecha).toLocaleDateString('es-ES')})</option>`).join('');

    // Personas registradas que todavía NO son estudiantes (para poder vincularlas)
    const idsPersonasEstudiante = new Set(estudiantes.map(e=>String(e.id_persona)));
    const opPersonasDisponibles = (personas||[]).filter(p=>!idsPersonasEstudiante.has(String(p.id_persona)))
        .map(p=>`<option value="${p.id_persona}">${p.nombre} ${p.apellido} — ${p.cedula}</option>`).join('');

    // Secciones y años del schema
    const secciones = ['A','B','C','D','U'];
    const anos = ['1er año','2er año','3er año','4er año','5er año','6er año'];
    const opSec = secciones.map(s=>`<option>${s}</option>`).join('');
    const opAno = anos.map(a=>`<option>${a}</option>`).join('');

    const filas = asistencias.map(a=>`<tr>
        <td><span class="table-tag">ASI-${String(a.id_asistencia).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${a.nombre||''} ${a.apellido||''}</span><span class="cell-subtitle">${a.cedula||'—'}</span></div></td>
        <td>${a.año||'—'} ${a.seccion||''}</td>
        <td>#${a.id_solicitud||'—'}</td>
        <td><span class="status-badge ${a.asistio==='Si'?'success':'danger'}">${a.asistio==='Si'?'Presente':'Ausente'}</span></td>
        <td><button class="btn-icon-small" onclick="eliminarAsistencia(${a.id_asistencia})"><i class="fas fa-trash"></i></button></td>
    </tr>`).join('');

    document.getElementById('views-container').innerHTML = `
        <div id="view-asistencias" class="view-section active">
            <div class="section-header"><h1 class="page-title">Control de Asistencia</h1></div>
            ${esAdmin ? '' : `<div class="glass-panel" style="padding:.75rem 1rem;margin-bottom:1rem;display:flex;align-items:center;gap:.6rem;font-size:.85rem;color:var(--text-secondary)">
                <i class="fas fa-info-circle" style="color:var(--primary)"></i>
                Como docente, solo puede ver y registrar la asistencia de los eventos/solicitudes que usted mismo creó.
            </div>`}
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Total registros</span><strong>${asistencias.length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Presentes</span><strong>${asistencias.filter(a=>a.asistio==='Si').length}</strong></div>
                <div class="metric-chip warning"><span class="metric-label">Ausentes</span><strong>${asistencias.filter(a=>a.asistio==='No').length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Estudiantes</span><strong>${estudiantes.length}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Registros de Asistencia</h3>
                    <div style="display:flex;gap:.5rem">
                        <button class="btn btn-outline" onclick="toggleFormRegistrarEstudiante()"><i class="fas fa-user-plus"></i> Registrar Estudiante</button>
                        <button class="btn btn-primary" onclick="toggleFormAsistencia()"><i class="fas fa-clipboard-check"></i> Registrar Asistencia</button>
                    </div>
                </div>

                <!-- FORM REGISTRAR ESTUDIANTE -->
                <div id="form-registrar-estudiante" style="display:none;margin-bottom:1.5rem;padding:1.25rem;background:rgba(79,70,229,.08);border-radius:var(--radius-md);border:1px solid rgba(79,70,229,.25)">
                    <h4 style="margin-bottom:1rem"><i class="fas fa-user-graduate" style="margin-right:.4rem;color:#4F46E5"></i>Registrar Estudiante</h4>
                    <div class="form-group" style="margin-bottom:1rem">
                        <label>¿La persona ya está registrada en el sistema?</label>
                        <select id="est-modo" class="form-control" onchange="toggleModoEstudiante()">
                            <option value="nueva">No, registrar una persona nueva</option>
                            <option value="existente">Sí, vincular una persona ya existente</option>
                        </select>
                    </div>
                    <div id="est-bloque-existente" style="display:none;margin-bottom:.5rem">
                        <div class="form-group"><label>Persona ya registrada *</label>
                            <select id="est-persona-existente" class="form-control">
                                <option value="">Seleccione una persona…</option>
                                ${opPersonasDisponibles}
                            </select>
                        </div>
                    </div>
                    <div id="est-bloque-nueva">
                        <div class="form-row">
                            <div class="form-group"><label>Nombre *</label><input type="text" id="est-nombre" class="form-control" placeholder="Nombre" maxlength="40"></div>
                            <div class="form-group"><label>Apellido *</label><input type="text" id="est-apellido" class="form-control" placeholder="Apellido" maxlength="40"></div>
                        </div>
                        <div class="form-row">
                            <div class="form-group"><label>Cédula *</label><input type="text" id="est-cedula" class="form-control" placeholder="V-12345678"></div>
                            <div class="form-group"><label>Teléfono</label><input type="text" id="est-telefono" class="form-control" placeholder="0412-1234567"></div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Año *</label><select id="est-ano" class="form-control">${opAno}</select></div>
                        <div class="form-group"><label>Sección</label><select id="est-seccion" class="form-control">${opSec}</select></div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary" onclick="guardarEstudiante()"><i class="fas fa-save"></i> Guardar Estudiante</button>
                        <button class="btn btn-outline" onclick="toggleFormRegistrarEstudiante()">Cancelar</button>
                    </div>
                </div>

                <!-- FORM ASISTENCIA -->
                <div id="form-asistencia" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4>Registrar Asistencia</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Estudiante</label><select id="asi-estudiante" class="form-control">${opEst||'<option>Sin estudiantes registrados</option>'}</select></div>
                        <div class="form-group"><label>Solicitud / Actividad</label><select id="asi-solicitud" class="form-control">${opSol||'<option>Sin solicitudes aprobadas</option>'}</select></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>¿Asistió?</label>
                            <select id="asi-asistio" class="form-control"><option value="Si">Sí — Presente</option><option value="No">No — Ausente</option></select>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary" onclick="guardarAsistencia()"><i class="fas fa-save"></i> Guardar</button>
                        <button class="btn btn-outline" onclick="ocultarFormulario('form-asistencia')">Cancelar</button>
                    </div>
                </div>

                ${barraBusqueda('Buscar por estudiante, cédula o asistencia...',[{idx:1,label:'Estudiante'},{idx:2,label:'Año/Sección'},{idx:4,label:'Asistencia'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Estudiante</th><th>Año/Sección</th><th>Solicitud</th><th>Asistencia</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="6" class="empty-state">Sin registros de asistencia</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}

function toggleFormRegistrarEstudiante() {
    const f = document.getElementById('form-registrar-estudiante');
    f.style.display = f.style.display === 'none' ? 'block' : 'none';
    if (f.style.display === 'block') { ocultarFormulario('form-asistencia'); f.scrollIntoView({behavior:'smooth'}); }
}
function toggleFormAsistencia() {
    const f = document.getElementById('form-asistencia');
    f.style.display = f.style.display === 'none' ? 'block' : 'none';
    if (f.style.display === 'block') { document.getElementById('form-registrar-estudiante').style.display='none'; f.scrollIntoView({behavior:'smooth'}); }
}
function toggleModoEstudiante() {
    const modo = document.getElementById('est-modo')?.value;
    document.getElementById('est-bloque-existente').style.display = modo === 'existente' ? 'block' : 'none';
    document.getElementById('est-bloque-nueva').style.display = modo === 'existente' ? 'none' : 'block';
}
async function guardarEstudiante() {
    const modo    = document.getElementById('est-modo')?.value;
    const año     = document.getElementById('est-ano')?.value;
    const seccion = document.getElementById('est-seccion')?.value;

    if (modo === 'existente') {
        const id_persona_existente = document.getElementById('est-persona-existente')?.value;
        if (!id_persona_existente || !año) return showToast('Seleccione la persona y el año','error');
        const r = await api('POST','/asistencias/registrar-estudiante',{id_persona_existente,año,seccion});
        if (r.ok) { showToast(r.msg,'success'); renderAsistencias(); } else showToast(r.msg,'error');
        return;
    }

    const nombre   = val('est-nombre');
    const apellido = val('est-apellido');
    const cedula   = val('est-cedula');
    const telefono = val('est-telefono');
    if (!nombre||!apellido||!cedula||!año) return showToast('Complete los campos requeridos','error');
    const r = await api('POST','/asistencias/registrar-estudiante',{nombre,apellido,cedula,telefono,año,seccion});
    if (r.ok) { showToast(r.msg,'success'); renderAsistencias(); } else showToast(r.msg,'error');
}
async function guardarAsistencia() {
    const id_estudiante = document.getElementById('asi-estudiante')?.value;
    const id_solicitud  = document.getElementById('asi-solicitud')?.value;
    const asistio       = document.getElementById('asi-asistio')?.value;
    if (!id_estudiante||!id_solicitud||!asistio) return showToast('Complete todos los campos','error');
    const r = await api('POST','/asistencias',{id_estudiante,id_solicitud,asistio});
    if (r.ok) { showToast(r.msg,'success'); renderAsistencias(); } else showToast(r.msg,'error');
}
async function eliminarAsistencia(id) {
    if (!confirm('¿Eliminar este registro?')) return;
    const r = await api('DELETE',`/asistencias/${id}`);
    if (r.ok) { showToast(r.msg,'success'); renderAsistencias(); } else showToast(r.msg,'error');
}


// ==================== RESERVAS ====================
async function renderReservas() {
    setContainer(loadingPanel('Reservas Activas','view-reservas'));
    const r = await api('GET','/reservas'); if(!r.ok) return;
    const filas = r.reservas.map(s=>`<tr>
        <td>${s.id_solicitud}</td>
        <td><div class="cell-stack"><span class="cell-title">${s.actividad_nombre||'N/A'}</span><span class="cell-subtitle">${s.espacio_nombre||''}</span></div></td>
        <td>${s.persona_nombre||''} ${s.persona_apellido||''}</td>
        <td>${new Date(s.fecha).toLocaleDateString('es-ES')} &nbsp; ${String(s.hora_inicio).slice(0,5)}—${String(s.hora_fin).slice(0,5)}</td>
        <td><span class="count-pill info">${s.total_equipos||0} equipos</span></td>
        <td><span class="status-badge success">${s.estado}</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" title="Ver detalle" onclick="verDetalleSolicitud(${s.id_solicitud})"><i class="fas fa-eye"></i></button>
            <button class="btn-icon-small" title="Finalizar" onclick="finalizarReserva(${s.id_solicitud})" style="color:#10B981"><i class="fas fa-check-double"></i></button>
            <button class="btn-icon-small" title="Cancelar" onclick="cancelarSolicitud(${s.id_solicitud})"><i class="fas fa-ban"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML = `
        <div id="view-reservas" class="view-section active">
            <div class="section-header"><h1 class="page-title">Reservas Activas — CBIT</h1></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Reservas aprobadas</span><strong>${r.reservas.length}</strong></div>
            </div>
            <div class="glass-panel">
                ${barraBusqueda('Buscar por actividad, docente o estado...',[{idx:1,label:'Actividad/Espacio'},{idx:2,label:'Docente'},{idx:3,label:'Fecha'},{idx:5,label:'Estado'}])}
                <div class="table-responsive"><table class="premium-table">
                <thead><tr><th>Código</th><th>Actividad / Espacio</th><th>Docente</th><th>Fecha y Horario</th><th>Equipos</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>${filas||'<tr><td colspan="7" class="empty-state">No hay reservas activas</td></tr>'}</tbody>
            </table></div></div>
        </div>`;
}
async function finalizarReserva(id) {
    if (!confirm('¿Marcar esta reserva como completada?')) return;
    const r = await api('PUT',`/reservas/${id}/finalizar`);
    if (r.ok) { showToast(r.msg,'success'); renderReservas(); } else showToast(r.msg,'error');
}

// ==================== MANTENIMIENTO ====================
async function renderMantenimiento() {
    setContainer(loadingPanel('Mantenimiento de Equipos','view-mantenimiento'));
    const r = await api('GET','/mantenimiento'); if(!r.ok) return;
    const {mantenimientos, tecnicos, equipos} = r;
    const opTec = tecnicos.map(t=>`<option value="${t.id_tecnicos}">${t.nombre} ${t.apellido} — ${t.especialidad}</option>`).join('');
    const opEq  = equipos.map(e=>`<option value="${e.id_equipos}">${e.nombre}</option>`).join('');
    const filas = mantenimientos.map(m=>`<tr>
        <td><span class="table-tag">MAN-${String(m.id_mantenimiento).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${m.equipo_nombre||'N/A'}</span><span class="cell-subtitle">${m.descripcion_fallas||'—'}</span></div></td>
        <td><code class="cell-code">${m.serial||'—'}</code></td>
        <td><span class="status-badge ${m.nivel_prioridad==='Alta'?'danger':m.nivel_prioridad==='Media'?'warning':'info'}">${m.nivel_prioridad}</span></td>
        <td>${m.tec_nombre||'—'} ${m.tec_apellido||''}</td>
        <td>${new Date(m.fecha_reporte).toLocaleDateString('es-ES')}</td>
        <td><button class="btn-icon-small" onclick="eliminarMantenimiento(${m.id_mantenimiento})"><i class="fas fa-trash"></i></button></td>
    </tr>`).join('');
    document.getElementById('views-container').innerHTML = `
        <div id="view-mantenimiento" class="view-section active">
            <div class="section-header"><h1 class="page-title">Mantenimiento de Equipos</h1></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Reportes</span><strong>${mantenimientos.length}</strong></div>
                <div class="metric-chip danger"><span class="metric-label">Alta prioridad</span><strong>${mantenimientos.filter(m=>m.nivel_prioridad==='Alta').length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Técnicos</span><strong>${tecnicos.length}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Registro de Mantenimiento</h3>
                    <button class="btn btn-primary" onclick="mostrarFormularioMantenimiento()"><i class="fas fa-plus"></i> Nuevo Reporte</button></div>
                <div id="form-mantenimiento" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4>Reportar Avería o Mantenimiento</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Equipo</label><select id="man-equipo" class="form-control">${opEq}</select></div>
                        <div class="form-group"><label>Prioridad</label><select id="man-prioridad" class="form-control"><option>Alta</option><option>Media</option><option>Baja</option></select></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Técnico Responsable</label><select id="man-tecnico" class="form-control"><option value="">Seleccione técnico</option>${opTec}</select></div>
                        <div class="form-group"><label>Descripción de la falla</label><input type="text" id="man-descripcion" class="form-control" placeholder="Describa el problema"></div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary" onclick="guardarMantenimiento()"><i class="fas fa-save"></i> Guardar</button>
                        <button class="btn btn-outline" onclick="ocultarFormulario('form-mantenimiento')">Cancelar</button>
                    </div>
                </div>
                ${barraBusqueda('Buscar por equipo, serial, técnico o prioridad...',[{idx:1,label:'Equipo'},{idx:2,label:'Serial'},{idx:3,label:'Prioridad'},{idx:4,label:'Técnico'},{idx:5,label:'Fecha'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Equipo / Descripción</th><th>Serial</th><th>Prioridad</th><th>Técnico</th><th>Fecha</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="7" class="empty-state">Sin reportes</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}
function mostrarFormularioMantenimiento() { document.getElementById('form-mantenimiento').style.display='block'; }
async function guardarMantenimiento() {
    const id_equipos=document.getElementById('man-equipo')?.value, nivel_prioridad=document.getElementById('man-prioridad')?.value, id_tecnicos=document.getElementById('man-tecnico')?.value, descripcion_fallas=val('man-descripcion');
    if (!id_equipos||!nivel_prioridad||!id_tecnicos||!descripcion_fallas) return showToast('Complete todos los campos','error');
    const r = await api('POST','/mantenimiento',{id_equipos,nivel_prioridad,id_tecnicos,descripcion_fallas});
    if (r.ok) { showToast(r.msg,'success'); renderMantenimiento(); } else showToast(r.msg,'error');
}
async function eliminarMantenimiento(id) {
    if (!confirm('¿Eliminar este reporte?')) return;
    const r = await api('DELETE',`/mantenimiento/${id}`);
    if (r.ok) { showToast(r.msg,'success'); renderMantenimiento(); } else showToast(r.msg,'error');
}

// ==================== TÉCNICOS ====================
async function renderTecnicos() {
    setContainer(loadingPanel('Técnicos de Soporte','view-tecnicos'));
    const r = await api('GET','/tecnicos'); if(!r.ok) return;
    const {tecnicos, personas} = r;
    const opPer = personas.map(p=>`<option value="${p.id_persona}">${p.nombre} ${p.apellido} — ${p.cedula}</option>`).join('');
    const especialidades = ['Hardware','Software','Redes','Seguridad','Soporte técnico','Recuperación de datos','Mantenimiento preventivo','Instalación de sistemas','Otros'];
    const opEsp = especialidades.map(e=>`<option>${e}</option>`).join('');
    const filas = tecnicos.map(t=>`<tr>
        <td><span class="table-tag">TEC-${String(t.id_tecnicos).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${t.nombre} ${t.apellido}</span><span class="cell-subtitle">${t.cedula}</span></div></td>
        <td><span class="count-pill info">${t.especialidad}</span></td>
        <td>${t.telefono||'—'}</td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarTecnico(${JSON.stringify(t)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarTecnico(${t.id_tecnicos})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML = `
        <div id="view-tecnicos" class="view-section active">
            <div class="section-header"><h1 class="page-title">Técnicos de Soporte</h1></div>
            <div class="section-metrics"><div class="metric-chip"><span class="metric-label">Técnicos</span><strong>${tecnicos.length}</strong></div></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Listado de Técnicos</h3>
                    <button class="btn btn-primary" onclick="mostrarFormularioTecnico()"><i class="fas fa-plus"></i> Nuevo Técnico</button></div>
                <div id="form-tecnico" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-tec-titulo">Registrar Técnico</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Persona</label><select id="tec-persona" class="form-control">${opPer}</select></div>
                        <div class="form-group"><label>Especialidad</label><select id="tec-especialidad" class="form-control">${opEsp}</select></div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary" onclick="guardarTecnico()"><i class="fas fa-save"></i> Guardar</button>
                        <button class="btn btn-outline" onclick="ocultarFormulario('form-tecnico')">Cancelar</button>
                    </div>
                </div>
                ${barraBusqueda('Buscar por nombre, cédula o especialidad...',[{idx:1,label:'Técnico'},{idx:2,label:'Especialidad'},{idx:3,label:'Teléfono'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Técnico</th><th>Especialidad</th><th>Teléfono</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="4" class="empty-state">Sin técnicos registrados</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarTecnico(t) {
    const form=document.getElementById('form-tecnico'); form.style.display='block'; form.dataset.editId=t.id_tecnicos;
    document.getElementById('form-tec-titulo').textContent='Editar Técnico';
    document.getElementById('tec-especialidad').value=t.especialidad;
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioTecnico() {
    const form=document.getElementById('form-tecnico'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-tec-titulo').textContent='Registrar Técnico';
}
async function guardarTecnico() {
    const id_persona=document.getElementById('tec-persona')?.value, especialidad=document.getElementById('tec-especialidad')?.value;
    if (!id_persona||!especialidad) return showToast('Complete todos los campos','error');
    const editId=document.getElementById('form-tecnico').dataset.editId;
    const r=editId?await api('PUT',`/tecnicos/${editId}`,{especialidad}):await api('POST','/tecnicos',{id_persona,especialidad});
    if (r.ok) { showToast(r.msg,'success'); renderTecnicos(); } else showToast(r.msg,'error');
}
async function eliminarTecnico(id) {
    if (!confirm('¿Eliminar este técnico?')) return;
    const r=await api('DELETE',`/tecnicos/${id}`);
    if (r.ok) { showToast(r.msg,'success'); renderTecnicos(); } else showToast(r.msg,'error');
}

async function renderPersonas() {
    setContainer(loadingPanel('Personas','view-personas'));
    const r=await api('GET','/personas'); if(!r.ok)return;
    const filas=r.personas.map(p=>`<tr>
        <td>${p.id_persona}</td>
        <td>${p.nombre}</td><td>${p.apellido}</td><td>${p.cedula}</td><td>${p.telefono||'—'}</td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarPersona(${JSON.stringify(p)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarPersona(${p.id_persona})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-personas" class="view-section active">
            <div class="section-header"><h1 class="page-title">Registro de Personas</h1></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Personas Registradas</h3><button class="btn btn-primary" onclick="mostrarFormularioPersona()"><i class="fas fa-plus"></i> Nueva Persona</button></div>
                <div id="form-persona" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-per-titulo">Registrar Nueva Persona</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Nombre</label><input type="text" id="per-nombre" class="form-control"></div>
                        <div class="form-group"><label>Apellido</label><input type="text" id="per-apellido" class="form-control"></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Cédula</label><input type="text" id="per-cedula" class="form-control" placeholder="V-12345678"></div>
                        <div class="form-group"><label>Teléfono</label><input type="text" id="per-telefono" class="form-control" placeholder="0412-1234567"></div>
                    </div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarPersona()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-persona')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar por nombre, apellido o cédula...',[{idx:1,label:'Nombre'},{idx:2,label:'Apellido'},{idx:3,label:'Cédula'},{idx:4,label:'Teléfono'}])}
                <div class="table-responsive"><table class="premium-table">
                    <thead><tr><th>Código</th><th>Nombre</th><th>Apellido</th><th>Cédula</th><th>Teléfono</th><th>Acciones</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarPersona(p) {
    const form=document.getElementById('form-persona'); form.style.display='block'; form.dataset.editId=p.id_persona;
    document.getElementById('form-per-titulo').textContent='Editar Persona';
    document.getElementById('per-nombre').value=p.nombre;
    document.getElementById('per-apellido').value=p.apellido;
    document.getElementById('per-cedula').value=p.cedula;
    document.getElementById('per-telefono').value=p.telefono;
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioPersona() {
    const form=document.getElementById('form-persona'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-per-titulo').textContent='Registrar Nueva Persona';
    ['per-nombre','per-apellido','per-cedula','per-telefono'].forEach(id=>document.getElementById(id).value='');
}
async function guardarPersona() {
    const nombre=val('per-nombre'),apellido=val('per-apellido'),cedula=val('per-cedula'),telefono=val('per-telefono');
    if(!nombre||!apellido||!cedula||!telefono)return showToast('Complete todos los campos','error');
    const editId=document.getElementById('form-persona').dataset.editId;
    const r=editId?await api('PUT',`/personas/${editId}`,{nombre,apellido,cedula,telefono}):await api('POST','/personas',{nombre,apellido,cedula,telefono});
    if(r.ok){showToast(r.msg,'success');renderPersonas();}else showToast(r.msg,'error');
}
async function eliminarPersona(id) {
    if(!confirm('¿Eliminar esta persona?'))return;
    const r=await api('DELETE',`/personas/${id}`);
    if(r.ok){showToast(r.msg,'success');renderPersonas();}else showToast(r.msg,'error');
}

// ==================== USUARIOS ====================
async function renderUsuarios() {
    setContainer(loadingPanel('Usuarios','view-usuarios'));
    const r=await api('GET','/usuarios'); if(!r.ok)return;
    const {usuarios, personas}=r;
    const opPer=personas.map(p=>`<option value="${p.id_persona}">${p.nombre} ${p.apellido} — ${p.cedula}</option>`).join('');
    const filas=usuarios.map(u=>`<tr>
        <td>${u.id_usuario}</td><td>${u.nombre_usuario}</td>
        <td>${u.nombre||''} ${u.apellido||''}</td><td>${u.correo}</td>
        <td><span class="status-badge ${u.estado==='Activo'?'success':'danger'}">${u.estado}</span></td>
        <td><span class="status-badge purple">${u.roles}</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarUsuario(${JSON.stringify(u)})'><i class="fas fa-edit"></i></button>
            ${u.estado==='Activo'
                ?`<button class="btn-icon-small" title="Inhabilitar" onclick="inhabilitarUsuario(${u.id_usuario})" style="color:#f59e0b"><i class="fas fa-user-slash"></i></button>`
                :`<button class="btn-icon-small" title="Activar" onclick="activarUsuario(${u.id_usuario})" style="color:#10B981"><i class="fas fa-user-check"></i></button>`}
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-usuarios" class="view-section active">
            <div class="section-header"><h1 class="page-title">Usuarios del Sistema</h1></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Total</span><strong>${usuarios.length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Activos</span><strong>${usuarios.filter(u=>u.estado==='Activo').length}</strong></div>
                <div class="metric-chip warning"><span class="metric-label">Inactivos</span><strong>${usuarios.filter(u=>u.estado!=='Activo').length}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Usuarios Registrados</h3><button class="btn btn-primary" onclick="mostrarFormularioUsuario()"><i class="fas fa-plus"></i> Nuevo Usuario</button></div>
                <div id="form-usuario" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-usr-titulo">Registrar Nuevo Usuario</h4>
                    <div id="form-usr-persona-row" class="form-row">
                        <div class="form-group"><label>Persona</label><select id="usr-persona" class="form-control">${opPer}</select></div>
                        <div class="form-group"><label>Nombre de Usuario</label><input type="text" id="usr-username" class="form-control" placeholder="usuario"></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Contraseña <span id="lbl-pass-opcional"></span></label><input type="password" id="usr-password" class="form-control" placeholder="******"></div>
                        <div class="form-group"><label>Correo</label><input type="email" id="usr-email" class="form-control" placeholder="correo@ejemplo.com"></div>
                    </div>
                    <div class="form-row">
                        <div class="form-group"><label>Rol</label><select id="usr-rol" class="form-control"><option>Administrador</option><option>Docente</option></select></div>
                    </div>
                    <div class="form-actions"><button class="btn btn-primary" onclick="guardarUsuario()"><i class="fas fa-save"></i> Guardar</button><button class="btn btn-outline" onclick="ocultarFormulario('form-usuario')">Cancelar</button></div>
                </div>
                ${barraBusqueda('Buscar por usuario, correo o rol...',[{idx:1,label:'Usuario'},{idx:2,label:'Persona'},{idx:3,label:'Correo'},{idx:4,label:'Estado'},{idx:5,label:'Rol'}])}
                <div class="table-responsive"><table class="premium-table">
                    <thead><tr><th>Código</th><th>Usuario</th><th>Persona</th><th>Correo</th><th>Estado</th><th>Rol</th><th>Acciones</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarUsuario(u) {
    const form=document.getElementById('form-usuario'); form.style.display='block'; form.dataset.editId=u.id_usuario;
    document.getElementById('form-usr-titulo').textContent='Editar Usuario';
    document.getElementById('form-usr-persona-row').style.display='none';
    document.getElementById('lbl-pass-opcional').textContent='(dejar en blanco para no cambiar)';
    document.getElementById('usr-email').value=u.correo;
    document.getElementById('usr-rol').value=u.roles;
    document.getElementById('usr-password').value='';
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioUsuario() {
    const form=document.getElementById('form-usuario'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-usr-titulo').textContent='Registrar Nuevo Usuario';
    document.getElementById('form-usr-persona-row').style.display='flex';
    document.getElementById('lbl-pass-opcional').textContent='';
    ['usr-username','usr-password','usr-email'].forEach(id=>document.getElementById(id).value='');
}
async function guardarUsuario() {
    const editId=document.getElementById('form-usuario').dataset.editId;
    if(editId) {
        const correo=val('usr-email'),roles=document.getElementById('usr-rol')?.value,contrasena_usuario=document.getElementById('usr-password')?.value||undefined;
        if(!correo||!roles)return showToast('Complete los campos requeridos','error');
        const r=await api('PUT',`/usuarios/${editId}`,{correo,roles,contrasena_usuario});
        if(r.ok){showToast(r.msg,'success');renderUsuarios();}else showToast(r.msg,'error');
    } else {
        const id_persona=document.getElementById('usr-persona')?.value,nombre_usuario=val('usr-username'),contrasena_usuario=document.getElementById('usr-password')?.value,correo=val('usr-email'),roles=document.getElementById('usr-rol')?.value;
        if(!id_persona||!nombre_usuario||!contrasena_usuario||!correo)return showToast('Complete todos los campos','error');
        const r=await api('POST','/usuarios',{id_persona,nombre_usuario,contrasena_usuario,correo,roles});
        if(r.ok){showToast(r.msg,'success');renderUsuarios();}else showToast(r.msg,'error');
    }
}
async function inhabilitarUsuario(id) {
    if(!confirm('¿Inhabilitar este usuario?'))return;
    const r=await api('PUT',`/usuarios/${id}/inhabilitar`);
    if(r.ok){showToast(r.msg,'success');renderUsuarios();}else showToast(r.msg,'error');
}
async function activarUsuario(id) {
    const r=await api('PUT',`/usuarios/${id}/activar`);
    if(r.ok){showToast(r.msg,'success');renderUsuarios();}else showToast(r.msg,'error');
}

// ==================== DISPONIBILIDAD ====================
async function renderDisponibilidadEquipos() {
    setContainer(loadingPanel('Disponibilidad de Equipos','view-disponibilidad-equipos'));
    const r=await api('GET','/reportes/disponibilidad'); if(!r.ok)return;
    const filas=r.inventario.map(i=>`<tr>
        <td><code>${i.serial}</code></td>
        <td>${i.equipo_nombre||'N/A'} ${i.modelo_nombre?`<small style="opacity:.6">${i.modelo_nombre}</small>`:''}</td>
        <td>${i.ubicacion_nombre||'N/A'}</td>
        <td><span class="status-badge ${i.estado==='Operativo'?'success':i.estado==='En Reparacion'?'warning':'danger'}">${i.estado}</span></td>
        <td><span class="status-badge ${i.estado==='Operativo'?'success':'warning'}">${i.estado==='Operativo'?'Disponible':'No disponible'}</span></td>
    </tr>`).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-disponibilidad-equipos" class="view-section active">
            <div class="section-header"><h1 class="page-title">Disponibilidad de Equipos — ${ubicacionPrincipal}</h1></div>
            <div class="glass-panel"><div class="table-responsive"><table class="premium-table">
                <thead><tr><th>Serial</th><th>Equipo</th><th>Ubicación</th><th>Estado</th><th>Disponibilidad</th></tr></thead>
                <tbody>${filas}</tbody>
            </table></div></div>
        </div>`;
}

// ==================== ESPACIOS ====================
async function renderEspacios() {
    setContainer(loadingPanel('Espacios y Laboratorios','view-espacios'));
    const r = await api('GET','/espacios'); if(!r.ok) return;
    const filas = r.espacios.map(e=>`<tr>
        <td><span class="table-tag">ESP-${String(e.id_espacio).padStart(2,'0')}</span></td>
        <td><div class="cell-stack"><span class="cell-title">${e.nombre}</span><span class="cell-subtitle">Espacio disponible para reservas.</span></div></td>
        <td><span class="count-pill">${e.capacidad} personas</span></td>
        <td><div class="table-actions">
            <button class="btn-icon-small" onclick='editarEspacio(${JSON.stringify(e)})'><i class="fas fa-edit"></i></button>
            <button class="btn-icon-small" onclick="eliminarEspacio(${e.id_espacio})"><i class="fas fa-trash"></i></button>
        </div></td></tr>`).join('');
    document.getElementById('views-container').innerHTML=`
        <div id="view-espacios" class="view-section active">
            <div class="section-header"><h1 class="page-title">Espacios y Laboratorios</h1><p class="page-subtitle">Administra los espacios disponibles para reservas.</p></div>
            <div class="section-metrics"><div class="metric-chip"><span class="metric-label">Espacios</span><strong>${r.espacios.length}</strong></div></div>
            <div class="glass-panel">
                <div class="panel-toolbar"><div class="table-section-intro"><h3>Espacios Registrados</h3></div>
                    <button class="btn btn-primary" onclick="mostrarFormularioEspacio()"><i class="fas fa-plus"></i> Nuevo Espacio</button></div>
                <div id="form-espacio" style="display:none;margin-bottom:1.5rem;padding:1rem;background:var(--glass-bg);border-radius:var(--radius-md);">
                    <h4 id="form-esp-titulo">Registrar Espacio</h4>
                    <div class="form-row">
                        <div class="form-group"><label>Nombre</label><input type="text" id="esp-nombre" class="form-control" placeholder="Ej: Laboratorio 1"></div>
                        <div class="form-group"><label>Capacidad (personas)</label><input type="number" id="esp-capacidad" class="form-control" min="1" placeholder="30"></div>
                    </div>
                    <div class="form-actions">
                        <button class="btn btn-primary" onclick="guardarEspacio()"><i class="fas fa-save"></i> Guardar</button>
                        <button class="btn btn-outline" onclick="ocultarFormulario('form-espacio')">Cancelar</button>
                    </div>
                </div>
                ${barraBusqueda('Buscar espacio...',[{idx:1,label:'Nombre'},{idx:2,label:'Capacidad'}])}
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Código</th><th>Nombre</th><th>Capacidad</th><th>Acciones</th></tr></thead>
                    <tbody>${filas||'<tr><td colspan="4" class="empty-state">Sin espacios registrados</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}
function editarEspacio(e) {
    const form=document.getElementById('form-espacio'); form.style.display='block'; form.dataset.editId=e.id_espacio;
    document.getElementById('form-esp-titulo').textContent='Editar Espacio';
    document.getElementById('esp-nombre').value=e.nombre;
    document.getElementById('esp-capacidad').value=e.capacidad;
    form.scrollIntoView({behavior:'smooth'});
}
function mostrarFormularioEspacio() {
    const form=document.getElementById('form-espacio'); form.style.display='block'; form.dataset.editId='';
    document.getElementById('form-esp-titulo').textContent='Registrar Espacio';
    document.getElementById('esp-nombre').value='';
    document.getElementById('esp-capacidad').value='';
}
async function guardarEspacio() {
    const nombre=val('esp-nombre'), capacidad=document.getElementById('esp-capacidad')?.value;
    if(!nombre||!capacidad) return showToast('Complete todos los campos','error');
    const editId=document.getElementById('form-espacio').dataset.editId;
    const r=editId?await api('PUT',`/espacios/${editId}`,{nombre,capacidad}):await api('POST','/espacios',{nombre,capacidad});
    if(r.ok){showToast(r.msg,'success');renderEspacios();}else showToast(r.msg,'error');
}
async function eliminarEspacio(id) {
    if(!confirm('¿Eliminar este espacio?')) return;
    const r=await api('DELETE',`/espacios/${id}`);
    if(r.ok){showToast(r.msg,'success');renderEspacios();}else showToast(r.msg,'error');
}


// ==================== REPORTES ====================
let _reporteActual = { titulo: '', columnas: [], filas: [] };
let _datosReporte  = null;

// Tabs config
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
];

function tabsHTML(activo) {
    const esAdmin = usuarioActual?.roles === 'Administrador';
    return `<div id="tabs-reporte" style="display:flex;gap:.4rem;flex-wrap:wrap;margin-bottom:1.5rem;padding-bottom:.75rem;border-bottom:1px solid var(--glass-border)">
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
    return `<div style="display:flex;gap:.5rem;align-items:center">
        <span style="font-size:.78rem;opacity:.5">Exportar:</span>
        <button class="btn btn-outline" style="padding:.35rem .8rem;font-size:.8rem" onclick="exportarExcel()">
            <i class="fas fa-file-excel" style="color:#21a366;margin-right:.3rem"></i>Excel</button>
        <button class="btn btn-outline" style="padding:.35rem .8rem;font-size:.8rem" onclick="exportarPDF()">
            <i class="fas fa-file-pdf" style="color:#e53e3e;margin-right:.3rem"></i>PDF</button>
    </div>`;
}

function kpi(label, valor, icon, color) {
    return `<div class="stat-card glass-panel" style="flex:1;min-width:130px">
        <div class="stat-icon ${color}"><i class="${icon}"></i></div>
        <div class="stat-info"><h3 style="font-size:.78rem">${label}</h3><h2>${valor}</h2></div>
    </div>`;
}

function barraH(items, max, color) {
    if (!items?.length) return '<p style="opacity:.4;text-align:center;padding:1rem">Sin datos</p>';
    return items.map(item => `
        <div style="margin-bottom:.8rem">
            <div style="display:flex;justify-content:space-between;margin-bottom:.25rem">
                <span style="font-size:.84rem">${item.nombre}</span>
                <strong style="font-size:.84rem">${item.total}</strong>
            </div>
            <div style="background:rgba(255,255,255,.08);border-radius:99px;height:8px">
                <div style="width:${Math.round((item.total/max)*100)}%;background:${color};border-radius:99px;height:8px;transition:width .6s"></div>
            </div>
        </div>`).join('');
}

function tablaHTML(columnas, filas) {
    if (!filas?.length) return '<p style="opacity:.4;text-align:center;padding:1.5rem">Sin registros</p>';
    return `<div class="table-responsive" style="max-height:440px;overflow-y:auto;margin-top:.75rem">
        <table class="premium-table" style="font-size:.82rem">
            <thead><tr>${columnas.map(c=>`<th>${c}</th>`).join('')}</tr></thead>
            <tbody>${filas.map(f=>`<tr>${f.map(c=>`<td>${c??'—'}</td>`).join('')}</tr>`).join('')}</tbody>
        </table>
    </div>`;
}

async function renderReportes() {
    setContainer(loadingPanel('Reportes e Informes','view-reportes'));
    // Cargar tab inicial: resumen
    const r = await api('GET','/reportes/resumen');
    if (!r.ok) return;
    _datosReporte = r;
    _construirVistaReportes('resumen');
    _renderTabResumen(r);
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
                <div id="reporte-contenido"><div style="text-align:center;padding:2rem;opacity:.4"><i class="fas fa-spinner fa-spin fa-2x"></i></div></div>
            </div>
        </div>`;
}

async function cargarTabReporte(tab) {
    // Actualizar estilo de tabs
    document.querySelectorAll('.reporte-tab').forEach(t => {
        const isActive = t.dataset.tab === tab;
        t.classList.toggle('active', isActive);
        t.style.background = isActive ? 'var(--primary,#4F46E5)' : 'var(--bg-main)';
        t.style.color = isActive ? '#fff' : 'var(--text-primary)';
    });
    const cont = document.getElementById('reporte-contenido');
    cont.innerHTML = '<div style="text-align:center;padding:2rem;opacity:.4"><i class="fas fa-spinner fa-spin fa-2x"></i> Cargando...</div>';

    const r = await api('GET', `/reportes/${tab}`);
    if (!r.ok) { cont.innerHTML = `<p style="color:#f87171;padding:1rem">${r.msg}</p>`; return; }

    const fecha = new Date().toLocaleDateString('es-ES');
    switch(tab) {
        case 'resumen':            _renderTabResumen(r); break;
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
    }
}

function _renderTabResumen(r) {
    const {inv_stats:i, sol_stats:s, man_stats:m, top_espacios, top_actividades} = r;
    const maxE = Math.max(...(top_espacios||[{total:1}]).map(e=>e.total), 1);
    const maxA = Math.max(...(top_actividades||[{total:1}]).map(a=>a.total), 1);
    document.getElementById('reporte-contenido').innerHTML = `
        <h4 style="margin-bottom:.75rem;opacity:.7">Inventario de Equipos</h4>
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.5rem">
            ${kpi('Total',i.total,'fas fa-layer-group','purple')}
            ${kpi('Operativos',i.operativo,'fas fa-check-circle','green')}
            ${kpi('En Reparación',i.en_reparacion,'fas fa-tools','orange')}
            ${kpi('No Operativo',i.no_operativo,'fas fa-ban','blue')}
            ${kpi('Dañados',i.daniado,'fas fa-exclamation-triangle','orange')}
        </div>
        <h4 style="margin-bottom:.75rem;opacity:.7">Solicitudes y Reservas</h4>
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.5rem">
            ${kpi('Total',s.total,'fas fa-list','purple')}
            ${kpi('Aprobadas',s.aprobadas,'fas fa-calendar-check','green')}
            ${kpi('Pendientes',s.pendientes,'fas fa-clock','orange')}
            ${kpi('Completadas',s.completadas,'fas fa-check-double','blue')}
            ${kpi('Canceladas',s.canceladas,'fas fa-times-circle','orange')}
        </div>
        <h4 style="margin-bottom:.75rem;opacity:.7">Mantenimiento</h4>
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
    _reporteActual = {
        titulo: `Resumen General CBIT — ${new Date().toLocaleDateString('es-ES')}`,
        columnas: ['Módulo','Indicador','Valor'],
        filas: [
            ...['total','operativo','en_reparacion','no_operativo','daniado'].map(k=>['Inventario',k,i[k]]),
            ...['total','aprobadas','pendientes','completadas','canceladas'].map(k=>['Solicitudes',k,s[k]]),
            ...['total','alta','media','baja'].map(k=>['Mantenimiento',k,m[k]]),
            ...(top_espacios||[]).map(e=>['Top Espacios',e.nombre,e.total]),
            ...(top_actividades||[]).map(a=>['Top Actividades',a.nombre,a.total]),
        ]
    };
}

function _renderTabUsuarios(r, fecha) {
    const cols = ['ID','Usuario','Nombre','Apellido','Cédula','Correo','Rol','Estado','Solicitudes'];
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
    _reporteActual = { titulo:`Reporte General de Usuarios — ${fecha}`, columnas:cols, filas };
}

function _renderTabEquipos(r, fecha) {
    const cols = ['Serial','Equipo','Categoría','Marca','Modelo','Ubicación','Estado'];
    const filas = (r.equipos||[]).map(e=>[e.serial,e.equipo_nombre,e.categoria||'—',e.marca||'—',e.modelo||'—',(e.ubicacion||'N/A').split(' - ').pop(),e.estado]);
    const porEstado = {};
    (r.equipos||[]).forEach(e=>{ porEstado[e.estado]=(porEstado[e.estado]||0)+1; });
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total',r.equipos.length,'fas fa-laptop','purple')}
            ${Object.entries(porEstado).map(([est,n])=>kpi(est,n,'fas fa-circle',est==='Operativo'?'green':est==='En Reparacion'?'orange':'blue')).join('')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _reporteActual = { titulo:`Reporte de Equipos Tecnológicos — ${fecha}`, columnas:cols, filas };
}

function _renderTabDisponibilidad(r, fecha) {
    const cols = ['Serial','Equipo','Modelo','Ubicación','Estado','Disponibilidad'];
    const filas = (r.inventario||[]).map(i=>[i.serial,i.equipo_nombre||'N/A',i.modelo_nombre||'—',(i.ubicacion_nombre||'N/A').split(' - ').pop(),i.estado,i.estado==='Operativo'?'Disponible':'No disponible']);
    const disp = (r.inventario||[]).filter(i=>i.estado==='Operativo').length;
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total',r.inventario.length,'fas fa-boxes','purple')}
            ${kpi('Disponibles',disp,'fas fa-check-circle','green')}
            ${kpi('No disponibles',r.inventario.length-disp,'fas fa-times-circle','orange')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _reporteActual = { titulo:`Reporte de Disponibilidad de Equipos — ${fecha}`, columnas:cols, filas };
}

function _renderTabReservasEquipos(r, fecha) {
    const cols = ['Serial','Equipo','Modelo','Docente','Actividad','Fecha','Hora Inicio','Hora Fin','Estado'];
    const filas = (r.reservas||[]).map(x=>[x.serial,x.equipo_nombre||'N/A',x.modelo_nombre||'—',`${x.docente_nombre||''} ${x.docente_apellido||''}`.trim()||'—',x.actividad_nombre||'N/A',new Date(x.fecha).toLocaleDateString('es-ES'),String(x.hora_inicio).slice(0,5),String(x.hora_fin).slice(0,5),x.estado]);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1rem">
            ${kpi('Total reservas equipos',r.reservas.length,'fas fa-hdd','purple')}
            ${kpi('Aprobadas',r.reservas.filter(x=>x.estado==='Aprobado').length,'fas fa-check','green')}
        </div>
        ${tablaHTML(cols, filas)}`;
    _reporteActual = { titulo:`Reporte de Reservas de Equipos — ${fecha}`, columnas:cols, filas };
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
    _reporteActual = { titulo:`Reporte de Reservas de Espacio — ${fecha}`, columnas:cols, filas };
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
    _reporteActual = { titulo:`Reporte de Actividades Educativas — ${fecha}`, columnas:cols, filas };
}

function _renderTabFallas(r, fecha) {
    const cols = ['ID','Equipo','Categoría','Serial','Descripción Falla','Prioridad','Técnico','Especialidad','Fecha Reporte'];
    const filas = (r.fallas||[]).map(f=>[
        `MAN-${String(f.id_mantenimiento).padStart(2,'0')}`,
        f.equipo_nombre||'N/A', f.categoria||'—', f.serial||'—',
        f.descripcion_fallas||'—', f.nivel_prioridad,
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
    _reporteActual = { titulo:`Reporte de Fallas Técnicas — ${fecha}`, columnas:cols, filas };
}

function _renderTabMantenimiento(r, fecha) {
    const cols = ['ID','Equipo','Serial','Descripción','Prioridad','Técnico','Especialidad','Fecha'];
    const filas = (r.mantenimientos||[]).map(m=>[
        `MAN-${String(m.id_mantenimiento).padStart(2,'0')}`,
        m.equipo_nombre||'N/A', m.serial||'—',
        m.descripcion_fallas||'—', m.nivel_prioridad,
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
    _reporteActual = { titulo:`Reporte de Mantenimiento de Equipos — ${fecha}`, columnas:cols, filas };
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
    _reporteActual = { titulo:`Reporte de Asistencia por Docente — ${fecha}`, columnas:cols, filas };
}

function _renderTabMaquinas(r, fecha) {
    const cols = ['Equipo','Marca','Modelo','Total Usos'];
    const filas = (r.maquinas||[]).map(m=>[m.equipo_nombre,m.marca||'—',m.modelo_nombre||'—',m.total_usos]);
    const max = Math.max(...(r.maquinas||[{total_usos:1}]).map(m=>m.total_usos), 1);
    document.getElementById('reporte-contenido').innerHTML = `
        <div style="display:flex;flex-wrap:wrap;gap:.6rem;margin-bottom:1.25rem">
            ${kpi('Equipos con uso',r.maquinas.length,'fas fa-fire','orange')}
            ${kpi('Más usado', r.maquinas[0]?.equipo_nombre||'—', 'fas fa-trophy','green')}
            ${kpi('Total usos registrados', (r.maquinas||[]).reduce((a,m)=>a+m.total_usos,0),'fas fa-chart-bar','purple')}
        </div>
        <div class="dashboard-content-grid" style="margin-bottom:1rem">
            <div>
                <h4 style="margin-bottom:.75rem;opacity:.7;font-size:.9rem"><i class="fas fa-fire" style="margin-right:.3rem;color:#F59E0B"></i>Ranking de uso</h4>
                ${barraH((r.maquinas||[]).map(m=>({nombre:m.equipo_nombre,total:m.total_usos})), max, 'linear-gradient(90deg,#F59E0B,#EC4899)')}
            </div>
        </div>
        ${tablaHTML(cols, filas)}`;
    _reporteActual = { titulo:`Reporte de Máquinas más usadas — ${fecha}`, columnas:cols, filas };
}

// ── EXPORTAR EXCEL ─────────────────────────────────────────────────────────
function exportarExcel() {
    if (!_reporteActual.filas.length) return showToast('No hay datos para exportar','error');
    try {
        const wb = XLSX.utils.book_new();
        const datos = [_reporteActual.columnas, ..._reporteActual.filas];
        const ws = XLSX.utils.aoa_to_sheet(datos);
        ws['!cols'] = _reporteActual.columnas.map((_, ci) =>
            ({ wch: Math.max(...datos.map(r => String(r[ci]||'').length), 10) + 2 }));
        XLSX.utils.book_append_sheet(wb, ws, 'Reporte');
        XLSX.writeFile(wb, _reporteActual.titulo.replace(/[^a-zA-Z0-9_\- ]/g,'').trim() + '.xlsx');
        showToast('Excel descargado ✅','success');
    } catch(e) { console.error(e); showToast('Error al generar el Excel','error'); }
}

// ── EXPORTAR PDF ───────────────────────────────────────────────────────────
function exportarPDF() {
    if (!_reporteActual.filas.length) return showToast('No hay datos para exportar','error');
    try {
        const { jsPDF } = window.jspdf;
        const landscape = _reporteActual.columnas.length > 5;
        const doc = new jsPDF({ orientation: landscape ? 'landscape' : 'portrait', unit:'mm', format:'a4' });
        const pw = doc.internal.pageSize.getWidth();

        // Header bar
        doc.setFillColor(79,70,229);
        doc.rect(0, 0, pw, 22, 'F');
        doc.setTextColor(255,255,255);
        doc.setFontSize(13); doc.setFont(undefined,'bold');
        doc.text('CBIT Manager', 14, 10);
        doc.setFontSize(9); doc.setFont(undefined,'normal');
        doc.text(_reporteActual.titulo, 14, 17);
        doc.text(`${ubicacionPrincipal}   |   ${new Date().toLocaleString('es-ES')}`, pw/2, 17, {align:'center'});

        doc.autoTable({
            startY: 28,
            head: [_reporteActual.columnas],
            body: _reporteActual.filas,
            styles: { fontSize: 8, cellPadding: 2.5, overflow: 'linebreak' },
            headStyles: { fillColor:[79,70,229], textColor:[255,255,255], fontStyle:'bold' },
            alternateRowStyles: { fillColor:[245,245,250] },
            margin: { left:14, right:14 },
        });

        const total = doc.getNumberOfPages();
        for (let i=1; i<=total; i++) {
            doc.setPage(i); doc.setFontSize(7); doc.setTextColor(150);
            doc.text(`Página ${i} de ${total}`, pw-14, doc.internal.pageSize.getHeight()-8, {align:'right'});
        }
        doc.save(_reporteActual.titulo.replace(/[^a-zA-Z0-9_\- ]/g,'').trim() + '.pdf');
        showToast('PDF descargado ✅','success');
    } catch(e) { console.error(e); showToast('Error al generar el PDF','error'); }
}

// ==================== LOGOUT / TEMA / EYE ====================
document.getElementById('logout-btn')?.addEventListener('click', async e => {
    e.preventDefault();
    await api('POST','/auth/logout');
    usuarioActual = null;
    document.getElementById('app-screen').style.display = 'none';
    document.getElementById('login-screen').style.display = 'flex';
    document.getElementById('btn-ayuda-flotante').style.display = 'none';
    desconectarSocket();
    document.getElementById('login-user').value = '';
    document.getElementById('login-pass').value = '';
    showToast('Sesión cerrada correctamente','success');
});
let isDark = false;
document.querySelector('.theme-toggle')?.addEventListener('click', function() {
    isDark = !isDark; document.body.classList.toggle('dark-theme', isDark);
    this.innerHTML = isDark ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
});
document.getElementById('eye-toggle')?.addEventListener('click', function() {
    const p = document.getElementById('login-pass');
    p.type = p.type === 'password' ? 'text' : 'password';
    this.querySelector('i').className = `fas fa-eye${p.type==='password'?'':'-slash'}`;
});
document.getElementById('login-pass')?.addEventListener('keypress', e => { if(e.key==='Enter') iniciarSesion(); });

// ==================== HISTORIAL DE ACTIVIDADES (Admin) ====================
async function renderHistorial(filtros = {}) {
    setContainer(loadingPanel('Historial de Actividades','view-historial'));
    const qs = new URLSearchParams(filtros).toString();
    const r = await api('GET', '/historial' + (qs ? `?${qs}` : ''));
    if (!r.ok) return;
    const { historial, usuarios, modulos } = r;

    const hoy = new Date().toDateString();
    const totalHoy = historial.filter(h => new Date(h.fecha).toDateString() === hoy).length;

    const opUsuarios = usuarios.map(u => `<option value="${u.id_usuario}" ${String(filtros.id_usuario)===String(u.id_usuario)?'selected':''}>${u.nombre||''} ${u.apellido||''} (${u.nombre_usuario})</option>`).join('');
    const opModulos = modulos.map(m => `<option value="${m}" ${filtros.modulo===m?'selected':''}>${m}</option>`).join('');

    const iconoAccion = a => a.includes('Creación') ? 'fa-plus-circle' : a.includes('Actualización') ? 'fa-edit' : a.includes('Eliminación') ? 'fa-trash' : a.includes('fallido') ? 'fa-triangle-exclamation' : a.includes('sesión') ? 'fa-right-to-bracket' : 'fa-circle-info';
    const colorAccion = a => a.includes('Creación') ? 'success' : a.includes('Actualización') ? 'info' : a.includes('Eliminación') ? 'danger' : a.includes('fallido') ? 'warning' : 'purple';

    const filas = historial.map(h => `<tr>
        <td>${new Date(h.fecha).toLocaleString('es-ES')}</td>
        <td>${h.usuario || 'Sistema'}</td>
        <td><span class="status-badge ${colorAccion(h.accion)}"><i class="fas ${iconoAccion(h.accion)}" style="margin-right:.3rem"></i>${h.accion}</span></td>
        <td><span class="table-tag">${h.modulo}</span></td>
        <td style="opacity:.8">${h.detalle || '—'}</td>
        <td style="opacity:.5;font-size:.78rem">${h.ip || '—'}</td>
    </tr>`).join('');

    document.getElementById('views-container').innerHTML = `
        <div id="view-historial" class="view-section active">
            <div class="section-header"><h1 class="page-title">Historial de Actividades del Sistema</h1></div>
            <div class="section-metrics">
                <div class="metric-chip"><span class="metric-label">Registros mostrados</span><strong>${historial.length}</strong></div>
                <div class="metric-chip"><span class="metric-label">Hoy</span><strong>${totalHoy}</strong></div>
            </div>
            <div class="glass-panel">
                <div class="panel-toolbar"><h3>Bitácora del Sistema</h3></div>
                <div class="barra-busqueda-modulo" style="display:flex;flex-wrap:wrap;gap:.6rem;align-items:center;padding:.75rem 1rem;margin-bottom:1rem;background:rgba(79,70,229,0.04);border:1px solid rgba(79,70,229,0.12);border-radius:10px">
                    <select id="hist-usuario" class="form-control" style="max-width:220px"><option value="">Todos los usuarios</option>${opUsuarios}</select>
                    <select id="hist-modulo" class="form-control" style="max-width:180px"><option value="">Todos los módulos</option>${opModulos}</select>
                    <input type="date" id="hist-desde" class="form-control" style="max-width:160px" value="${filtros.desde||''}">
                    <input type="date" id="hist-hasta" class="form-control" style="max-width:160px" value="${filtros.hasta||''}">
                    <button class="btn btn-primary" onclick="aplicarFiltrosHistorial()"><i class="fas fa-filter"></i> Filtrar</button>
                    <button class="btn btn-outline" onclick="renderHistorial()"><i class="fas fa-rotate"></i> Limpiar</button>
                </div>
                <div class="table-responsive table-enhanced"><table class="premium-table premium-table-detailed">
                    <thead><tr><th>Fecha y Hora</th><th>Usuario</th><th>Acción</th><th>Módulo</th><th>Detalle</th><th>IP</th></tr></thead>
                    <tbody>${filas || '<tr><td colspan="6" class="empty-state">Sin registros en el historial</td></tr>'}</tbody>
                </table></div>
            </div>
        </div>`;
}
function aplicarFiltrosHistorial() {
    renderHistorial({
        id_usuario: document.getElementById('hist-usuario').value,
        modulo: document.getElementById('hist-modulo').value,
        desde: document.getElementById('hist-desde').value,
        hasta: document.getElementById('hist-hasta').value
    });
}

// ==================== AYUDA CONTEXTUAL (Manual de Sistema) ====================
const MANUAL_AYUDA = {
    dashboard: {
        titulo: 'Panel Principal',
        icono: 'fa-home',
        descripcion: 'Muestra un resumen general del estado del CBIT: inventario de equipos, solicitudes y reservas activas.',
        pasos: ['Revise las tarjetas de "Inventario de Equipos" para ver cuántos equipos están operativos, en reparación, no operativos o dañados.', 'Revise "Solicitudes y Reservas" para ver cuántas están pendientes de aprobación.'],
        consejos: ['Este panel se actualiza cada vez que entra al sistema.', 'Si algo aparece en "Dañados", vaya al módulo de Mantenimiento para reportarlo.']
    },
    calendario: {
        titulo: 'Calendario de Reservas',
        icono: 'fa-calendar-alt',
        descripcion: 'Muestra en formato semanal todas las reservas de espacios ya aprobadas.',
        pasos: ['Use las flechas para moverse entre semanas.', 'Haga clic sobre una reserva para ver su detalle (espacio, actividad, docente, horario).'],
        consejos: ['Solo se muestran reservas con estado "Aprobado". Las pendientes se ven en el módulo de Solicitudes.']
    },
    categorias: {
        titulo: 'Categorías de Equipos',
        icono: 'fa-tags',
        descripcion: 'Agrupa los equipos tecnológicos por tipo (ej. Laptops, Proyectores, Tablets).',
        pasos: ['Clic en "Nueva Categoría" e ingrese un nombre único (2 a 60 caracteres).', 'Para editar, use el ícono de lápiz en la fila correspondiente.'],
        consejos: ['No se puede eliminar una categoría que tenga equipos asociados.', 'No se permiten nombres duplicados.']
    },
    marcas: {
        titulo: 'Marcas de Equipos',
        icono: 'fa-trademark',
        descripcion: 'Administra las marcas de fabricantes (ej. HP, Dell, Lenovo) usadas en el catálogo de equipos.',
        pasos: ['Clic en "Nueva Marca" e ingrese el nombre del fabricante.', 'Edite o elimine usando los íconos de la tabla.'],
        consejos: ['No se puede eliminar una marca en uso por algún equipo.']
    },
    modelos: {
        titulo: 'Modelos de Equipos',
        icono: 'fa-cubes',
        descripcion: 'Administra los modelos específicos de equipo (ej. "ProBook 450 G8", "PowerLite X05") que luego se asocian al registrar un equipo en el catálogo.',
        pasos: ['Clic en "Nuevo Modelo" e ingrese el nombre del modelo y, opcionalmente, una descripción.', 'Edite o elimine usando los íconos de la tabla.'],
        consejos: ['No se puede eliminar un modelo que ya esté en uso por algún equipo del catálogo.']
    },
    equipos: {
        titulo: 'Catálogo de Equipos',
        icono: 'fa-laptop',
        descripcion: 'Define los "modelos" o tipos de equipo del catálogo, asociados a una categoría y una marca. Es la base para luego registrar unidades físicas en Inventario.',
        pasos: ['Complete nombre, categoría y marca (el modelo es opcional).', 'Cada unidad física de este equipo se registra luego en el módulo Inventario, con su propio serial.'],
        consejos: ['No se puede eliminar un equipo que ya tenga unidades registradas en inventario.']
    },
    inventario: {
        titulo: 'Inventario',
        icono: 'fa-boxes',
        descripcion: 'Registra cada unidad física de un equipo: su serial único, ubicación y estado actual (Operativo, No operativo, En Reparación, Dañado).',
        pasos: ['Seleccione el equipo del catálogo y la ubicación física.', 'Ingrese un serial único (no puede repetirse) y el estado actual.'],
        consejos: ['El estado se actualiza automáticamente cuando se reporta un mantenimiento.', 'El serial es la forma de identificar de forma única cada unidad.']
    },
    actividades: {
        titulo: 'Actividades Educativas',
        icono: 'fa-chalkboard',
        descripcion: 'Catálogo de actividades o materias (ej. "Clase de Robótica") que se usan al crear una solicitud de reserva.',
        pasos: ['Ingrese nombre y una breve descripción de la actividad.'],
        consejos: ['No se puede eliminar una actividad que ya tenga solicitudes asociadas.']
    },
    solicitudes: {
        titulo: 'Solicitudes de Uso',
        icono: 'fa-clipboard-list',
        descripcion: 'Aquí los docentes solicitan el uso de un espacio y, opcionalmente, equipos, en una fecha y horario específicos. El administrador aprueba o rechaza.',
        pasos: ['Docente: cree una solicitud indicando espacio, actividad, fecha y horario.', 'Administrador: revise las solicitudes "Pendientes" y apruébelas o cancélelas.', 'Al aprobar o rechazar, el sistema envía un correo automático al docente.'],
        consejos: ['La fecha no puede ser anterior a hoy.', 'No se puede reservar un espacio si ya está ocupado en ese horario.']
    },
    asistencias: {
        titulo: 'Control de Asistencia',
        icono: 'fa-clipboard-user',
        descripcion: 'Registra qué estudiantes asistieron a un evento/solicitud ya aprobado.',
        pasos: ['Registre primero al estudiante si no existe (nombre, apellido, cédula, año).', 'Luego registre su asistencia asociándola a la solicitud/evento correspondiente.'],
        consejos: ['Los docentes solo ven y registran la asistencia de los eventos que ellos mismos crearon. El administrador ve la asistencia de todos los eventos.']
    },
    reservas: {
        titulo: 'Reservas Activas',
        icono: 'fa-calendar-check',
        descripcion: 'Muestra las solicitudes ya aprobadas que están en curso o próximas, permitiendo marcarlas como finalizadas.',
        pasos: ['Ubique la reserva en curso y use "Finalizar" cuando el uso del espacio haya terminado.'],
        consejos: []
    },
    mantenimiento: {
        titulo: 'Mantenimiento',
        icono: 'fa-tools',
        descripcion: 'Registra reportes de fallas técnicas sobre un equipo del inventario y asigna un técnico responsable.',
        pasos: ['Seleccione el técnico, el equipo con falla, el nivel de prioridad y describa el problema.'],
        consejos: ['Un reporte de mantenimiento actualiza automáticamente el estado del equipo en inventario.']
    },
    tecnicos: {
        titulo: 'Técnicos de Soporte',
        icono: 'fa-user-gear',
        descripcion: 'Administra el personal técnico y su especialidad (Hardware, Software, Redes, etc.), usado luego en Mantenimiento.',
        pasos: ['Seleccione una persona ya registrada y asígnele una especialidad.'],
        consejos: ['Una persona no puede registrarse dos veces como técnico.']
    },
    personas: {
        titulo: 'Registro de Personas',
        icono: 'fa-users',
        descripcion: 'Base de datos central de personas (nombre, apellido, cédula, teléfono) que luego se vincula a Usuarios, Técnicos o Estudiantes.',
        pasos: ['Registre a la persona antes de crearle un usuario o asignarla como técnico.'],
        consejos: ['La cédula debe tener formato V-12345678 o E-12345678 y no puede repetirse.']
    },
    usuarios: {
        titulo: 'Usuarios del Sistema',
        icono: 'fa-user-cog',
        descripcion: 'Administra las cuentas de acceso al sistema y su rol: Administrador o Docente. Solo el Administrador puede gestionar usuarios.',
        pasos: ['Seleccione una persona ya registrada, asigne usuario, contraseña y rol.', 'Puede inhabilitar o reactivar una cuenta sin eliminarla.'],
        consejos: ['La contraseña debe tener mínimo 6 caracteres, con letras y números.', 'El nombre de usuario y el correo no pueden repetirse.']
    },
    espacios: {
        titulo: 'Espacios y Laboratorios',
        icono: 'fa-door-open',
        descripcion: 'Administra los espacios físicos disponibles para reserva (laboratorios, salas) y su capacidad.',
        pasos: ['Solo el Administrador puede crear, editar o eliminar espacios. Los docentes solo pueden consultarlos.'],
        consejos: []
    },
    'disponibilidad-equipos': {
        titulo: 'Disponibilidad de Equipos',
        icono: 'fa-microchip',
        descripcion: 'Consulta rápida de qué equipos del inventario están disponibles para un horario específico, antes de crear una solicitud.',
        pasos: ['Seleccione fecha y horario para ver los equipos operativos y libres en ese rango.'],
        consejos: []
    },
    reportes: {
        titulo: 'Reportes e Informes',
        icono: 'fas fa-chart-bar',
        descripcion: 'Centraliza todos los reportes del sistema: resumen general, inventario, reservas, fallas técnicas, máquinas más usadas, entre otros.',
        pasos: ['Use las pestañas superiores para cambiar de reporte.', 'Puede exportar cualquier reporte a Excel o PDF con los botones correspondientes.'],
        consejos: ['El reporte de "Usuarios" solo está disponible para el Administrador.']
    },
    historial: {
        titulo: 'Historial de Actividades',
        icono: 'fa-history',
        descripcion: 'Bitácora de auditoría exclusiva del Administrador: registra quién creó, editó o eliminó información, y cuándo.',
        pasos: ['Filtre por usuario, módulo o rango de fechas para investigar un cambio específico.'],
        consejos: ['Los inicios de sesión fallidos también quedan registrados aquí, útil para detectar accesos indebidos.']
    }
};

function mostrarAyuda(moduloKey) {
    const key = moduloKey || vistaActual;
    const ayuda = MANUAL_AYUDA[key] || MANUAL_AYUDA.dashboard;
    document.getElementById('modal-overlay')?.remove();
    const overlay = document.createElement('div');
    overlay.id = 'modal-overlay';
    overlay.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:1000;display:flex;align-items:center;justify-content:center;padding:1rem;';
    overlay.innerHTML = `
        <div style="background:var(--bg-surface,#1e1e2e);border:1px solid var(--glass-border,rgba(255,255,255,0.1));border-radius:16px;padding:2rem;min-width:320px;max-width:560px;width:100%;max-height:85vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.5);">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
                <h3 style="margin:0;color:var(--text-primary);display:flex;align-items:center;gap:.5rem"><i class="fas ${ayuda.icono}" style="color:var(--primary,#4F46E5)"></i> ${ayuda.titulo}</h3>
                <button onclick="document.getElementById('modal-overlay').remove()" style="background:none;border:none;color:var(--text-secondary);font-size:1.4rem;cursor:pointer;padding:0.2rem 0.5rem;">&times;</button>
            </div>
            <p style="color:var(--text-secondary);font-size:.9rem;margin-bottom:1.1rem;line-height:1.5">${ayuda.descripcion}</p>
            ${ayuda.pasos?.length ? `<h4 style="font-size:.85rem;color:var(--text-primary);margin-bottom:.5rem"><i class="fas fa-list-ol" style="margin-right:.4rem;opacity:.7"></i>Cómo usarlo</h4>
            <ol style="margin:0 0 1.1rem 1.1rem;padding:0;color:var(--text-secondary);font-size:.85rem;line-height:1.7">${ayuda.pasos.map(p=>`<li>${p}</li>`).join('')}</ol>` : ''}
            ${ayuda.consejos?.length ? `<h4 style="font-size:.85rem;color:var(--text-primary);margin-bottom:.5rem"><i class="fas fa-lightbulb" style="margin-right:.4rem;opacity:.7"></i>Consejos</h4>
            <ul style="margin:0 0 1.1rem 1.1rem;padding:0;color:var(--text-secondary);font-size:.85rem;line-height:1.7">${ayuda.consejos.map(c=>`<li>${c}</li>`).join('')}</ul>` : ''}
            <div style="display:flex;justify-content:flex-end;gap:.6rem;border-top:1px solid var(--glass-border);padding-top:1rem;margin-top:.5rem">
                <a href="/manual-usuario-cbit-manager.pdf" target="_blank" rel="noopener" class="btn btn-outline" style="text-decoration:none"><i class="fas fa-file-pdf" style="color:#e53e3e;margin-right:.3rem"></i>Manual completo (PDF)</a>
                <button class="btn btn-primary" onclick="document.getElementById('modal-overlay').remove()">Entendido</button>
            </div>
        </div>`;
    document.body.appendChild(overlay);
    overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
}

// ==================== TIEMPO REAL (Socket.IO) Y SONIDO DE NOTIFICACIÓN ====================
let socket = null;
let audioCtx = null;

// Genera un sonido de notificación corto (dos tonos ascendentes) sin necesidad
// de archivos de audio externos, usando la Web Audio API.
function reproducirSonidoActualizacion() {
    try {
        audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
        if (audioCtx.state === 'suspended') audioCtx.resume();
        const ahora = audioCtx.currentTime;
        [[880, ahora], [1174.66, ahora + 0.11]].forEach(([freq, inicio]) => {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'sine';
            osc.frequency.value = freq;
            gain.gain.setValueAtTime(0.0001, inicio);
            gain.gain.exponentialRampToValueAtTime(0.18, inicio + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.0001, inicio + 0.16);
            osc.connect(gain).connect(audioCtx.destination);
            osc.start(inicio);
            osc.stop(inicio + 0.18);
        });
    } catch (e) { /* Audio no disponible en este navegador/contexto: se ignora silenciosamente */ }
}

// Qué vistas deben refrescarse cuando cambia un módulo determinado
// (una misma acción puede afectar datos visibles en varias pantallas).
const RELACIONES_MODULO = {
    categorias: ['categorias', 'equipos', 'dashboard'],
    marcas: ['marcas', 'equipos', 'dashboard'],
    modelos: ['modelos', 'equipos', 'dashboard'],
    equipos: ['equipos', 'inventario', 'modelos', 'disponibilidad-equipos', 'dashboard'],
    inventario: ['inventario', 'equipos', 'mantenimiento', 'disponibilidad-equipos', 'dashboard', 'reportes'],
    actividades: ['actividades', 'solicitudes', 'dashboard'],
    solicitudes: ['solicitudes', 'calendario', 'reservas', 'asistencias', 'disponibilidad-equipos', 'dashboard', 'reportes'],
    reservas: ['reservas', 'calendario', 'solicitudes', 'dashboard'],
    mantenimiento: ['mantenimiento', 'inventario', 'dashboard', 'reportes'],
    tecnicos: ['tecnicos', 'mantenimiento', 'personas', 'dashboard'],
    asistencias: ['asistencias', 'dashboard'],
    usuarios: ['usuarios', 'personas', 'dashboard'],
    personas: ['personas', 'usuarios', 'tecnicos', 'asistencias', 'dashboard'],
    espacios: ['espacios', 'solicitudes', 'calendario', 'dashboard'],
    historial: ['historial'],
};

function conectarSocket() {
    if (socket || typeof io === 'undefined') return;
    socket = io({ withCredentials: true });

    socket.on('data:changed', (data) => {
        reproducirSonidoActualizacion();

        const nombrePropio = usuarioActual ? `${usuarioActual.nombre || ''} ${usuarioActual.apellido || ''}`.trim() : '';

        // Avisos de inicio/cierre de sesión: se muestran con el texto exacto
        // que envía el servidor (ej. "Eddy Pacheco ha iniciado sesión").
        if (data.tipo === 'sesion') {
            if (data.usuario !== nombrePropio) showToast(data.detalle, 'info');
            return;
        }

        if (data.usuario && nombrePropio && data.usuario !== nombrePropio) {
            showToast(`${data.usuario} hizo una ${(data.accion || '').toLowerCase()} en ${data.moduloLabel}`, 'info');
        }

        // Si hay un formulario/modal abierto, no interrumpimos al usuario:
        // solo suena la notificación y se avisa por toast, sin recargar datos.
        const hayModalAbierto = document.getElementById('modal-overlay');
        const vistasAfectadas = RELACIONES_MODULO[data.modulo] || [data.modulo];
        if (!hayModalAbierto && vistasAfectadas.includes(vistaActual)) {
            cargarVista(vistaActual);
        }
    });
}

function desconectarSocket() {
    if (socket) { socket.disconnect(); socket = null; }
}

// ==================== VERIFICAR SESIÓN ====================
(async () => {
    const r = await api('GET','/auth/sesion');
    if (r.ok) { usuarioActual = r.usuario; mostrarApp(); }
})();

// ==================== EXPONER GLOBALES ====================
Object.assign(window, {
    // Buscador integrado
    filtrarTabla, ordenarTablaCol, toggleDirOrden, limpiarBuscador,
    // Auth & nav
    iniciarSesion, recuperarContrasena, showPanel, ocultarFormulario, cargarVista,
    // Calendario
    verDetalleReserva, semanaAnterior, semanaSiguiente, irSemanaActual,
    // Categorías
    mostrarFormularioCategoria, guardarCategoria, eliminarCategoria, editarCategoria,
    // Marcas
    mostrarFormularioMarca, guardarMarca, eliminarMarca, editarMarca,
    renderModelos, mostrarFormularioModelo, guardarModelo, eliminarModelo, editarModelo,
    // Equipos
    mostrarFormularioEquipo, guardarEquipo, eliminarEquipo, editarEquipo,
    // Inventario
    mostrarFormularioInventario, guardarInventario, eliminarInventario, editarInventario,
    // Actividades
    mostrarFormularioActividad, guardarActividad, eliminarActividad, editarActividad,
    // Solicitudes
    mostrarFormularioSolicitud, guardarSolicitud, aprobarSolicitud, cancelarSolicitud,
    eliminarSolicitud, editarSolicitud, verDetalleSolicitud, buscarEquiposDisponibles,
    // Reservas
    finalizarReserva,
    // Mantenimiento
    mostrarFormularioMantenimiento, guardarMantenimiento, eliminarMantenimiento,
    // Técnicos
    mostrarFormularioTecnico, guardarTecnico, eliminarTecnico, editarTecnico,
    // Asistencia
    toggleFormAsistencia, toggleFormRegistrarEstudiante, toggleModoEstudiante,
    guardarAsistencia, guardarEstudiante, eliminarAsistencia,
    // Personas
    mostrarFormularioPersona, guardarPersona, eliminarPersona, editarPersona,
    // Usuarios
    mostrarFormularioUsuario, guardarUsuario, inhabilitarUsuario, activarUsuario, editarUsuario,
    // Espacios
    mostrarFormularioEspacio, guardarEspacio, eliminarEspacio, editarEspacio,
    // Reportes
    cargarTabReporte, exportarExcel, exportarPDF,
    // Historial de Actividades
    renderHistorial, aplicarFiltrosHistorial,
    // Ayuda contextual
    mostrarAyuda,
    // Tiempo real y sonido
    conectarSocket, desconectarSocket, reproducirSonidoActualizacion,
    // Navegación móvil
    toggleSidebar,
});
