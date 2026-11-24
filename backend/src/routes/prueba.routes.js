const express = require('express');
const { verificarToken } = require('../middlewares/auth');
const { requiereRol } = require('../middlewares/roles');

const router = express.Router();

router.get('/protegida', verificarToken, (req, res) => {
    res.json({ mensaje: 'Acceso permitido', usuario: req.usuario });
});

router.get('/solo-operador', verificarToken, requiereRol('operador'), (req, res) => {
    res.json({ mensaje: 'Acceso de operador permitido', usuario: req.usuario });
});

module.exports = router;