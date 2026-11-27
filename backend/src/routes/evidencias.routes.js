const express = require('express');

const evidenciasController = require('../controllers/evidencias.controller');

const { verificarToken } = require('../middlewares/auth');

const {
    subirImagen,
    validarImagen
} = require('../middlewares/upload');

const router = express.Router();

// Subir una evidencia fotográfica
router.post(
    '/solicitudes/:id/evidencias',
    verificarToken,
    subirImagen,
    validarImagen,
    evidenciasController.crear
);

// Listar las evidencias de una solicitud
router.get(
    '/solicitudes/:id/evidencias',
    verificarToken,
    evidenciasController.listarPorSolicitud
);

// Consultar el archivo de una evidencia
router.get(
    '/evidencias/:id/archivo',
    verificarToken,
    evidenciasController.obtenerArchivo
);

module.exports = router;