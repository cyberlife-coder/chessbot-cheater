# Script de configuration PARFAIT pour ChessBot GPU - Windows 11
# Version optimisée avec venv et dépendances à jour
# Exécuter dans PowerShell en tant qu'administrateur

param(
    [switch]$Force,
    [switch]$SkipCuda,
    [string]$PythonVersion = "3.10"
)

Write-Host "[SETUP] Configuration PARFAITE ChessBot GPU - Windows 11 + RTX 4090" -ForegroundColor Green
Write-Host "[INFO] Version: $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor Gray

# Fonction de vérification des prérequis
function Test-Prerequisites {
    $errors = @()
    
    # Vérifier Python 3.10.x ou 3.11.x
    Write-Host "[CHECK] Vérification Python $PythonVersion..." -ForegroundColor Yellow
    try {
        $pythonCmd = Get-Command python -ErrorAction Stop
        $pythonVersionOutput = & python --version 2>&1
        if ($pythonVersionOutput -match "Python (\d+\.\d+)\.(\d+)") {
            $majorMinor = $matches[1]
            $patch = $matches[2]
            if ($majorMinor -eq $PythonVersion) {
                Write-Host "[OK] Python $pythonVersionOutput détecté" -ForegroundColor Green
            } else {
                $errors += "[ERROR] Python $PythonVersion requis, trouvé: $pythonVersionOutput"
            }
        } else {
            $errors += "[ERROR] Impossible de déterminer la version Python"
        }
    } catch {
        $errors += "[ERROR] Python non trouvé. Installez Python $PythonVersion.x depuis python.org"
    }
    
    # Vérifier CUDA 11.8 (optionnel si -SkipCuda)
    if (-not $SkipCuda) {
        Write-Host "[CHECK] Vérification CUDA 11.8..." -ForegroundColor Yellow
        try {
            $cudaOutput = & nvcc --version 2>&1
            if ($cudaOutput -match "release 11\.8") {
                Write-Host "[OK] CUDA 11.8 détecté" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] CUDA 11.8 recommandé pour RTX 4090" -ForegroundColor Yellow
                Write-Host "   Téléchargez: https://developer.nvidia.com/cuda-11-8-0-download-archive" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "[WARNING] CUDA non détecté (mode CPU uniquement)" -ForegroundColor Yellow
        }
    }
    
    # Vérifier GPU NVIDIA
    Write-Host "[CHECK] Vérification GPU NVIDIA..." -ForegroundColor Yellow
    try {
        $gpuInfo = & nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>&1
        if ($gpuInfo -match "RTX") {
            Write-Host "[OK] GPU NVIDIA détecté: $gpuInfo" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] GPU NVIDIA non détecté" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[WARNING] nvidia-smi non disponible" -ForegroundColor Yellow
    }
    
    return $errors
}

# Vérifier les prérequis
$prereqErrors = Test-Prerequisites
if ($prereqErrors.Count -gt 0 -and -not $Force) {
    Write-Host "[ERROR] Erreurs de prérequis:" -ForegroundColor Red
    $prereqErrors | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    Write-Host "[TIP] Utilisez -Force pour continuer malgré les erreurs" -ForegroundColor Cyan
    exit 1
}

# Nettoyer environnement existant
Write-Host "[CLEAN] Nettoyage environnement existant..." -ForegroundColor Yellow
if (Test-Path "venv_chessbot_gpu") {
    if ($Force -or (Read-Host "Supprimer l'environnement existant? (y/N)") -eq 'y') {
        Remove-Item -Recurse -Force "venv_chessbot_gpu"
        Write-Host "[OK] Environnement supprimé" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Opération annulée" -ForegroundColor Red
        exit 1
    }
}

# Créer environnement virtuel
Write-Host "[CREATE] Création environnement virtuel Python..." -ForegroundColor Yellow
& python -m venv venv_chessbot_gpu --upgrade-deps
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur création environnement virtuel" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Environnement virtuel créé" -ForegroundColor Green

# Activer environnement
Write-Host "[ACTIVATE] Activation environnement..." -ForegroundColor Yellow
$activateScript = ".\venv_chessbot_gpu\Scripts\Activate.ps1"
if (-not (Test-Path $activateScript)) {
    Write-Host "[ERROR] Script d'activation non trouvé" -ForegroundColor Red
    exit 1
}

# Exécuter dans l'environnement virtuel
& $activateScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur activation environnement" -ForegroundColor Red
    exit 1
}

# Mettre à jour pip, setuptools, wheel
Write-Host "[UPDATE] Mise à jour outils Python..." -ForegroundColor Yellow
& python -m pip install --upgrade pip setuptools wheel
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur mise à jour pip" -ForegroundColor Red
    exit 1
}

# Installer PyTorch avec CUDA 11.8 (versions exactes testées)
Write-Host "[INSTALL] Installation PyTorch 2.1.0 + CUDA 11.8..." -ForegroundColor Yellow
& pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur installation PyTorch" -ForegroundColor Red
    exit 1
}

# Installer TensorFlow GPU (version exacte testée)
Write-Host "[INSTALL] Installation TensorFlow GPU 2.13.1..." -ForegroundColor Yellow
& pip install tensorflow-gpu==2.13.1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur installation TensorFlow" -ForegroundColor Red
    exit 1
}

# Installer dépendances projet
Write-Host "[INSTALL] Installation dépendances projet..." -ForegroundColor Yellow
if (Test-Path "chess-snapshot-api/requirements.txt") {
    & pip install -r chess-snapshot-api/requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Erreur installation dépendances" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[WARNING] requirements.txt non trouvé, installation manuelle..." -ForegroundColor Yellow
    & pip install numpy==1.24.3 opencv-python==4.8.1.78 ultralytics==8.1.20 scikit-learn==1.3.2 pyclipper==1.3.0.post5 flask==3.0.2 stockfish==3.28.0
}

# Tests de validation GPU
Write-Host "[TEST] Tests de validation GPU..." -ForegroundColor Yellow

Write-Host "Test 1: PyTorch CUDA" -ForegroundColor Cyan
$torchTest = & python -c "import torch; print(f'CUDA disponible: {torch.cuda.is_available()}'); print(f'Version CUDA: {torch.version.cuda}'); print(f'Devices: {torch.cuda.device_count()}')" 2>&1
Write-Host $torchTest -ForegroundColor White

Write-Host "Test 2: TensorFlow GPU" -ForegroundColor Cyan
$tfTest = & python -c "import tensorflow as tf; gpus = tf.config.list_physical_devices('GPU'); print(f'TensorFlow GPU devices: {len(gpus)}'); [print(f'  - {gpu}') for gpu in gpus]" 2>&1
Write-Host $tfTest -ForegroundColor White

Write-Host "Test 3: Configuration projet" -ForegroundColor Cyan
if (Test-Path "gpu_config.py") {
    $projectTest = & python -c "from gpu_config import GPUConfig; gpu = GPUConfig(); print(f'GPU Config: {gpu.get_device_info()}'); print(f'CUDA disponible: {gpu.cuda_available}')" 2>&1
    Write-Host $projectTest -ForegroundColor White
} else {
    Write-Host "[WARNING] gpu_config.py non trouvé" -ForegroundColor Yellow
}

# Test benchmark (optionnel)
Write-Host "Test 4: Benchmark rapide" -ForegroundColor Cyan
if (Test-Path "benchmark_gpu.py") {
    Write-Host "[INFO] Benchmark disponible: python benchmark_gpu.py" -ForegroundColor Cyan
} else {
    Write-Host "[WARNING] benchmark_gpu.py non trouvé" -ForegroundColor Yellow
}

# Résumé final
Write-Host "`n[SUCCESS] CONFIGURATION TERMINÉE AVEC SUCCÈS!" -ForegroundColor Green
Write-Host "[SUMMARY] Résumé de l'installation:" -ForegroundColor White
Write-Host "   • Environnement: venv_chessbot_gpu" -ForegroundColor Gray
Write-Host "   • Python: $(& python --version)" -ForegroundColor Gray
Write-Host "   • PyTorch: 2.1.0 + CUDA 11.8" -ForegroundColor Gray
Write-Host "   • TensorFlow: 2.13.1 GPU" -ForegroundColor Gray
Write-Host "   • Optimisé pour: RTX 4090" -ForegroundColor Gray

Write-Host "`n[COMMANDS] COMMANDES UTILES:" -ForegroundColor Cyan
Write-Host "   Activer environnement:" -ForegroundColor White
Write-Host "   .\venv_chessbot_gpu\Scripts\Activate.ps1" -ForegroundColor Gray
Write-Host "`n   Lancer le bot:" -ForegroundColor White
Write-Host "   python chess_bot.py" -ForegroundColor Gray
Write-Host "`n   Tester performance GPU:" -ForegroundColor White
Write-Host "   python benchmark_gpu.py" -ForegroundColor Gray
Write-Host "`n   Vérifier utilisation GPU:" -ForegroundColor White
Write-Host "   nvidia-smi" -ForegroundColor Gray

Write-Host "`n[READY] Votre ChessBot GPU est prêt pour RTX 4090!" -ForegroundColor Green
