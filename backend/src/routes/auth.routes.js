const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const { verificarToken } = require('../middlewares/auth');

const router = express.Router();

// Validaciones para el registro
const validarRegistro = [
    body('nombre')
        .isString()
        .bail()
        .trim()
        .notEmpty()
        .isLength({ max: 100 }),

    body('correo')
        .isString()
        .bail()
        .trim()
        .isEmail()
        .isLength({ max: 150 })
        .toLowerCase(),

    body('password')
        .isString()
        .bail()
        .isLength({ min: 8 })
        .custom((password) => {
            return Buffer.byteLength(password, 'utf8') <= 72;
        })
];

// Validaciones para el inicio de sesión
const validarLogin = [
    body('correo')
        .isString()
        .bail()
        .trim()
        .notEmpty()
        .toLowerCase(),

    body('password')
        .isString()
        .bail()
        .notEmpty()
        .custom((password) => {
            return Buffer.byteLength(password, 'utf8') <= 72;
        })
];

// Registro público
router.post(
    '/registro',
    validarRegistro,
    authController.registrar
);

// Inicio de sesión público
router.post(
    '/login',
    validarLogin,
    authController.iniciarSesion
);

// Consultar usuario autenticado
router.get(
    '/me',
    verificarToken,
    authController.obtenerUsuarioActual
);

module.exports = router;