const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const pruebaRoutes = require('./routes/prueba.routes');
const authRoutes = require('./routes/auth.routes');
const solicitudesRoutes = require('./routes/solicitudes.routes');
const { rutaNoEncontrada, manejarErrores } = require('./middlewares/errorHandler');
const categoriasRoutes = require('./routes/categorias.routes');
const evidenciasRoutes = require('./routes/evidencias.routes');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/api/categorias', categoriasRoutes);
app.use('/api', evidenciasRoutes);

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

// Rutas de prueba
if (process.env.NODE_ENV !== 'production') {
    app.use('/api/prueba', pruebaRoutes);
}

// Rutas de autenticación
app.use('/api/auth', authRoutes);
app.use('/api/solicitudes', solicitudesRoutes);

// Manejo de errores
app.use(rutaNoEncontrada);
app.use(manejarErrores);

module.exports = app;