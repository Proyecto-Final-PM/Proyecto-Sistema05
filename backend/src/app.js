const express = require('express');
const cors = require('cors');
const pruebaRoutes = require('./routes/prueba.routes');
const { rutaNoEncontrada, manejarErrores } = require('./middlewares/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        message: 'API de Recolección de Reciclables funcionando'
    });
});

if (process.env.NODE_ENV !== 'production') {
    app.use('/api/prueba', pruebaRoutes);
}

app.use(rutaNoEncontrada);
app.use(manejarErrores);

module.exports = app;