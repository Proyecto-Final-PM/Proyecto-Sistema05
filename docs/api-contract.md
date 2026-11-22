# Contrato de la API REST

## Sistema de Recolección de Reciclables

## 1. Introducción

Este documento define el contrato de comunicación entre la aplicación Flutter y el backend desarrollado con Node.js y Express.

Establece las rutas, métodos HTTP, estructuras JSON, permisos y respuestas que utilizarán los distintos módulos del sistema. Es la referencia para desarrollar el frontend y el backend de forma coordinada.

## 2. Configuración general

**URL base local:** `http://localhost:3000/api`

La dirección cambia según el dispositivo desde el que se acceda al backend (emulador Android, navegador, celular físico). Las rutas de este documento ya incluyen el prefijo `/api`.

**Formato de comunicación:**

- Protocolo: HTTP durante el desarrollo local.
- Formato de datos: JSON (excepto la subida de imágenes, que usa `multipart/form-data`).
- Codificación: UTF-8.
- Autenticación: JWT mediante Bearer Token.

### 2.1. Resumen de endpoints

| Método | Ruta | Acceso | Descripción |
|---|---|---|---|
| GET | `/api/health` | Público | Estado del servidor |
| GET | `/api/health/db` | Público | Estado de la conexión a MySQL |
| POST | `/api/auth/registro` | Público | Registrar usuario |
| POST | `/api/auth/login` | Público | Iniciar sesión |
| GET | `/api/auth/me` | Autenticado | Usuario actual |
| GET | `/api/categorias` | Autenticado | Listar categorías |
| GET | `/api/categorias/:id` | Autenticado | Consultar categoría |
| POST | `/api/categorias` | Operador | Crear categoría |
| PUT | `/api/categorias/:id` | Operador | Modificar categoría |
| POST | `/api/solicitudes` | Usuario | Crear solicitud |
| GET | `/api/solicitudes` | Autenticado | Listar, buscar y filtrar solicitudes |
| GET | `/api/solicitudes/:id` | Propietario u operador | Detalle de solicitud |
| PUT | `/api/solicitudes/:id` | Propietario | Modificar solicitud |
| PATCH | `/api/solicitudes/:id/cancelar` | Propietario | Cancelar solicitud |
| PATCH | `/api/solicitudes/:id/estado` | Operador | Cambiar estado o finalizar |
| GET | `/api/solicitudes/:id/historial` | Propietario u operador | Historial de la solicitud |
| POST | `/api/solicitudes/:id/evidencias` | Propietario u operador | Subir fotografía |
| GET | `/api/solicitudes/:id/evidencias` | Propietario u operador | Listar evidencias |
| GET | `/api/evidencias/:id/archivo` | Propietario u operador | Descargar la imagen |

## 3. Convenciones de datos

| Elemento | Convención |
|---|---|
| Nombres de campos | snake_case |
| Identificadores | Números enteros |
| Llaves foráneas | usuario_id, categoria_id, solicitud_id |
| Roles | `usuario`, `operador` |
| Estados | `solicitada`, `aceptada`, `en_recoleccion`, `finalizada` |
| Acciones del historial | `creacion`, `modificacion`, `cambio_estado`, `cancelacion` |
| Fechas | ISO 8601 en UTC (`2026-11-20T15:30:00Z`) |
| Cantidad recolectada | Número decimal en kilogramos |
| Ubicación | `latitud` y `longitud` como números |
| Contraseñas | Nunca se incluyen en las respuestas |

Los nombres visibles de los estados (por ejemplo, «En recolección») se resuelven en la pantalla de Flutter. En la base de datos y en la API siempre se usan los valores de la tabla.

### 3.1. Cancelación de solicitudes

Las solicitudes se cancelan sin eliminar su registro, mediante el campo booleano `cancelada`:

- `false`: la solicitud no está cancelada (valor por defecto).
- `true`: la solicitud fue cancelada.

Ejemplo:

```json
{
  "id": 1,
  "usuario_id": 3,
  "categoria_id": 2,
  "estado": "solicitada",
  "cancelada": true
}
```

Reglas:

- La cancelación no modifica `estado`, que conserva uno de los cuatro estados establecidos.
- Una solicitud cancelada no puede modificarse, avanzar de estado ni finalizarse.
- Solo se pueden cancelar solicitudes en estado `solicitada` (regla inicial por confirmar con el equipo).
- La cancelación queda registrada en el historial con la acción `cancelacion`.

## 4. Autenticación

Los endpoints protegidos requieren un token JWT en el encabezado:

```http
Authorization: Bearer TOKEN_JWT
```

Los endpoints públicos (salud del servidor, registro e inicio de sesión) no requieren token.

Los permisos dependen del rol:

- `usuario`: crea, consulta, modifica y cancela sus propias solicitudes, y agrega evidencias a ellas.
- `operador`: consulta todas las solicitudes, cambia su estado, las finaliza y agrega evidencias.

El backend verifica los permisos de forma independiente de las restricciones visuales del frontend. El identificador del usuario siempre se obtiene del token, nunca del body.

## 5. Formato de errores

Cuando ocurre un error, la API devuelve un código HTTP y un objeto JSON con la misma estructura:

```json
{
  "error": "No tienes permisos para realizar esta acción"
}
```

| Código | Significado |
|---|---|
| 200 | Solicitud procesada correctamente |
| 201 | Recurso creado correctamente |
| 400 | Datos inválidos o regla de negocio incumplida |
| 401 | Token ausente, inválido o vencido |
| 403 | Usuario autenticado sin permisos |
| 404 | Recurso no encontrado |
| 409 | Conflicto con el estado actual del recurso |
| 413 | Archivo demasiado grande |
| 500 | Error interno del servidor |

**Error común 401.** Todos los endpoints protegidos pueden responder:

```json
{
  "error": "Token ausente, inválido o vencido"
}
```

## 6. Estado del servidor

### 6.1. Salud del servidor

**Método:** GET · **Ruta:** `/api/health` · **Acceso:** Público

Comprueba que el servidor está funcionando.

Respuesta — 200 OK:

```json
{
  "status": "ok"
}
```

### 6.2. Salud de la base de datos

**Método:** GET · **Ruta:** `/api/health/db` · **Acceso:** Público

Comprueba la conexión del backend con MySQL.

Respuesta — 200 OK:

```json
{
  "status": "ok",
  "base_de_datos": "conectada"
}
```

Error — 500:

```json
{
  "error": "No se pudo conectar con la base de datos"
}
```

## 7. Autenticación y usuarios

El registro público asigna siempre el rol `usuario`. La cuenta de `operador` se crea en el script `seed.sql` (con la contraseña ya cifrada) y no se puede obtener mediante el registro.

### 7.1. Registrar usuario

**Método:** POST · **Ruta:** `/api/auth/registro` · **Acceso:** Público

Registra una cuenta nueva.

Body JSON:

```json
{
  "nombre": "Ana López",
  "correo": "ana@example.com",
  "password": "ClaveSegura123!"
}
```

Validaciones:

- El nombre es obligatorio.
- El correo debe tener formato válido y no estar registrado.
- La contraseña es obligatoria y tiene mínimo 8 caracteres.
- El usuario no puede elegir su rol.

Respuesta — 201 Created:

```json
{
  "mensaje": "Usuario registrado correctamente",
  "usuario": {
    "id": 1,
    "nombre": "Ana López",
    "correo": "ana@example.com",
    "rol": "usuario"
  }
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `Los datos de registro son inválidos` |
| 409 | `El correo ya está registrado` |

Seguridad: la contraseña se guarda como hash (bcrypt). `password_hash` nunca se devuelve.

### 7.2. Iniciar sesión

**Método:** POST · **Ruta:** `/api/auth/login` · **Acceso:** Público

Autentica con correo y contraseña.

Body JSON:

```json
{
  "correo": "ana@example.com",
  "password": "ClaveSegura123!"
}
```

Respuesta — 200 OK:

```json
{
  "mensaje": "Inicio de sesión exitoso",
  "token": "TOKEN_JWT_GENERADO",
  "tipo_token": "Bearer",
  "usuario": {
    "id": 1,
    "nombre": "Ana López",
    "correo": "ana@example.com",
    "rol": "usuario"
  }
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El correo y la contraseña son obligatorios` |
| 401 | `Credenciales incorrectas` |

Seguridad: el JWT se firma con `JWT_SECRET`, expira según `JWT_EXPIRES_IN` y contiene el id y el rol del usuario. Nunca se devuelve la contraseña ni su hash.

### 7.3. Consultar usuario actual

**Método:** GET · **Ruta:** `/api/auth/me` · **Acceso:** Autenticado (`usuario` u `operador`)

Devuelve los datos del usuario del token.

Respuesta — 200 OK:

```json
{
  "id": 1,
  "nombre": "Ana López",
  "correo": "ana@example.com",
  "rol": "usuario"
}
```

Errores:

| Código | Mensaje |
|---|---|
| 401 | Error común |
| 404 | `Usuario no encontrado` |

## 8. Categorías de materiales reciclables

Las categorías clasifican los materiales. Las iniciales son: Plástico, Papel, Vidrio y Metal. Se leen siempre desde la base de datos.

### 8.1. Listar categorías

**Método:** GET · **Ruta:** `/api/categorias` · **Acceso:** Autenticado

Respuesta — 200 OK:

```json
[
  { "id": 1, "nombre": "Plástico" },
  { "id": 2, "nombre": "Papel" },
  { "id": 3, "nombre": "Vidrio" },
  { "id": 4, "nombre": "Metal" }
]
```

Si no hay categorías se devuelve `[]`. Error: 401 (común).

### 8.2. Consultar categoría por ID

**Método:** GET · **Ruta:** `/api/categorias/:id` · **Acceso:** Autenticado

Respuesta — 200 OK:

```json
{
  "id": 1,
  "nombre": "Plástico"
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El identificador de la categoría no es válido` |
| 401 | Error común |
| 404 | `Categoría no encontrada` |

### 8.3. Crear categoría

**Método:** POST · **Ruta:** `/api/categorias` · **Acceso:** Solo `operador`

Body JSON:

```json
{
  "nombre": "Cartón"
}
```

Validaciones: el nombre es obligatorio, no puede estar vacío y no puede repetirse.

Respuesta — 201 Created:

```json
{
  "id": 5,
  "nombre": "Cartón"
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El nombre de la categoría es obligatorio` |
| 401 | Error común |
| 403 | `No tienes permisos para crear categorías` |
| 409 | `La categoría ya existe` |

### 8.4. Modificar categoría

**Método:** PUT · **Ruta:** `/api/categorias/:id` · **Acceso:** Solo `operador`

Body JSON:

```json
{
  "nombre": "Cartón reciclable"
}
```

Respuesta — 200 OK:

```json
{
  "id": 5,
  "nombre": "Cartón reciclable"
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El nombre de la categoría no es válido` |
| 401 | Error común |
| 403 | `No tienes permisos para modificar categorías` |
| 404 | `Categoría no encontrada` |
| 409 | `Ya existe otra categoría con ese nombre` |

## 9. Solicitudes de recolección

Cada solicitud pertenece a un usuario y está asociada a una categoría.

### 9.1. Estructura de una solicitud

```json
{
  "id": 1,
  "usuario_id": 3,
  "categoria_id": 2,
  "descripcion": "Cajas de cartón y hojas usadas",
  "direccion": "Av. Universidad 100",
  "latitud": 21.9123456,
  "longitud": -102.3123456,
  "estado": "solicitada",
  "cancelada": false,
  "cantidad_recolectada": null,
  "fecha_creacion": "2026-11-20T15:30:00Z"
}
```

| Campo | Tipo JSON | Descripción |
|---|---|---|
| id | number (entero) | Identificador de la solicitud |
| usuario_id | number (entero) | Usuario que creó la solicitud |
| categoria_id | number (entero) | Categoría del material |
| descripcion | string | Descripción de los materiales |
| direccion | string | Dirección de recolección |
| latitud | number | Coordenada geográfica |
| longitud | number | Coordenada geográfica |
| estado | string | Estado actual |
| cancelada | boolean | Indica si fue cancelada |
| cantidad_recolectada | number o null | Kilogramos recolectados |
| fecha_creacion | string | Fecha ISO 8601 en UTC |

### 9.2. Crear solicitud

**Método:** POST · **Ruta:** `/api/solicitudes` · **Acceso:** Solo `usuario`

Body JSON:

```json
{
  "categoria_id": 2,
  "descripcion": "Cajas de cartón y hojas usadas",
  "direccion": "Av. Universidad 100",
  "latitud": 21.9123456,
  "longitud": -102.3123456
}
```

Validaciones:

- La categoría debe existir.
- La descripción y la dirección son obligatorias.
- La latitud está entre -90 y 90, y la longitud entre -180 y 180.
- `usuario_id` se obtiene del token, no del body.
- El estado inicial es `solicitada`, `cancelada` es `false` y `cantidad_recolectada` es `null`.

La fotografía se envía después con el endpoint de evidencias (sección 12.2), usando el `id` de la solicitud creada.

Respuesta — 201 Created:

```json
{
  "mensaje": "Solicitud creada correctamente",
  "solicitud": {
    "id": 1,
    "usuario_id": 3,
    "categoria_id": 2,
    "descripcion": "Cajas de cartón y hojas usadas",
    "direccion": "Av. Universidad 100",
    "latitud": 21.9123456,
    "longitud": -102.3123456,
    "estado": "solicitada",
    "cancelada": false,
    "cantidad_recolectada": null,
    "fecha_creacion": "2026-11-20T15:30:00Z"
  }
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `Los datos de la solicitud son inválidos` |
| 401 | Error común |
| 403 | `No tienes permisos para crear solicitudes` |
| 404 | `La categoría indicada no existe` |

El backend registra la acción `creacion` en el historial.

### 9.3. Listar, buscar y filtrar solicitudes

**Método:** GET · **Ruta:** `/api/solicitudes` · **Acceso:** `usuario` y `operador`

- `usuario`: solo ve sus propias solicitudes.
- `operador`: ve todas.

Parámetros opcionales:

| Parámetro | Ejemplo | Función |
|---|---|---|
| q | botellas | Busca texto en `descripcion` y `direccion` |
| estado | solicitada | Filtra por estado |
| categoria_id | 2 | Filtra por categoría |
| cancelada | false | Filtra por canceladas o no |
| usuario_id | 3 | Filtra por usuario (solo `operador`) |

Los parámetros se pueden combinar. El resultado se ordena de la solicitud más reciente a la más antigua (`fecha_creacion` descendente).

Ejemplo:

```http
GET /api/solicitudes?q=botellas&estado=solicitada&cancelada=false
Authorization: Bearer TOKEN_JWT
```

Respuesta — 200 OK:

```json
[
  {
    "id": 1,
    "usuario_id": 3,
    "categoria_id": 1,
    "descripcion": "Botellas de plástico limpias",
    "direccion": "Av. Universidad 100",
    "latitud": 21.9123456,
    "longitud": -102.3123456,
    "estado": "solicitada",
    "cancelada": false,
    "cantidad_recolectada": null,
    "fecha_creacion": "2026-11-20T15:30:00Z"
  }
]
```

Si ninguna solicitud cumple los filtros se devuelve `[]`.

Errores:

| Código | Mensaje |
|---|---|
| 400 | `Los filtros proporcionados no son válidos` |
| 401 | Error común |
| 403 | `No tienes permisos para filtrar por usuario` |

Regla de seguridad: un `usuario` nunca puede consultar solicitudes ajenas mediante `usuario_id`.

### 9.4. Consultar solicitud por ID

**Método:** GET · **Ruta:** `/api/solicitudes/:id` · **Acceso:** `usuario` propietario u `operador`

Respuesta — 200 OK: el objeto de la sección 9.1.

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El identificador de la solicitud no es válido` |
| 401 | Error común |
| 403 | `No tienes permisos para consultar esta solicitud` |
| 404 | `Solicitud no encontrada` |

### 9.5. Modificar solicitud

**Método:** PUT · **Ruta:** `/api/solicitudes/:id` · **Acceso:** `usuario` propietario

Solo se pueden modificar solicitudes con `estado = solicitada` y `cancelada = false`.

Body JSON:

```json
{
  "categoria_id": 1,
  "descripcion": "Botellas de plástico limpias",
  "direccion": "Av. Universidad 150",
  "latitud": 21.9123456,
  "longitud": -102.3123456
}
```

Respuesta — 200 OK:

```json
{
  "mensaje": "Solicitud actualizada correctamente",
  "solicitud": {
    "id": 1,
    "usuario_id": 3,
    "categoria_id": 1,
    "descripcion": "Botellas de plástico limpias",
    "direccion": "Av. Universidad 150",
    "latitud": 21.9123456,
    "longitud": -102.3123456,
    "estado": "solicitada",
    "cancelada": false,
    "cantidad_recolectada": null,
    "fecha_creacion": "2026-11-20T15:30:00Z"
  }
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `Los datos proporcionados no son válidos` |
| 401 | Error común |
| 403 | `No tienes permisos para modificar esta solicitud` |
| 404 | `Solicitud no encontrada` |
| 409 | `La solicitud ya no puede modificarse` |

Restricción: este endpoint no modifica `usuario_id`, `estado`, `cancelada` ni `cantidad_recolectada`. El backend registra la acción `modificacion` en el historial.

### 9.6. Cancelar solicitud

**Método:** PATCH · **Ruta:** `/api/solicitudes/:id/cancelar` · **Acceso:** `usuario` propietario

Cancela la solicitud sin eliminarla. Solo aplica a solicitudes con `estado = solicitada` y `cancelada = false`. No lleva body.

Respuesta — 200 OK:

```json
{
  "mensaje": "Solicitud cancelada correctamente",
  "solicitud": {
    "id": 1,
    "estado": "solicitada",
    "cancelada": true
  }
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El identificador de la solicitud no es válido` |
| 401 | Error común |
| 403 | `No tienes permisos para cancelar esta solicitud` |
| 404 | `Solicitud no encontrada` |
| 409 | `La solicitud no puede cancelarse en su estado actual` |

Reglas: no se elimina físicamente, `cancelada` cambia a `true`, el estado original se conserva y se registra la acción `cancelacion` en el historial.

## 10. Cambios de estado

Las solicitudes pasan por cuatro estados: `solicitada`, `aceptada`, `en_recoleccion` y `finalizada`. Cambiar el estado es exclusivo del rol `operador`.

### 10.1. Flujo de estados

`solicitada → aceptada → en_recoleccion → finalizada`

- Una solicitud nueva comienza en `solicitada`.
- No se permiten saltos ni retrocesos.
- Una solicitud `finalizada` no puede cambiar de estado.
- Una solicitud con `cancelada = true` no puede cambiar de estado.
- Para finalizar, `cantidad_recolectada` debe ser mayor que cero.

### 10.2. Actualizar estado

**Método:** PATCH · **Ruta:** `/api/solicitudes/:id/estado` · **Acceso:** Solo `operador`

Body JSON:

```json
{
  "estado": "aceptada"
}
```

Respuesta — 200 OK:

```json
{
  "mensaje": "Estado actualizado correctamente",
  "solicitud": {
    "id": 1,
    "estado": "aceptada",
    "cancelada": false,
    "cantidad_recolectada": null
  }
}
```

Validaciones: la solicitud existe, el estado es válido, la transición respeta el flujo, la solicitud no está cancelada ni finalizada.

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El estado proporcionado no es válido` |
| 401 | Error común |
| 403 | `No tienes permisos para cambiar el estado` |
| 404 | `Solicitud no encontrada` |
| 409 | `La transición de estado no está permitida` |

### 10.3. Finalizar una recolección

**Método:** PATCH · **Ruta:** `/api/solicitudes/:id/estado` · **Acceso:** Solo `operador`

Es el mismo endpoint, con la cantidad recolectada. Condiciones: la solicitud está en `en_recoleccion` y no está cancelada.

Body JSON:

```json
{
  "estado": "finalizada",
  "cantidad_recolectada": 12.50
}
```

Respuesta — 200 OK:

```json
{
  "mensaje": "Recolección finalizada correctamente",
  "solicitud": {
    "id": 1,
    "estado": "finalizada",
    "cancelada": false,
    "cantidad_recolectada": 12.50
  }
}
```

Validaciones:

- `cantidad_recolectada` es obligatoria al finalizar, numérica, en kilogramos y mayor que cero.
- No se aceptan cantidades negativas ni iguales a cero.
- Debe respetar la precisión `DECIMAL(10,2)` del almacenamiento: máximo dos decimales y valor máximo 99999999.99.
- Si la validación falla, no cambia el estado ni la cantidad guardada.

Errores específicos:

| Código | Mensaje |
|---|---|
| 400 | `La cantidad recolectada debe ser mayor que cero` |
| 400 | `La cantidad recolectada debe tener máximo dos decimales` |
| 409 | `Solo pueden finalizarse solicitudes en recolección` |

### 10.4. Registro en el historial

Cada cambio de estado exitoso genera un registro en `historial` con la acción `cambio_estado`. La actualización y el registro del historial se hacen en la misma transacción de base de datos; si una falla, se revierten las dos.

## 11. Historial de solicitudes

El historial conserva la trazabilidad de todo lo que ocurre con una solicitud: quién hizo qué y cuándo.

### 11.1. Estructura de un registro

```json
{
  "id": 1,
  "solicitud_id": 5,
  "usuario_id": 2,
  "accion": "cambio_estado",
  "estado_anterior": "solicitada",
  "estado_nuevo": "aceptada",
  "fecha_cambio": "2026-11-20T16:30:00Z"
}
```

| Campo | Tipo JSON | Descripción |
|---|---|---|
| id | number (entero) | Identificador del registro |
| solicitud_id | number (entero) | Solicitud relacionada |
| usuario_id | number (entero) | Usuario u operador que realizó la acción |
| accion | string | `creacion`, `modificacion`, `cambio_estado` o `cancelacion` |
| estado_anterior | string o null | Estado previo (solo en `cambio_estado`) |
| estado_nuevo | string o null | Estado nuevo (solo en `cambio_estado`) |
| fecha_cambio | string | Fecha ISO 8601 en UTC |

### 11.2. Consultar historial de una solicitud

**Método:** GET · **Ruta:** `/api/solicitudes/:id/historial` · **Acceso:** `usuario` propietario u `operador`

Respuesta — 200 OK:

```json
[
  {
    "id": 1,
    "solicitud_id": 5,
    "usuario_id": 3,
    "accion": "creacion",
    "estado_anterior": null,
    "estado_nuevo": null,
    "fecha_cambio": "2026-11-20T15:30:00Z"
  },
  {
    "id": 2,
    "solicitud_id": 5,
    "usuario_id": 2,
    "accion": "cambio_estado",
    "estado_anterior": "solicitada",
    "estado_nuevo": "aceptada",
    "fecha_cambio": "2026-11-20T16:30:00Z"
  }
]
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El identificador de la solicitud no es válido` |
| 401 | Error común |
| 403 | `No tienes permisos para consultar este historial` |
| 404 | `Solicitud no encontrada` |

### 11.3. Reglas del historial

- Se genera automáticamente en cada creación, modificación, cambio de estado y cancelación.
- Cada operación y su registro de historial se ejecutan en una misma transacción.
- Los registros no se pueden modificar ni eliminar mediante la API.
- Se ordenan por `fecha_cambio` ascendente y, en caso de empate, por `id` ascendente.
- El `usuario` solo consulta el historial de sus solicitudes; el `operador` consulta cualquiera.

## 12. Evidencias fotográficas

Las evidencias son las fotografías asociadas a una solicitud. El usuario sube la foto del material al registrar su solicitud, y el operador puede agregar fotos durante la recolección.

La imagen se envía con `multipart/form-data`. El servidor guarda el archivo en `backend/uploads/` con un nombre generado por él, y registra los metadatos en MySQL (tabla `evidencias`, con el nombre del archivo guardado).

### 12.1. Estructura de una evidencia

```json
{
  "id": 1,
  "solicitud_id": 5,
  "usuario_id": 3,
  "url": "/api/evidencias/1/archivo",
  "fecha_subida": "2026-11-20T15:35:00Z"
}
```

| Campo | Tipo JSON | Descripción |
|---|---|---|
| id | number (entero) | Identificador de la evidencia |
| solicitud_id | number (entero) | Solicitud relacionada |
| usuario_id | number (entero) | Usuario u operador que subió la imagen |
| url | string | Ruta de la API para obtener la imagen |
| fecha_subida | string | Fecha ISO 8601 en UTC |

La API nunca devuelve rutas internas del servidor.

### 12.2. Subir evidencia

**Método:** POST · **Ruta:** `/api/solicitudes/:id/evidencias` · **Acceso:** `usuario` propietario u `operador`

Encabezados:

```http
Authorization: Bearer TOKEN_JWT
Content-Type: multipart/form-data
```

Datos enviados:

| Campo | Tipo | Obligatorio |
|---|---|---|
| imagen | Archivo | Sí |

Validaciones:

- La solicitud existe y no está cancelada.
- El `usuario` solo puede subir a sus propias solicitudes y solo mientras estén en estado `solicitada`.
- El `operador` puede subir a cualquier solicitud no cancelada.
- El archivo es una imagen válida (se revisa su contenido, no solo la extensión): JPEG, PNG o WebP.
- Tamaño máximo: 5 MB.
- El nombre del archivo lo genera el servidor; el cliente no envía rutas.
- `usuario_id` se obtiene del token.

Respuesta — 201 Created:

```json
{
  "mensaje": "Evidencia registrada correctamente",
  "evidencia": {
    "id": 1,
    "solicitud_id": 5,
    "usuario_id": 3,
    "url": "/api/evidencias/1/archivo",
    "fecha_subida": "2026-11-20T15:35:00Z"
  }
}
```

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El archivo enviado no es una imagen válida` |
| 401 | Error común |
| 403 | `No tienes permisos para subir evidencias a esta solicitud` |
| 404 | `Solicitud no encontrada` |
| 409 | `No se pueden agregar evidencias a esta solicitud` |
| 413 | `La imagen supera el tamaño máximo permitido` |

### 12.3. Listar evidencias de una solicitud

**Método:** GET · **Ruta:** `/api/solicitudes/:id/evidencias` · **Acceso:** `usuario` propietario u `operador`

Respuesta — 200 OK:

```json
[
  {
    "id": 1,
    "solicitud_id": 5,
    "usuario_id": 3,
    "url": "/api/evidencias/1/archivo",
    "fecha_subida": "2026-11-20T15:35:00Z"
  },
  {
    "id": 2,
    "solicitud_id": 5,
    "usuario_id": 2,
    "url": "/api/evidencias/2/archivo",
    "fecha_subida": "2026-11-21T10:25:00Z"
  }
]
```

Si no hay evidencias se devuelve `[]`.

Errores:

| Código | Mensaje |
|---|---|
| 400 | `El identificador de la solicitud no es válido` |
| 401 | Error común |
| 403 | `No tienes permisos para consultar estas evidencias` |
| 404 | `Solicitud no encontrada` |

### 12.4. Obtener la imagen de una evidencia

**Método:** GET · **Ruta:** `/api/evidencias/:id/archivo` · **Acceso:** `usuario` propietario de la solicitud u `operador`

Devuelve el archivo de imagen. La carpeta `uploads/` no se expone públicamente: todas las imágenes pasan por este endpoint, que revisa el token y los permisos.

Respuesta — 200 OK: contenido de la imagen, con `Content-Type` `image/jpeg`, `image/png` o `image/webp`.

En Flutter se puede mostrar con `Image.network`, enviando el token en el parámetro `headers`.

Errores:

| Código | Mensaje |
|---|---|
| 401 | Error común |
| 403 | `No tienes permisos para ver esta evidencia` |
| 404 | `Evidencia no encontrada` |

### 12.5. Reglas de seguridad

- Un `usuario` solo sube y consulta evidencias de sus propias solicitudes.
- El `operador` consulta las evidencias de cualquier solicitud.
- Los nombres de archivo los genera el backend y no se aceptan rutas del cliente.
- Las imágenes se validan por contenido y tipo; no se ejecutan como código.
- No se expone la carpeta `uploads/` sin comprobar permisos.
- La API no permite eliminar evidencias en esta fase.

## 13. Pendientes por confirmar

Antes de aprobar este contrato, se deben revisar estos puntos:

1. **Esquema MySQL:** que `solicitudes` tenga `descripcion`, `direccion`, `latitud`, `longitud`, `cancelada` y `cantidad_recolectada` (de tipo `DECIMAL(10,2)`); que `historial` tenga `usuario_id` y `accion`; y que `evidencias` guarde `usuario_id` y el nombre del archivo.
2. **Cancelación:** confirmar que solo se cancela en estado `solicitada`.
3. **Cuenta de operador:** crearla en `seed.sql` con la contraseña cifrada.
4. **Contraseña:** confirmar el mínimo de 8 caracteres.
5. **Imágenes:** confirmar formatos (JPEG, PNG, WebP) y tamaño máximo de 5 MB.
6. **Unidad de la cantidad recolectada:** kilogramos.
