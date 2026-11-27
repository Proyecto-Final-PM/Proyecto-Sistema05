const express = require('express');
const categoriasController = require('../controllers/categorias.controller');
const { verificarToken } = require('../middlewares/auth');

const router = express.Router();

// Verificar permisos de operador
function soloOperador(mensaje) {
    return (req, res, next) => {
        if (req.usuario.rol !== 'operador') {
            return res.status(403).json({
                error: mensaje
            });
        }

        next();
    };
}

// Todas las rutas requieren autenticación
router.use(verificarToken);

// Listar categorías
router.get(
    '/',
    categoriasController.listar
);

// Consultar categoría por ID
router.get(
    '/:id',
    categoriasController.obtenerPorId
);

// Crear categoría (solo operador)
router.post(
    '/',
    soloOperador('No tienes permisos para crear categorías'),
    categoriasController.crear
);

// Modificar categoría (solo operador)
router.put(
    '/:id',
    soloOperador('No tienes permisos para modificar categorías'),
    categoriasController.actualizar
);

module.exports = router;