// Registrar una acción en el historial de una solicitud
async function registrarHistorial(
    conexion,
    solicitudId,
    usuarioId,
    accion,
    estadoAnterior = null,
    estadoNuevo = null
) {
    await conexion.execute(
        `INSERT INTO historial
         (solicitud_id, usuario_id, accion, estado_anterior, estado_nuevo)
         VALUES (?, ?, ?, ?, ?)`,
        [
            solicitudId,
            usuarioId,
            accion,
            estadoAnterior,
            estadoNuevo
        ]
    );
}

// Consultar el historial de una solicitud.
async function listarHistorial(solicitudId) {
    const [filas] = await require('../config/db').execute(
        `SELECT
            id,
            solicitud_id,
            usuario_id,
            accion,
            estado_anterior,
            estado_nuevo,
            fecha_cambio
         FROM historial
         WHERE solicitud_id = ?
         ORDER BY fecha_cambio ASC, id ASC`,
        [solicitudId]
    );

    return filas;
}

module.exports = {
    registrarHistorial,
    listarHistorial
};