const authService = require('../services/auth.service');
const { validationResult } = require('express-validator');

// Registrar un nuevo usuario
async function registrar(req, res, next) {
    try {
        const errores = validationResult(req);

        if (!errores.isEmpty()) {
            return res.status(400).json({
                error: 'Los datos de registro son inválidos'
            });
        }

        const { nombre, correo, password } = req.body;

        // Verificar si el correo ya está registrado
        const usuarioExistente = await authService.buscarPorCorreo(correo);

        if (usuarioExistente) {
            return res.status(409).json({
                error: 'El correo ya está registrado'
            });
        }

        // Registrar al usuario
        const usuario = await authService.registrarUsuario(
            nombre,
            correo,
            password
        );

        return res.status(201).json({
            mensaje: 'Usuario registrado correctamente',
            usuario
        });

    } catch (error) {

        // Controlar correos duplicados en peticiones simultáneas
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                error: 'El correo ya está registrado'
            });
        }

        next(error);
    }
}

// Iniciar sesión
async function iniciarSesion(req, res, next) {
    try {
        const errores = validationResult(req);

        if (!errores.isEmpty()) {
            return res.status(400).json({
                error: 'El correo y la contraseña son obligatorios'
            });
        }

        const { correo, password } = req.body;

        // Validar las credenciales
        const usuario = await authService.validarCredenciales(
            correo,
            password
        );

        if (!usuario) {
            return res.status(401).json({
                error: 'Credenciales incorrectas'
            });
        }

        // Generar el token JWT
        const token = authService.generarToken(usuario);

        return res.status(200).json({
            mensaje: 'Inicio de sesión exitoso',
            token,
            tipo_token: 'Bearer',
            usuario
        });

    } catch (error) {
        next(error);
    }
}

// Consultar el usuario autenticado
async function obtenerUsuarioActual(req, res, next) {
    try {
        const usuario = await authService.buscarPorId(req.usuario.id);

        if (!usuario) {
            return res.status(404).json({
                error: 'Usuario no encontrado'
            });
        }

        return res.status(200).json(usuario);

    } catch (error) {
        next(error);
    }
}

module.exports = {
    registrar,
    iniciarSesion,
    obtenerUsuarioActual
};