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

module.exports = {
    registrarHistorial
};
