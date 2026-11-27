const express = require('express');
const { body, param, query } = require('express-validator');

const solicitudesController = require('../controllers/solicitudes.controller');
const { verificarToken } = require('../middlewares/auth');

const router = express.Router();

const ESTADOS_VALIDOS = [
    'solicitada',
    'aceptada',
    'en_recoleccion',
    'finalizada'
];

// Permitir unicamente usuarios con rol usuario.
function requiereUsuario(mensaje) {
    return (req, res, next) => {
        if (req.usuario.rol !== 'usuario') {
            return res.status(403).json({ error: mensaje });
        }

        next();
    };
}

// Impedir que un usuario filtre solicitudes por usuario_id.
function protegerFiltroUsuario(req, res, next) {
    if (
        req.usuario.rol === 'usuario' &&
        req.query.usuario_id !== undefined
    ) {
        return res.status(403).json({
            error: 'No tienes permisos para filtrar por usuario'
        });
    }

    next();
}

// Validar los datos de una solicitud.
const validarSolicitud = [
    body('categoria_id')
        .isInt({ min: 1 })
        .toInt(),

    body('descripcion')
        .isString()
        .bail()
        .trim()
        .notEmpty(),

    body('direccion')
        .isString()
        .bail()
        .trim()
        .notEmpty()
        .isLength({ max: 255 }),

    body('latitud')
        .isFloat({ min: -90, max: 90 })
        .toFloat(),

    body('longitud')
        .isFloat({ min: -180, max: 180 })
        .toFloat()
];

// Validar el identificador de la solicitud.
const validarId = [
    param('id')
        .isInt({ min: 1 })
        .toInt()
];

// Validar los filtros de busqueda.
const validarFiltros = [
    query('q')
        .optional()
        .isString()
        .bail()
        .trim(),

    query('estado')
        .optional()
        .isIn(ESTADOS_VALIDOS),

    query('categoria_id')
        .optional()
        .isInt({ min: 1 })
        .toInt(),

    query('cancelada')
        .optional()
        .isIn(['true', 'false'])
        .toBoolean(),

    query('usuario_id')
        .optional()
        .isInt({ min: 1 })
        .toInt()
];

// Crear una solicitud.
router.post(
    '/',
    verificarToken,
    requiereUsuario('No tienes permisos para crear solicitudes'),
    validarSolicitud,
    solicitudesController.crear
);

// Listar solicitudes con búsqueda y filtros.
router.get(
    '/',
    verificarToken,
    protegerFiltroUsuario,
    validarFiltros,
    solicitudesController.listar
);

// Consultar el detalle de una solicitud.
router.get(
    '/:id',
    verificarToken,
    validarId,
    solicitudesController.obtenerPorId
);

// Modificar una solicitud.
router.put(
    '/:id',
    verificarToken,
    requiereUsuario('No tienes permisos para modificar esta solicitud'),
    validarId,
    validarSolicitud,
    solicitudesController.actualizar
);

// Cancelar una solicitud.
router.patch(
    '/:id/cancelar',
    verificarToken,
    requiereUsuario('No tienes permisos para cancelar esta solicitud'),
    validarId,
    solicitudesController.cancelar
);

module.exports = router;
