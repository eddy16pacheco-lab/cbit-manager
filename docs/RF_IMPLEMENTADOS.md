# Requerimientos Funcionales Implementados

| RF   | Descripción                                                         | Dónde                                          | Status |
|------|---------------------------------------------------------------------|------------------------------------------------|--------|
| RF-47 | Consultar datos de usuario (nombre, rol, estado)                  | `rf_features.js` → `mostrarPerfilUsuario()`    | ✅ O   |
| RF-48 | Filtrar inventario por tipo, marca, modelo, estado, ubicación     | `Inventario.filtrar()` + barra filtros UI      | ✅ X→O |
| RF-49 | Filtrar solicitudes por usuario, fecha, tipo, estado              | `Solicitud.filtrar()` + barra filtros UI       | ✅ X→O |
| RF-50 | Filtrar historial mantenimiento por equipo, fecha, prioridad      | `Mantenimiento.filtrar()`                      | ✅ X→O |
| RF-51 | Validar superposición de reservas con detalle de conflicto        | `Solicitud.verificarSuperposicion()`           | ✅ O   |
| RF-52 | Calcular disponibilidad según reservas activas y estado           | `Inventario.disponibilidad()`                  | ✅ O   |
| RF-53 | Serial único automático TIPO-0001 al registrar equipo             | `Inventario.generarSerial()` + autocompletar   | ✅ O   |
| RF-54 | Al inhabilitar usuario, cancelar sus reservas activas             | `Usuario.inhabilitarConReservas()`             | ✅ O   |
| RF-55 | Docente solo puede reservar fechas futuras, máx 3 simultáneas     | `Solicitud.validarRestriccionesDocente()`      | ✅ O   |
| RF-56 | Al finalizar reserva, confirmar estado equipo → mantenimiento     | `finalizarReservaConEstado()` rf_features.js   | ✅ O   |
| RF-57 | Reportes automáticos diarios (23:00) y semanales (lunes 08:00)    | `app/helpers/scheduler.js`                     | ✅ O   |
| RF-58 | Validar formato cédula, teléfono, correo al registrar persona     | `validators.js` + validación tiempo real UI    | ✅ X→O |
