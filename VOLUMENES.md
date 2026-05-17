# 📦 Documentación de Volúmenes Docker - Innovatech App

## Estrategia de Persistencia de Datos

Este proyecto utiliza **Named Volumes** de Docker para garantizar la persistencia de datos críticos entre reinicios de contenedores.

---

## 🗂️ Volúmenes Definidos

### 1. `db-data` - Base de Datos MySQL

**Tipo:** Named Volume  
**Ruta del contenedor:** `/var/lib/mysql`  
**Propósito:** Almacenar toda la información de la base de datos MySQL

```yaml
volumes:
  db-data:
    name: innovatech-db-data
    driver: local
```

**Contenido persistido:**
- ✅ Tablas y registros de la base de datos
- ✅ Índices y metadatos
- ✅ Logs de transacciones
- ✅ Configuraciones de MySQL

**Justificación:**
- Los datos de la BD son **críticos** y no deben perderse
- Sin este volumen, cada reinicio eliminaría todos los usuarios, productos, etc.
- Permite actualizaciones del contenedor sin pérdida de información

---

### 2. `backend-data` - Datos de Aplicación Backend

**Tipo:** Named Volume  
**Ruta del contenedor:** `/app/data`  
**Propósito:** Almacenar archivos generados por la aplicación backend

```yaml
volumes:
  backend-data:
    name: innovatech-backend-data
    driver: local
```

**Contenido persistido:**
- ✅ Archivos subidos por usuarios (uploads)
- ✅ Logs de aplicación
- ✅ Caché de datos procesados
- ✅ Reportes generados

**Justificación:**
- Preserva archivos importantes entre despliegues
- Facilita debugging mediante logs persistentes
- Evita recargar archivos grandes en cada reinicio

---

### 3. Bind Mount - Scripts SQL de Inicialización

**Tipo:** Bind Mount (solo lectura)  
**Ruta del host:** `./db/init.sql`  
**Ruta del contenedor:** `/docker-entrypoint-initdb.d/init.sql`

```yaml
volumes:
  - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
```

**Propósito:**
- Ejecutar scripts SQL automáticamente al crear el contenedor de BD por primera vez
- Crear tablas iniciales, usuarios, y datos semilla

**Justificación del Bind Mount:**
- Necesitamos **modificar** el script SQL desde el host durante desarrollo
- El archivo debe estar en control de versiones (Git)
- Es un archivo de configuración, no datos persistentes

---

## 🔄 Named Volumes vs Bind Mounts

### ¿Por qué elegimos Named Volumes?

#### ✅ **Ventajas de Named Volumes:**

1. **Portabilidad entre sistemas operativos**
   - Funcionan igual en Windows, Linux y macOS
   - Docker gestiona la ubicación automáticamente
   - No dependen de rutas absolutas del host

2. **Mejor rendimiento**
   - Especialmente en Windows y macOS con Docker Desktop
   - Acceso más rápido que bind mounts en sistemas no-Linux
   - Optimizados para operaciones de I/O intensivas

3. **Gestión simplificada**
   ```bash
   docker volume ls              # Listar volúmenes
   docker volume inspect db-data # Ver detalles
   docker volume backup          # Respaldo fácil
   docker volume prune           # Limpiar volúmenes sin usar
   ```

4. **Seguridad**
   - Aislados del filesystem del host
   - No exponen rutas internas del sistema
   - Menor riesgo de modificación accidental

5. **Compatibilidad con orquestadores**
   - Funciona nativamente con Docker Swarm
   - Compatible con Kubernetes mediante PersistentVolumes
   - Facilita migración a cloud (AWS ECS, Azure Container Instances)

#### ❌ **Desventajas de Bind Mounts:**

1. **Dependencia de rutas del host**
   ```yaml
   # ❌ Malo - ruta absoluta no portable
   volumes:
     - C:\Users\Usuario\data:/app/data  # Solo funciona en Windows
   ```

2. **Problemas de permisos**
   - Especialmente en Linux con UIDs diferentes
   - Puede requerir cambiar permisos del host

3. **Rendimiento reducido**
   - En Windows/macOS, Docker Desktop usa virtualización
   - Los bind mounts pasan por capa de traducción

---

## 📊 Comparativa Técnica

| Característica | Named Volume | Bind Mount |
|----------------|--------------|------------|
| **Portabilidad** | ✅ Alta | ❌ Baja (rutas específicas) |
| **Rendimiento** | ✅ Óptimo | ⚠️ Depende del SO |
| **Gestión** | ✅ Docker CLI | ⚠️ Sistema de archivos |
| **Respaldos** | ✅ `docker volume backup` | ⚠️ Herramientas del SO |
| **Desarrollo** | ⚠️ Menos conveniente | ✅ Edición directa |
| **Producción** | ✅ Recomendado | ❌ No recomendado |
| **Seguridad** | ✅ Aislado | ⚠️ Expone filesystem |

---

## 🛠️ Comandos Útiles

### Ver volúmenes creados
```bash
docker volume ls
```

### Inspeccionar un volumen
```bash
docker volume inspect innovatech-db-data
docker volume inspect innovatech-backend-data
```

### Respaldo de volumen
```bash
# Crear backup de la base de datos
docker run --rm \
  -v innovatech-db-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/db-backup.tar.gz -C /data .
```

### Restaurar volumen desde backup
```bash
docker run --rm \
  -v innovatech-db-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/db-backup.tar.gz -C /data
```

### Eliminar volúmenes (⚠️ Cuidado - elimina datos)
```bash
docker-compose down -v  # Elimina volúmenes definidos en compose
docker volume rm innovatech-db-data  # Eliminar volumen específico
```

### Ver ubicación física del volumen
```bash
docker volume inspect innovatech-db-data --format '{{ .Mountpoint }}'
```

---

## 🎯 Conclusión

**Elegimos Named Volumes porque:**

1. ✅ Este proyecto debe funcionar en **cualquier sistema operativo**
2. ✅ Priorizamos **producción** sobre conveniencia de desarrollo
3. ✅ Necesitamos **portabilidad** para trabajar en equipo
4. ✅ Queremos **mejor rendimiento** en Windows/macOS
5. ✅ Facilitamos **respaldos** y **migración a cloud**

**Cuándo usar Bind Mounts:**
- ⚠️ Solo para archivos de configuración (como `init.sql`)
- ⚠️ Durante desarrollo cuando necesitas editar código en tiempo real
- ⚠️ Para compartir código fuente con hot-reload

---

## 📚 Referencias

- [Docker Volumes Documentation](https://docs.docker.com/storage/volumes/)
- [Best Practices for Docker Volumes](https://docs.docker.com/storage/#choose-the-right-type-of-mount)
- [Docker Compose Volumes Reference](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes)

---

**Fecha:** 2026-05-17  
**Proyecto:** Innovatech App  
**Autor:** Equipo de Desarrollo
