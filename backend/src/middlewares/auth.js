const jwt = require('jsonwebtoken');

const ROLES_VALIDOS = ['usuario', 'operador'];
const MENSAJE_401 = 'Token ausente, inválido o vencido';

function verificarToken(req, res, next) {
    const secreto = process.env.JWT_SECRET;
    if (!secreto) {
        console.error('Falta JWT_SECRET en el archivo .env');
        return res.status(500).json({ error: 'Error interno del servidor' });
    }

    const encabezado = req.headers.authorization;
    if (!encabezado || !encabezado.startsWith('Bearer ')) {
        return res.status(401).json({ error: MENSAJE_401 });
    }

    const token = encabezado.slice(7).trim();

    try {
        const payload = jwt.verify(token, secreto, { algorithms: ['HS256'] });

        if (!Number.isInteger(payload.id) || !ROLES_VALIDOS.includes(payload.rol)) {
            return res.status(401).json({ error: MENSAJE_401 });
        }

        req.usuario = { id: payload.id, rol: payload.rol };
        next();
    } catch (error) {
        return res.status(401).json({ error: MENSAJE_401 });
    }
}

module.exports = { verificarToken };