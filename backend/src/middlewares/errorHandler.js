function rutaNoEncontrada(req, res) {
    res.status(404).json({ error: 'Ruta no encontrada' });
}

function manejarErrores(err, req, res, next) {
    if (err.type === 'entity.parse.failed') {
        return res.status(400).json({
            error: 'El cuerpo de la petición no es un JSON válido'
        });
    }

    console.error(err);
    res.status(500).json({ error: 'Error interno del servidor' });
}

module.exports = { rutaNoEncontrada, manejarErrores };