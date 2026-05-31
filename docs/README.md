# CBIT Manager — Sistema Integral de Gestión

## Tecnologías
- **Backend:** Node.js + Express.js
- **Base de datos:** MySQL (db_cbit_manager_definitivo)
- **Frontend:** HTML5 + CSS3 + JavaScript (Vanilla)
- **Patrón:** MVC (Model-View-Controller)

## Estructura del proyecto
```
cbit_manager/
├── server.js                      ← Punto de entrada
├── package.json
├── .env.example
├── config/
│   ├── database.js                ← Pool de conexiones MySQL
│   └── app.js                     ← Configuración general
├── app/
│   ├── models/                    ← Acceso a BD (una clase por tabla)
│   │   ├── Usuario.js
│   │   ├── Persona.js
│   │   ├── Categoria.js
│   │   ├── Marca.js
│   │   ├── Modelo.js
│   │   ├── Equipo.js
│   │   ├── UbicacionFisica.js
│   │   ├── Inventario.js
│   │   ├── Actividad.js
│   │   ├── Espacio.js
│   │   ├── Solicitud.js
│   │   ├── Tecnico.js
│   │   ├── Mantenimiento.js
│   │   ├── Asistencia.js
│   │   ├── Estudiante.js
│   │   ├── Horario.js
│   │   └── Notificacion.js
│   ├── controllers/               ← Lógica de negocio (uno por módulo)
│   │   ├── AuthController.js
│   │   ├── DashboardController.js
│   │   ├── CategoriaController.js
│   │   ├── MarcaController.js
│   │   ├── EquiposController.js
│   │   ├── InventarioController.js
│   │   ├── ActividadController.js
│   │   ├── SolicitudesController.js
│   │   ├── ReservasController.js
│   │   ├── MantenimientoController.js
│   │   ├── TecnicosController.js
│   │   ├── AsistenciaController.js
│   │   ├── UsuariosController.js
│   │   ├── PersonaController.js
│   │   ├── EspaciosController.js
│   │   └── ReportesController.js
│   ├── views/                     ← Plantillas HTML por módulo
│   └── helpers/
│       ├── formatters.js
│       └── validators.js
├── routes/
│   ├── api.js                     ← Todas las rutas REST /api/*
│   └── web.js                     ← Sirve el SPA (index.html)
├── public/
│   ├── index.html                 ← SPA principal (mismo diseño original)
│   ├── css/style.css              ← CSS original del proyecto
│   └── js/app.js                  ← Frontend que consume la API REST
└── database/
    ├── migrations/001_create_tables.sql
    └── seeders/seed_datos_iniciales.sql
```

## Instalación y puesta en marcha

### 1. Instalar dependencias
```bash
cd cbit_manager
npm install
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env
# Editar .env con tus credenciales de MySQL:
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=tu_contraseña
# DB_NAME=db_cbit_manager_definitivo
```

### 3. Crear la base de datos
```sql
-- En MySQL Workbench o consola:
SOURCE database/migrations/001_create_tables.sql;
SOURCE database/seeders/seed_datos_iniciales.sql;
```

### 4. Iniciar el servidor
```bash
npm start
# ó para desarrollo con auto-reload:
npm run dev
```

### 5. Abrir en el navegador
```
http://localhost:3000
```

## Credenciales de prueba
| Usuario   | Contraseña  | Rol           |
|-----------|-------------|---------------|
| admin     | admin123    | Administrador |
| docente1  | docente123  | Docente       |

## Arquitectura MVC

| Capa           | Archivo              | Responsabilidad                                  |
|----------------|----------------------|--------------------------------------------------|
| **Model**      | `app/models/*.js`    | SQL directo a MySQL; nunca toca la vista        |
| **Controller** | `app/controllers/*.js` | Recibe la petición HTTP, llama el modelo, responde JSON |
| **View**       | `public/js/app.js`   | Renderiza HTML dinámico y llama la API REST     |

## Flujo de datos
```
Navegador (View)
   │── fetch /api/...  ──▶  routes/api.js
                                │── Controller.metodo()
                                        │── Model.findAll() / create() / ...
                                               │── MySQL (db_cbit_manager_definitivo)
                                               └── resultado
                                        └── res.json({ ok, data })
   └── renderiza la tabla / formulario en pantalla
```
