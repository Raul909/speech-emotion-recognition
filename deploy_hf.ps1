# PowerShell deployment script for Hugging Face Space (VoxSense)
$ErrorActionPreference = "Stop"

$workspaceRoot = "c:\Users\dtaa0\OneDrive\Documents\raul_workspace\Speech-Emotion-Recognition\speech-emotion-recognition"
$deployDir = Join-Path -Path $workspaceRoot -ChildPath "hf-deploy"

Write-Output "--- Starting Clean Binary-Free Hugging Face Spaces Deployment ---"

# 1. Cleanup old deployment folder if it exists
if (Test-Path -Path $deployDir) {
    Write-Output "Removing existing hf-deploy folder..."
    Remove-Item -Path $deployDir -Recurse -Force
}

# 2. Create hf-deploy and subdirectories
Write-Output "Creating hf-deploy directory structure..."
New-Item -ItemType Directory -Force -Path $deployDir
New-Item -ItemType Directory -Force -Path (Join-Path -Path $deployDir -ChildPath "static")
New-Item -ItemType Directory -Force -Path (Join-Path -Path $deployDir -ChildPath "models") # Empty folder placeholder

# 3. Copy necessary application files
Write-Output "Copying code and config files..."
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "server.py") -Destination (Join-Path -Path $deployDir -ChildPath "server.py")
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "requirements.txt") -Destination (Join-Path -Path $deployDir -ChildPath "requirements.txt")
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "Dockerfile") -Destination (Join-Path -Path $deployDir -ChildPath "Dockerfile")
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath ".dockerignore") -Destination (Join-Path -Path $deployDir -ChildPath ".dockerignore")

# Rename README_HF.md to README.md in the deploy directory
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "README_HF.md") -Destination (Join-Path -Path $deployDir -ChildPath "README.md")

# 4. Copy static files
Write-Output "Copying static web assets..."
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "static\index.html") -Destination (Join-Path -Path $deployDir -ChildPath "static\index.html")
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "static\style.css") -Destination (Join-Path -Path $deployDir -ChildPath "static\style.css")
Copy-Item -Path (Join-Path -Path $workspaceRoot -ChildPath "static\app.js") -Destination (Join-Path -Path $deployDir -ChildPath "static\app.js")

# 5. Initialize git, commit and push to Hugging Face
Write-Output "Initializing git repository in hf-deploy..."
Set-Location -Path $deployDir
git init -b main
git config user.name "Raul909"
git config user.email "rb341047@gmail.com"
git remote add hf "https://huggingface.co/spaces/Raul909/voxsense"

Write-Output "Staging files..."
git add .

Write-Output "Creating deployment commit..."
git commit -m "deploy: premium Thorgal-style UI upgrade (binary-free)"

Write-Output "Pushing to Hugging Face Spaces (main branch)..."
git push -f hf main

# 6. Return to workspace root and clean up
Set-Location -Path $workspaceRoot
Write-Output "Cleaning up temporary hf-deploy folder..."
Remove-Item -Path $deployDir -Recurse -Force

Write-Output "--- Deployment Completed Successfully! ---"
