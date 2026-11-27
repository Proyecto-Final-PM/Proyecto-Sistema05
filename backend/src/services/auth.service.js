const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Buscar un usuario por correo
async function buscarPorCorreo(correo) {
    const [filas] = await pool.execute(
        `SELECT id, nombre, correo, password_hash, rol
         FROM usuarios
         WHERE correo = ?`,
        [correo]
    );

    return filas[0] || null;
}

// Buscar un usuario por ID sin devolver su contraseña
async function buscarPorId(id) {
    const [filas] = await pool.execute(
        `SELECT id, nombre, correo, rol
         FROM usuarios
         WHERE id = ?`,
        [id]
    );

    return filas[0] || null;
}

// Registrar un nuevo usuario
async function registrarUsuario(nombre, correo, password) {
    const passwordHash = await bcrypt.hash(password, 10);

    const [resultado] = await pool.execute(
        `INSERT INTO usuarios
         (nombre, correo, password_hash, rol)
         VALUES (?, ?, ?, 'usuario')`,
        [nombre, correo, passwordHash]
    );

    return await buscarPorId(resultado.insertId);
}

// Validar las credenciales del usuario
async function validarCredenciales(correo, password) {
    const usuario = await buscarPorCorreo(correo);

    if (!usuario) {
        return null;
    }

    const passwordValido = await bcrypt.compare(
        password,
        usuario.password_hash
    );

    if (!passwordValido) {
        return null;
    }

    // Devolver únicamente los datos públicos
    return {
        id: usuario.id,
        nombre: usuario.nombre,
        correo: usuario.correo,
        rol: usuario.rol
    };
}

// Generar un token JWT
function generarToken(usuario) {
    return jwt.sign(
        {
            id: usuario.id,
            rol: usuario.rol
        },
        process.env.JWT_SECRET,
        {
            algorithm: 'HS256',
            expiresIn: process.env.JWT_EXPIRES_IN || '1h'
        }
    );
}

module.exports = {
    buscarPorCorreo,
    buscarPorId,
    registrarUsuario,
    validarCredenciales,
    generarToken
};