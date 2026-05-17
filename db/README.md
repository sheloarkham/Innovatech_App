# 🗄️ Base de Datos - Innovatech App

Este directorio contiene scripts SQL para inicializar la base de datos MySQL.

## 📁 Archivos

### `init.sql`
Script de inicialización que se ejecuta automáticamente al crear el contenedor de MySQL por primera vez.

**Contenido:**
- ✅ Creación de tablas (`users`, `products`, `orders`, `order_items`)
- ✅ Definición de índices para optimización
- ✅ Relaciones entre tablas (Foreign Keys)
- ✅ Datos de prueba (seed data)

## 🚀 Cómo funciona

El archivo se monta en el contenedor mediante un **bind mount** en `docker-compose.yml`:

```yaml
volumes:
  - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
```

MySQL ejecuta automáticamente todos los archivos `.sql` en `/docker-entrypoint-initdb.d/` al inicializar el contenedor por primera vez.

## 🔄 Ejecutar scripts manualmente

Si necesitas ejecutar el script después de que el contenedor ya existe:

```bash
# Desde el host
docker exec -i innovatech-db mysql -uroot -padmin123 innovatech < db/init.sql

# Desde dentro del contenedor
docker exec -it innovatech-db mysql -uroot -padmin123 innovatech
source /docker-entrypoint-initdb.d/init.sql;
```

## 📊 Estructura de tablas

- **users**: Usuarios del sistema
- **products**: Catálogo de productos
- **orders**: Órdenes de compra
- **order_items**: Detalles de productos en cada orden

## ⚠️ Nota importante

Este script solo se ejecuta si la base de datos está vacía. Si quieres reiniciar:

```bash
# Eliminar volumen de base de datos
docker-compose down -v
docker-compose up -d
```
