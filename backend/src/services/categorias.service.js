const pool = require('../config/db');

// Obtener todas las categorías
async function listar() {
    const [filas] = await pool.execute(
        `SELECT id, nombre
         FROM categorias
         ORDER BY id ASC`
    );

    return filas;
}

// Buscar una categoría por ID
async function obtenerPorId(id) {
    const [filas] = await pool.execute(
        `SELECT id, nombre
         FROM categorias
         WHERE id = ?`,
        [id]
    );

    return filas[0] || null;
}

// Buscar una categoría por nombre
async function buscarPorNombre(nombre) {
    const [filas] = await pool.execute(
        `SELECT id, nombre
         FROM categorias
         WHERE nombre = ?`,
        [nombre]
    );

    return filas[0] || null;
}

// Crear una categoría
async function crear(nombre) {
    const [resultado] = await pool.execute(
        `INSERT INTO categorias (nombre)
         VALUES (?)`,
        [nombre]
    );

    return await obtenerPorId(resultado.insertId);
}

// Modificar una categoría existente
async function actualizar(id, nombre) {
    await pool.execute(
        `UPDATE categorias
         SET nombre = ?
         WHERE id = ?`,
        [nombre, id]
    );

    return await obtenerPorId(id);
}

module.exports = {
    listar,
    obtenerPorId,
    buscarPorNombre,
    crear,
    actualizar
};