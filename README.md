# Proyecto-Sistema05

# Sistema de RecolecciÃ³n de Reciclables

Proyecto final de la materia **ProgramaciÃ³n de Dispositivos MÃ³viles**.

## DescripciÃ³n

Sistema multiplataforma que permite a los usuarios registrar solicitudes de recolecciÃ³n de materiales reciclables, adjuntar evidencias fotogrÃ¡ficas, indicar su ubicaciÃ³n y consultar el estado de sus solicitudes.

Los operadores podrÃ¡n administrar las solicitudes, actualizar su estado y registrar las recolecciones realizadas.

## TecnologÃ­as utilizadas

- **Frontend:** Flutter y Dart.
- **Backend:** Node.js y Express.
- **Base de datos:** MySQL.
- **ComunicaciÃ³n:** API REST mediante HTTP y JSON.
- **AutenticaciÃ³n:** JSON Web Tokens (JWT).
- **Control de versiones:** Git y GitHub.

## Estructura del proyecto

```text
Proyecto-Sistema05/
â”œâ”€â”€ frontend/       # AplicaciÃ³n Flutter
â”œâ”€â”€ backend/        # Servidor Node.js y Express
â”‚   â”œâ”€â”€ scripts/    # Scripts auxiliares
â”‚   â”œâ”€â”€ src/
â”‚   â”‚   â”œâ”€â”€ config/       # ConfiguraciÃ³n de base de datos
â”‚   â”‚   â”œâ”€â”€ controllers/  # Controladores
â”‚   â”‚   â”œâ”€â”€ middlewares/  # AutenticaciÃ³n, roles y errores
â”‚   â”‚   â”œâ”€â”€ routes/       # Rutas de la API
â”‚   â”‚   â””â”€â”€ services/     # Servicios de autenticaciÃ³n
â”‚   â”œâ”€â”€ uploads/    # Archivos subidos
â”‚   â”œâ”€â”€ server.js
â”‚   â”œâ”€â”€ package.json
â”‚   â””â”€â”€ .env.example
â”œâ”€â”€ database/
â”‚   â”œâ”€â”€ schema.sql  # CreaciÃ³n de la base de datos y tablas
â”‚   â””â”€â”€ seed.sql    # Datos iniciales de prueba
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ diagramas/      # Diagramas del sistema
â”‚   â””â”€â”€ api-contract.md # Contrato de comunicaciÃ³n de la API
â”œâ”€â”€ .github/        # Plantillas de colaboraciÃ³n
â”œâ”€â”€ .gitignore
â””â”€â”€ README.md
```

## Requisitos previos

Para ejecutar el proyecto localmente se necesita:

- Flutter SDK.
- Node.js 24.
- MySQL.
- Git.
- Visual Studio Code u otro editor compatible.

## InstalaciÃ³n

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

Para ejecutar en Android o Windows, seleccionar el dispositivo compatible mediante:

```bash
flutter devices
```

## ConfiguraciÃ³n de la conexiÃ³n con el backend (Flutter)

La aplicaciÃ³n Flutter utiliza una URL base configurable para comunicarse con la API. La configuraciÃ³n se encuentra centralizada en `frontend/lib/core/api_config.dart`.

### URLs segÃºn el dispositivo

| Plataforma | URL base |
|---|---|
| Web (Chrome) | `http://localhost:3000/api` |
| Windows | `http://localhost:3000/api` |
| Emulador Android | `http://10.0.2.2:3000/api` |
| Celular fÃ­sico | `http://IP_DE_LA_PC:3000/api` |

**Celular fÃ­sico:** reemplazar `IP_DE_LA_PC` por la direcciÃ³n IPv4 de la computadora donde se ejecuta el backend. Ambos dispositivos deben estar conectados a la misma red Wi-Fi. TambiÃ©n es necesario permitir las conexiones al puerto 3000 en el firewall si corresponde.

### ConfiguraciÃ³n personalizada

La URL tambiÃ©n puede modificarse al ejecutar Flutter, sin cambiar el cÃ³digo:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

Para Android fÃ­sico, por ejemplo:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
```

Reemplazar `192.168.1.100` por la IPv4 real de la computadora.

### Requisitos de conexiÃ³n

- El servidor backend debe estar ejecutÃ¡ndose.
- La API debe estar disponible en el puerto 3000.
- La ruta de verificaciÃ³n de conexiÃ³n es `GET /api/health`.
- La ruta `GET /api/health/db` permite comprobar la conexiÃ³n con MySQL.
- Si no se puede conectar al servidor, la aplicaciÃ³n muestra un mensaje de error en lugar de cerrarse.

### 3. Configurar el backend

Desde la raÃ­z del proyecto:

```bash
cd backend
npm install
```

Crear el archivo `.env` a partir de `.env.example` y configurar las variables correspondientes:

```env
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=recoleccion_reciclables

JWT_SECRET=coloca_aqui_una_clave_segura
JWT_EXPIRES_IN=1d
```

Se debe establecer una clave segura para `JWT_SECRET` y configurar los datos de acceso correspondientes a MySQL.

Iniciar el servidor en modo desarrollo:

```bash
npm run dev
```

TambiÃ©n se puede iniciar en modo normal:

```bash
npm start
```

La API estarÃ¡ disponible, de forma predeterminada, en:

`http://localhost:3000`

Rutas de verificaciÃ³n:

- `GET http://localhost:3000/api/health`
- `GET http://localhost:3000/api/health/db`

### 4. Configurar la base de datos

Los archivos de la base de datos se encuentran en `database/`.

- `schema.sql`: crea la base de datos `recoleccion_reciclables` y sus tablas.
- `seed.sql`: inserta datos iniciales y cuentas de prueba.

Para preparar la base de datos, ejecutar los scripts en este orden desde MySQL:

```sql
SOURCE ruta/al/proyecto/database/schema.sql;
SOURCE ruta/al/proyecto/database/seed.sql;
```

El esquema contiene las siguientes tablas:

| Tabla | DescripciÃ³n |
|---|---|
| `usuarios` | Cuentas, contraseÃ±as cifradas y roles. |
| `categorias` | Tipos de materiales reciclables. |
| `solicitudes` | Solicitudes de recolecciÃ³n, ubicaciÃ³n y estado. |
| `evidencias` | Archivos asociados a las solicitudes. |
| `historial` | Registro de acciones y cambios de estado. |

El archivo `seed.sql` incluye dos cuentas de prueba (usuario y operador), cuatro categorÃ­as de materiales y cuatro solicitudes de ejemplo.

### 5. Endpoints implementados

Actualmente, el backend cuenta con los siguientes endpoints implementados:

| MÃ©todo | Ruta | DescripciÃ³n | Acceso |
|---|---|---|---|
| GET | `/api/health` | Verificar el estado del servidor. | PÃºblico |
| GET | `/api/health/db` | Verificar la conexiÃ³n con MySQL. | PÃºblico |
| POST | `/api/auth/registro` | Registrar un usuario. | PÃºblico |
| POST | `/api/auth/login` | Iniciar sesiÃ³n y obtener un JWT. | PÃºblico |
| GET | `/api/auth/me` | Consultar los datos del usuario autenticado. | Autenticado |

La autenticaciÃ³n utiliza JWT mediante el encabezado:

```http
Authorization: Bearer TOKEN_JWT
```

El registro pÃºblico asigna el rol `usuario`. Las cuentas de operador se preparan mediante el script de datos iniciales.

### 6. DocumentaciÃ³n de la API

El archivo `docs/api-contract.md` contiene el contrato de comunicaciÃ³n entre Flutter y el backend.

En Ã©l se describen las rutas previstas para los mÃ³dulos de:

- AutenticaciÃ³n y usuarios.
- CategorÃ­as de materiales.
- Solicitudes de recolecciÃ³n.
- Cambios de estado.
- Historial.
- Evidencias fotogrÃ¡ficas.

**Importante:** el contrato define las especificaciones de comunicaciÃ³n del sistema. No todos los endpoints descritos se encuentran implementados todavÃ­a. Para conocer las rutas disponibles actualmente, consultar la secciÃ³n de endpoints implementados de este README y el cÃ³digo del backend.

## OrganizaciÃ³n del trabajo

El desarrollo se realiza mediante ramas independientes.

1. Crear un Issue para la actividad.
2. Crear una rama desde `main`.
3. Implementar y probar los cambios.
4. Realizar commits descriptivos.
5. Crear un Pull Request.
6. Solicitar revisiÃ³n de otro integrante antes de integrar los cambios.

No se desarrolla directamente sobre `main`.

## Estado actual

El proyecto cuenta con la estructura principal del frontend, backend y base de datos.

- AplicaciÃ³n Flutter con pantallas de autenticaciÃ³n, navegaciÃ³n y perfil.
- Preferencia de tema claro y oscuro con persistencia local.
- Servidor Node.js y Express configurado.
- ConexiÃ³n con MySQL mediante un pool de conexiones.
- Esquema de base de datos con cinco tablas y relaciones.
- Datos iniciales de prueba para usuarios, categorÃ­as y solicitudes.
- AutenticaciÃ³n mediante registro, inicio de sesiÃ³n y consulta del usuario actual.
- Middleware de autenticaciÃ³n, autorizaciÃ³n por roles y manejo de errores.
- Contrato de API y documentaciÃ³n tÃ©cnica.

Los mÃ³dulos de categorÃ­as, administraciÃ³n de solicitudes, historial y evidencias se encuentran contemplados en el contrato de API y estÃ¡n pendientes de completar su implementaciÃ³n.

## Integrantes

- Tania Paola Garcia Meza
- Lorenzo Antonio Pacheco Leyva
- Maria Fernanda Resendiz Mejia
- Miguel de Jesus Zavala Romo
