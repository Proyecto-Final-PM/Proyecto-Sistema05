const categoriasService = require('../services/categorias.service');

// Validar que el ID sea un entero positivo
function idValido(id) {
    return /^\d+$/.test(id) &&
        Number.isSafeInteger(Number(id)) &&
        Number(id) > 0 &&
        Number(id) <= 2147483647;
}

// Validar el nombre de una categoría
function nombreValido(nombre) {
    return typeof nombre === 'string' &&
        nombre.trim().length > 0 &&
        nombre.trim().length <= 80;
}

// Listar todas las categorías
async function listar(req, res, next) {
    try {
        const categorias = await categoriasService.listar();

        return res.status(200).json(categorias);

    } catch (error) {
        next(error);
    }
}

// Consultar una categoría por ID
async function obtenerPorId(req, res, next) {
    try {
        const { id } = req.params;

        if (!idValido(id)) {
            return res.status(400).json({
                error: 'El identificador de la categoría no es válido'
            });
        }

        const categoria = await categoriasService.obtenerPorId(
            Number(id)
        );

        if (!categoria) {
            return res.status(404).json({
                error: 'Categoría no encontrada'
            });
        }

        return res.status(200).json(categoria);

    } catch (error) {
        next(error);
    }
}

// Crear una categoría
async function crear(req, res, next) {
    try {
        const { nombre } = req.body || {};

        if (!nombreValido(nombre)) {
            return res.status(400).json({
                error: 'El nombre de la categoría es obligatorio'
            });
        }

        const nombreLimpio = nombre.trim();

        const existente = await categoriasService.buscarPorNombre(
            nombreLimpio
        );

        if (existente) {
            return res.status(409).json({
                error: 'La categoría ya existe'
            });
        }

        const categoria = await categoriasService.crear(
            nombreLimpio
        );

        return res.status(201).json(categoria);

    } catch (error) {

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                error: 'La categoría ya existe'
            });
        }

        next(error);
    }
}

// Modificar una categoría
async function actualizar(req, res, next) {
    try {
        const { id } = req.params;
        const { nombre } = req.body || {};

        if (!idValido(id)) {
            return res.status(400).json({
                error: 'El identificador de la categoría no es válido'
            });
        }

        if (!nombreValido(nombre)) {
            return res.status(400).json({
                error: 'El nombre de la categoría no es válido'
            });
        }

        const categoria = await categoriasService.obtenerPorId(
            Number(id)
        );

        if (!categoria) {
            return res.status(404).json({
                error: 'Categoría no encontrada'
            });
        }

        const nombreLimpio = nombre.trim();

        const existente = await categoriasService.buscarPorNombre(
            nombreLimpio
        );

        if (existente && existente.id !== Number(id)) {
            return res.status(409).json({
                error: 'Ya existe otra categoría con ese nombre'
            });
        }

        const categoriaActualizada =
            await categoriasService.actualizar(
                Number(id),
                nombreLimpio
            );

        return res.status(200).json(categoriaActualizada);

    } catch (error) {

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                error: 'Ya existe otra categoría con ese nombre'
            });
        }

        next(error);
    }
}

module.exports = {
    listar,
    obtenerPorId,
    crear,
    actualizar
};