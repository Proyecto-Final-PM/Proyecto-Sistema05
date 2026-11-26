# Proyecto-Sistema05

# Sistema de Recolección de Reciclables

Proyecto final de la materia **Programación de Dispositivos Móviles**

## Descripción

Sistema multiplataforma que permite a los usuarios registrar solicitudes de recolección de materiales reciclables, adjuntar evidencias fotográficas, indicar su ubicación y consultar el estado de sus solicitudes.
Los operadores podrán administrar las solicitudes, actualizar su estado y registrar las recolecciones realizadas.

## Tecnologías utilizadas

- **Frontend:** Flutter y Dart.
- **Backend:** Node.js y Express.
- **Base de datos:** MySQL.
- **Comunicación:** API REST mediante HTTP y JSON.
- **Control de versiones:** GitHub.

## Estructura del proyecto
```text
Proyecto-Sistema05/
├── frontend/       # Aplicación Flutter
├── backend/        # Servidor Node.js y Express
├── database/       # Scripts SQL
├── docs/           # Documentación técnica
├── .github/        # Plantillas de colaboración (si están configuradas)
├── .gitignore
└── README.md
```

## Requisitos previos
Para ejecutar el proyecto localmente se necesita:
- Flutter SDK.
- Node.js 24.
- MySQL.
- Git.
- Visual Studio Code u otro editor compatible.

## Instalación

### 1. Clonar el repositorio
```bash
git clone URL_DEL_REPOSITORIO
cd Proyecto-Sistema05
```

### 2. Configurar el frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome
```
Para ejecutar en Android o Windows, seleccionar el dispositivo compatible mediante `flutter devices`.

## Configuración de la conexión con el backend (Flutter)

La aplicación Flutter utiliza una URL base configurable para comunicarse con la API. La configuración se encuentra centralizada en `frontend/lib/core/api_config.dart`.

### URLs según el dispositivo

| Plataforma | URL base |
|---|---|
| Web (Chrome) | `http://localhost:3000/api` |
| Windows | `http://localhost:3000/api` |
| Emulador Android | `http://10.0.2.2:3000/api` |
| Celular físico | `http://IP_DE_LA_PC:3000/api` |

**Celular físico:** reemplazar `IP_DE_LA_PC` por la dirección IPv4 de la computadora donde se ejecuta el backend. Ambos dispositivos deben estar conectados a la misma red Wi-Fi. También es necesario permitir las conexiones al puerto 3000 en el firewall si corresponde.

### Configuración personalizada

La URL también puede modificarse al ejecutar Flutter, sin cambiar el código:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

Para Android físico, por ejemplo:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
```

Reemplazar `192.168.1.100` por la IPv4 real de la computadora.

### Requisitos de conexión

- El servidor backend debe estar ejecutándose.
- La API debe estar disponible en el puerto 3000.
- La ruta de verificación de conexión es `GET /api/health`.
- Si no se puede conectar al servidor, la aplicación muestra un mensaje de error en lugar de cerrarse.


### 3. Configurar el backend
Desde la raíz del proyecto:

```bash
cd backend
npm install
```

Crear el archivo `.env` a partir de `.env.example` y configurar las variables correspondientes.

Iniciar el servidor:

```bash
npm run dev
```

La API estará disponible, de forma predeterminada, en:

`http://localhost:3000`

Ruta de verificación:

`http://localhost:3000/api/health`

### 4. Base de datos
Los archivos de la base de datos se encuentran en `database/`:

- `schema.sql`: creación de tablas y relaciones.
- `seed.sql`: datos iniciales de prueba.

**Nota:** Los scripts SQL están pendientes de implementación. La conexión a MySQL todavía no está integrada al backend.

## Organización del trabajo
El desarrollo se realizará mediante ramas independientes.

1. Crear un Issue para la actividad.
2. Crear una rama desde `main`.
3. Implementar y probar los cambios.
4. Realizar commits descriptivos.
5. Crear un Pull Request.
6. Solicitar revisión de otro integrante antes de integrar los cambios.

No se desarrollará directamente sobre `main`.

## Estado actual
El proyecto se encuentra en su etapa de configuración inicial.

- Estructura Flutter creada.
- Backend Node.js y Express inicializado.
- Ruta de verificación de la API implementada.
- Estructura de base de datos preparada.
- Funcionalidades del sistema pendientes de desarrollo.

## Integrantes

- Tania Paola Garcia Meza
- Lorenzo Antonio Pacheco Leyva
- Maria Fernanda Resendiz Mejia
- Miguel de Jesus Zavala Romo
