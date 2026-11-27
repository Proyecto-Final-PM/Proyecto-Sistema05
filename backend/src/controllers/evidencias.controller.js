const evidenciasService = require('../services/evidencias.service');
const fs = require('node:fs/promises');
const path = require('node:path');

// Validar identificadores
function idValido(id) {
    return /^\d+$/.test(id) &&
        Number.isSafeInteger(Number(id)) &&
        Number(id) > 0 &&
        Number(id) <= 2147483647;
}

// Verificar permisos sobre una solicitud
function tienePermiso(usuario, propietarioId) {
    return usuario.rol === 'operador' ||
        (
            usuario.rol === 'usuario' &&
            Number(usuario.id) === Number(propietarioId)
        );
}

// Subir una evidencia fotográfica
async function crear(req, res, next) {
    try {
        const { id } = req.params;

        if (!idValido(id)) {
            return res.status(400).json({
                error: 'El identificador de la solicitud no es válido'
            });
        }

        const resultado = await evidenciasService.crear(
            Number(id),
            Number(req.usuario.id),
            req.file,
            req.usuario.rol
        );

        if (resultado.error === 'NO_ENCONTRADA') {
            return res.status(404).json({
                error: 'Solicitud no encontrada'
            });
        }

        if (resultado.error === 'SIN_PERMISOS') {
            return res.status(403).json({
                error: 'No tienes permisos para subir evidencias a esta solicitud'
            });
        }

        if (resultado.error === 'ESTADO_INVALIDO') {
            return res.status(409).json({
                error: 'No se pueden agregar evidencias a esta solicitud'
            });
        }

        return res.status(201).json({
            mensaje: 'Evidencia registrada correctamente',
            evidencia: resultado.evidencia
        });

    } catch (error) {
        next(error);
    }
}

// Listar evidencias de una solicitud
async function listarPorSolicitud(req, res, next) {
    try {
        const { id } = req.params;

        if (!idValido(id)) {
            return res.status(400).json({
                error: 'El identificador de la solicitud no es válido'
            });
        }

        const solicitud = await evidenciasService.obtenerSolicitud(
            Number(id)
        );

        if (!solicitud) {
            return res.status(404).json({
                error: 'Solicitud no encontrada'
            });
        }

        if (!tienePermiso(req.usuario, solicitud.usuario_id)) {
            return res.status(403).json({
                error: 'No tienes permisos para consultar estas evidencias'
            });
        }

        const evidencias = await evidenciasService.listarPorSolicitud(
            Number(id)
        );

        return res.status(200).json(evidencias);

    } catch (error) {
        next(error);
    }
}

// Consultar el archivo de una evidencia
async function obtenerArchivo(req, res, next) {
    try {
        const { id } = req.params;

        if (!idValido(id)) {
            return res.status(400).json({
                error: 'El identificador de la evidencia no es válido'
            });
        }

        const evidencia = await evidenciasService.obtenerPorId(
            Number(id)
        );

        if (!evidencia) {
            return res.status(404).json({
                error: 'Evidencia no encontrada'
            });
        }

        if (!tienePermiso(req.usuario, evidencia.propietario_id)) {
            return res.status(403).json({
                error: 'No tienes permisos para ver esta evidencia'
            });
        }

        const rutaArchivo = evidenciasService.obtenerRutaArchivo(
            evidencia.nombre_archivo
        );

        // Comprobar que el archivo exista físicamente
        try {
            await fs.access(rutaArchivo);
        } catch (error) {
            if (error.code === 'ENOENT') {
                return res.status(404).json({
                    error: 'Evidencia no encontrada'
                });
            }

            throw error;
        }

        // Establecer el tipo de contenido
        const tiposMime = {
            '.jpg': 'image/jpeg',
            '.png': 'image/png',
            '.webp': 'image/webp'
        };

        const extension = path.extname(
            evidencia.nombre_archivo
        );

        res.setHeader('Content-Type', tiposMime[extension]);
        res.setHeader('X-Content-Type-Options', 'nosniff');
        res.setHeader('Cache-Control', 'private, no-store');

        return res.sendFile(rutaArchivo, (error) => {
            if (error) {
                if (!res.headersSent && error.code === 'ENOENT') {
                    return res.status(404).json({
                        error: 'Evidencia no encontrada'
                    });
                }

                next(error);
            }
        });

    } catch (error) {
        next(error);
    }
}

module.exports = {
    crear,
    listarPorSolicitud,
    obtenerArchivo
};
