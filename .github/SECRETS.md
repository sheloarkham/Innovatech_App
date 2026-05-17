#  Configuración de Secrets para GitHub Actions

Este documento explica cómo configurar los **secrets** necesarios para que los pipelines de CI/CD funcionen correctamente.

##  Ubicación de Secrets

En tu repositorio de GitHub:
```
Settings → Secrets and variables → Actions → New repository secret
```

---

##  Secrets Requeridos

### **Opción A: Amazon ECR (Recomendado para AWS)**

| Secret Name | Descripción | Ejemplo |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | Access Key de IAM con permisos ECR | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de IAM | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_ACCOUNT_ID` | ID de cuenta AWS (12 dígitos) | `123456789012` |
| `EC2_HOST` | IP pública o DNS de la instancia EC2 | `ec2-3-80-123-45.compute-1.amazonaws.com` |
| `EC2_USER` | Usuario SSH en EC2 | `ubuntu` o `ec2-user` |
| `EC2_SSH_KEY` | Clave privada SSH (.pem) completa | `-----BEGIN RSA PRIVATE KEY-----...` |
| `DB_HOST` | Host de base de datos | `db` o `RDS endpoint` |
| `DB_USER` | Usuario de base de datos | `root` |
| `DB_PASS` | Contraseña de base de datos | `admin123` |
| `DB_NAME` | Nombre de base de datos | `innovatech` |
| `VITE_API_URL` | URL del backend para frontend | `http://3.80.123.45:3000` |

### **Opción B: Docker Hub (Alternativa)**

| Secret Name | Descripción | Ejemplo |
|-------------|-------------|---------|
| `DOCKERHUB_USERNAME` | Usuario de Docker Hub | `tu-usuario` |
| `DOCKERHUB_TOKEN` | Access Token de Docker Hub | `dckr_pat_xxxxx` |
| `EC2_HOST` | IP pública de EC2 | `3.80.123.45` |
| `EC2_USER` | Usuario SSH | `ubuntu` |
| `EC2_SSH_KEY` | Clave privada SSH | Ver ejemplo abajo |
| `DB_HOST` | Host de base de datos | `db` |
| `DB_USER` | Usuario de BD | `root` |
| `DB_PASS` | Contraseña de BD | `admin123` |
| `DB_NAME` | Nombre de BD | `innovatech` |
| `VITE_API_URL` | URL del backend | `http://3.80.123.45:3000` |

---

## 🛠️ Cómo Obtener Cada Secret

### 1. **AWS Credentials** (para ECR)

#### Crear usuario IAM:
```bash
# En AWS Console:
IAM → Users → Add user → innovatech-github-actions
```

#### Permisos necesarios:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Obtener las keys:
```
IAM → Users → innovatech-github-actions → Security credentials → Create access key
```

---

### 2. **Docker Hub Token**

```bash
# 1. Ir a Docker Hub
https://hub.docker.com/settings/security

# 2. New Access Token
Nombre: github-actions-innovatech
Permisos: Read, Write

# 3. Copiar el token (solo se muestra una vez)
```

---

### 3. **EC2 SSH Key**

La clave SSH privada completa, incluyendo header y footer:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAxxxxxxxxxxxxxxxxxxxxx...
...todo el contenido de tu archivo .pem...
-----END RSA PRIVATE KEY-----
```

**Cómo obtenerla:**
```bash
# Si ya tienes el archivo .pem
cat /ruta/a/tu-clave.pem

# En Windows
type C:\ruta\a\tu-clave.pem
```

⚠️ **Importante**: Copia **TODO** el contenido, incluyendo las líneas BEGIN y END.

---

### 4. **EC2 Host**

```bash
# En AWS Console:
EC2 → Instances → Tu instancia → Public IPv4 address

# O usando AWS CLI:
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query 'Reservations[0].Instances[0].PublicIpAddress'
```

---

### 5. **Variables de Base de Datos**

Usa las mismas que definiste en tu `.env` o `docker-compose.yml`:
- `DB_HOST`: `db` (si es contenedor) o endpoint de RDS
- `DB_USER`: `root` o el usuario que creaste
- `DB_PASS`: La contraseña configurada
- `DB_NAME`: `innovatech`

---

## 📝 Verificación de Secrets

Después de configurar, verifica que todos estén presentes:

```bash
# En tu repositorio:
Settings → Secrets and variables → Actions

# Deberías ver (ejemplo para ECR):
✅ AWS_ACCESS_KEY_ID
✅ AWS_SECRET_ACCESS_KEY  
✅ AWS_ACCOUNT_ID
✅ EC2_HOST
✅ EC2_USER
✅ EC2_SSH_KEY
✅ DB_HOST
✅ DB_USER
✅ DB_PASS
✅ DB_NAME
✅ VITE_API_URL
```

---

## 🚀 Preparación de EC2

Tu instancia EC2 debe tener:

### 1. **Docker instalado**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

### 2. **AWS CLI instalado** (para ECR)
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 3. **Configurar AWS CLI en EC2**
```bash
aws configure
# AWS Access Key ID: [tu key]
# AWS Secret Access Key: [tu secret]
# Default region: us-east-1
# Default output format: json
```

### 4. **Security Group configurado**
```
- Puerto 22 (SSH)
- Puerto 80 (Frontend)
- Puerto 3000 (Backend)
- Puerto 3306 (MySQL, opcional)
```

---

## 🔄 Flujo del Pipeline

```mermaid
graph LR
    A[Push a rama deploy] --> B[GitHub Actions]
    B --> C[Build Docker Image]
    C --> D[Push a ECR/Docker Hub]
    D --> E[SSH a EC2]
    E --> F[Pull nueva imagen]
    F --> G[Stop contenedor viejo]
    G --> H[Run contenedor nuevo]
    H --> I[Health Check]
    I --> J[✅ Deployment OK]
    I --> K[❌ Rollback]
```

---

## 🧪 Probar el Pipeline

### 1. Crear rama deploy
```bash
git checkout -b deploy
git push origin deploy
```

### 2. Ver ejecución
```
GitHub → Actions → Workflow ejecutándose
```

### 3. Ver logs en tiempo real
```
Click en el workflow → Click en el job → Ver pasos
```

---

## ⚠️ Troubleshooting

### Error: "Permission denied (publickey)"
```bash
# Verifica que el EC2_SSH_KEY esté completo
# Verifica que EC2_USER sea correcto (ubuntu, ec2-user, etc)
```

### Error: "Unable to locate credentials"
```bash
# Verifica AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY
# Verifica que el usuario IAM tenga permisos ECR
```

### Error: "Repository does not exist"
```bash
# Crea los repositorios en ECR:
aws ecr create-repository --repository-name innovatech-backend --region us-east-1
aws ecr create-repository --repository-name innovatech-frontend --region us-east-1
```

### Error: "Connection refused" al hacer health check
```bash
# Espera unos segundos más (el contenedor tarda en iniciar)
# Verifica que los puertos estén abiertos en Security Group
# Verifica que el servicio esté corriendo: docker ps
```

---

## 🔒 Seguridad

✅ **Buenas prácticas:**
- Nunca commitees secrets en el código
- Rota las credenciales periódicamente
- Usa IAM roles con permisos mínimos
- Habilita MFA en AWS
- Usa Docker Hub tokens en vez de contraseñas

❌ **Nunca hagas esto:**
- Poner credenciales en archivos `.env` del repo
- Compartir keys por email/chat
- Usar la cuenta root de AWS
- Hardcodear contraseñas en workflows

---

## 📚 Referencias

- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [AWS ECR Authentication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html)
- [Docker Hub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
