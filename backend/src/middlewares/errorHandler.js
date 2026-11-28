const multer = require('multer');

// Gestionar rutas inexistentes
function rutaNoEncontrada(req, res) {
    res.status(404).json({
        error: 'Ruta no encontrada'
    });
}

// Middleware general de errores
function manejarErrores(err, req, res, next) {

    if (res.headersSent) {
        return next(err);
    }

    // Error de JSON inválido
    if (err.type === 'entity.parse.failed') {
        return res.status(400).json({
            error: 'El cuerpo de la petición no es un JSON válido'
        });
    }

    // Errores generados por multer
    if (err instanceof multer.MulterError) {

        // Imagen superior a 5 MB
        if (err.code === 'LIMIT_FILE_SIZE') {
            return res.status(413).json({
                error: 'La imagen supera el tamaño máximo permitido'
            });
        }

        // Otros errores relacionados con la carga
        return res.status(400).json({
            error: 'El archivo enviado no es una imagen válida'
        });
    }

    // Formulario multipart incompleto o incorrecto
    if (
        req.is('multipart/form-data') &&
        (
            err.message === 'Unexpected end of form' ||
            err.message === 'Unexpected end of file' ||
            err.message === 'Multipart: Boundary not found' ||
            err.message === 'Malformed part header'
        )
    ) {
        return res.status(400).json({
            error: 'El archivo enviado no es una imagen válida'
        });
    }

    // Errores controlados por los servicios.
    if (err.status && err.status >= 400 && err.status < 500) {
        return res.status(err.status).json({
            error: err.message
        });
    }

    // Error interno del servidor.
    console.error(err);

    return res.status(500).json({
        error: 'Error interno del servidor'
    });
}

module.exports = {
    rutaNoEncontrada,
    manejarErrores
};