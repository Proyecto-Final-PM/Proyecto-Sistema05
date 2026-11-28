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

// Permitir únicamente usuarios con rol operador.
function requiereOperador(mensaje) {
    return (req, res, next) => {
        if (req.usuario.rol !== 'operador') {
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

// Validar los datos para cambiar el estado de una solicitud.
const validarCambioEstado = [
    body('estado')
        .isString()
        .withMessage('El estado proporcionado no es válido')
        .bail()
        .isIn(ESTADOS_VALIDOS)
        .withMessage('El estado proporcionado no es válido'),

    body('cantidad_recolectada')
        .custom((value, { req }) => {
            if (req.body.estado !== 'finalizada') {
                return true;
            }

            if (
                value === undefined ||
                value === null ||
                value === ''
            ) {
                throw new Error(
                    'La cantidad recolectada debe ser mayor que cero'
                );
            }

            const texto = String(value);

            if (!/^\d+(\.\d{1,2})?$/.test(texto)) {
                throw new Error(
                    'La cantidad recolectada debe tener máximo dos decimales'
                );
            }

            const cantidad = Number(value);

            if (
                typeof value !== 'number' ||
                !Number.isFinite(cantidad) ||
                cantidad <= 0
            ) {
                throw new Error(
                    'La cantidad recolectada debe ser mayor que cero'
                );
            }

            if (cantidad > 99999999.99) {
                throw new Error(
                    'La cantidad recolectada no puede superar 99999999.99'
                );
            }

            return true;
        })
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

// Consultar el historial de una solicitud.
router.get(
    '/:id/historial',
    verificarToken,
    validarId,
    solicitudesController.obtenerHistorial
);

// Cambiar el estado de una solicitud (solo operadores).
router.patch(
    '/:id/estado',
    verificarToken,
    (req, res, next) => requiereOperador('No tienes permisos para cambiar el estado')(req, res, next),
    validarId,
    validarCambioEstado,
    solicitudesController.actualizarEstado
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
