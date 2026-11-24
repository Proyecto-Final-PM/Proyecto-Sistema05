const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env'), quiet: true });
const jwt = require('jsonwebtoken');

const secreto = process.env.JWT_SECRET;
if (!secreto) {
    console.error('Falta JWT_SECRET en backend/.env');
    process.exit(1);
}

const expira = process.env.JWT_EXPIRES_IN || '1d';

// Usuarios ficticios solo para pruebas
const USUARIO = { id: 1, rol: 'usuario' };
const OPERADOR = { id: 2, rol: 'operador' };

function tokenValido(datos) {
    return jwt.sign(datos, secreto, { expiresIn: expira });
}

function tokenVencido(datos) {
    const hace1Minuto = Math.floor(Date.now() / 1000) - 60;
    return jwt.sign({ ...datos, exp: hace1Minuto }, secreto);
}

function tokenManipulado() {
    // Token de usuario con el rol cambiado a operador, sin volver a firmarlo
    const [encabezado, cuerpo, firma] = tokenValido(USUARIO).split('.');
    const payload = JSON.parse(Buffer.from(cuerpo, 'base64url').toString());
    payload.rol = 'operador';
    const cuerpoNuevo = Buffer.from(JSON.stringify(payload)).toString('base64url');
    return [encabezado, cuerpoNuevo, firma].join('.');
}

const tokens = {
    usuario: () => tokenValido(USUARIO),
    operador: () => tokenValido(OPERADOR),
    vencido: () => tokenVencido(OPERADOR),
    manipulado: () => tokenManipulado()
};

const tipo = process.argv[2];

if (tipo && tokens[tipo]) {
    console.log(tokens[tipo]());
} else {
    for (const [nombre, generar] of Object.entries(tokens)) {
        console.log(`\n--- ${nombre} ---`);
        console.log(generar());
    }
}