const pool = require('../config/db');
const historialService = require('./historial.service');

// Crear errores controlados para que el controlador responda según el contrato.
function crearError(status, mensaje) {
    const error = new Error(mensaje);
    error.status = status;
    return error;
}

// Normalizar los datos de una solicitud para la respuesta JSON.
function normalizarSolicitud(solicitud) {
    if (!solicitud) return null;

    return {
        ...solicitud,
        cancelada: Boolean(solicitud.cancelada)
    };
}

// Obtener una solicitud por ID usando una conexión existente.
async function buscarPorId(conexion, id) {
    const [filas] = await conexion.execute(
        `SELECT id, usuario_id, categoria_id, descripcion, direccion,
                latitud, longitud, estado, cancelada,
                cantidad_recolectada, fecha_creacion
         FROM solicitudes
         WHERE id = ?
         FOR UPDATE`,
        [id]
    );

    return normalizarSolicitud(filas[0]);
}

// Listar solicitudes aplicando búsqueda y filtros.
async function listar(filtros, usuario) {
    let sql = `
        SELECT id, usuario_id, categoria_id, descripcion, direccion,
               latitud, longitud, estado, cancelada,
               cantidad_recolectada, fecha_creacion
        FROM solicitudes
    `;

    const condiciones = [];
    const valores = [];

    // Los usuarios únicamente pueden consultar sus propias solicitudes.
    if (usuario.rol === 'usuario') {
        condiciones.push('usuario_id = ?');
        valores.push(usuario.id);
    }

    // El operador puede filtrar por usuario.
    if (usuario.rol === 'operador' && filtros.usuario_id !== undefined) {
        condiciones.push('usuario_id = ?');
        valores.push(filtros.usuario_id);
    }

    if (filtros.q) {
        condiciones.push('(descripcion LIKE ? OR direccion LIKE ?)');
        valores.push(`%${filtros.q}%`, `%${filtros.q}%`);
    }

    if (filtros.estado) {
        condiciones.push('estado = ?');
        valores.push(filtros.estado);
    }

    if (filtros.categoria_id !== undefined) {
        condiciones.push('categoria_id = ?');
        valores.push(filtros.categoria_id);
    }

    if (filtros.cancelada !== undefined) {
        condiciones.push('cancelada = ?');
        valores.push(filtros.cancelada);
    }

    if (condiciones.length > 0) {
        sql += ` WHERE ${condiciones.join(' AND ')}`;
    }

    sql += ' ORDER BY fecha_creacion DESC';

    const [filas] = await pool.execute(sql, valores);

    return filas.map(normalizarSolicitud);
}

// Consultar una solicitud por ID.
async function obtenerPorId(id) {
    const [filas] = await pool.execute(
        `SELECT id, usuario_id, categoria_id, descripcion, direccion,
                latitud, longitud, estado, cancelada,
                cantidad_recolectada, fecha_creacion
         FROM solicitudes
         WHERE id = ?`,
        [id]
    );

    return normalizarSolicitud(filas[0]);
}

// Comprobar que una categoría exista.
async function verificarCategoria(conexion, categoriaId) {
    const [filas] = await conexion.execute(
        'SELECT id FROM categorias WHERE id = ?',
        [categoriaId]
    );

    if (filas.length === 0) {
        throw crearError(404, 'La categoría indicada no existe');
    }
}

// Crear una solicitud y registrar su historial en la misma transacción.
async function crear(datos, usuarioId) {
    const conexion = await pool.getConnection();

    try {
        await conexion.beginTransaction();

        await verificarCategoria(conexion, datos.categoria_id);

        const [resultado] = await conexion.execute(
            `INSERT INTO solicitudes
             (usuario_id, categoria_id, descripcion, direccion, latitud, longitud)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [
                usuarioId,
                datos.categoria_id,
                datos.descripcion,
                datos.direccion,
                datos.latitud,
                datos.longitud
            ]
        );

        const solicitudId = resultado.insertId;

        await historialService.registrarHistorial(
            conexion,
            solicitudId,
            usuarioId,
            'creacion',
            null,
            'solicitada'
        );

        const solicitud = await buscarPorId(conexion, solicitudId);

        await conexion.commit();

        return solicitud;

    } catch (error) {
        try {
            await conexion.rollback();
        } catch (errorRollback) {
            console.error('Error al revertir la transacción:', errorRollback);
        }

        throw error;

    } finally {
        conexion.release();
    }
}

// Modificar una solicitud propia que todavía pueda editarse.
async function actualizar(id, datos, usuarioId) {
    const conexion = await pool.getConnection();

    try {
        await conexion.beginTransaction();

        const solicitudActual = await buscarPorId(conexion, id);

        if (!solicitudActual) {
            throw crearError(404, 'Solicitud no encontrada');
        }

        if (solicitudActual.usuario_id !== usuarioId) {
            throw crearError(
                403,
                'No tienes permisos para modificar esta solicitud'
            );
        }

        if (
            solicitudActual.estado !== 'solicitada' ||
            solicitudActual.cancelada
        ) {
            throw crearError(409, 'La solicitud ya no puede modificarse');
        }

        await verificarCategoria(conexion, datos.categoria_id);

        await conexion.execute(
            `UPDATE solicitudes
             SET categoria_id = ?,
                 descripcion = ?,
                 direccion = ?,
                 latitud = ?,
                 longitud = ?
             WHERE id = ?`,
            [
                datos.categoria_id,
                datos.descripcion,
                datos.direccion,
                datos.latitud,
                datos.longitud,
                id
            ]
        );

        await historialService.registrarHistorial(
            conexion,
            id,
            usuarioId,
            'modificacion',
            solicitudActual.estado,
            solicitudActual.estado
        );

        const solicitudActualizada = await buscarPorId(conexion, id);

        await conexion.commit();

        return solicitudActualizada;

    } catch (error) {
        try {
            await conexion.rollback();
        } catch (errorRollback) {
            console.error('Error al revertir la transacción:', errorRollback);
        }

        throw error;

    } finally {
        conexion.release();
    }
}

// Cancelar una solicitud sin eliminarla.
async function cancelar(id, usuarioId) {
    const conexion = await pool.getConnection();

    try {
        await conexion.beginTransaction();

        const solicitudActual = await buscarPorId(conexion, id);

        if (!solicitudActual) {
            throw crearError(404, 'Solicitud no encontrada');
        }

        if (solicitudActual.usuario_id !== usuarioId) {
            throw crearError(
                403,
                'No tienes permisos para cancelar esta solicitud'
            );
        }

        if (
            solicitudActual.estado !== 'solicitada' ||
            solicitudActual.cancelada
        ) {
            throw crearError(
                409,
                'La solicitud no puede cancelarse en su estado actual'
            );
        }

        await conexion.execute(
            `UPDATE solicitudes
             SET cancelada = TRUE
             WHERE id = ?`,
            [id]
        );

        await historialService.registrarHistorial(
            conexion,
            id,
            usuarioId,
            'cancelacion',
            solicitudActual.estado,
            solicitudActual.estado
        );

        const solicitudCancelada = await buscarPorId(conexion, id);

        await conexion.commit();

        return solicitudCancelada;

    } catch (error) {
        try {
            await conexion.rollback();
        } catch (errorRollback) {
            console.error('Error al revertir la transacción:', errorRollback);
        }

        throw error;
    } finally {
        conexion.release();
    }
}

module.exports = {
    listar,
    obtenerPorId,
    crear,
    actualizar,
    cancelar
};
