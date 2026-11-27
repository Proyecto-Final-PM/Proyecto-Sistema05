const solicitudesService = require('../services/solicitudes.service');
const { validationResult } = require('express-validator');

// Validar los datos recibidos por la ruta.
function validarPeticion(req, res, mensaje = 'Los datos proporcionados no son validos') {
    const errores = validationResult(req);

    if (!errores.isEmpty()) {
        return res.status(400).json({ error: mensaje });
    }

    return null;
}

// Validar el identificador de una solicitud.
function validarId(req, res) {
    const errores = validationResult(req);

    if (!errores.isEmpty()) {
        return res.status(400).json({
            error: 'El identificador de la solicitud no es válido'
        });
    }

    return null;
}

// Crear una solicitud.
async function crear(req, res, next) {
    try {
        const respuestaValidacion = validarPeticion(req, res, 'Los datos de la solicitud son inválidos');
        if (respuestaValidacion) return respuestaValidacion;

        const solicitud = await solicitudesService.crear(
            req.body,
            req.usuario.id
        );

        return res.status(201).json({
            mensaje: 'Solicitud creada correctamente',
            solicitud
        });

    } catch (error) {
        if (error.status) {
            return res.status(error.status).json({
                error: error.message
            });
        }

        next(error);
    }
}

// Listar solicitudes con filtros y búsqueda.
async function listar(req, res, next) {
    try {
        const respuestaValidacion = validarPeticion(req, res, 'Los filtros proporcionados no son válidos' );
        if (respuestaValidacion) return respuestaValidacion;

        const filtros = {
            q: req.query.q,
            estado: req.query.estado,
            categoria_id: req.query.categoria_id,
            cancelada: req.query.cancelada,
            usuario_id: req.query.usuario_id
        };

        const solicitudes = await solicitudesService.listar(
            filtros,
            req.usuario
        );

        return res.status(200).json(solicitudes);

    } catch (error) {
        if (error.status) {
            return res.status(error.status).json({
                error: error.message
            });
        }

        next(error);
    }
}

// Consultar el detalle de una solicitud.
async function obtenerPorId(req, res, next) {
    try {
        const respuestaValidacion = validarId(req, res);
        if (respuestaValidacion) return respuestaValidacion;

        const solicitud = await solicitudesService.obtenerPorId(
            Number(req.params.id)
        );

        if (!solicitud) {
            return res.status(404).json({
                error: 'Solicitud no encontrada'
            });
        }

        if (
            req.usuario.rol === 'usuario' &&
            solicitud.usuario_id !== req.usuario.id
        ) {
            return res.status(403).json({
                error: 'No tienes permisos para consultar esta solicitud'
            });
        }

        return res.status(200).json(solicitud);

    } catch (error) {
        next(error);
    }
}

// Modificar una solicitud.
async function actualizar(req, res, next) {
    try {
        const respuestaId = validarId(req, res);
        if (respuestaId) return respuestaId;

        const respuestaValidacion = validarPeticion(req, res);
        if (respuestaValidacion) return respuestaValidacion;

        const solicitud = await solicitudesService.actualizar(
            Number(req.params.id),
            req.body,
            req.usuario.id
        );

        return res.status(200).json({
            mensaje: 'Solicitud actualizada correctamente',
            solicitud
        });

    } catch (error) {
        if (error.status) {
            return res.status(error.status).json({
                error: error.message
            });
        }

        next(error);
    }
}

// Cancelar una solicitud.
async function cancelar(req, res, next) {
    try {
        const respuestaId = validarId(req, res);
        if (respuestaId) return respuestaId;

        const solicitud = await solicitudesService.cancelar(
            Number(req.params.id),
            req.usuario.id
        );

        return res.status(200).json({
            mensaje: 'Solicitud cancelada correctamente',
            solicitud: {
                id: solicitud.id,
                estado: solicitud.estado,
                cancelada: solicitud.cancelada
            }
        });

    } catch (error) {
        if (error.status) {
            return res.status(error.status).json({
                error: error.message
            });
        }

        next(error);
    }
}

module.exports = {
    crear,
    listar,
    obtenerPorId,
    actualizar,
    cancelar
};
