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
