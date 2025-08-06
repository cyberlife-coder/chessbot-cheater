# Script de configuration complète de l'environnement Windows 11
# Exécuter en tant qu'administrateur si nécessaire

Write-Host "🚀 Configuration environnement ChessBot GPU pour Windows 11" -ForegroundColor Green

# Vérifier Python
Write-Host "🔍 Vérification Python..." -ForegroundColor Yellow
$pythonVersion = python --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Python détecté: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Python non trouvé. Installez Python 3.10 depuis python.org" -ForegroundColor Red
    exit 1
}

# Vérifier CUDA
Write-Host "🔍 Vérification CUDA 11.8..." -ForegroundColor Yellow
$cudaVersion = nvcc --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ CUDA détecté" -ForegroundColor Green
} else {
    Write-Host "⚠️ CUDA 11.8 requis. Téléchargez depuis: https://developer.nvidia.com/cuda-11-8-0-download-archive" -ForegroundColor Yellow
}

# Créer environnement virtuel
Write-Host "📦 Création environnement virtuel..." -ForegroundColor Yellow
if (Test-Path "venv_chessbot_gpu") {
    Write-Host "⚠️ Environnement existant trouvé, suppression..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "venv_chessbot_gpu"
}

python -m venv venv_chessbot_gpu
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur création environnement virtuel" -ForegroundColor Red
    exit 1
}

# Activer environnement
Write-Host "🔧 Activation environnement..." -ForegroundColor Yellow
& ".\venv_chessbot_gpu\Scripts\Activate.ps1"

# Mettre à jour pip
Write-Host "⬆️ Mise à jour pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip

# Installer PyTorch avec CUDA 11.8
Write-Host "🔥 Installation PyTorch CUDA 11.8..." -ForegroundColor Yellow
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Installer TensorFlow GPU
Write-Host "🧠 Installation TensorFlow GPU..." -ForegroundColor Yellow
pip install tensorflow-gpu==2.13.1

# Installer autres dépendances
Write-Host "📚 Installation dépendances projet..." -ForegroundColor Yellow
pip install -r chess-snapshot-api/requirements.txt

# Test configuration
Write-Host "🧪 Test configuration GPU..." -ForegroundColor Yellow
Write-Host "Test PyTorch CUDA:" -ForegroundColor Cyan
python -c "import torch; print(f'PyTorch CUDA disponible: {torch.cuda.is_available()}')"

Write-Host "Test TensorFlow GPU:" -ForegroundColor Cyan
python -c "import tensorflow as tf; print(f'TensorFlow GPU devices: {len(tf.config.list_physical_devices(\"GPU\"))}')"

Write-Host "Test configuration projet:" -ForegroundColor Cyan
python -c "from gpu_config import GPUConfig; gpu = GPUConfig(); print(f'GPU Config: {gpu.get_device_info()}')"

Write-Host "✅ Configuration terminée!" -ForegroundColor Green
Write-Host "💡 Pour activer l'environnement: .\venv_chessbot_gpu\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host "💡 Pour tester: python benchmark_gpu.py" -ForegroundColor Cyan
