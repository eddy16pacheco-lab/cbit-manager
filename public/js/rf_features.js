// ══════════════════════════════════════════════════════════════
//  rf_features.js — Funcionalidades RF-47 a RF-58
//  Agregar en index.html DESPUÉS de app.js:
//  <script src="/js/rf_features.js"></script>
// ══════════════════════════════════════════════════════════════

// ─── LOGIN INTERACTIVO (botón activa al llenar campos) ────────
function initLoginInteractivo() {
    const userInput = document.getElementById('login-user');
    const passInput = document.getElementById('login-pass');
    const btnLogin  = document.querySelector('.btn-login');
    if (!userInput || !passInput || !btnLogin) return;

    function actualizarBoton() {
        const lleno = userInput.value.trim().length > 0 && passInput.value.length > 0;
        btnLogin.classList.toggle('activo', lleno);
        btnLogin.disabled = !lleno;
    }

    userInput.addEventListener('input', () => {
        userInput.classList.toggle('filled', userInput.value.trim().length > 0);
        actualizarBoton();
    });
    passInput.addEventListener('input', () => {
        passInput.classList.toggle('filled', passInput.value.length > 0);
        actualizarBoton();
    });

    // Shake al error
    document.addEventListener('loginError', () => {
        userInput.classList.add('error-field');
        passInput.classList.add('error-field');
        setTimeout(() => {
            userInput.classList.remove('error-field');
            passInput.classList.remove('error-field');
        }, 600);
    });

    actualizarBoton();
}

// Disparar el evento de error desde el login
const _iniciarSesionOriginal = window.iniciarSesion;
window.iniciarSesion = async function() {
    const userInput = document.getElementById('login-user');
    const passInput = document.getElementById('login-pass');
    const btnLogin  = document.querySelector('.btn-login');
    if (btnLogin) { btnLogin.classList.add('loading'); }
    try {
        const r = await api('POST', '/auth/login', {
            nombre_usuario: userInput?.value?.trim(),
            contrasena_usuario: passInput?.value
        });
        if (r.ok) {
            usuarioActual = r.usuario;
            mostrarApp();
            showToast(`Bienvenido, ${usuarioActual.nombre}`, 'success');
        } else {
            document.dispatchEvent(new Event('loginError'));
            showToast(r.msg, 'error');
        }
    } catch(e) {
        showToast('Error de conexión', 'error');
    } finally {
        if (btnLogin) btnLogin.classList.remove('loading');
    }
};

// ─── RF-47: Ver datos completos del usuario en sesión ─────────
function mostrarPerfilUsuario() {
    if (!usuarioActual) return;
    const u = usuarioActual;
    mostrarModal('Mi Perfil',
        `<div style="display:grid;gap:.5rem">
            ${[
                ['Usuario',    u.nombre_usuario],
                ['Nombre',     `${u.nombre||''} ${u.apellido||''}`],
                ['Rol',        u.roles],
                ['Estado',     'Activo'],
            ].map(([k,v])=>`<div style="display:flex;justify-content:space-between;padding:.5rem 0;border-bottom:1px solid rgba(255,255,255,.07)">
                <span style="opacity:.6">${k}</span><strong>${v||'—'}</strong></div>`).join('')}
        </div>`,
        () => document.getElementById('modal-overlay')?.remove()
    );
    document.getElementById('btn-modal-guardar').textContent = 'Cerrar';
}

// ─── RF-48: Filtros de inventario ─────────────────────────────
function renderFiltrosInventario(categorias, marcas, modelos) {
    const opCat = `<option value="">Todas las categorías</option>` +
        categorias.map(c=>`<option value="${c.nombre}">${c.nombre}</option>`).join('');
    const opMar = `<option value="">Todas las marcas</option>` +
        marcas.map(m=>`<option value="${m.nombre}">${m.nombre}</option>`).join('');
    const opEst = `<option value="">Todos los estados</option>
        <option>Operativo</option><option>En Reparacion</option>
        <option>No operativo</option><option>Dañado</option>`;
    return `<div class="filtros-bar">
        <i class="fas fa-filter" style="opacity:.5"></i>
        <select id="fil-categoria" class="form-control" style="min-width:140px">${opCat}</select>
        <select id="fil-marca"     class="form-control" style="min-width:130px">${opMar}</select>
        <select id="fil-estado"    class="form-control" style="min-width:140px">${opEst}</select>
        <input type="text" id="fil-serial" placeholder="Serial..." style="min-width:120px;padding:.4rem .75rem;border-radius:8px;border:1px solid var(--glass-border);background:var(--bg-surface);color:var(--text-primary);font-size:.82rem">
        <button class="btn-filtrar" onclick="aplicarFiltroInventario()"><i class="fas fa-search"></i> Filtrar</button>
        <button class="btn-limpiar" onclick="limpiarFiltroInventario()"><i class="fas fa-times"></i></button>
    </div>`;
}

async function aplicarFiltroInventario() {
    const categoria = document.getElementById('fil-categoria')?.value || '';
    const marca     = document.getElementById('fil-marca')?.value     || '';
    const estado    = document.getElementById('fil-estado')?.value    || '';
    const serial    = document.getElementById('fil-serial')?.value    || '';
    const params    = new URLSearchParams({ categoria, marca, estado }).toString();
    const r         = await api('GET', `/inventario/filtrar?${params}`);
    if (!r.ok) return showToast(r.msg, 'error');
    const tbody = document.querySelector('#tabla-inventario tbody');
    if (!tbody) return;
    tbody.innerHTML = r.inventario.map(i => {
        const cls = i.estado==='Operativo'?'success':i.estado==='En Reparacion'?'warning':'danger';
        return `<tr>
            <td><code>${i.serial}</code></td>
            <td>${i.equipo_nombre||'N/A'} <span style="opacity:.5">${i.modelo_nombre||''}</span></td>
            <td>${(i.ubicacion_nombre||'N/A').split(' - ').pop()}</td>
            <td>${i.categoria||'—'}</td>
            <td>${i.marca||'—'}</td>
            <td><span class="status-badge ${cls}">${i.estado}</span></td>
            <td>—</td>
        </tr>`;
    }).join('') || '<tr><td colspan="7" class="empty-state">Sin resultados</td></tr>';
    showToast(`${r.inventario.length} equipos encontrados`, 'success');
}
function limpiarFiltroInventario() {
    ['fil-categoria','fil-marca','fil-estado','fil-serial'].forEach(id => {
        const el = document.getElementById(id); if (el) el.value = '';
    });
    aplicarFiltroInventario();
}

// ─── RF-49: Filtros de solicitudes ────────────────────────────
function renderFiltrosSolicitudes(actividades) {
    const opAct = `<option value="">Todas las actividades</option>` +
        actividades.map(a=>`<option value="${a.id_actividad}">${a.nombre}</option>`).join('');
    const opEst = `<option value="">Todos los estados</option>
        <option>Pendiente</option><option>Aprobado</option>
        <option>Cancelado</option><option>Completado</option>`;
    return `<div class="filtros-bar">
        <i class="fas fa-filter" style="opacity:.5"></i>
        <input type="date" id="fil-sol-desde" title="Desde" style="min-width:130px;padding:.4rem .75rem;border-radius:8px;border:1px solid var(--glass-border);background:var(--bg-surface);color:var(--text-primary);font-size:.82rem">
        <input type="date" id="fil-sol-hasta" title="Hasta" style="min-width:130px;padding:.4rem .75rem;border-radius:8px;border:1px solid var(--glass-border);background:var(--bg-surface);color:var(--text-primary);font-size:.82rem">
        <select id="fil-sol-actividad" style="min-width:150px">${opAct}</select>
        <select id="fil-sol-estado"    style="min-width:130px">${opEst}</select>
        <button class="btn-filtrar" onclick="aplicarFiltroSolicitudes()"><i class="fas fa-search"></i> Filtrar</button>
        <button class="btn-limpiar" onclick="limpiarFiltroSolicitudes()"><i class="fas fa-times"></i></button>
    </div>`;
}
async function aplicarFiltroSolicitudes() {
    const fecha_inicio  = document.getElementById('fil-sol-desde')?.value     || '';
    const fecha_fin     = document.getElementById('fil-sol-hasta')?.value     || '';
    const id_actividad  = document.getElementById('fil-sol-actividad')?.value || '';
    const estado        = document.getElementById('fil-sol-estado')?.value    || '';
    const params = new URLSearchParams({ fecha_inicio, fecha_fin, id_actividad, estado }).toString();
    const r = await api('GET', `/solicitudes/filtrar?${params}`);
    if (!r.ok) return showToast(r.msg, 'error');
    const tbody = document.querySelector('#tabla-solicitudes tbody');
    if (!tbody) return;
    tbody.innerHTML = r.solicitudes.map(s => {
        const cls = s.estado==='Aprobado'?'success':s.estado==='Cancelado'?'danger':s.estado==='Completado'?'info':'warning';
        return `<tr>
            <td>${s.id_solicitud}</td>
            <td>${s.persona_nombre||''} ${s.persona_apellido||''}</td>
            <td>${s.espacio_nombre||'N/A'}</td>
            <td>${s.actividad_nombre||'N/A'}</td>
            <td>${new Date(s.fecha).toLocaleDateString('es-ES')}</td>
            <td>${String(s.hora_inicio).slice(0,5)} - ${String(s.hora_fin).slice(0,5)}</td>
            <td>—</td>
            <td><span class="status-badge ${cls}">${s.estado}</span></td>
            <td>—</td>
        </tr>`;
    }).join('') || '<tr><td colspan="9" class="empty-state">Sin resultados</td></tr>';
    showToast(`${r.solicitudes.length} solicitudes encontradas`, 'success');
}
function limpiarFiltroSolicitudes() {
    ['fil-sol-desde','fil-sol-hasta','fil-sol-actividad','fil-sol-estado'].forEach(id => {
        const el = document.getElementById(id); if (el) el.value = '';
    });
    renderSolicitudes();
}

// ─── RF-53: Autocompletar serial en formulario inventario ──────
async function autoGenerarSerial() {
    const id_cat = document.getElementById('eq-categoria')?.value ||
                   document.getElementById('inv-equipo')?.value;
    if (!id_cat) return;
    const r = await api('GET', `/inventario/generar-serial?id_categoria=${id_cat}`);
    if (!r.ok) return;
    const serialInput = document.getElementById('inv-serial');
    if (serialInput) {
        serialInput.value = r.serial;
        serialInput.classList.add('filled');
        let badge = document.getElementById('serial-badge');
        if (!badge) {
            badge = document.createElement('div');
            badge.id = 'serial-badge';
            badge.className = 'serial-auto-badge';
            serialInput.parentElement.after(badge);
        }
        badge.innerHTML = `<i class="fas fa-magic"></i> Serial generado automáticamente: <strong>${r.serial}</strong>`;
    }
}

// ─── RF-56: Modal confirmar estado al finalizar reserva ────────
async function finalizarReservaConEstado(id) {
    const overlay = document.createElement('div');
    overlay.className = 'modal-estado-equipo';
    overlay.id = 'modal-rf56';
    overlay.innerHTML = `
        <div class="inner">
            <h3 style="margin:0 0 .5rem"><i class="fas fa-clipboard-check" style="margin-right:.5rem;color:#4F46E5"></i>Finalizar Reserva</h3>
            <p style="color:var(--text-secondary);font-size:.9rem;margin-bottom:1rem">
                Antes de finalizar, indica el estado en el que quedaron los equipos:
            </p>
            <div class="estado-opciones">
                <button class="btn-estado bueno" onclick="confirmarFinalizacion(${id},'Operativo')">
                    <i class="fas fa-check-circle fa-lg"></i>
                    <span>Buen estado</span>
                    <small style="font-weight:400;font-size:.75rem">Sin novedades</small>
                </button>
                <button class="btn-estado fallas" onclick="confirmarFinalizacion(${id},'falla')">
                    <i class="fas fa-exclamation-triangle fa-lg"></i>
                    <span>Con fallas</span>
                    <small style="font-weight:400;font-size:.75rem">Derivar a mantenimiento</small>
                </button>
            </div>
            <button onclick="document.getElementById('modal-rf56').remove()" style="width:100%;padding:.6rem;border-radius:8px;background:none;border:1px solid var(--glass-border);color:var(--text-secondary);cursor:pointer;font-size:.85rem">
                Cancelar
            </button>
        </div>`;
    document.body.appendChild(overlay);
}

async function confirmarFinalizacion(id_reserva, estadoEquipo) {
    document.getElementById('modal-rf56')?.remove();
    // Finalizar la reserva
    const r = await api('PUT', `/reservas/${id_reserva}/finalizar`);
    if (!r.ok) return showToast(r.msg, 'error');

    if (estadoEquipo === 'falla') {
        // RF-56: derivar automáticamente a mantenimiento
        const detalle = await api('GET', `/solicitudes/${id_reserva}/detalle`);
        if (detalle.ok && detalle.equipos.length > 0) {
            // Mostrar modal para seleccionar técnico y descripción
            const tecRes = await api('GET', '/tecnicos');
            const opTec  = (tecRes.tecnicos || []).map(t =>
                `<option value="${t.id_tecnicos}">${t.nombre} ${t.apellido}</option>`).join('');
            mostrarModal('Reportar falla detectada al finalizar',
                `<p style="color:var(--text-secondary);font-size:.85rem;margin-bottom:1rem">
                    Se encontraron fallas en los equipos. Se creará un reporte de mantenimiento automáticamente.
                </p>
                <div class="form-group"><label>Equipo con falla</label>
                    <select id="rf56-equipo" class="form-control">
                        ${detalle.equipos.map(e=>`<option value="${e.id_equipos}">${e.equipo_nombre} — ${e.serial}</option>`).join('')}
                    </select>
                </div>
                <div class="form-group"><label>Técnico</label>
                    <select id="rf56-tecnico" class="form-control">${opTec}</select>
                </div>
                <div class="form-group"><label>Descripción de la falla</label>
                    <input type="text" id="rf56-desc" class="form-control" placeholder="Describa el problema encontrado">
                </div>`,
                async () => {
                    const r2 = await api('POST', '/mantenimiento', {
                        id_equipos:       document.getElementById('rf56-equipo')?.value,
                        id_tecnicos:      document.getElementById('rf56-tecnico')?.value,
                        nivel_prioridad:  'Alta',
                        descripcion_fallas: document.getElementById('rf56-desc')?.value || 'Falla detectada al finalizar reserva'
                    });
                    document.getElementById('modal-overlay')?.remove();
                    if (r2.ok) showToast('Reserva finalizada y falla reportada a mantenimiento ✅', 'success');
                    else showToast(r2.msg, 'error');
                    renderReservas();
                }
            );
        }
    } else {
        showToast('Reserva finalizada. Equipos en buen estado ✅', 'success');
        if (typeof renderReservas === 'function') renderReservas();
    }
}

// ─── RF-58: Validación en tiempo real en formularios ──────────
function initValidacionesFormularios() {
    document.addEventListener('input', e => {
        const el = e.target;
        const id = el.id;

        // Cédula
        if (id === 'per-cedula' || id === 'est-cedula') {
            const ok = /^[VEve]-?\d{6,8}$/.test(el.value.trim());
            el.style.borderColor = el.value ? (ok ? '#10B981' : '#EF4444') : '';
            let hint = el.parentElement.querySelector('.field-hint');
            if (!hint) {
                hint = document.createElement('p');
                hint.className = 'field-hint';
                hint.style.cssText = 'font-size:.73rem;margin-top:.25rem';
                el.parentElement.appendChild(hint);
            }
            hint.textContent = el.value && !ok ? '⚠ Formato: V-12345678 o E-12345678' : '';
            hint.style.color = '#EF4444';
        }

        // Teléfono
        if (id === 'per-telefono' || id === 'est-telefono') {
            const clean = el.value.replace(/-/g,'');
            const ok = /^(0412|0414|0416|0424|0426|0212)\d{7}$/.test(clean);
            el.style.borderColor = el.value ? (ok ? '#10B981' : '#EF4444') : '';
        }

        // Correo
        if (id === 'usr-email') {
            const ok = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(el.value.trim());
            el.style.borderColor = el.value ? (ok ? '#10B981' : '#EF4444') : '';
        }
    });
}

// ─── EXPONER GLOBALES ─────────────────────────────────────────
Object.assign(window, {
    mostrarPerfilUsuario,
    aplicarFiltroInventario, limpiarFiltroInventario,
    aplicarFiltroSolicitudes, limpiarFiltroSolicitudes,
    autoGenerarSerial,
    finalizarReservaConEstado, confirmarFinalizacion,
});

// ─── INICIALIZAR ──────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    initLoginInteractivo();
    initValidacionesFormularios();
});
// También inicializar si el DOM ya cargó
if (document.readyState !== 'loading') {
    initLoginInteractivo();
    initValidacionesFormularios();
}
