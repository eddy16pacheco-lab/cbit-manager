# CBIT Manager — Registro de Cambios (v1.0.3 → v1.1.0)

## ⚠️ Paso obligatorio antes de desplegar
Ejecute la nueva migración sobre su base de datos existente (agrega la tabla del historial de actividades):

```
mysql -u usuario -p db_cbit_2 < database/migrations/003_historial_actividad.sql
```

No se modificó ninguna tabla existente, por lo que no hay riesgo de pérdida de datos.

---

## 1. Corrección del bug visual de los filtros de colores
**Archivo:** `public/js/app.js`

Las pestañas de navegación del módulo Reportes (Resumen, Usuarios, Equipos, Disponibilidad, etc.) usaban
texto blanco fijo (`color:#fff`) sobre un fondo semitransparente pensado solo para modo oscuro
(`rgba(255,255,255,.06)`). En modo claro el texto quedaba prácticamente invisible.

Se reemplazó por las variables de tema del sistema (`var(--text-primary)`, `var(--bg-main)`), por lo que
ahora las pestañas se ven correctamente tanto en modo claro como oscuro. Se corrigió tanto el render
inicial como el cambio de pestaña activa.

## 2. Validación de datos en todos los módulos
**Archivo nuevo:** `app/helpers/validators.js`

Se creó un set de validadores reutilizables (cédula, correo, teléfono, texto, longitud, fechas, números,
enums, códigos) y se aplicaron a los controladores de: Personas, Categorías, Marcas, Equipos, Inventario,
Actividades, Espacios, Mantenimiento, Técnicos, Usuarios, Asistencia, Solicitudes y Autenticación.

Reglas aplicadas: campos requeridos, formatos correctos, longitudes razonables, valores dentro de los ENUM
permitidos, referencias existentes (no se puede asociar a una categoría/marca/persona inexistente), y
verificación de duplicados (cédulas, seriales, nombres de categoría/marca, nombre de usuario, correo).
Si algún dato no cumple, la operación se rechaza con un mensaje claro y **no se inserta nada**.

## 3. Restricción de asistencia por rol (Docente)
**Archivo:** `app/controllers/AsistenciaController.js`

- Los usuarios con rol **Docente** ahora solo ven y registran la asistencia de los eventos/solicitudes que
  ellos mismos crearon (filtrado por `solicitud.id_usuario`).
- El **Administrador** sigue viendo la asistencia de todos los eventos.
- Se corrigió además un bug previo en `public/js/app.js`: el módulo "Asistencias" estaba oculto por
  completo para los docentes en el menú lateral. Ahora es visible, con los datos ya correctamente acotados
  por el backend.

## 4. Historial de Actividades del Sistema (solo Administrador)
**Archivos nuevos:**
- `database/migrations/003_historial_actividad.sql` — tabla `historial_actividad`
- `app/models/HistorialActividad.js`
- `app/helpers/auditLog.js`
- `app/middlewares/auditMiddleware.js` — registra automáticamente toda creación/edición/eliminación
  exitosa en cualquier módulo, sin necesidad de tocar cada controlador individualmente
- `app/controllers/HistorialController.js`

**Modificados:** `routes/api.js` (nueva ruta `GET /api/historial`, solo admin), `AuthController.js`
(registra inicio de sesión, cierre de sesión e intentos fallidos), `public/index.html` y `public/js/app.js`
(nuevo ítem de menú y vista "Historial de Actividades" con filtros por usuario, módulo y rango de fechas).

## 5. Manual de sistema dentro de la aplicación (ayuda por módulo)
**Archivos:** `public/index.html`, `public/js/app.js`

Se agregó un botón de ayuda flotante (ícono "?", esquina inferior derecha) visible en toda la aplicación.
Al presionarlo, muestra una ficha de ayuda contextual del módulo que se está usando en ese momento:
descripción, pasos de uso y consejos — para los 18 módulos del sistema — más un enlace directo al manual
completo en PDF.

## 6. Manual de usuario en PDF
**Archivo:** `public/manual-usuario-cbit-manager.pdf` (también entregado por separado)

Manual de 15 páginas con portada, tabla de contenido, explicación de roles, guía paso a paso de cada
módulo, tabla de reglas de validación de datos y preguntas frecuentes. Se sirve automáticamente desde el
propio sistema en `/manual-usuario-cbit-manager.pdf` (enlazado desde la ayuda contextual).

---

## 7. Actualización en tiempo real (sin recargar la página)
**Nueva dependencia:** `socket.io` (servidor) — se sirve automáticamente al cliente en `/socket.io/socket.io.js`, sin necesidad de configuración adicional.

**Archivos:** `server.js` (crea el servidor HTTP y adjunta Socket.IO), `app/middlewares/auditMiddleware.js`
(además de registrar el historial, ahora emite el evento `data:changed` a todos los clientes conectados
cada vez que una creación/edición/eliminación es exitosa), `public/index.html` (carga el script del
cliente), `public/js/app.js` (se conecta al socket al iniciar sesión, escucha `data:changed` y refresca en
silencio solo la vista relacionada con el módulo que cambió — sin recargar toda la página y sin interrumpir
a un usuario que esté completando un formulario en ese momento).

## 8. Sonido de notificación al modificar datos
**Archivo:** `public/js/app.js`

Se agregó un sonido corto (dos tonos, generado con la Web Audio API, sin archivos de audio externos que
descargar) que suena en el navegador de **todos** los usuarios conectados cada vez que alguien crea, edita
o elimina un registro en cualquier módulo. Si el cambio lo hizo otra persona, además aparece un aviso breve
indicando quién y en qué módulo.

## 9. Responsividad completa (computadoras, tablets y teléfonos)
**Archivos:** `public/css/responsive.css` (reescrito con reglas mobile-first), `public/index.html` (nuevo
botón de menú "hamburguesa" y overlay para el menú lateral), `public/js/app.js` (función `toggleSidebar()`
y cierre automático del menú al navegar en móvil).

Antes de este cambio, el sistema **no tenía forma de abrir el menú lateral en pantallas de celular**: quedaba
oculto fuera de la pantalla sin ningún botón para mostrarlo. También se corrigieron ventanas modales con un
ancho mínimo fijo (480px) que se salían de la pantalla en teléfonos, y se ajustaron tablas, tarjetas,
tipografía y botones para pantallas pequeñas (probado a nivel de reglas CSS en anchos de 1200px, 1024px,
768px, 480px y 360px).

## 10. Validación de teléfono contra números repetidos
`esTelefono()` en `app/helpers/validators.js` ahora rechaza números donde todos los dígitos son iguales
(ej. 7777777777, 0000000000), además de la validación existente de 7 a 15 dígitos. Aplica a Personas,
Estudiantes y cualquier otro módulo que registre teléfono.

## 11. Registro de estudiante asociado a una persona ya existente
El formulario de "Registrar Estudiante" (módulo Asistencia) ahora pregunta primero si la persona ya está
registrada en el sistema. Si es así, se selecciona de una lista (sin crear un registro de Persona
duplicado) y solo se completan año/sección. Si no, se registra una persona nueva como antes. Backend:
`AsistenciaController.registrarEstudiante` soporta ambos flujos; se agregó `Estudiante.findByPersona()`
para evitar que la misma persona quede registrada dos veces como estudiante.

## 12. Reporte de Asistencia ordenado por docente, con actividades realizadas
Nueva pestaña "Asistencia" en Reportes e Informes (`ReportesController.asistenciaReporte`, ruta
`GET /api/reportes/asistencia`). Muestra cada registro de asistencia con los datos del docente que creó
el evento, la actividad realizada, el espacio, el estudiante y si asistió — todo **ordenado por apellido y
nombre del docente**. Respeta el mismo control de acceso que el módulo de Asistencia: un docente solo ve
los registros de sus propios eventos; el administrador ve todos.

## 13. Límite de caracteres para nombres (3 a 40) en todos los módulos
Nuevos validadores en `app/helpers/validators.js`: `esNombrePersonaValido` (solo letras, para Personas y
Estudiantes) y `esNombreCatalogoValido` (letras, números y puntuación básica, para Categorías, Marcas,
Equipos, Modelos, Espacios y Actividades). Ambos exigen entre 3 y 40 caracteres. Se aplicaron en los
controladores de Persona, Categoría, Marca, Equipo, Espacio, Actividad y el nuevo módulo de Modelos.

## 14. Nuevo módulo: Modelos de Equipos
El catálogo de equipos ya permitía asociar un "modelo" (ej. "ProBook 450 G8"), pero no existía una pantalla
para administrarlos — solo la tabla en la base de datos. Se agregó:
- `app/models/Modelo.js` completado con `update`/`delete`/`findByNombre` (antes solo tenía `create`/`findAll`).
- `app/controllers/ModeloController.js` (CRUD completo con validación y verificación de duplicados/uso).
- Rutas `GET/POST/PUT/DELETE /api/modelos`.
- Pantalla nueva en el menú lateral ("Modelos", bajo Gestión de Equipos) con su propio formulario, tabla,
  buscador y ayuda contextual — igual que Categorías y Marcas.

## 15. Aviso de solicitudes duplicadas (misma fecha y horario)
Antes de crear una solicitud, el sistema ahora verifica si ya existe otra solicitud (en cualquier espacio,
no cancelada) con exactamente la misma fecha y el mismo horario. Si la encuentra, muestra una ventana de
confirmación indicando de qué solicitud se trata (actividad, espacio, docente) y pregunta si desea
continuar de todas formas — sin bloquear el registro, ya que podría ser intencional (ej. dos docentes en
espacios distintos a la misma hora). El bloqueo real (mismo espacio ya ocupado) se mantiene como error
estricto, sin excepción. Backend: `Solicitud.findSimilares()` + `SolicitudesController.crear` (parámetro
`confirmar_duplicado`); Frontend: `guardarSolicitud()` muestra el aviso y reenvía si el usuario confirma.

## 16. Acceso directo al Manual de Usuario
Se agregó un enlace fijo "Manual de Usuario (PDF)" en el menú lateral (visible para todos los roles, junto
a Reportes), que abre el PDF en una pestaña nueva sin depender del botón de ayuda flotante. Se revisó que
el archivo se sirve correctamente (`/manual-usuario-cbit-manager.pdf` responde 200) y se añadió `rel="noopener"`
a ambos enlaces del manual por buenas prácticas. Si el PDF sigue sin abrir en un dispositivo particular,
probablemente sea el navegador bloqueando la descarga o un visor de PDF no configurado en el teléfono, no
el enlace en sí.

## 17. Texto exacto en las notificaciones de inicio/cierre de sesión
Antes, cuando alguien iniciaba o cerraba sesión, el resto de usuarios conectados veía un aviso genérico
("X hizo una creación en Autenticación"). Ahora `AuthController` emite un evento de Socket.IO dedicado con
el texto exacto: **"nombre_apellido ha iniciado sesión"** y **"nombre_apellido ha finalizado su sesión"**,
que se muestra tal cual en el toast a todos los demás usuarios conectados (y sigue sonando la notificación).
Este aviso ya no se mezcla con las notificaciones de creación/edición/eliminación de otros módulos.

## Notas y recomendaciones para una futura revisión (fuera del alcance de esta solicitud)
- **Contraseñas en texto plano:** `Usuario.findByCredentials` compara `contrasena_usuario` sin cifrar,
  aunque el proyecto ya tiene `bcryptjs` como dependencia. Se recomienda migrar a hash de contraseñas en
  una próxima iteración (requiere script de migración para las cuentas ya existentes).
- No se pudo probar el arranque del servidor de punta a punta en este entorno por no contar con una
  instancia de MySQL disponible; toda la validación se hizo por revisión de código y chequeo de sintaxis
  (`node --check`) de cada archivo modificado.
