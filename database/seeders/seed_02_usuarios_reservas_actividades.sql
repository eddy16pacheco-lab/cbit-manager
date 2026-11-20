-- ============================================================================
--  CBIT MANAGER — SCRIPT 2 DE 2: USUARIOS, ESPACIOS, ACTIVIDADES, RESERVAS Y MÁS
--  Registra: personas, usuarios, técnicos, estudiantes, espacios, actividades,
--  horarios, solicitudes (reservas), equipos reservados, asistencia y
--  mantenimiento.
--
--  REQUISITOS
--    * Ejecutar PRIMERO el script 1 (catálogo e inventario): las reservas y los
--      mantenimientos usan esos equipos y sus códigos de Bienes Nacionales.
--    * Seleccionar la base de datos antes de ejecutar (HeidiSQL: clic sobre la base).
--
--  CARACTERÍSTICAS
--    * Las fechas son RELATIVAS a hoy (CURDATE): hay reservas pasadas (Completado,
--      Cancelado) y futuras (Aprobado, Pendiente), siempre en días hábiles.
--    * No hay dos reservas en el mismo espacio y fecha, ni un equipo reservado dos
--      veces cerca. Solo se reservan equipos Operativos.
--    * Se puede ejecutar más de una vez sin duplicar registros.
--
--  ACCESOS DE PRUEBA (el sistema guarda las contraseñas en texto plano):
--    Administrador:  coordcbit / admin123
--    Docentes:       cmendoza, lfernandez, jramirez, arojas, mperez, ytorres, rsalazar,
--                    gmarquez, hvillalobos, dcontreras  /  docente123
--    pquintero (Inactivo) y mochoa (Bloqueado) existen para probar esos estados.
-- ============================================================================
SET NAMES utf8mb4;

-- ── 1. Espacios (10) ─────────────────────────────────────────────────
INSERT IGNORE INTO espacio (nombre, capacidad) VALUES
('CBIT Francisco de Miranda - Laboratorio 1', 30),
('CBIT Francisco de Miranda - Laboratorio 2', 25),
('CBIT Francisco de Miranda - Laboratorio 3', 28),
('CBIT Francisco de Miranda - Laboratorio de Robótica', 20),
('CBIT Francisco de Miranda - Biblioteca Digital', 35),
('CBIT Francisco de Miranda - Sala de Videoconferencias', 15),
('CBIT Francisco de Miranda - Aula Magna', 80),
('CBIT Francisco de Miranda - Taller de Redes', 18),
('CBIT Francisco de Miranda - Aula de Clases', 40),
('CBIT Francisco de Miranda - Sala de Servidores', 6);

-- ── 2. Actividades (16) ──────────────────────────────────────────────
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Clase de Informática', 'Enseñanza básica de computación' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Clase de Informática');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Taller de Programación', 'Introducción a la programación' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Taller de Programación');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Mantenimiento Preventivo', 'Revisión y limpieza de equipos' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Mantenimiento Preventivo');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Curso de Ofimática', 'Microsoft Office y herramientas básicas' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Curso de Ofimática');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Taller de Robótica Educativa', 'Construcción y programación de robots con kits educativos' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Taller de Robótica Educativa');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Clase de Redes y Telecomunicaciones', 'Fundamentos de redes de datos y cableado estructurado' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Clase de Redes y Telecomunicaciones');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Jornada de Alfabetización Digital', 'Formación en herramientas digitales para la comunidad' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Jornada de Alfabetización Digital');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Evaluación de Competencias Digitales', 'Aplicación de pruebas prácticas de habilidades informáticas' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Evaluación de Competencias Digitales');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Taller de Diseño Gráfico', 'Creación de material gráfico y edición de imágenes' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Taller de Diseño Gráfico');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Charla de Seguridad Informática', 'Buenas prácticas de seguridad y uso responsable de la tecnología' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Charla de Seguridad Informática');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Curso de Hojas de Cálculo Avanzado', 'Fórmulas, tablas dinámicas y gráficos' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Curso de Hojas de Cálculo Avanzado');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Videoconferencia Institucional', 'Reuniones y encuentros virtuales con otras instituciones' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Videoconferencia Institucional');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Taller de Edición de Video', 'Grabación y edición de material audiovisual' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Taller de Edición de Video');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Clase de Bases de Datos', 'Modelado y consultas básicas' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Clase de Bases de Datos');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Feria de Ciencia y Tecnología', 'Exposición de proyectos tecnológicos estudiantiles' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Feria de Ciencia y Tecnología');
INSERT INTO actividad (nombre, descripcion_actividad) SELECT 'Capacitación Docente en TIC', 'Formación de docentes en el uso pedagógico de la tecnología' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM actividad WHERE nombre = 'Capacitación Docente en TIC');

-- ── 3. Horarios (12) ─────────────────────────────────────────────────
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Lunes', '07:00', '09:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Lunes' AND hora_inicio = '07:00' AND hora_final = '09:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Lunes', '09:00', '11:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Lunes' AND hora_inicio = '09:00' AND hora_final = '11:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Martes', '07:00', '09:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Martes' AND hora_inicio = '07:00' AND hora_final = '09:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Martes', '13:00', '15:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Martes' AND hora_inicio = '13:00' AND hora_final = '15:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Miercoles', '08:00', '10:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Miercoles' AND hora_inicio = '08:00' AND hora_final = '10:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Miercoles', '10:00', '12:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Miercoles' AND hora_inicio = '10:00' AND hora_final = '12:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Jueves', '07:00', '09:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Jueves' AND hora_inicio = '07:00' AND hora_final = '09:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Jueves', '14:00', '16:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Jueves' AND hora_inicio = '14:00' AND hora_final = '16:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Viernes', '08:00', '10:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Viernes' AND hora_inicio = '08:00' AND hora_final = '10:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Viernes', '10:00', '12:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Viernes' AND hora_inicio = '10:00' AND hora_final = '12:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Lunes', '13:00', '15:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Lunes' AND hora_inicio = '13:00' AND hora_final = '15:00');
INSERT INTO horario (dias, hora_inicio, hora_final) SELECT 'Jueves', '09:00', '11:00' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM horario WHERE dias = 'Jueves' AND hora_inicio = '09:00' AND hora_final = '11:00');

-- ── 4. Personas: 12 docentes, 1 administrador, 10 técnicos, 24 estudiantes ──
-- Cédula y teléfono cumplen los CHECK de la tabla (V-/E- + 7 u 8 dígitos; 0412/0414/0416/0422/0424/0426 + 7 dígitos).
INSERT IGNORE INTO persona (nombre, apellido, cedula, telefono) VALUES
('Carlos', 'Mendoza', 'V-20019455', '04246184138'),
('Luisa', 'Fernández', 'V-8415056', '04267188185'),
('José', 'Ramírez', 'V-14099226', '04228083634'),
('Andreína', 'Rojas', 'V-9521428', '04229362688'),
('Miguel Ángel', 'Pérez', 'V-9953672', '04229495290'),
('Yolanda', 'Torres', 'V-21464542', '04249238128'),
('Rafael', 'Salazar', 'V-14679821', '04245339316'),
('Gabriela', 'Márquez', 'V-15045862', '04249039473'),
('Héctor', 'Villalobos', 'V-16605863', '04241425740'),
('Daniela', 'Contreras', 'V-17655560', '04143164241'),
('Pedro', 'Quintero', 'V-21725980', '04129778116'),
('Mariana', 'Ochoa', 'V-19248839', '04128204296'),
('Ana Beatriz', 'Linares', 'V-12942984', '04149088515'),
('Ernesto', 'Rivas', 'V-26836195', '04143047042'),
('Karina', 'Delgado', 'V-22513786', '04268663770'),
('Oswaldo', 'Becerra', 'V-23312929', '04225211189'),
('Liliana', 'Pacheco', 'V-21391819', '04226161129'),
('Jonathan', 'Medina', 'V-21196406', '04269420478'),
('Verónica', 'Aguilar', 'V-23715925', '04227743569'),
('Armando', 'Colmenares', 'V-19265655', '04145938778'),
('Beatriz', 'Sandoval', 'V-25955992', '04161155640'),
('Freddy', 'Navarro', 'V-12555481', '04148687780'),
('Nelson', 'Paredes', 'V-25481280', '04249212741'),
('Valentina', 'Acosta', 'V-33019360', '04145363930'),
('Santiago', 'Brito', 'V-35810351', '04228829190'),
('Camila', 'Cedeño', 'V-34288816', '04228285161'),
('Mateo', 'Dugarte', 'V-34679484', '04261564049'),
('Sofía', 'Escalona', 'V-32433276', '04168678186'),
('Sebastián', 'Figueroa', 'V-30825220', '04229643174'),
('Isabella', 'Guerra', 'V-32171233', '04224071049'),
('Diego', 'Hernández', 'V-33571672', '04269038740'),
('Luciana', 'Idrogo', 'V-30539346', '04265470559'),
('Samuel', 'Jiménez', 'V-34181056', '04162621728'),
('Fabiana', 'Landaeta', 'V-31632310', '04267900650'),
('Daniel', 'Machado', 'V-31227745', '04221235427'),
('Antonella', 'Nieves', 'V-30773166', '04128570388'),
('Gabriel', 'Olivares', 'V-34870761', '04242393608'),
('Victoria', 'Peña', 'V-35118172', '04145158025'),
('Alejandro', 'Quiroz', 'V-31013502', '04241749254'),
('Mía', 'Reyes', 'V-34583943', '04166993671'),
('Emanuel', 'Silva', 'V-31298228', '04126258696'),
('Renata', 'Tovar', 'V-35574912', '04249254204'),
('Joaquín', 'Uzcátegui', 'V-35786097', '04263262652'),
('Paula', 'Vargas', 'V-34578532', '04148935346'),
('Adrián', 'Zambrano', 'V-34931952', '04149467819'),
('Nicole', 'Arias', 'V-32438401', '04128009167'),
('Bruno', 'Bastidas', 'V-35608244', '04143270731');

-- ── 5. Usuarios (13) ─────────────────────────────────────────────────
INSERT IGNORE INTO usuario (id_persona, nombre_usuario, contrasena_usuario, correo, estado, roles) VALUES
((SELECT id_persona FROM persona WHERE cedula = 'V-20019455'), 'cmendoza', 'docente123', 'carlos.mendoza@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-8415056'), 'lfernandez', 'docente123', 'luisa.fernandez@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-14099226'), 'jramirez', 'docente123', 'jose.ramirez@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-9521428'), 'arojas', 'docente123', 'andreina.rojas@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-9953672'), 'mperez', 'docente123', 'miguel.perez@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-21464542'), 'ytorres', 'docente123', 'yolanda.torres@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-14679821'), 'rsalazar', 'docente123', 'rafael.salazar@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-15045862'), 'gmarquez', 'docente123', 'gabriela.marquez@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-16605863'), 'hvillalobos', 'docente123', 'hector.villalobos@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-17655560'), 'dcontreras', 'docente123', 'daniela.contreras@cbit.edu.ve', 'Activo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-21725980'), 'pquintero', 'docente123', 'pedro.quintero@cbit.edu.ve', 'Inactivo', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-19248839'), 'mochoa', 'docente123', 'mariana.ochoa@cbit.edu.ve', 'Bloqueado', 'Docente'),
((SELECT id_persona FROM persona WHERE cedula = 'V-12942984'), 'coordcbit', 'admin123', 'ana.linares@cbit.edu.ve', 'Activo', 'Administrador');

-- ── 6. Técnicos (10) ─────────────────────────────────────────────────
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Hardware', id_persona FROM persona WHERE cedula = 'V-26836195' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Software', id_persona FROM persona WHERE cedula = 'V-22513786' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Redes', id_persona FROM persona WHERE cedula = 'V-23312929' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Seguridad', id_persona FROM persona WHERE cedula = 'V-21391819' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Soporte técnico', id_persona FROM persona WHERE cedula = 'V-21196406' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Recuperación de datos', id_persona FROM persona WHERE cedula = 'V-23715925' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Mantenimiento preventivo', id_persona FROM persona WHERE cedula = 'V-19265655' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Instalación de sistemas', id_persona FROM persona WHERE cedula = 'V-25955992' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'otros', id_persona FROM persona WHERE cedula = 'V-12555481' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);
INSERT INTO tecnicos (especialidad, id_persona) SELECT 'Hardware', id_persona FROM persona WHERE cedula = 'V-25481280' AND NOT EXISTS (SELECT 1 FROM tecnicos t WHERE t.id_persona = persona.id_persona);

-- ── 7. Estudiantes (24) ──────────────────────────────────────────────
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'A', '1er año' FROM persona WHERE cedula = 'V-33019360' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'B', '2er año' FROM persona WHERE cedula = 'V-35810351' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'C', '3er año' FROM persona WHERE cedula = 'V-34288816' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'D', '4er año' FROM persona WHERE cedula = 'V-34679484' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'U', '5er año' FROM persona WHERE cedula = 'V-32433276' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'A', '6er año' FROM persona WHERE cedula = 'V-30825220' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'B', '1er año' FROM persona WHERE cedula = 'V-32171233' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'C', '2er año' FROM persona WHERE cedula = 'V-33571672' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'D', '3er año' FROM persona WHERE cedula = 'V-30539346' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'U', '4er año' FROM persona WHERE cedula = 'V-34181056' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'A', '5er año' FROM persona WHERE cedula = 'V-31632310' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'B', '6er año' FROM persona WHERE cedula = 'V-31227745' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'C', '1er año' FROM persona WHERE cedula = 'V-30773166' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'D', '2er año' FROM persona WHERE cedula = 'V-34870761' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'U', '3er año' FROM persona WHERE cedula = 'V-35118172' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'A', '4er año' FROM persona WHERE cedula = 'V-31013502' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'B', '5er año' FROM persona WHERE cedula = 'V-34583943' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'C', '6er año' FROM persona WHERE cedula = 'V-31298228' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'D', '1er año' FROM persona WHERE cedula = 'V-35574912' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'U', '2er año' FROM persona WHERE cedula = 'V-35786097' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'A', '3er año' FROM persona WHERE cedula = 'V-34578532' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'B', '4er año' FROM persona WHERE cedula = 'V-34931952' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'C', '5er año' FROM persona WHERE cedula = 'V-32438401' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);
INSERT INTO estudiante (id_persona, seccion, `año`) SELECT id_persona, 'D', '6er año' FROM persona WHERE cedula = 'V-35608244' AND NOT EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = persona.id_persona);

-- ── 8. Reservas / solicitudes (36): Completado 14, Aprobado 10, Pendiente 8, Cancelado 4 ──
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -79 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -79 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '14:00', '16:00', 'Completado', 'Armado de cables UTP — 1er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Redes y Telecomunicaciones' JOIN usuario u ON u.nombre_usuario = 'rsalazar'
WHERE e.nombre = 'CBIT Francisco de Miranda - Taller de Redes' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Armado de cables UTP — 1er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -76 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -76 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '09:00', '11:00', 'Completado', 'Configuración de switch y VLAN — 1er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Redes y Telecomunicaciones' JOIN usuario u ON u.nombre_usuario = 'lfernandez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Taller de Redes' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Configuración de switch y VLAN — 1er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -73 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -73 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '07:00', '09:00', 'Completado', 'Retoque fotográfico básico — docentes del plantel'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Diseño Gráfico' JOIN usuario u ON u.nombre_usuario = 'ytorres'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Retoque fotográfico básico — docentes del plantel');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -62 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -62 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '10:00', '12:00', 'Completado', 'Evaluación final del trimestre — comunidad educativa'
FROM espacio e JOIN actividad a ON a.nombre = 'Evaluación de Competencias Digitales' JOIN usuario u ON u.nombre_usuario = 'lfernandez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Evaluación final del trimestre — comunidad educativa');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -61 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -61 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '14:00', '16:00', 'Completado', 'Jornada comunitaria de correo electrónico — docentes del plantel (sesión 28)'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'mochoa'
WHERE e.nombre = 'CBIT Francisco de Miranda - Biblioteca Digital' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — docentes del plantel (sesión 28)');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -59 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -59 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '07:00', '09:00', 'Completado', 'Diseño de afiches escolares — 3er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Diseño Gráfico' JOIN usuario u ON u.nombre_usuario = 'mperez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Diseño de afiches escolares — 3er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -49 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -49 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '15:00', '17:00', 'Completado', 'Jornada comunitaria de correo electrónico — 5er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'cmendoza'
WHERE e.nombre = 'CBIT Francisco de Miranda - Aula de Clases' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 5er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -45 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -45 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '09:00', '11:00', 'Completado', 'Evaluación final del trimestre — 5er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Evaluación de Competencias Digitales' JOIN usuario u ON u.nombre_usuario = 'lfernandez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 1' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Evaluación final del trimestre — 5er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -39 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -39 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '13:00', '15:00', 'Cancelado', 'Diseño de afiches escolares — 2er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Diseño Gráfico' JOIN usuario u ON u.nombre_usuario = 'pquintero'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 1' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Diseño de afiches escolares — 2er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -37 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -37 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '14:00', '16:00', 'Completado', 'Recursos educativos digitales — 6er año sección U'
FROM espacio e JOIN actividad a ON a.nombre = 'Capacitación Docente en TIC' JOIN usuario u ON u.nombre_usuario = 'jramirez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Aula de Clases' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Recursos educativos digitales — 6er año sección U');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -37 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -37 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '07:00', '09:00', 'Completado', 'Limpieza interna de computadoras — 2er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Mantenimiento Preventivo' JOIN usuario u ON u.nombre_usuario = 'ytorres'
WHERE e.nombre = 'CBIT Francisco de Miranda - Sala de Servidores' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Limpieza interna de computadoras — 2er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -29 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -29 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '10:00', '12:00', 'Completado', 'Modelo entidad-relación — 4er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Bases de Datos' JOIN usuario u ON u.nombre_usuario = 'dcontreras'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Modelo entidad-relación — 4er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -14 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -14 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '07:00', '09:00', 'Completado', 'Jornada comunitaria de correo electrónico — docentes del plantel'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'jramirez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Biblioteca Digital' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — docentes del plantel');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -10 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -10 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '14:00', '16:00', 'Completado', 'Prueba diagnóstica de competencias — 5er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Evaluación de Competencias Digitales' JOIN usuario u ON u.nombre_usuario = 'mperez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Prueba diagnóstica de competencias — 5er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL -9 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL -9 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '15:00', '17:00', 'Completado', 'Tablas dinámicas — 6er año sección U'
FROM espacio e JOIN actividad a ON a.nombre = 'Curso de Hojas de Cálculo Avanzado' JOIN usuario u ON u.nombre_usuario = 'rsalazar'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 1' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Tablas dinámicas — 6er año sección U');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 3 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 3 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '14:00', '16:00', 'Aprobado', 'Jornada comunitaria de correo electrónico — 2er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'mperez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Biblioteca Digital' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 2er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 3 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 3 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '13:00', '15:00', 'Pendiente', 'Retoque fotográfico básico — 3er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Diseño Gráfico' JOIN usuario u ON u.nombre_usuario = 'arojas'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 1' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Retoque fotográfico básico — 3er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 9 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 9 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '10:00', '12:00', 'Aprobado', 'Muestra de proyectos de robótica — 5er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Feria de Ciencia y Tecnología' JOIN usuario u ON u.nombre_usuario = 'mperez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Aula Magna' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Muestra de proyectos de robótica — 5er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 11 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 11 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '10:00', '12:00', 'Aprobado', 'Armado de robot seguidor de línea — docentes del plantel'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Robótica Educativa' JOIN usuario u ON u.nombre_usuario = 'arojas'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Armado de robot seguidor de línea — docentes del plantel');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 13 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 13 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '14:00', '16:00', 'Aprobado', 'Uso responsable de redes sociales — 3er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Charla de Seguridad Informática' JOIN usuario u ON u.nombre_usuario = 'arojas'
WHERE e.nombre = 'CBIT Francisco de Miranda - Aula de Clases' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Uso responsable de redes sociales — 3er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 13 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 13 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '15:00', '17:00', 'Pendiente', 'Prueba diagnóstica de competencias — 5er año sección D'
FROM espacio e JOIN actividad a ON a.nombre = 'Evaluación de Competencias Digitales' JOIN usuario u ON u.nombre_usuario = 'dcontreras'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Prueba diagnóstica de competencias — 5er año sección D');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 16 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 16 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '08:00', '10:00', 'Aprobado', 'Edición de video documental — docentes del plantel'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Edición de Video' JOIN usuario u ON u.nombre_usuario = 'ytorres'
WHERE e.nombre = 'CBIT Francisco de Miranda - Sala de Videoconferencias' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Edición de video documental — docentes del plantel');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 24 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 24 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '08:00', '10:00', 'Pendiente', 'Prueba diagnóstica de competencias — 1er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Evaluación de Competencias Digitales' JOIN usuario u ON u.nombre_usuario = 'mperez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Prueba diagnóstica de competencias — 1er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 25 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 25 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '08:00', '10:00', 'Aprobado', 'Limpieza interna de computadoras — 3er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Mantenimiento Preventivo' JOIN usuario u ON u.nombre_usuario = 'lfernandez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 1' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Limpieza interna de computadoras — 3er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 26 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 26 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '13:00', '15:00', 'Pendiente', 'Procesador de textos — 2er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Curso de Ofimática' JOIN usuario u ON u.nombre_usuario = 'jramirez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Biblioteca Digital' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Procesador de textos — 2er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 29 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 29 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '08:00', '10:00', 'Pendiente', 'Manejo de archivos y carpetas — 5er año sección D'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Informática' JOIN usuario u ON u.nombre_usuario = 'gmarquez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Manejo de archivos y carpetas — 5er año sección D');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 29 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 29 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '08:00', '10:00', 'Aprobado', 'Limpieza interna de computadoras — 2er año sección B (sesión 21)'
FROM espacio e JOIN actividad a ON a.nombre = 'Mantenimiento Preventivo' JOIN usuario u ON u.nombre_usuario = 'cmendoza'
WHERE e.nombre = 'CBIT Francisco de Miranda - Sala de Servidores' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Limpieza interna de computadoras — 2er año sección B (sesión 21)');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 31 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 31 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '15:00', '17:00', 'Cancelado', 'Direccionamiento IP — 2er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Redes y Telecomunicaciones' JOIN usuario u ON u.nombre_usuario = 'hvillalobos'
WHERE e.nombre = 'CBIT Francisco de Miranda - Taller de Redes' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Direccionamiento IP — 2er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 31 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 31 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '09:00', '11:00', 'Cancelado', 'Trámites en línea y servicios públicos — 2er año sección B'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'lfernandez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Biblioteca Digital' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Trámites en línea y servicios públicos — 2er año sección B');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 32 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 32 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '08:00', '10:00', 'Pendiente', 'Modelo entidad-relación — 3er año sección C'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Bases de Datos' JOIN usuario u ON u.nombre_usuario = 'hvillalobos'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Modelo entidad-relación — 3er año sección C');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 36 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 36 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '07:00', '09:00', 'Pendiente', 'Primeros pasos en Python — docentes del plantel'
FROM espacio e JOIN actividad a ON a.nombre = 'Taller de Programación' JOIN usuario u ON u.nombre_usuario = 'cmendoza'
WHERE e.nombre = 'CBIT Francisco de Miranda - Laboratorio 2' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Primeros pasos en Python — docentes del plantel');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 36 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 36 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '13:00', '15:00', 'Pendiente', 'Armado de cables UTP — docentes del plantel'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Redes y Telecomunicaciones' JOIN usuario u ON u.nombre_usuario = 'rsalazar'
WHERE e.nombre = 'CBIT Francisco de Miranda - Taller de Redes' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Armado de cables UTP — docentes del plantel');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 39 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 39 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '09:00', '11:00', 'Aprobado', 'Jornada comunitaria de correo electrónico — 3er año sección A'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'mperez'
WHERE e.nombre = 'CBIT Francisco de Miranda - Aula de Clases' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 3er año sección A');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 40 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 40 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '07:00', '09:00', 'Cancelado', 'Limpieza interna de computadoras — 6er año sección U'
FROM espacio e JOIN actividad a ON a.nombre = 'Mantenimiento Preventivo' JOIN usuario u ON u.nombre_usuario = 'hvillalobos'
WHERE e.nombre = 'CBIT Francisco de Miranda - Sala de Servidores' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Limpieza interna de computadoras — 6er año sección U');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 40 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 40 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '13:00', '15:00', 'Aprobado', 'Configuración de switch y VLAN — 1er año sección A (sesión 36)'
FROM espacio e JOIN actividad a ON a.nombre = 'Clase de Redes y Telecomunicaciones' JOIN usuario u ON u.nombre_usuario = 'rsalazar'
WHERE e.nombre = 'CBIT Francisco de Miranda - Taller de Redes' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Configuración de switch y VLAN — 1er año sección A (sesión 36)');
INSERT INTO solicitud (id_espacio, id_actividad, id_usuario, fecha, hora_inicio, hora_fin, estado, descripcion)
SELECT e.id_espacio, a.id_actividad, u.id_usuario, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 41 DAY), INTERVAL CASE DAYOFWEEK(DATE_ADD(CURDATE(), INTERVAL 41 DAY)) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END DAY), '10:00', '12:00', 'Aprobado', 'Jornada comunitaria de correo electrónico — 5er año sección D'
FROM espacio e JOIN actividad a ON a.nombre = 'Jornada de Alfabetización Digital' JOIN usuario u ON u.nombre_usuario = 'dcontreras'
WHERE e.nombre = 'CBIT Francisco de Miranda - Biblioteca Digital' AND NOT EXISTS (SELECT 1 FROM solicitud s WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 5er año sección D');

-- ── 9. Equipos asignados a cada reserva (detalle_solicitud) ────────────
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100341', '0100352', '0100393')
WHERE s.descripcion = 'Armado de cables UTP — 1er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100383', '0100316', '0100291', '0100334')
WHERE s.descripcion = 'Configuración de switch y VLAN — 1er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100446', '0100445', '0100455', '0100231', '0100360')
WHERE s.descripcion = 'Retoque fotográfico básico — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100279', '0100296', '0100250', '0100334', '0100371', '0100231')
WHERE s.descripcion = 'Evaluación final del trimestre — comunidad educativa' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100291', '0100303')
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — docentes del plantel (sesión 28)' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100250', '0100363', '0100371', '0100360')
WHERE s.descripcion = 'Diseño de afiches escolares — 3er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100270', '0100350', '0100265', '0100352')
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100231', '0100244', '0100270', '0100296')
WHERE s.descripcion = 'Evaluación final del trimestre — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100461', '0100371', '0100456', '0100445', '0100484', '0100260')
WHERE s.descripcion = 'Diseño de afiches escolares — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100341', '0100428', '0100296', '0100279', '0100353', '0100303')
WHERE s.descripcion = 'Recursos educativos digitales — 6er año sección U' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100455', '0100244', '0100370', '0100476', '0100231', '0100250')
WHERE s.descripcion = 'Limpieza interna de computadoras — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100270', '0100291', '0100352', '0100346', '0100275', '0100353')
WHERE s.descripcion = 'Modelo entidad-relación — 4er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100291', '0100316', '0100260', '0100484', '0100350')
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100353', '0100250', '0100296', '0100275', '0100359')
WHERE s.descripcion = 'Prueba diagnóstica de competencias — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100334', '0100303', '0100270', '0100360')
WHERE s.descripcion = 'Tablas dinámicas — 6er año sección U' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100286', '0100291', '0100334', '0100260', '0100446', '0100275')
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100363', '0100360', '0100371', '0100455', '0100456', '0100244')
WHERE s.descripcion = 'Retoque fotográfico básico — 3er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100478', '0100439', '0100260', '0100265')
WHERE s.descripcion = 'Muestra de proyectos de robótica — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100279', '0100291', '0100346', '0100446', '0100359')
WHERE s.descripcion = 'Armado de robot seguidor de línea — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100428')
WHERE s.descripcion = 'Uso responsable de redes sociales — 3er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100231', '0100370')
WHERE s.descripcion = 'Prueba diagnóstica de competencias — 5er año sección D' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100363', '0100455', '0100461', '0100244')
WHERE s.descripcion = 'Edición de video documental — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100363', '0100270', '0100291', '0100234', '0100350', '0100334')
WHERE s.descripcion = 'Prueba diagnóstica de competencias — 1er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100360', '0100231', '0100461', '0100476', '0100371', '0100370')
WHERE s.descripcion = 'Limpieza interna de computadoras — 3er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100303', '0100250')
WHERE s.descripcion = 'Procesador de textos — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100279', '0100244', '0100291', '0100360')
WHERE s.descripcion = 'Manejo de archivos y carpetas — 5er año sección D' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100234', '0100250', '0100461', '0100472')
WHERE s.descripcion = 'Limpieza interna de computadoras — 2er año sección B (sesión 21)' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100353', '0100270', '0100383', '0100286', '0100327', '0100402')
WHERE s.descripcion = 'Direccionamiento IP — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100303', '0100439', '0100265')
WHERE s.descripcion = 'Trámites en línea y servicios públicos — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100291', '0100334', '0100346')
WHERE s.descripcion = 'Modelo entidad-relación — 3er año sección C' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100286', '0100275', '0100234')
WHERE s.descripcion = 'Primeros pasos en Python — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100404', '0100291', '0100296', '0100316')
WHERE s.descripcion = 'Armado de cables UTP — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100291', '0100346', '0100439', '0100445', '0100484', '0100316')
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 3er año sección A' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100244', '0100461', '0100371', '0100370')
WHERE s.descripcion = 'Limpieza interna de computadoras — 6er año sección U' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100402', '0100279', '0100383', '0100404')
WHERE s.descripcion = 'Configuración de switch y VLAN — 1er año sección A (sesión 36)' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);
INSERT INTO detalle_solicitud (id_solicitud, id_inventario)
SELECT s.id_solicitud, i.id_inventario FROM solicitud s JOIN inventario i ON i.codigo_bien_nacional IN ('0100286', '0100258', '0100303', '0100352', '0100270')
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 5er año sección D' AND NOT EXISTS (SELECT 1 FROM detalle_solicitud d WHERE d.id_solicitud = s.id_solicitud AND d.id_inventario = i.id_inventario);

-- ── 10. Asistencia de estudiantes en las reservas completadas ──────────
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-31227745'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-34583943', 'V-34870761', 'V-30773166', 'V-35786097', 'V-31227745', 'V-33571672', 'V-31298228') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Armado de cables UTP — 1er año sección A' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-34870761'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-31013502', 'V-30825220', 'V-34870761', 'V-34583943', 'V-32171233', 'V-31227745', 'V-33019360') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Configuración de switch y VLAN — 1er año sección A' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-31632310', 'V-33571672'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-34870761', 'V-33571672', 'V-31632310', 'V-34181056') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Retoque fotográfico básico — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-32171233'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-35118172', 'V-34578532', 'V-34870761', 'V-34679484', 'V-32171233') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Evaluación final del trimestre — comunidad educativa' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-34931952'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-33571672', 'V-32433276', 'V-35118172', 'V-34931952', 'V-34679484', 'V-31298228') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — docentes del plantel (sesión 28)' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN (''), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-35118172', 'V-31013502', 'V-35810351', 'V-31227745') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Diseño de afiches escolares — 3er año sección A' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-34583943', 'V-32438401'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-30539346', 'V-32438401', 'V-31298228', 'V-34583943') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN (''), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-35786097', 'V-34181056', 'V-30539346', 'V-34870761', 'V-34679484') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Evaluación final del trimestre — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-34181056', 'V-35786097'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-31632310', 'V-34870761', 'V-35786097', 'V-35574912', 'V-34181056', 'V-33571672') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Recursos educativos digitales — 6er año sección U' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN (''), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-34181056', 'V-34870761', 'V-30539346', 'V-32171233', 'V-35574912', 'V-35118172', 'V-30825220') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Limpieza interna de computadoras — 2er año sección B' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN (''), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-32438401', 'V-31632310', 'V-34578532', 'V-34679484', 'V-35608244', 'V-30773166') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Modelo entidad-relación — 4er año sección A' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-34931952', 'V-30773166'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-34931952', 'V-35118172', 'V-35574912', 'V-31632310', 'V-35608244', 'V-30773166', 'V-31227745') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Jornada comunitaria de correo electrónico — docentes del plantel' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-32438401'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-35786097', 'V-33019360', 'V-32438401', 'V-34181056') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Prueba diagnóstica de competencias — 5er año sección B' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);
INSERT INTO asistencia (id_estudiante, id_solicitud, asistio)
SELECT est.id_estudiante, s.id_solicitud, IF(p.cedula IN ('V-34181056', 'V-30539346'), 'No', 'Si')
FROM solicitud s JOIN persona p ON p.cedula IN ('V-30539346', 'V-30773166', 'V-34181056', 'V-35608244', 'V-33019360', 'V-32171233', 'V-35574912') JOIN estudiante est ON est.id_persona = p.id_persona
WHERE s.descripcion = 'Tablas dinámicas — 6er año sección U' AND NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_estudiante = est.id_estudiante AND a.id_solicitud = s.id_solicitud);

-- ── 11. Mantenimiento (14 reportes) y equipos afectados ─────────────────
-- Cada reporte se registra solo si su descripción aún no existe (así no se duplica al re-ejecutar).
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Pantalla con líneas verticales y parpadeo constante');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 3 DAY), INTERVAL 15 HOUR), 'Alta'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-26836195' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Pantalla con líneas verticales y parpadeo constante' FROM equipos WHERE nombre = 'Laptop ProBook 450' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Atascos de papel recurrentes por desgaste del rodillo');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 6 DAY), INTERVAL 15 HOUR), 'Media'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-21196406' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Atascos de papel recurrentes por desgaste del rodillo' FROM equipos WHERE nombre = 'Impresora Laser' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Puerto 12 sin enlace y reinicios aleatorios del equipo');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 2 DAY), INTERVAL 7 HOUR), 'Alta'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-23312929' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Puerto 12 sin enlace y reinicios aleatorios del equipo' FROM equipos WHERE nombre = 'Switch Catalyst 2960' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'La batería no carga al 100 % y se descarga rápido');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 15 DAY), INTERVAL 11 HOUR), 'Baja'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-25481280' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'La batería no carga al 100 % y se descarga rápido' FROM equipos WHERE nombre = 'Tablet Galaxy Tab A8' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'No enciende; posible falla de la placa madre');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 9 DAY), INTERVAL 9 HOUR), 'Alta'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-26836195' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'No enciende; posible falla de la placa madre' FROM equipos WHERE nombre = 'Laptop Aspire 5' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Micrófono sin detección e imagen intermitente');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 12 DAY), INTERVAL 8 HOUR), 'Media'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-21196406' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Micrófono sin detección e imagen intermitente' FROM equipos WHERE nombre = 'Cámara Web C920' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Manchas oscuras en el panel y pérdida de brillo');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 28 DAY), INTERVAL 13 HOUR), 'Media'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-26836195' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Manchas oscuras en el panel y pérdida de brillo' FROM equipos WHERE nombre = 'Monitor HP P24' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Líquido derramado sobre el teclado; equipo sin respuesta');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 5 DAY), INTERVAL 10 HOUR), 'Alta'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-22513786' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Líquido derramado sobre el teclado; equipo sin respuesta' FROM equipos WHERE nombre = 'Laptop Canaima Educativa' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Lámpara quemada; proyecta imagen muy tenue');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 8 DAY), INTERVAL 8 HOUR), 'Alta'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-19265655' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Lámpara quemada; proyecta imagen muy tenue' FROM equipos WHERE nombre = 'Proyector EB-X06' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Pantalla táctil rota en la esquina inferior');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 20 DAY), INTERVAL 8 HOUR), 'Media'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-25481280' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Pantalla táctil rota en la esquina inferior' FROM equipos WHERE nombre = 'Tablet Redmi Pad' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Alertas de disco; se requiere chequeo SMART y respaldo');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 11 DAY), INTERVAL 8 HOUR), 'Media'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-23715925' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Alertas de disco; se requiere chequeo SMART y respaldo' FROM equipos WHERE nombre = 'Servidor PowerEdge T40' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Batería con baja autonomía; programar reemplazo');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 33 DAY), INTERVAL 8 HOUR), 'Baja'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-19265655' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Batería con baja autonomía; programar reemplazo' FROM equipos WHERE nombre = 'UPS Smart 1500' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Mantenimiento preventivo trimestral: limpieza y actualización');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 40 DAY), INTERVAL 13 HOUR), 'Baja'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-25955992' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Mantenimiento preventivo trimestral: limpieza y actualización' FROM equipos WHERE nombre = 'Computadora OptiPlex 7090' AND @nuevo IS NOT NULL;
SET @ya := (SELECT COUNT(*) FROM mantenimiento_equipos WHERE descripcion_fallas = 'Actualización de firmware y cambio de contraseñas por defecto');
INSERT INTO mantenimiento (id_tecnicos, fecha_reporte, nivel_prioridad)
SELECT t.id_tecnicos, DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 47 DAY), INTERVAL 7 HOUR), 'Baja'
FROM tecnicos t JOIN persona p ON p.id_persona = t.id_persona WHERE p.cedula = 'V-21391819' AND @ya = 0;
SET @nuevo := IF(@ya = 0 AND ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);
INSERT INTO mantenimiento_equipos (id_mantenimiento, id_equipos, descripcion_fallas)
SELECT @nuevo, id_equipos, 'Actualización de firmware y cambio de contraseñas por defecto' FROM equipos WHERE nombre = 'Router Archer C6' AND @nuevo IS NOT NULL;

-- ── Resumen de lo registrado ────────────────────────────────────────────
SELECT 'persona' AS tabla, COUNT(*) AS total FROM persona
UNION ALL SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL SELECT 'tecnicos', COUNT(*) FROM tecnicos
UNION ALL SELECT 'estudiante', COUNT(*) FROM estudiante
UNION ALL SELECT 'espacio', COUNT(*) FROM espacio
UNION ALL SELECT 'actividad', COUNT(*) FROM actividad
UNION ALL SELECT 'horario', COUNT(*) FROM horario
UNION ALL SELECT 'solicitud', COUNT(*) FROM solicitud
UNION ALL SELECT 'detalle_solicitud', COUNT(*) FROM detalle_solicitud
UNION ALL SELECT 'asistencia', COUNT(*) FROM asistencia
UNION ALL SELECT 'mantenimiento', COUNT(*) FROM mantenimiento
UNION ALL SELECT 'mantenimiento_equipos', COUNT(*) FROM mantenimiento_equipos;
