const multer = require('multer');

// Tamaño máximo permitido: 5 MB
const MAX_FILE_SIZE = 5 * 1024 * 1024;

// Almacenamiento temporal en memoria
const storage = multer.memoryStorage();

// Configuración de multer
const upload = multer({
    storage: storage,
    limits: {
        fileSize: MAX_FILE_SIZE,
        files: 1
    }
});

// Identificar el formato real de la imagen
function detectarFormato(buffer) {

    if (!Buffer.isBuffer(buffer)) {
        return null;
    }

    // JPEG
    if (
        buffer.length >= 3 &&
        buffer[0] === 0xFF &&
        buffer[1] === 0xD8 &&
        buffer[2] === 0xFF
    ) {
        return {
            extension: '.jpg',
            mimeType: 'image/jpeg'
        };
    }

    // PNG
    const firmaPNG = Buffer.from([
        0x89, 0x50, 0x4E, 0x47,
        0x0D, 0x0A, 0x1A, 0x0A
    ]);

    if (
        buffer.length >= 8 &&
        buffer.subarray(0, 8).equals(firmaPNG)
    ) {
        return {
            extension: '.png',
            mimeType: 'image/png'
        };
    }

    // WebP
    if (
        buffer.length >= 16 &&
        buffer.toString('ascii', 0, 4) === 'RIFF' &&
        buffer.toString('ascii', 8, 12) === 'WEBP' &&
        ['VP8 ', 'VP8L', 'VP8X'].includes(
            buffer.toString('ascii', 12, 16)
        )
    ) {
        return {
            extension: '.webp',
            mimeType: 'image/webp'
        };
    }

    return null;
}

// Validar la imagen recibida
function validarImagen(req, res, next) {

    if (!req.file) {
        return res.status(400).json({
            error: 'El archivo enviado no es una imagen válida'
        });
    }

    const formato = detectarFormato(req.file.buffer);

    if (!formato) {
        return res.status(400).json({
            error: 'El archivo enviado no es una imagen válida'
        });
    }

    req.file.extension = formato.extension;
    req.file.mimeTypeReal = formato.mimeType;

    next();
}

module.exports = {
    subirImagen: upload.single('imagen'),
    validarImagen
};