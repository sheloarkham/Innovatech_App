#  Workflows CI/CD - GitHub Actions

Este directorio contiene los pipelines de CI/CD para automatizar el despliegue de Innovatech App.

##  Archivos Disponibles

### **Opción 1: Amazon ECR** (Recomendado para AWS)
- [`backend-deploy.yml`](backend-deploy.yml) - Pipeline backend con ECR
- [`frontend-deploy.yml`](frontend-deploy.yml) - Pipeline frontend con ECR

### **Opción 2: Docker Hub** (Alternativa gratuita)
- [`backend-deploy-dockerhub.yml`](backend-deploy-dockerhub.yml) - Pipeline backend con Docker Hub
- [`frontend-deploy-dockerhub.yml`](frontend-deploy-dockerhub.yml) - Pipeline frontend con Docker Hub

---

## ⚙️ ¿Cuál usar?

### Usa **Amazon ECR** si:
-  Tienes cuenta de AWS
-  Usarás otros servicios AWS (ECS, EKS, Lambda)
-  Necesitas repositorios privados ilimitados
-  Mejor integración con IAM

### Usa **Docker Hub** si:
-  No tienes cuenta AWS
-  Quieres algo más simple y rápido
-  Repositorio público está bien (o tienes plan Pro)
-  Prefieres no configurar IAM

---

## 🔧 Configuración

### 1️ **Elegir workflows**

#### Para ECR:
Los archivos `backend-deploy.yml` y `frontend-deploy.yml` están listos.

#### Para Docker Hub:
Renombra o desactiva los workflows de ECR y activa los de Docker Hub:

```bash
# Desactivar ECR (opcional)
mv .github/workflows/backend-deploy.yml .github/workflows/backend-deploy.yml.disabled
mv .github/workflows/frontend-deploy.yml .github/workflows/frontend-deploy.yml.disabled

# Activar Docker Hub
mv .github/workflows/backend-deploy-dockerhub.yml .github/workflows/backend-deploy.yml
mv .github/workflows/frontend-deploy-dockerhub.yml .github/workflows/frontend-deploy.yml
```

O simplemente **elimina los que no uses**.

---

### 2️ **Configurar Secrets**

Ver documentación completa en [`SECRETS.md`](../SECRETS.md)

#### Secrets para ECR:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_ACCOUNT_ID
EC2_HOST
EC2_USER
EC2_SSH_KEY
DB_HOST
DB_USER
DB_PASS
DB_NAME
VITE_API_URL
```

#### Secrets para Docker Hub:
```
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
EC2_HOST
EC2_USER
EC2_SSH_KEY
DB_HOST
DB_USER
DB_PASS
DB_NAME
VITE_API_URL
```

---

### 3️⃣ **Preparar EC2**

Tu instancia EC2 debe tener:
- ✅ Docker instalado
- ✅ AWS CLI instalado (solo para ECR)
- ✅ Puertos 22, 80, 3000 abiertos
- ✅ Usuario con permisos Docker

```bash
# Conectarse a EC2
ssh -i tu-clave.pem ubuntu@tu-ec2-ip

# Instalar Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu

# Solo para ECR: Instalar AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
```

---

### 4️⃣ **Crear repositorios**

#### Para ECR:
```bash
aws ecr create-repository --repository-name innovatech-backend --region us-east-1
aws ecr create-repository --repository-name innovatech-frontend --region us-east-1
```

#### Para Docker Hub:
```bash
# Crear repositorios manualmente en https://hub.docker.com/
# O dejar que se creen automáticamente en el primer push
```

---

## 🚀 Uso

### Trigger automático
```bash
# Los pipelines se disparan al hacer push a la rama 'deploy'
git checkout -b deploy
git add .
git commit -m "Deploy to production"
git push origin deploy
```

### Trigger manual
```
GitHub → Actions → Seleccionar workflow → Run workflow → Run workflow
```

---

## 📊 Flujo de los Pipelines

```
1. Push a rama 'deploy'
      ↓
2. GitHub Actions detecta el cambio
      ↓
3. Checkout del código
      ↓
4. Login a ECR/Docker Hub
      ↓
5. Build de imagen Docker
      ↓
6. Scan de vulnerabilidades (opcional)
      ↓
7. Push de imagen al registry
      ↓
8. SSH a instancia EC2
      ↓
9. Pull de nueva imagen
      ↓
10. Stop del contenedor viejo
      ↓
11. Start del contenedor nuevo
      ↓
12. Health check
      ↓
13. ✅ Deployment exitoso
      ↓
14. (Si falla) → Rollback automático
```

---

## 🔍 Características de los Pipelines

### ✅ **Incluido:**
- Multi-stage builds optimizados
- Versionado con SHA del commit
- Health checks automáticos
- Rollback en caso de fallo
- Limpieza de imágenes viejas
- Escaneo de vulnerabilidades
- Ejecución manual disponible
- Logs detallados

### 📝 **Jobs incluidos:**
1. **build-and-push**: Construye y sube imagen
2. **deploy**: Despliega a EC2
3. **rollback**: Revierte en caso de error

---

## 🧪 Testing Local

Antes de hacer push, prueba localmente:

```bash
# Backend
cd backend
docker build -t test-backend -f dockerfile .
docker run -p 3000:3000 test-backend

# Frontend
cd frontend
docker build -t test-frontend -f dockerfile .
docker run -p 80:80 test-frontend
```

---

## 📦 Versionado de Imágenes

Cada imagen se tagea con:
- **SHA del commit**: `innovatech-backend:a1b2c3d`
- **Latest**: `innovatech-backend:latest`

Ejemplo:
```
ECR:
123456789012.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend:a1b2c3d
123456789012.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend:latest

Docker Hub:
tuusuario/innovatech-backend:a1b2c3d
tuusuario/innovatech-backend:latest
```

---

## ⚠️ Troubleshooting

Ver sección completa en [`SECRETS.md`](../SECRETS.md)

### Error común: Repository not found
```bash
# ECR: Crear repositorio
aws ecr create-repository --repository-name innovatech-backend

# Docker Hub: Crear en web o dejar que se cree automáticamente
```

### Error: Permission denied (publickey)
```bash
# Verificar que EC2_SSH_KEY está completo
# Verificar usuario correcto (ubuntu vs ec2-user)
```

---

## 🔒 Seguridad

- ✅ Secrets encriptados en GitHub
- ✅ No se hardcodean credenciales
- ✅ SSH keys seguras
- ✅ Escaneo de vulnerabilidades
- ✅ Limpieza automática de imágenes

---

## 📚 Referencias

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [AWS ECR](https://aws.amazon.com/ecr/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
