USE db_cbit_manager_definitivo;

-- Ubicaciones
INSERT IGNORE INTO ubicacion_fisica (nombre) VALUES
('CBIT Francisco de Miranda - Laboratorio 1'),
('CBIT Francisco de Miranda - Laboratorio 2'),
('CBIT Francisco de Miranda - Sala de Servidores'),
('CBIT Francisco de Miranda - Aula de Clases');

-- Categorías
INSERT IGNORE INTO categoria (nombre) VALUES
('Computadora'), ('Impresora'), ('Proyector'), ('Tablet'), ('Router'), ('Switch');

-- Marcas
INSERT IGNORE INTO marca (nombre) VALUES
('HP'), ('Dell'), ('Lenovo'), ('Epson'), ('Samsung');

-- Modelos
INSERT IGNORE INTO modelo (nombre) VALUES
('OptiPlex 3080'), ('Latitude 3420'), ('LaserJet M404dn'), ('PowerLite 1785W'), ('Tab M10');

-- Equipos
INSERT IGNORE INTO equipos (nombre, id_categoria, id_marca, id_modelo) VALUES
('Computadora Escritorio',  1, 2, 1),
('Laptop Educativa',        1, 2, 2),
('Impresora Laser',         2, 1, 3),
('Proyector Multimedia',    3, 4, 4),
('Tablet Educativa',        4, 5, 5);

-- Inventario
INSERT IGNORE INTO inventario (id_equipos, id_ubicacion_fisica, serial, estado) VALUES
(1, 1, 'DL-OPT-2024-001', 'Operativo'),
(1, 2, 'DL-OPT-2024-002', 'Operativo'),
(2, 1, 'DL-LAT-3420-001', 'Operativo'),
(2, 3, 'DL-LAT-3420-002', 'En Reparacion'),
(3, 4, 'HP-LJ-404-001',   'Operativo'),
(4, 3, 'EP-PL-1785-001',  'Operativo');

-- Actividades
INSERT IGNORE INTO actividad (nombre, descripcion_actividad) VALUES
('Clase de Informática',       'Enseñanza básica de computación'),
('Taller de Programación',     'Introducción a la programación'),
('Mantenimiento Preventivo',   'Revisión y limpieza de equipos'),
('Curso de Ofimática',         'Microsoft Office y herramientas básicas');

-- Espacios
INSERT IGNORE INTO espacio (nombre, capacidad) VALUES
('CBIT Francisco de Miranda - Laboratorio 1', 30),
('CBIT Francisco de Miranda - Laboratorio 2', 25);

-- Personas
INSERT IGNORE INTO persona (nombre, apellido, cedula, telefono) VALUES
('Jose',   'Paez',       'V-31394077', '0412-1234567'),
('Maria',  'Gonzalez',   'V-87654321', '0414-7654321'),
('Carlos', 'Rodriguez',  'V-12345678', '0424-1234567');

-- Usuarios (admin / admin123)
INSERT IGNORE INTO usuario (id_persona, nombre_usuario, contrasena_usuario, correo, estado, roles) VALUES
(1, 'admin',    'admin123',   'admin@cbit.com',   'Activo', 'Administrador'),
(2, 'docente1', 'docente123', 'docente@cbit.com', 'Activo', 'Docente');

-- Técnico
INSERT IGNORE INTO tecnicos (id_persona, especialidad) VALUES
(3, 'Hardware');
