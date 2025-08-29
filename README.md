# Demo: Buildpacks Multi-Arquitectura

Este demo acompaña la charla "De ARM a x86: Construyendo Aplicaciones Multi-Arquitectura con Cloud Native Buildpacks".

## 📋 Descripción

Una aplicación Flask simple que utiliza `bcrypt`, una librería que requiere compilación nativa de código C. Esto la hace perfecta para demostrar los desafíos de construir imágenes para múltiples arquitecturas (ARM64 y AMD64).

## 🏗️ Estructura del Proyecto

```
kdc/
├── app.py              # Aplicación Flask con bcrypt
├── requirements.txt    # Dependencias Python (incluye bcrypt)  
├── Procfile           # Define cómo ejecutar la app (buildpacks)
├── Dockerfile         # Multi-arch Dockerfile (complejo)
├── demo-docker.sh     # 🎬 Script demo Docker (presentación)
├── demo-pack.sh       # 🎬 Script demo Buildpacks (presentación)
├── .dockerignore     # Archivos a ignorar
├── .github/workflows/ # GitHub Actions multi-arch workflow
└── README.md         # Este archivo
```

## 🚀 Métodos de Build

### 1. Con Dockerfile (Método Tradicional)

El Dockerfile muestra la complejidad de manejar dependencias nativas:

```bash
# Build multi-arquitectura con Docker
docker buildx create --name multiarch --use
docker buildx build --platform linux/amd64,linux/arm64 -t buildpack-demo-docker .
```

**Problemas del Dockerfile:**
- Configuración manual de compiladores para cada arquitectura
- Gestión compleja de dependencias del sistema
- Mantenimiento continuo requerido
- Debugging difícil cuando falla la compilación

### 2. Con Cloud Native Buildpacks (Método Simplificado)

```bash
# Instalar pack CLI si no lo tienes
# macOS: brew install buildpacks/tap/pack
# Linux: Ver https://buildpacks.io/docs/install-pack/

# Build con buildpacks - ¡Una sola línea!
pack build buildpack-demo-pack --builder heroku/builder:24

# Para diferentes arquitecturas, ejecutar desde máquina con esa arquitectura
# En máquina ARM64:
pack build buildpack-demo-pack --builder heroku/builder:24

# En máquina AMD64:
pack build buildpack-demo-pack --builder heroku/builder:24
```

## 🎬 Demo Scripts (¡Perfecto para presentaciones!)

Para facilitar las demostraciones en vivo, incluimos scripts automatizados:

### 🐳 Demo Docker (Complejidad tradicional)
```bash
./demo-docker.sh
```

**Lo que hace:**
- Muestra la complejidad del Dockerfile (50+ líneas)
- Construye imagen multi-arquitectura con Docker
- Prueba todos los endpoints automáticamente
- Resalta los puntos de dolor del enfoque tradicional

### 📦 Demo Buildpacks (Simplicidad moderna)
```bash
./demo-pack.sh
```

**Lo que hace:**
- Demuestra la simplicidad (1 comando)
- Construye con `pack build` automáticamente
- Prueba la misma funcionalidad
- Compara resultados con Docker

### 🚀 Flujo recomendado para presentación:
1. `./demo-docker.sh` - Muestra el problema
2. `./demo-pack.sh` - Muestra la solución
3. Compara ambos enfoques lado a lado

## 🧪 Probar Manualmente

### Ejecutar localmente

```bash
# Instalar dependencias
python -m venv venv
source venv/bin/activate  # Linux/macOS
pip install -r requirements.txt

# Ejecutar aplicación
python app.py
```

### Ejecutar con Docker

```bash
# Con imagen construida por Dockerfile
docker run -p 5000:5000 buildpack-demo-docker

# Con imagen construida por Buildpacks
docker run -p 5000:5000 buildpack-demo-pack
```

### Endpoints Disponibles

1. **GET /** - Información del sistema
   ```bash
   curl http://localhost:5000/
   ```

2. **POST /hash** - Hash de contraseña con bcrypt
   ```bash
   curl -X POST http://localhost:5000/hash \
     -H "Content-Type: application/json" \
     -d '{"password": "mi_password_seguro"}'
   ```

3. **POST /verify** - Verificar contraseña
   ```bash
   curl -X POST http://localhost:5000/verify \
     -H "Content-Type: application/json" \
     -d '{"password": "mi_password_seguro", "hash": "hash_obtenido_anteriormente"}'
   ```

4. **GET /health** - Health check
   ```bash
   curl http://localhost:5000/health
   ```

## 🔍 Qué Observar en el Demo

### Dockerfile vs Buildpacks

| Aspecto | Dockerfile | Buildpacks |
|---------|-----------|------------|
| **Líneas de código** | ~50 líneas complejas | 0 líneas |
| **Configuración multi-arch** | Manual y propensa a errores | Automática |
| **Dependencias nativas** | Gestión manual por arquitectura | Detectada automáticamente |
| **Mantenimiento** | Constante | Mínimo |
| **Debugging** | Complejo | Simplificado |

### Lo que Buildpacks hace automáticamente:

1. **Detecta** `bcrypt` en `requirements.txt`
2. **Identifica** que necesita compilación nativa
3. **Instala** las herramientas de build correctas para la arquitectura
4. **Configura** las variables de entorno necesarias
5. **Compila** con los flags optimizados
6. **Cachea** las capas para builds futuros más rápidos

## 📊 Resultados del Demo

Al probar ambas imágenes, deberías ver:

- **Arquitectura detectada** correctamente en todos los endpoints
- **bcrypt funcionando** sin problemas en ambas arquitecturas
- **Tamaño de imagen** optimizado con buildpacks
- **Tiempo de build** reducido en builds subsecuentes

## 🤖 CI/CD con GitHub Actions

Este repositorio incluye un workflow completo que demuestra buildpacks en CI:

```yaml
# .github/workflows/buildpacks-demo.yml
- uses: buildpacks/github-actions/setup-pack@v5.9.3
- run: pack build image --builder heroku/builder:24 --publish
```

### Lo que hace el workflow:

1. **🧪 Testing**: Verifica que bcrypt funcione correctamente
2. **🏗️ Build AMD64**: Construye imagen para x86_64 con buildpacks
3. **🏗️ Build ARM64**: Construye imagen para ARM64 con buildpacks  
4. **📦 Multi-Arch Manifest**: Combina ambas en una imagen universal

### Beneficios en CI/CD:

- **Sin configuración compleja** de Docker buildx multi-platform
- **Cacheo automático** de dependencias entre builds
- **Detección automática** de arquitectura del runner
- **Optimización** de capas sin configuración manual

### Ejecutar el workflow:

1. Haz fork de este repo
2. Habilita GitHub Actions
3. Push a `main` o abre un PR
4. Ve la magia de buildpacks en acción 🚀

## 💡 Puntos Clave para la Presentación

1. **Complejidad**: El Dockerfile requiere conocimiento especializado
2. **Mantenimiento**: Buildpacks se actualiza automáticamente
3. **Productividad**: Los desarrolladores se enfocan en el código, no en la infraestructura
4. **Confiabilidad**: Menos errores de configuración
5. **CI/CD**: Integración seamless con GitHub Actions

## 🔗 Enlaces Útiles

- [Cloud Native Buildpacks](https://buildpacks.io/)
- [Heroku Builder](https://github.com/heroku/builder)
- [Pack CLI](https://buildpacks.io/docs/install-pack/)
- [Bcrypt Documentation](https://pypi.org/project/bcrypt/)

---

**Nota**: Este demo fue creado para la charla en KCD Colombia 2025. Para preguntas, contacta a [@jjbustamante](https://github.com/jjbustamante).
