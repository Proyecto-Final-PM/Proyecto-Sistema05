CREATE DATABASE IF NOT EXISTS recoleccion_reciclables
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE recoleccion_reciclables;

-- TABLA: usuarios

CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('usuario', 'operador') NOT NULL DEFAULT 'usuario'
) ENGINE=InnoDB;

-- TABLA: categorias

CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 3. TABLA: solicitudes

CREATE TABLE IF NOT EXISTS solicitudes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    categoria_id INT NOT NULL,
    descripcion TEXT NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    latitud DECIMAL(10,7) NOT NULL,
    longitud DECIMAL(10,7) NOT NULL,

    estado ENUM(
        'solicitada',
        'aceptada',
        'en_recoleccion',
        'finalizada'
    ) NOT NULL DEFAULT 'solicitada',

    cancelada BOOLEAN NOT NULL DEFAULT FALSE,
    cantidad_recolectada DECIMAL(10,2) DEFAULT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_solicitudes_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_solicitudes_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_solicitudes_latitud
        CHECK (latitud BETWEEN -90 AND 90),

    CONSTRAINT chk_solicitudes_longitud
        CHECK (longitud BETWEEN -180 AND 180),

    CONSTRAINT chk_solicitudes_cantidad
        CHECK (
            cantidad_recolectada IS NULL
            OR cantidad_recolectada > 0
        ),

    CONSTRAINT chk_solicitudes_finalizada
        CHECK (
            estado <> 'finalizada'
            OR cantidad_recolectada IS NOT NULL
        )
) ENGINE=InnoDB;

-- TABLA: evidencias

CREATE TABLE IF NOT EXISTS evidencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL,
    usuario_id INT NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    fecha_subida DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_evidencias_solicitud
        FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_evidencias_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABLA: historial

CREATE TABLE IF NOT EXISTS historial (
    id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL,
    usuario_id INT NOT NULL,

    accion ENUM(
        'creacion',
        'modificacion',
        'cambio_estado',
        'cancelacion'
    ) NOT NULL,

    estado_anterior ENUM(
        'solicitada',
        'aceptada',
        'en_recoleccion',
        'finalizada'
    ) DEFAULT NULL,

    estado_nuevo ENUM(
        'solicitada',
        'aceptada',
        'en_recoleccion',
        'finalizada'
    ) DEFAULT NULL,

    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_historial_solicitud
        FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_historial_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;
