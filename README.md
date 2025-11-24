# SIMEVEC

This is a simple crud application built with Flutter and Firebase.

## Features

- User authentication with Firebase Auth
- User profile management
- Client management
- Instalation Light management
- Vehicule management
- Employee management
- Cam management

## Quality Assurance

This project uses SonarQube for static code analysis and quality monitoring.

### Running SonarQube Analysis

#### Prerequisites

- Docker and Docker Compose installed
- Flutter SDK installed

#### Quick Start

```bash
# Make scripts executable
chmod +x download-sonar-flutter-plugin.sh
chmod +x run_sonar_analysis.sh

# Run complete analysis
./run_sonar_analysis.sh
```

#### Access SonarQube

- **URL**: http://localhost:9000
- **Default credentials**: admin/admin
- **Project**: Client Service

### Manual Commands

```bash
# Start only SonarQube
docker-compose up -d sonarqube

# Stop SonarQube
docker-compose down

# View logs
docker-compose logs -f sonarqube
```

## Testing

The project includes comprehensive tests organized by category con SOnnarqube

```bash
# Run all tests
flutter test

# Run tests by category
flutter test test/crud/
flutter test test/viewmodels/
flutter test test/utils/
flutter test test/services/
flutter test test/repositories/

# Run tests with coverage
flutter test --coverage
```

## CI/CD

The project uses GitHub Actions for continuous integration:

- **Build and Test**: Runs on every push and pull request
- **SonarQube Analysis**: Quality gate analysis with coverage
- **Release**: Automatic release creation with assets

## Documentation

- [SonarQube Setup Guide](docs/sonarqube-setup.md) - Complete setup instructions
- [Test Documentation](test/) - Test organization and examples

# SonarQube con Docker para Client Service

Este README explica cómo usar SonarQube con Docker para el análisis de calidad de código del proyecto Client Service.

## 🐳 Configuración Rápida con Docker

### Prerrequisitos

- Docker instalado
- Docker Compose instalado
- Flutter SDK instalado

### Pasos de Configuración

1. **Clonar el repositorio** (si no lo has hecho ya):

   ```bash
   git clone <tu-repositorio>
   cd client_service
   ```

2. **Hacer ejecutables los scripts**:

   ```bash
   chmod +x download-sonar-flutter-plugin.sh
   chmod +x run_sonar_analysis_docker.sh
   ```

3. **Ejecutar el análisis completo**:
   ```bash
   ./run_sonar_analysis_docker.sh
   ```

¡Eso es todo! El script se encarga de todo automáticamente.

## 📋 Qué hace el script automáticamente

1. ✅ Descarga el plugin sonar-flutter
2. ✅ Inicia SonarQube con Docker
3. ✅ Espera a que SonarQube esté listo
4. ✅ Instala dependencias de Flutter
5. ✅ Ejecuta tests con cobertura
6. ✅ Genera reportes de tests
7. ✅ Ejecuta el análisis de SonarQube
8. ✅ Muestra los resultados

## 🌐 Acceder a SonarQube

Una vez que el análisis esté completo, puedes acceder a SonarQube en:

**URL**: http://localhost:9000

**Credenciales por defecto**:

- Usuario: `admin`
- Contraseña: `admin`

**Proyecto**: Client Service

## 🛠️ Comandos Útiles

### Iniciar solo SonarQube (sin análisis)

```bash
docker-compose up -d sonarqube
```

### Detener SonarQube

```bash
docker-compose down
```

### Ver logs de SonarQube

```bash
docker-compose logs -f sonarqube
```

### Ejecutar análisis manual con Docker

```bash
docker-compose run --rm sonar-scanner \
  -Dsonar.projectKey=client_service \
  -Dsonar.projectName="Client Service" \
  -Dsonar.sources=lib,pubspec.yaml \
  -Dsonar.tests=test \
  -Dsonar.flutter.coverage.reportPath=coverage/lcov.info \
  -Dsonar.flutter.tests.reportPath=tests.output
```

## 📊 Interpretación de Resultados

### Quality Gate

SonarQube verificará automáticamente:

- **Coverage**: Porcentaje de cobertura de código
- **Duplications**: Código duplicado
- **Issues**: Problemas de calidad (bugs, vulnerabilidades, code smells)
- **Maintainability**: Mantenibilidad del código
- **Reliability**: Confiabilidad del código
- **Security**: Seguridad del código

### Métricas Importantes

- **Code Coverage**: Debe estar por encima del 80%
- **Technical Debt**: Debe ser mínimo
- **Code Smells**: Deben ser pocos o nulos
- **Bugs**: Deben ser cero
- **Vulnerabilities**: Deben ser cero

## 🔧 Configuración Avanzada

### Modificar configuración de SonarQube

Edita el archivo `docker-compose.yml` para cambiar:

- Puerto de SonarQube
- Configuración de memoria
- Volúmenes de datos

### Personalizar análisis

Edita el archivo `sonar-project.properties` para:

- Cambiar exclusiones de archivos
- Modificar configuración del analizador
- Ajustar rutas de reportes

## 🚨 Troubleshooting

### Error: "Docker no está instalado"

```bash
# Instalar Docker en Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
# Reiniciar sesión después
```

### Error: "SonarQube no está listo"

```bash
# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs sonarqube

# Reiniciar
docker-compose restart sonarqube
```

### Error: "Plugin no encontrado"

```bash
# Descargar plugin manualmente
./download-sonar-flutter-plugin.sh

# Reiniciar SonarQube
docker-compose restart sonarqube
```

### Error: "No coverage data found"

```bash
# Verificar que los tests se ejecuten
flutter test --coverage

# Verificar archivo de cobertura
ls -la coverage/lcov.info
```

## 📚 Recursos Adicionales

- [Documentación oficial de sonar-flutter](https://github.com/insideapp-oss/sonar-flutter)
- [SonarQube Docker Hub](https://hub.docker.com/_/sonarqube)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Docker Compose](https://docs.docker.com/compose/)

## 🤝 Contribuir

Si encuentras problemas o quieres mejorar la configuración:

1. Abre un issue en el repositorio
2. Describe el problema o mejora
3. Incluye logs si es necesario
4. Proporciona pasos para reproducir el problema

---
