const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const pruebaRoutes = require('./routes/prueba.routes');
const { rutaNoEncontrada, manejarErrores } = require('./middlewares/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());

// Estado general de la API
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        message: 'API de Recolección de Reciclables funcionando'
    });
});

// Estado de la conexión con MySQL
app.get('/api/health/db', async (req, res) => {
    try {
        await db.query('SELECT 1');

        res.status(200).json({
            status: 'ok',
            message: 'Conexión con la base de datos establecida correctamente'
        });
    } catch (error) {
        console.error('Error al conectar con MySQL:', error.message);

        res.status(503).json({
            status: 'error',
            message: 'No fue posible conectar con la base de datos'
        });
    }
});

module.exports = app;
if (process.env.NODE_ENV !== 'production') {
    app.use('/api/prueba', pruebaRoutes);
}

app.use(rutaNoEncontrada);
app.use(manejarErrores);

module.exports = app;
