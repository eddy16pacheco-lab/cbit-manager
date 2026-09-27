# CBIT Manager — Sistema Integral de Gestión administrativa

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
<img width="1919" height="969" alt="modelos_dark" src="https://github.com/user-attachments/assets/2d6a2de4-6dea-4958-a967-4fea66a55390" />
<img width="1920" height="970" alt="modelos" src="https://github.com/user-attachments/assets/41461a04-4fe5-4c4c-bb87-fc7e3fe20b49" />
<img width="1920" height="972" alt="marcas" src="https://github.com/user-attachments/assets/977ad9df-1ce4-4b00-bdd9-5f97aad791d6" />
<img width="1920" height="972" alt="marca_dark" src="https://github.com/user-attachments/assets/39a32dfe-55de-4120-86b2-ab269c014e70" />
<img width="1920" height="972" alt="Historial_dark" src="https://github.com/user-attachments/assets/213b6352-25c2-41ac-ba95-7b4b8a1c3f69" />
<img width="1919" height="973" alt="HIstorial" src="https://github.com/user-attachments/assets/89020430-c390-4d37-882c-0f44bf306ea9" />
<img width="1920" height="972" alt="categorias" src="https://github.com/user-attachments/assets/a83e2ac6-d89f-40be-a97f-b4ef76648a9b" />
<img width="1917" height="972" alt="categoria_dark" src="https://github.com/user-attachments/assets/2efe22df-f9d2-45fa-ae1a-9b5df4cc7053" />
<img width="1920" height="973" alt="calendario_reserva" src="https://github.com/user-attachments/assets/fb8b345c-3a29-44e7-962d-5598c98275b5" />
<img width="1920" height="973" alt="calendario de reserva_dark" src="https://github.com/user-attachments/assets/118bffcb-6020-49f0-856e-ac4df7da9800" />
<img width="1920" height="971" alt="reportes_dark" src="https://github.com/user-attachments/assets/d3c88330-3d47-45db-b277-1cc1801cba7c" />
<img width="1919" height="973" alt="Reportes" src="https://github.com/user-attachments/assets/12bfd398-36d0-4003-852e-3ec28c02eec3" />
<img width="1919" height="973" alt="panel_principal_dark" src="https://github.com/user-attachments/assets/3a6bd14b-c2a8-4ad3-99c2-b48ff57de672" />
<img width="1920" height="970" alt="panel_principal" src="https://github.com/user-attachments/assets/7a143928-15e8-403f-a402-c8c543bba866" />

