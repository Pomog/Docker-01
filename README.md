# Docker-01
docker-playground

## 1. Install or Verify Docker on Windows
```powershall
docker --version
```
```result
Docker version 24.0.6, build ed223bc
```

- Start Docker Desktop Verify Docker is running
```powershall
docker info
```
## 2. Relocate Docker’s Storage:
- If you are using the WSL 2 backend: Open Docker Desktop → Settings → Resources → Advance
```result
Docker Root Dir is currently /var/lib/docker (the default for the WSL2 backend)
```
- If you previously had images or containers on C:, you may want to remove them
```powershall
docker system prune -a
docker volume prune
```
## 3. Create a Project Folder & .env
- Create your project directory
```powershall
mkdir F:\my-docker-microservices
cd F:\my-docker-microservices
```
- Create a .env file
```powershall
New-Item -Path .env -ItemType "file"
```
- edit .env
```text
POSTGRES_USER=inventory_admin
POSTGRES_PASSWORD=someSecurePass
RABBITMQ_DEFAULT_USER=rmqadmin
RABBITMQ_DEFAULT_PASS=anotherSecurePass
```
- Update .gitignore to exclude .env
```powershall
Add-Content .gitignore ".env"
```
## 4. Write docker-compose.yml
- docker-compose.yml. Each service has its own “build” section pointing to a local Dockerfile.
```yaml
version: "3.9"

services:
  # 1) INVENTORY DATABASE
  inventory-db:
    build:
      context: ./inventory-database
      dockerfile: Dockerfile
    container_name: inventory-db
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5433:5432"
    volumes:
      - inventory-db-volume:/var/lib/postgresql/data
    networks:
      - app-network
    restart: unless-stopped

  # 2) BILLING DATABASE
  billing-db:
    build:
      context: ./billing-database
      dockerfile: Dockerfile
    container_name: billing-db
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5434:5432"
    volumes:
      - billing-db-volume:/var/lib/postgresql/data
    networks:
      - app-network
    restart: unless-stopped

  # 3) RABBITMQ QUEUE
  rabbit-queue:
    build:
      context: ./rabbitmq
      dockerfile: Dockerfile
    container_name: rabbit-queue
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_DEFAULT_USER}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_DEFAULT_PASS}
    ports:
      - "5672:5672"
    networks:
      - app-network
    restart: unless-stopped

  # 4) INVENTORY-APP
  inventory-app:
    build:
      context: ./inventory-app
      dockerfile: Dockerfile
    container_name: inventory-app
    depends_on:
      - inventory-db
    ports:
      - "8081:8080"
    networks:
      - app-network
    restart: unless-stopped

  # 5) BILLING-APP
  billing-app:
    build:
      context: ./billing-app
      dockerfile: Dockerfile
    container_name: billing-app
    depends_on:
      - billing-db
      - rabbit-queue
    ports:
      - "8082:8080"
    networks:
      - app-network
    restart: unless-stopped

  # 6) API-GATEWAY
  api-gateway-app:
    build:
      context: ./api-gateway
      dockerfile: Dockerfile
    container_name: api-gateway-app
    ports:
      - "3000:3000"
    volumes:
      - api-gateway-volume:/var/logs/api-gateway
    networks:
      - app-network
    restart: unless-stopped

volumes:
  inventory-db-volume:
  billing-db-volume:
  api-gateway-volume:

networks:
  app-network:
    driver: bridge
```

## 5. Create Each Service’s Dockerfile
- setup.ps1
```powershall
# setup.ps1
# Root directory for your project
$root = "F:\my-docker-microservices"

# Create the root directory if it doesn't exist
if (!(Test-Path -Path $root)) {
    New-Item -Path $root -ItemType Directory -Force | Out-Null
    Write-Output "Created root directory: $root"
} else {
    Write-Output "Root directory already exists: $root"
}

# Create docker-compose.yml in the root directory
$composeFile = Join-Path $root "docker-compose.yml"
if (!(Test-Path -Path $composeFile)) {
    New-Item -Path $composeFile -ItemType File -Force | Out-Null
    Write-Output "Created file: $composeFile"
} else {
    Write-Output "File already exists: $composeFile"
}

# Define the subdirectories to create
$subDirs = @(
    "inventory-app",
    "billing-app",
    "inventory-database",
    "billing-database",
    "rabbitmq",
    "api-gateway"
)

# Loop through each subdirectory, create it and add a Dockerfile inside
foreach ($subDir in $subDirs) {
    $subDirPath = Join-Path $root $subDir
    if (!(Test-Path -Path $subDirPath)) {
        New-Item -Path $subDirPath -ItemType Directory -Force | Out-Null
        Write-Output "Created directory: $subDirPath"
    } else {
        Write-Output "Directory already exists: $subDirPath"
    }
    
    # Create a Dockerfile inside the subdirectory
    $dockerfile = Join-Path $subDirPath "Dockerfile"
    if (!(Test-Path -Path $dockerfile)) {
        New-Item -Path $dockerfile -ItemType File -Force | Out-Null
        Write-Output "Created file: $dockerfile"
    } else {
        Write-Output "File already exists: $dockerfile"
    }
}

Write-Output "Setup completed: Directory structure is ready."
```
```powershall
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup.ps1
```
- PostgreSQL Dockerfile 
```text
# F:\my-docker-microservices\inventory-database\Dockerfile
FROM postgres:14-alpine
# We rely on environment variables for POSTGRES_USER and POSTGRES_PASSWORD
# so no manual creation of user/password here.

EXPOSE 5432
CMD ["postgres"]
```
- RabbitMQ container
```text
FROM rabbitmq:3.9-alpine
EXPOSE 5672
```
## inventory-app, billing-app, api-gateway are Provided

## 6. Build and Run with Docker Compose

