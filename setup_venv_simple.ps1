# Script SIMPLE et RAPIDE pour environnement ChessBot GPU
# Version minimaliste pour utilisateurs expérimentés

Write-Host "🚀 Setup ChessBot GPU - Version Express" -ForegroundColor Green

# Vérifications rapides
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python requis: https://python.org" -ForegroundColor Red; exit 1
}

# Créer environnement
Write-Host "📦 Création venv..." -ForegroundColor Yellow
if (Test-Path "venv_chessbot_gpu") { Remove-Item -Recurse -Force "venv_chessbot_gpu" }
python -m venv venv_chessbot_gpu --upgrade-deps

# Activer et installer
Write-Host "⚡ Installation dépendances..." -ForegroundColor Yellow
& ".\venv_chessbot_gpu\Scripts\Activate.ps1"
python -m pip install --upgrade pip

# PyTorch CUDA 11.8 (versions exactes)
pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118

# TensorFlow GPU
pip install tensorflow-gpu==2.13.1

# Dépendances projet
pip install numpy==1.24.3 opencv-python==4.8.1.78 ultralytics==8.1.20 scikit-learn==1.3.2 pyclipper==1.3.0.post5 flask==3.0.2 stockfish==3.28.0

# Test rapide
Write-Host "🧪 Test GPU..." -ForegroundColor Yellow
python -c "import torch, tensorflow as tf; print(f'PyTorch CUDA: {torch.cuda.is_available()}'); print(f'TensorFlow GPU: {len(tf.config.list_physical_devices(\"GPU\"))}')"

Write-Host "✅ Terminé! Activez avec: .\venv_chessbot_gpu\Scripts\Activate.ps1" -ForegroundColor Green
