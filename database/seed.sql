
USE recoleccion_reciclables;

-- USUARIOS DE PRUEBA

INSERT INTO usuarios (nombre, correo, password_hash, rol)
VALUES
(
    'Usuario',
    'usuario.prueba@example.com',
    '$2b$10$A6/3swM8aiMzKTYdkoyFWe3jkpbVqqcVOmuAsH7zk4xVgmmccRZKW',
    'usuario'
),
(
    'Operador',
    'operador.prueba@example.com',
    '$2b$10$j.sEVEOBRNubkBSZ6rbVReXVPrplcGCQmogzcjUqOmBjfRrL4imeO',
    'operador'
)
ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre),
    password_hash = VALUES(password_hash),
    rol = VALUES(rol);

-- CATEGORÍAS

INSERT IGNORE INTO categorias (nombre)
VALUES
    ('Plástico'),
    ('Papel'),
    ('Vidrio'),
    ('Metal');

-- SOLICITUDES DE PRUEBA
-- Solicitud 1: Plástico, solicitada
INSERT INTO solicitudes (
    usuario_id, categoria_id, descripcion,
    direccion, latitud, longitud, estado
)
SELECT
    u.id, c.id,
    'Recolección de botellas de plástico',
    'Ubicación de prueba 1',
    21.8853000, -102.2916000,
    'solicitada'
FROM usuarios u
JOIN categorias c ON c.nombre = 'Plástico'
WHERE u.correo = 'usuario.prueba@example.com'
AND NOT EXISTS (
    SELECT 1 FROM solicitudes s
    WHERE s.usuario_id = u.id
    AND s.descripcion = 'Recolección de botellas de plástico'
);

-- Solicitud 2: Papel, aceptada
INSERT INTO solicitudes (
    usuario_id, categoria_id, descripcion,
    direccion, latitud, longitud, estado
)
SELECT
    u.id, c.id,
    'Recolección de cajas de cartón',
    'Ubicación de prueba 2',
    21.8860000, -102.2920000,
    'aceptada'
FROM usuarios u
JOIN categorias c ON c.nombre = 'Papel'
WHERE u.correo = 'usuario.prueba@example.com'
AND NOT EXISTS (
    SELECT 1 FROM solicitudes s
    WHERE s.usuario_id = u.id
    AND s.descripcion = 'Recolección de cajas de cartón'
);

-- Solicitud 3: Vidrio, en recolección
INSERT INTO solicitudes (
    usuario_id, categoria_id, descripcion,
    direccion, latitud, longitud, estado
)
SELECT
    u.id, c.id,
    'Recolección de envases de vidrio',
    'Ubicación de prueba 3',
    21.8870000, -102.2930000,
    'en_recoleccion'
FROM usuarios u
JOIN categorias c ON c.nombre = 'Vidrio'
WHERE u.correo = 'usuario.prueba@example.com'
AND NOT EXISTS (
    SELECT 1 FROM solicitudes s
    WHERE s.usuario_id = u.id
    AND s.descripcion = 'Recolección de envases de vidrio'
);

-- Solicitud 4: Metal, finalizada
INSERT INTO solicitudes (
    usuario_id, categoria_id, descripcion,
    direccion, latitud, longitud, estado,
    cantidad_recolectada
)
SELECT
    u.id, c.id,
    'Recolección de latas de aluminio',
    'Ubicación de prueba 4',
    21.8880000, -102.2940000,
    'finalizada',
    12.50
FROM usuarios u
JOIN categorias c ON c.nombre = 'Metal'
WHERE u.correo = 'usuario.prueba@example.com'
AND NOT EXISTS (
    SELECT 1 FROM solicitudes s
    WHERE s.usuario_id = u.id
    AND s.descripcion = 'Recolección de latas de aluminio'
);
