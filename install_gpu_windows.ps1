# Script d'installation GPU pour Windows 11
Write-Host "🚀 Installation des dépendances GPU pour chessbot-cheater" -ForegroundColor Green

# Vérifier CUDA 11.8
Write-Host "🔍 Vérification CUDA 11.8..." -ForegroundColor Yellow
$cudaVersion = nvcc --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ CUDA détecté: $cudaVersion" -ForegroundColor Green
} else {
    Write-Host "❌ CUDA 11.8 requis. Téléchargez depuis: https://developer.nvidia.com/cuda-11-8-0-download-archive" -ForegroundColor Red
    exit 1
}

# Installer les dépendances Python
Write-Host "📦 Installation des dépendances Python..." -ForegroundColor Yellow
pip install -r chess-snapshot-api/requirements.txt

# Vérifier l'installation GPU
Write-Host "🧪 Test de la configuration GPU..." -ForegroundColor Yellow
python -c "import torch; print(f'PyTorch GPU: {torch.cuda.is_available()}')"
python -c "import tensorflow as tf; print(f'TensorFlow GPU: {len(tf.config.list_physical_devices(\"GPU\"))}')"

Write-Host "✅ Installation terminée!" -ForegroundColor Green
