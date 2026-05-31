const express = require('express');
const router = express.Router();

const AuthController        = require('../app/controllers/AuthController');
const DashboardController   = require('../app/controllers/DashboardController');
const CategoriaController   = require('../app/controllers/CategoriaController');
const MarcaController       = require('../app/controllers/MarcaController');
const EquiposController     = require('../app/controllers/EquiposController');
const InventarioController  = require('../app/controllers/InventarioController');
const ActividadController   = require('../app/controllers/ActividadController');
const SolicitudesController = require('../app/controllers/SolicitudesController');
const ReservasController    = require('../app/controllers/ReservasController');
const MantenimientoController = require('../app/controllers/MantenimientoController');
const TecnicosController    = require('../app/controllers/TecnicosController');
const AsistenciaController  = require('../app/controllers/AsistenciaController');
const UsuariosController    = require('../app/controllers/UsuariosController');
const PersonaController     = require('../app/controllers/PersonaController');
const EspaciosController    = require('../app/controllers/EspaciosController');
const ReportesController    = require('../app/controllers/ReportesController');

function auth(req, res, next) {
    if (req.session && req.session.usuario) return next();
    res.status(401).json({ ok: false, msg: 'No autenticado' });
}
function adminOnly(req, res, next) {
    if (req.session?.usuario?.roles === 'Administrador') return next();
    res.status(403).json({ ok: false, msg: 'Solo administradores' });
}

// Auth
router.post('/auth/login',     AuthController.login);
router.post('/auth/logout',    AuthController.logout);
router.post('/auth/recuperar', AuthController.recuperar);
router.get('/auth/sesion',     AuthController.sesionActual);

// Dashboard
router.get('/dashboard/stats', auth, DashboardController.stats);

// Categorías
router.get('/categorias',         auth, CategoriaController.listar);
router.post('/categorias',        auth, CategoriaController.crear);
router.put('/categorias/:id',     auth, CategoriaController.actualizar);
router.delete('/categorias/:id',  auth, adminOnly, CategoriaController.eliminar);

// Marcas
router.get('/marcas',         auth, MarcaController.listar);
router.post('/marcas',        auth, MarcaController.crear);
router.put('/marcas/:id',     auth, MarcaController.actualizar);
router.delete('/marcas/:id',  auth, adminOnly, MarcaController.eliminar);

// Equipos
router.get('/equipos',         auth, EquiposController.listar);
router.post('/equipos',        auth, EquiposController.crear);
router.put('/equipos/:id',     auth, EquiposController.actualizar);
router.delete('/equipos/:id',  auth, adminOnly, EquiposController.eliminar);

// Inventario
router.get('/inventario',         auth, InventarioController.listar);
router.post('/inventario',        auth, InventarioController.crear);
router.put('/inventario/:id',     auth, InventarioController.actualizar);
router.delete('/inventario/:id',  auth, adminOnly, InventarioController.eliminar);

// Actividades
router.get('/actividades',         auth, ActividadController.listar);
router.post('/actividades',        auth, ActividadController.crear);
router.put('/actividades/:id',     auth, ActividadController.actualizar);
router.delete('/actividades/:id',  auth, adminOnly, ActividadController.eliminar);

// Solicitudes
router.get('/solicitudes',                  auth, SolicitudesController.listar);
router.get('/solicitudes/equipos-disponibles', auth, SolicitudesController.equiposDisponibles);
router.get('/solicitudes/:id/detalle',      auth, SolicitudesController.detalle);
router.post('/solicitudes',                 auth, SolicitudesController.crear);
router.put('/solicitudes/:id',              auth, SolicitudesController.actualizar);
router.put('/solicitudes/:id/aprobar',      auth, adminOnly, SolicitudesController.aprobar);
router.put('/solicitudes/:id/cancelar',     auth, SolicitudesController.cancelar);
router.delete('/solicitudes/:id',           auth, SolicitudesController.eliminar);
router.get('/calendario',                   auth, SolicitudesController.calendario);

// Reservas
router.get('/reservas',                 auth, ReservasController.listar);
router.put('/reservas/:id/finalizar',   auth, ReservasController.finalizar);

// Mantenimiento
router.get('/mantenimiento',          auth, MantenimientoController.listar);
router.post('/mantenimiento',         auth, MantenimientoController.crear);
router.delete('/mantenimiento/:id',   auth, adminOnly, MantenimientoController.eliminar);

// Técnicos
router.get('/tecnicos',         auth, TecnicosController.listar);
router.post('/tecnicos',        auth, TecnicosController.crear);
router.put('/tecnicos/:id',     auth, TecnicosController.actualizar);
router.delete('/tecnicos/:id',  auth, adminOnly, TecnicosController.eliminar);

// Asistencia
router.get('/asistencias',                   auth, AsistenciaController.listar);
router.post('/asistencias',                  auth, AsistenciaController.crear);
router.post('/asistencias/registrar-estudiante', auth, AsistenciaController.registrarEstudiante);
router.delete('/asistencias/:id',            auth, AsistenciaController.eliminar);

// Usuarios
router.get('/usuarios',                 auth, adminOnly, UsuariosController.listar);
router.post('/usuarios',                auth, adminOnly, UsuariosController.crear);
router.put('/usuarios/:id',             auth, adminOnly, UsuariosController.actualizar);
router.put('/usuarios/:id/inhabilitar', auth, adminOnly, UsuariosController.inhabilitar);
router.put('/usuarios/:id/activar',     auth, adminOnly, UsuariosController.activar);

// Personas
router.get('/personas',         auth, PersonaController.listar);
router.post('/personas',        auth, PersonaController.crear);
router.put('/personas/:id',     auth, PersonaController.actualizar);
router.delete('/personas/:id',  auth, adminOnly, PersonaController.eliminar);

// Espacios (solo lectura para docentes, admin puede editar)
router.get('/espacios',         auth, EspaciosController.listar);
router.post('/espacios',        auth, adminOnly, EspaciosController.crear);
router.put('/espacios/:id',     auth, adminOnly, EspaciosController.actualizar);
router.delete('/espacios/:id',  auth, adminOnly, EspaciosController.eliminar);

// Reportes — todos los endpoints
router.get('/reportes/resumen',           auth, ReportesController.resumenGeneral);
router.get('/reportes/disponibilidad',    auth, ReportesController.disponibilidadEquipos);
router.get('/reportes/usuarios',          auth, adminOnly, ReportesController.usuariosGeneral);
router.get('/reportes/equipos',           auth, ReportesController.equiposTecnologicos);
router.get('/reportes/reservas-equipos',  auth, ReportesController.reservasEquipos);
router.get('/reportes/reservas-espacios', auth, ReportesController.reservasEspacios);
router.get('/reportes/actividades',       auth, ReportesController.actividadesEducativas);
router.get('/reportes/fallas',            auth, ReportesController.fallasTecnicas);
router.get('/reportes/mantenimiento',     auth, ReportesController.mantenimientoEquipos);
router.get('/reportes/maquinas-usadas',   auth, ReportesController.maquinasMasUsadas);

module.exports = router;
