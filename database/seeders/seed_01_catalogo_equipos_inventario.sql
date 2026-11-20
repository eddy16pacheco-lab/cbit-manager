-- ============================================================================
--  CBIT MANAGER — SCRIPT 1 DE 2: CATÁLOGO DE EQUIPOS E INVENTARIO
--  Registra: ubicaciones, categorías, marcas, modelos, equipos e inventario.
--
--  REQUISITOS
--    * Haber ejecutado antes las migraciones (001 a 005). En especial la 005, que
--      agrega inventario.codigo_bien_nacional y el estado 'Desincorporado'.
--    * Seleccionar la base de datos ANTES de ejecutar (en HeidiSQL: clic sobre la
--      base db_cbit_2 y luego Archivo > Ejecutar script SQL).
--
--  CARACTERÍSTICAS
--    * Se puede ejecutar más de una vez: no duplica registros (usa claves únicas
--      y NOT EXISTS). Si ya existen datos del seeder inicial, los respeta.
--    * Ejecutar este script ANTES del script 2 (reservas, actividades, etc.).
-- ============================================================================
SET NAMES utf8mb4;

-- ── 1. Ubicaciones físicas (12) ──────────────────────────────────────
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Laboratorio 1' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Laboratorio 2' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Sala de Servidores' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Servidores');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Aula de Clases' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula de Clases');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Laboratorio 3' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Laboratorio de Robótica' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Biblioteca Digital' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Biblioteca Digital');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Sala de Videoconferencias' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Videoconferencias');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Depósito de Equipos' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Depósito de Equipos');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Taller de Redes' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Taller de Redes');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Oficina Administrativa' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Oficina Administrativa');
INSERT INTO ubicacion_fisica (nombre) SELECT 'CBIT Francisco de Miranda - Aula Magna' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula Magna');

-- ── 2. Categorías (12) ────────────────────────────────────────────────
INSERT IGNORE INTO categoria (nombre) VALUES
('Computadora'),
('Impresora'),
('Proyector'),
('Tablet'),
('Router'),
('Switch'),
('Laptop'),
('Monitor'),
('Servidor'),
('Cámara Web'),
('Pizarra Digital'),
('UPS');

-- ── 3. Marcas (19) ────────────────────────────────────────────────────
INSERT IGNORE INTO marca (nombre) VALUES
('HP'),
('Dell'),
('Lenovo'),
('Epson'),
('Samsung'),
('Asus'),
('Acer'),
('Apple'),
('Cisco'),
('TP-Link'),
('Logitech'),
('Canon'),
('BenQ'),
('Ubiquiti'),
('APC'),
('Brother'),
('Xiaomi'),
('Canaima'),
('VIT');

-- ── 4. Modelos (28) ───────────────────────────────────────────────────
INSERT IGNORE INTO modelo (nombre) VALUES
('OptiPlex 3080'),
('Latitude 3420'),
('LaserJet M404dn'),
('PowerLite 1785W'),
('Tab M10'),
('ProBook 450 G8'),
('ThinkPad E14'),
('VivoBook 15'),
('Aspire 5'),
('MacBook Air M1'),
('Catalyst 2960'),
('Archer C6'),
('C920 HD Pro'),
('PIXMA G3110'),
('EB-X06'),
('MW605'),
('Canaima Educativa 2.0'),
('OptiPlex 7090'),
('PowerEdge T40'),
('ProLiant ML30'),
('Smart UPS 1500'),
('UniFi AP AC'),
('DCP-L2540DW'),
('Galaxy Tab A8'),
('Redmi Pad'),
('UltraSharp U2422H'),
('P24 G4'),
('RP8603');

-- ── 5. Equipos del catálogo (28) ─────────────────────────────────────
INSERT IGNORE INTO equipos (nombre, id_categoria, id_marca, id_modelo) VALUES
('Computadora Escritorio', (SELECT id_categoria FROM categoria WHERE nombre = 'Computadora'), (SELECT id_marca FROM marca WHERE nombre = 'Dell'), (SELECT id_modelo FROM modelo WHERE nombre = 'OptiPlex 3080')),
('Laptop Educativa', (SELECT id_categoria FROM categoria WHERE nombre = 'Computadora'), (SELECT id_marca FROM marca WHERE nombre = 'Dell'), (SELECT id_modelo FROM modelo WHERE nombre = 'Latitude 3420')),
('Impresora Laser', (SELECT id_categoria FROM categoria WHERE nombre = 'Impresora'), (SELECT id_marca FROM marca WHERE nombre = 'HP'), (SELECT id_modelo FROM modelo WHERE nombre = 'LaserJet M404dn')),
('Proyector Multimedia', (SELECT id_categoria FROM categoria WHERE nombre = 'Proyector'), (SELECT id_marca FROM marca WHERE nombre = 'Epson'), (SELECT id_modelo FROM modelo WHERE nombre = 'PowerLite 1785W')),
('Tablet Educativa', (SELECT id_categoria FROM categoria WHERE nombre = 'Tablet'), (SELECT id_marca FROM marca WHERE nombre = 'Samsung'), (SELECT id_modelo FROM modelo WHERE nombre = 'Tab M10')),
('Laptop Canaima Educativa', (SELECT id_categoria FROM categoria WHERE nombre = 'Laptop'), (SELECT id_marca FROM marca WHERE nombre = 'Canaima'), (SELECT id_modelo FROM modelo WHERE nombre = 'Canaima Educativa 2.0')),
('Laptop ProBook 450', (SELECT id_categoria FROM categoria WHERE nombre = 'Laptop'), (SELECT id_marca FROM marca WHERE nombre = 'HP'), (SELECT id_modelo FROM modelo WHERE nombre = 'ProBook 450 G8')),
('Laptop ThinkPad E14', (SELECT id_categoria FROM categoria WHERE nombre = 'Laptop'), (SELECT id_marca FROM marca WHERE nombre = 'Lenovo'), (SELECT id_modelo FROM modelo WHERE nombre = 'ThinkPad E14')),
('Laptop VivoBook 15', (SELECT id_categoria FROM categoria WHERE nombre = 'Laptop'), (SELECT id_marca FROM marca WHERE nombre = 'Asus'), (SELECT id_modelo FROM modelo WHERE nombre = 'VivoBook 15')),
('Laptop Aspire 5', (SELECT id_categoria FROM categoria WHERE nombre = 'Laptop'), (SELECT id_marca FROM marca WHERE nombre = 'Acer'), (SELECT id_modelo FROM modelo WHERE nombre = 'Aspire 5')),
('MacBook Air', (SELECT id_categoria FROM categoria WHERE nombre = 'Laptop'), (SELECT id_marca FROM marca WHERE nombre = 'Apple'), (SELECT id_modelo FROM modelo WHERE nombre = 'MacBook Air M1')),
('Computadora OptiPlex 7090', (SELECT id_categoria FROM categoria WHERE nombre = 'Computadora'), (SELECT id_marca FROM marca WHERE nombre = 'Dell'), (SELECT id_modelo FROM modelo WHERE nombre = 'OptiPlex 7090')),
('Servidor PowerEdge T40', (SELECT id_categoria FROM categoria WHERE nombre = 'Servidor'), (SELECT id_marca FROM marca WHERE nombre = 'Dell'), (SELECT id_modelo FROM modelo WHERE nombre = 'PowerEdge T40')),
('Servidor ProLiant ML30', (SELECT id_categoria FROM categoria WHERE nombre = 'Servidor'), (SELECT id_marca FROM marca WHERE nombre = 'HP'), (SELECT id_modelo FROM modelo WHERE nombre = 'ProLiant ML30')),
('Switch Catalyst 2960', (SELECT id_categoria FROM categoria WHERE nombre = 'Switch'), (SELECT id_marca FROM marca WHERE nombre = 'Cisco'), (SELECT id_modelo FROM modelo WHERE nombre = 'Catalyst 2960')),
('Router Archer C6', (SELECT id_categoria FROM categoria WHERE nombre = 'Router'), (SELECT id_marca FROM marca WHERE nombre = 'TP-Link'), (SELECT id_modelo FROM modelo WHERE nombre = 'Archer C6')),
('Punto de Acceso UniFi', (SELECT id_categoria FROM categoria WHERE nombre = 'Router'), (SELECT id_marca FROM marca WHERE nombre = 'Ubiquiti'), (SELECT id_modelo FROM modelo WHERE nombre = 'UniFi AP AC')),
('Cámara Web C920', (SELECT id_categoria FROM categoria WHERE nombre = 'Cámara Web'), (SELECT id_marca FROM marca WHERE nombre = 'Logitech'), (SELECT id_modelo FROM modelo WHERE nombre = 'C920 HD Pro')),
('Impresora Multifuncional PIXMA', (SELECT id_categoria FROM categoria WHERE nombre = 'Impresora'), (SELECT id_marca FROM marca WHERE nombre = 'Canon'), (SELECT id_modelo FROM modelo WHERE nombre = 'PIXMA G3110')),
('Impresora Brother Laser', (SELECT id_categoria FROM categoria WHERE nombre = 'Impresora'), (SELECT id_marca FROM marca WHERE nombre = 'Brother'), (SELECT id_modelo FROM modelo WHERE nombre = 'DCP-L2540DW')),
('Proyector EB-X06', (SELECT id_categoria FROM categoria WHERE nombre = 'Proyector'), (SELECT id_marca FROM marca WHERE nombre = 'Epson'), (SELECT id_modelo FROM modelo WHERE nombre = 'EB-X06')),
('Proyector BenQ MW605', (SELECT id_categoria FROM categoria WHERE nombre = 'Proyector'), (SELECT id_marca FROM marca WHERE nombre = 'BenQ'), (SELECT id_modelo FROM modelo WHERE nombre = 'MW605')),
('Tablet Galaxy Tab A8', (SELECT id_categoria FROM categoria WHERE nombre = 'Tablet'), (SELECT id_marca FROM marca WHERE nombre = 'Samsung'), (SELECT id_modelo FROM modelo WHERE nombre = 'Galaxy Tab A8')),
('Monitor UltraSharp 24', (SELECT id_categoria FROM categoria WHERE nombre = 'Monitor'), (SELECT id_marca FROM marca WHERE nombre = 'Dell'), (SELECT id_modelo FROM modelo WHERE nombre = 'UltraSharp U2422H')),
('Monitor HP P24', (SELECT id_categoria FROM categoria WHERE nombre = 'Monitor'), (SELECT id_marca FROM marca WHERE nombre = 'HP'), (SELECT id_modelo FROM modelo WHERE nombre = 'P24 G4')),
('UPS Smart 1500', (SELECT id_categoria FROM categoria WHERE nombre = 'UPS'), (SELECT id_marca FROM marca WHERE nombre = 'APC'), (SELECT id_modelo FROM modelo WHERE nombre = 'Smart UPS 1500')),
('Pizarra Digital Interactiva', (SELECT id_categoria FROM categoria WHERE nombre = 'Pizarra Digital'), (SELECT id_marca FROM marca WHERE nombre = 'BenQ'), (SELECT id_modelo FROM modelo WHERE nombre = 'RP8603')),
('Tablet Redmi Pad', (SELECT id_categoria FROM categoria WHERE nombre = 'Tablet'), (SELECT id_marca FROM marca WHERE nombre = 'Xiaomi'), (SELECT id_modelo FROM modelo WHERE nombre = 'Redmi Pad'));

-- ── 6. Inventario: unidades físicas con código de Bienes Nacionales (61) ──
-- Estados variados: Operativo, En Reparacion, No operativo, Dañado y Desincorporado.
INSERT IGNORE INTO inventario (codigo_bien_nacional, id_equipos, id_ubicacion_fisica, serial, estado, fecha_desincorporacion, motivo_desincorporacion) VALUES
('0100231', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora Escritorio'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'DL-OPT3080-26-0001', 'Operativo', NULL, NULL),
('0100234', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora Escritorio'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'DL-OPT3080-26-0002', 'Operativo', NULL, NULL),
('0100239', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora Escritorio'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'DL-OPT3080-26-0003', 'Desincorporado', DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'Obsolescencia tecnológica: placa madre y fuente de poder irrecuperables'),
('0100244', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'DL-LAT3420-26-0001', 'Operativo', NULL, NULL),
('0100250', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'DL-LAT3420-26-0002', 'Operativo', NULL, NULL),
('0100257', (SELECT id_equipos FROM equipos WHERE nombre = 'Impresora Laser'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Oficina Administrativa'), 'HP-LJ404-26-0001', 'En Reparacion', NULL, NULL),
('0100258', (SELECT id_equipos FROM equipos WHERE nombre = 'Proyector Multimedia'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula de Clases'), 'EP-PL1785-26-0001', 'Operativo', NULL, NULL),
('0100260', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'SM-TABM10-26-0001', 'Operativo', NULL, NULL),
('0100265', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'SM-TABM10-26-0002', 'Operativo', NULL, NULL),
('0100270', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'CAN-EDU-26-0001', 'Operativo', NULL, NULL),
('0100275', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'CAN-EDU-26-0002', 'Operativo', NULL, NULL),
('0100279', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'CAN-EDU-26-0003', 'Operativo', NULL, NULL),
('0100286', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'CAN-EDU-26-0004', 'Operativo', NULL, NULL),
('0100291', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'CAN-EDU-26-0005', 'Operativo', NULL, NULL),
('0100296', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'CAN-EDU-26-0006', 'Operativo', NULL, NULL),
('0100303', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'CAN-EDU-26-0007', 'Operativo', NULL, NULL),
('0100309', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Canaima Educativa'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'CAN-EDU-26-0008', 'Dañado', NULL, NULL),
('0100316', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop ProBook 450'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'HP-PB450-26-0001', 'Operativo', NULL, NULL),
('0100323', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop ProBook 450'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'HP-PB450-26-0002', 'En Reparacion', NULL, NULL),
('0100327', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop ProBook 450'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'HP-PB450-26-0003', 'Operativo', NULL, NULL),
('0100334', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop ThinkPad E14'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'LN-TPE14-26-0001', 'Operativo', NULL, NULL),
('0100341', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop ThinkPad E14'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Biblioteca Digital'), 'LN-TPE14-26-0002', 'Operativo', NULL, NULL),
('0100346', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop ThinkPad E14'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'LN-TPE14-26-0003', 'Operativo', NULL, NULL),
('0100350', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop VivoBook 15'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Biblioteca Digital'), 'AS-VB15-26-0001', 'Operativo', NULL, NULL),
('0100352', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop VivoBook 15'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Biblioteca Digital'), 'AS-VB15-26-0002', 'Operativo', NULL, NULL),
('0100353', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Aspire 5'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'AC-ASP5-26-0001', 'Operativo', NULL, NULL),
('0100358', (SELECT id_equipos FROM equipos WHERE nombre = 'Laptop Aspire 5'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Depósito de Equipos'), 'AC-ASP5-26-0002', 'No operativo', NULL, NULL),
('0100359', (SELECT id_equipos FROM equipos WHERE nombre = 'MacBook Air'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'AP-MBA-M1-26-0001', 'Operativo', NULL, NULL),
('0100360', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora OptiPlex 7090'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'DL-OPT7090-26-0001', 'Operativo', NULL, NULL),
('0100363', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora OptiPlex 7090'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'DL-OPT7090-26-0002', 'Operativo', NULL, NULL),
('0100370', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora OptiPlex 7090'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'DL-OPT7090-26-0003', 'Operativo', NULL, NULL),
('0100371', (SELECT id_equipos FROM equipos WHERE nombre = 'Computadora OptiPlex 7090'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'DL-OPT7090-26-0004', 'Operativo', NULL, NULL),
('0100375', (SELECT id_equipos FROM equipos WHERE nombre = 'Servidor PowerEdge T40'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Servidores'), 'DL-PET40-26-0001', 'Operativo', NULL, NULL),
('0100376', (SELECT id_equipos FROM equipos WHERE nombre = 'Servidor ProLiant ML30'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Servidores'), 'HP-PLML30-26-0001', 'Operativo', NULL, NULL),
('0100383', (SELECT id_equipos FROM equipos WHERE nombre = 'Switch Catalyst 2960'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Servidores'), 'CS-CAT2960-26-0001', 'Operativo', NULL, NULL),
('0100389', (SELECT id_equipos FROM equipos WHERE nombre = 'Switch Catalyst 2960'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Taller de Redes'), 'CS-CAT2960-26-0002', 'En Reparacion', NULL, NULL),
('0100393', (SELECT id_equipos FROM equipos WHERE nombre = 'Router Archer C6'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Taller de Redes'), 'TP-ARC6-26-0001', 'Operativo', NULL, NULL),
('0100399', (SELECT id_equipos FROM equipos WHERE nombre = 'Router Archer C6'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Taller de Redes'), 'TP-ARC6-26-0002', 'Operativo', NULL, NULL),
('0100402', (SELECT id_equipos FROM equipos WHERE nombre = 'Punto de Acceso UniFi'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Biblioteca Digital'), 'UB-UAP-26-0001', 'Operativo', NULL, NULL),
('0100404', (SELECT id_equipos FROM equipos WHERE nombre = 'Punto de Acceso UniFi'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula Magna'), 'UB-UAP-26-0002', 'Operativo', NULL, NULL),
('0100408', (SELECT id_equipos FROM equipos WHERE nombre = 'Cámara Web C920'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Videoconferencias'), 'LG-C920-26-0001', 'Operativo', NULL, NULL),
('0100411', (SELECT id_equipos FROM equipos WHERE nombre = 'Cámara Web C920'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Videoconferencias'), 'LG-C920-26-0002', 'Operativo', NULL, NULL),
('0100414', (SELECT id_equipos FROM equipos WHERE nombre = 'Cámara Web C920'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Videoconferencias'), 'LG-C920-26-0003', 'No operativo', NULL, NULL),
('0100417', (SELECT id_equipos FROM equipos WHERE nombre = 'Impresora Multifuncional PIXMA'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Biblioteca Digital'), 'CN-PIXMA-26-0001', 'Operativo', NULL, NULL),
('0100424', (SELECT id_equipos FROM equipos WHERE nombre = 'Impresora Brother Laser'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Oficina Administrativa'), 'BR-DCP2540-26-0001', 'Operativo', NULL, NULL),
('0100428', (SELECT id_equipos FROM equipos WHERE nombre = 'Proyector EB-X06'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'EP-EBX06-26-0001', 'Operativo', NULL, NULL),
('0100434', (SELECT id_equipos FROM equipos WHERE nombre = 'Proyector EB-X06'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula de Clases'), 'EP-EBX06-26-0002', 'Dañado', NULL, NULL),
('0100439', (SELECT id_equipos FROM equipos WHERE nombre = 'Proyector BenQ MW605'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula Magna'), 'BQ-MW605-26-0001', 'Operativo', NULL, NULL),
('0100445', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Galaxy Tab A8'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'SM-TABA8-26-0001', 'Operativo', NULL, NULL),
('0100446', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Galaxy Tab A8'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Depósito de Equipos'), 'SM-TABA8-26-0002', 'Operativo', NULL, NULL),
('0100452', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Galaxy Tab A8'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'SM-TABA8-26-0003', 'En Reparacion', NULL, NULL),
('0100455', (SELECT id_equipos FROM equipos WHERE nombre = 'Monitor UltraSharp 24'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'DL-U2422-26-0001', 'Operativo', NULL, NULL),
('0100456', (SELECT id_equipos FROM equipos WHERE nombre = 'Monitor UltraSharp 24'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 2'), 'DL-U2422-26-0002', 'Operativo', NULL, NULL),
('0100461', (SELECT id_equipos FROM equipos WHERE nombre = 'Monitor UltraSharp 24'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 1'), 'DL-U2422-26-0003', 'Operativo', NULL, NULL),
('0100466', (SELECT id_equipos FROM equipos WHERE nombre = 'Monitor HP P24'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'HP-P24G4-26-0001', 'Desincorporado', DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'Panel dañado sin repuesto disponible; dictamen técnico de baja'),
('0100469', (SELECT id_equipos FROM equipos WHERE nombre = 'Monitor HP P24'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio 3'), 'HP-P24G4-26-0002', 'No operativo', NULL, NULL),
('0100472', (SELECT id_equipos FROM equipos WHERE nombre = 'UPS Smart 1500'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Servidores'), 'APC-SUA1500-26-0001', 'Operativo', NULL, NULL),
('0100476', (SELECT id_equipos FROM equipos WHERE nombre = 'UPS Smart 1500'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Sala de Servidores'), 'APC-SUA1500-26-0002', 'Operativo', NULL, NULL),
('0100478', (SELECT id_equipos FROM equipos WHERE nombre = 'Pizarra Digital Interactiva'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Aula Magna'), 'BQ-RP8603-26-0001', 'Operativo', NULL, NULL),
('0100484', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Redmi Pad'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'XM-RPAD-26-0001', 'Operativo', NULL, NULL),
('0100490', (SELECT id_equipos FROM equipos WHERE nombre = 'Tablet Redmi Pad'), (SELECT MIN(id_ubicacion_fisica) FROM ubicacion_fisica WHERE nombre = 'CBIT Francisco de Miranda - Laboratorio de Robótica'), 'XM-RPAD-26-0002', 'Dañado', NULL, NULL);

-- ── Resumen de lo registrado ────────────────────────────────────────────
SELECT 'ubicacion_fisica' AS tabla, COUNT(*) AS total FROM ubicacion_fisica
UNION ALL SELECT 'categoria', COUNT(*) FROM categoria
UNION ALL SELECT 'marca', COUNT(*) FROM marca
UNION ALL SELECT 'modelo', COUNT(*) FROM modelo
UNION ALL SELECT 'equipos', COUNT(*) FROM equipos
UNION ALL SELECT 'inventario', COUNT(*) FROM inventario;
