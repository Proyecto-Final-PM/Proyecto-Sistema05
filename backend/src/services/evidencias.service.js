const pool = require('../config/db');
const fs = require('node:fs/promises');
const path = require('node:path');
const { randomUUID } = require('node:crypto');

// Ruta absoluta de almacenamiento
const UPLOADS_DIR = path.resolve(
    __dirname,
    '../../uploads'
);

// Convertir una evidencia al formato del contrato
function formatearEvidencia(evidencia) {
    return {
        id: evidencia.id,
        solicitud_id: evidencia.solicitud_id,
        usuario_id: evidencia.usuario_id,
        url: `/api/evidencias/${evidencia.id}/archivo`,
        fecha_subida: evidencia.fecha_subida
    };
}

// Consultar una solicitud
async function obtenerSolicitud(id) {
    const [filas] = await pool.execute(
        `SELECT id, usuario_id, estado, cancelada
         FROM solicitudes
         WHERE id = ?`,
        [id]
    );

    return filas[0] || null;
}

// Consultar una evidencia y el propietario de la solicitud
async function obtenerPorId(id) {
    const [filas] = await pool.execute(
        `SELECT e.id,
                e.solicitud_id,
                e.usuario_id,
                e.nombre_archivo,
                e.fecha_subida,
                s.usuario_id AS propietario_id
         FROM evidencias e
         INNER JOIN solicitudes s
             ON e.solicitud_id = s.id
         WHERE e.id = ?`,
        [id]
    );

    return filas[0] || null;
}

// Listar evidencias de una solicitud
async function listarPorSolicitud(solicitudId) {
    const [filas] = await pool.execute(
        `SELECT id, solicitud_id, usuario_id, fecha_subida
         FROM evidencias
         WHERE solicitud_id = ?
         ORDER BY fecha_subida ASC, id ASC`,
        [solicitudId]
    );

    return filas.map(formatearEvidencia);
}

// Guardar una fotografía y registrar sus metadatos
async function crear(solicitudId, usuarioId, archivo, rol) {

    const extensionesPermitidas = ['.jpg', '.png', '.webp'];

    if (!extensionesPermitidas.includes(archivo.extension)) {
        throw new Error('Formato de archivo no permitido');
    }

    const nombreArchivo = randomUUID() + archivo.extension;

    const rutaArchivo = path.join(
        UPLOADS_DIR,
        nombreArchivo
    );

    const conexion = await pool.getConnection();

    let archivoGuardado = false;

    try {
        await conexion.beginTransaction();

        // Bloquear la solicitud durante el registro
        const [solicitudes] = await conexion.execute(
            `SELECT id, usuario_id, estado, cancelada
             FROM solicitudes
             WHERE id = ?
             FOR UPDATE`,
            [solicitudId]
        );

        const solicitud = solicitudes[0];

        if (!solicitud) {
            await conexion.rollback();
            return { error: 'NO_ENCONTRADA' };
        }

        if (
            rol !== 'operador' &&
            (
                rol !== 'usuario' ||
                solicitud.usuario_id !== usuarioId
            )
        ) {
            await conexion.rollback();
            return { error: 'SIN_PERMISOS' };
        }

        if (
            solicitud.cancelada ||
            (
                rol === 'usuario' &&
                solicitud.estado !== 'solicitada'
            )
        ) {
            await conexion.rollback();
            return { error: 'ESTADO_INVALIDO' };
        }

        // Crear la carpeta si todavía no existe
        await fs.mkdir(UPLOADS_DIR, {
            recursive: true
        });

        // Guardar la imagen sin sobrescribir otros archivos
        await fs.writeFile(
            rutaArchivo,
            archivo.buffer,
            { flag: 'wx' }
        );

        archivoGuardado = true;

        // Registrar los metadatos en MySQL
        const [resultado] = await conexion.execute(
            `INSERT INTO evidencias
                (solicitud_id, usuario_id, nombre_archivo)
             VALUES (?, ?, ?)`,
            [
                solicitudId,
                usuarioId,
                nombreArchivo
            ]
        );

        const [filas] = await conexion.execute(
            `SELECT id, solicitud_id, usuario_id, fecha_subida
             FROM evidencias
             WHERE id = ?`,
            [resultado.insertId]
        );

        const evidencia = formatearEvidencia(filas[0]);

        await conexion.commit();

        return { evidencia };

    } catch (error) {

        await conexion.rollback().catch(console.error);

        // Eliminar el archivo si falla el registro
        if (archivoGuardado) {
            await fs.unlink(rutaArchivo).catch(console.error);
        }

        throw error;

    } finally {
        conexion.release();
    }
}

// Obtener la ruta interna de una fotografía
function obtenerRutaArchivo(nombreArchivo) {

    if (
        typeof nombreArchivo !== 'string' ||
        !/^[a-f0-9-]{36}\.(jpg|png|webp)$/.test(nombreArchivo)
    ) {
        throw new Error('Nombre de archivo no válido');
    }

    return path.join(UPLOADS_DIR, nombreArchivo);
}

module.exports = {
    obtenerSolicitud,
    obtenerPorId,
    listarPorSolicitud,
    crear,
    obtenerRutaArchivo
};