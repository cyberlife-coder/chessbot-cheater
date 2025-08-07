# Definir repertoire de travail
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptPath

# Afficher configuration
Write-Host "[SETUP] Configuration ChessBot GPU - Windows 11 + RTX 4090" -ForegroundColor Cyan
Write-Host "[INFO] Version: 2025-08-06" -ForegroundColor White
Write-Host "[INFO] Repertoire: $PWD" -ForegroundColor White

# Vérifications
Write-Host "[CHECK] Verification Python 3.10.11..." -ForegroundColor Yellow

# Chercher Python 3.10.11 dans les emplacements courants
$pythonPaths = @(
    "$env:USERPROFILE\.pyenv\pyenv-win\versions\3.10.11\python.exe",
    "C:\Python310\python.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python310\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
    "python"
)

$python310 = $null
foreach ($path in $pythonPaths) {
    if (Test-Path $path -ErrorAction SilentlyContinue) {
        $version = & $path --version 2>&1
        if ($version -match "3\.10\.11") {
            $python310 = $path
            Write-Host "[OK] Python 3.10.11 trouve: $path" -ForegroundColor Green
            break
        }
    }
}

if (-not $python310) {
    # Essayer avec la commande python par défaut
    $defaultVersion = & python --version 2>&1
    if ($defaultVersion -match "3\.10\.11") {
        $python310 = "python"
        Write-Host "[OK] Python 3.10.11 detecte (commande par defaut)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Python 3.10.11 requis pour CUDA 11.8 et TensorFlow 2.13.1" -ForegroundColor Red
        Write-Host "[INFO] Version detectee: $defaultVersion" -ForegroundColor Yellow
        Write-Host "[INFO] Installez Python 3.10.11 depuis: https://www.python.org/downloads/release/python-31011/" -ForegroundColor Cyan
        exit 1
    }
}

# Vérifier CUDA
Write-Host "[CHECK] Verification CUDA..." -ForegroundColor Yellow
$cudaVersion = $null
try {
    $cudaOutput = & nvcc --version 2>&1
    if ($cudaOutput -match "release (\d+\.\d+)") {
        $cudaVersion = $matches[1]
        Write-Host "[INFO] CUDA $cudaVersion detecte" -ForegroundColor Cyan
        if ($cudaVersion -eq "11.8") {
            Write-Host "[OK] Version CUDA compatible avec TensorFlow 2.13.1" -ForegroundColor Green
        } elseif ($cudaVersion -match "12\.\d+") {
            Write-Host "[WARNING] CUDA $cudaVersion detecte. TensorFlow 2.13.1 peut ne pas etre compatible." -ForegroundColor Yellow
            Write-Host "[INFO] TensorFlow 2.15+ recommande pour CUDA 12.x" -ForegroundColor Cyan
        } else {
            Write-Host "[WARNING] Version CUDA $cudaVersion non testee. Compatibilite incertaine." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARNING] Impossible de determiner la version de CUDA" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARNING] CUDA non detecte (mode CPU uniquement)" -ForegroundColor Yellow
}

# Vérifier GPU NVIDIA
Write-Host "[CHECK] Verification GPU NVIDIA..." -ForegroundColor Yellow
try {
    $gpuInfo = & nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>&1
    if ($gpuInfo -match "RTX") {
        Write-Host "[OK] GPU NVIDIA detecte: $gpuInfo" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] GPU NVIDIA non detecte" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARNING] nvidia-smi non disponible" -ForegroundColor Yellow
}

# Nettoyer environnement existant
Write-Host "[CLEAN] Nettoyage environnement existant..." -ForegroundColor Yellow
if (Test-Path "venv_chessbot_gpu") { 
    Remove-Item -Recurse -Force "venv_chessbot_gpu"
}

# Créer environnement virtuel
Write-Host "[CREATE] Creation environnement virtuel Python 3.10.11..." -ForegroundColor Yellow
& $python310 -m venv venv_chessbot_gpu --upgrade-deps
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur creation environnement virtuel" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Environnement virtuel cree" -ForegroundColor Green

# Activer environnement
Write-Host "[ACTIVATE] Activation environnement..." -ForegroundColor Yellow
& "$PWD\venv_chessbot_gpu\Scripts\Activate.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Erreur activation environnement virtuel" -ForegroundColor Red
    exit 1
}

# Mettre à jour pip
Write-Host "[UPDATE] Mise à jour de pip..." -ForegroundColor Yellow
& "$PWD\venv_chessbot_gpu\Scripts\python.exe" -m pip install --upgrade pip

# Installer PyTorch avec support CUDA 11.8
Write-Host "[INSTALL] Installation de PyTorch avec support CUDA 11.8..." -ForegroundColor Yellow
& "$PWD\venv_chessbot_gpu\Scripts\pip.exe" install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Installer TensorFlow (pas tensorflow-gpu car déprécié)
Write-Host "[INSTALL] Installation de TensorFlow..." -ForegroundColor Yellow
# Vérifier si CUDA 12.x est installé pour choisir la bonne version de TensorFlow
if ($cudaVersion -match "12\.\d+") {
    Write-Host "[INFO] Installation de TensorFlow 2.15 pour compatibilite CUDA 12.x..." -ForegroundColor Cyan
    & "$PWD\venv_chessbot_gpu\Scripts\python.exe" -m pip install tensorflow==2.15.0
} else {
    Write-Host "[INFO] Installation de TensorFlow 2.13.1 pour CUDA 11.8..." -ForegroundColor Cyan
    & "$PWD\venv_chessbot_gpu\Scripts\python.exe" -m pip install tensorflow==2.13.1
}

# Installer les dépendances du projet
Write-Host "[INSTALL] Installation des dépendances du projet..." -ForegroundColor Yellow
if (Test-Path "chess-snapshot-api\requirements.txt") {
    & "$PWD\venv_chessbot_gpu\Scripts\python.exe" -m pip install -r chess-snapshot-api\requirements.txt
} else {
    # Installation manuelle des dépendances
    & "$PWD\venv_chessbot_gpu\Scripts\python.exe" -m pip install numpy==1.24.3 opencv-python==4.8.1.78 ultralytics==8.1.20 scikit-learn==1.3.2 pyclipper==1.3.0.post5 flask==3.0.2 stockfish==3.28.0
}

# Test de validation
Write-Host "[TEST] Validation de l'installation..." -ForegroundColor Yellow
python -c "import torch; print(f'PyTorch CUDA disponible: {torch.cuda.is_available()}')"
python -c "import tensorflow as tf; print(f'TensorFlow version: {tf.__version__}'); print(f'GPU disponible: {len(tf.config.list_physical_devices(\"GPU\")) > 0}'); print(f'Compile avec CUDA: {tf.test.is_built_with_cuda()}')"

Write-Host "[SUCCESS] Configuration terminée!" -ForegroundColor Green
Write-Host "Pour activer l'environnement: .\venv_chessbot_gpu\Scripts\Activate.ps1" -ForegroundColor Cyan

Write-Host "[TEST] Tests de validation GPU..." -ForegroundColor Yellow

Write-Host "Test 1: PyTorch CUDA" -ForegroundColor Cyan
$torchTest = & "$PWD\venv_chessbot_gpu\Scripts\python.exe" -c "import torch; print(f'CUDA disponible: {torch.cuda.is_available()}'); print(f'Version CUDA: {torch.version.cuda}'); print(f'Devices: {torch.cuda.device_count()}')" 2>&1
Write-Host $torchTest -ForegroundColor White

Write-Host "Test 2: TensorFlow GPU" -ForegroundColor Cyan
$tfTest = & "$PWD\venv_chessbot_gpu\Scripts\python.exe" -c "import tensorflow as tf; gpus = tf.config.list_physical_devices('GPU'); print(f'TensorFlow GPU devices: {len(gpus)}'); [print(f'  - {gpu}') for gpu in gpus]" 2>&1
Write-Host $tfTest -ForegroundColor White

# Résumé final
Write-Host "`n[SUCCESS] CONFIGURATION TERMINEE AVEC SUCCES!" -ForegroundColor Green
Write-Host "Resume de l'installation:" -ForegroundColor White
Write-Host "   - Environnement: venv_chessbot_gpu" -ForegroundColor Gray
Write-Host "   - Python: $(& "$PWD\venv_chessbot_gpu\Scripts\python.exe" --version)" -ForegroundColor Gray
Write-Host "   - PyTorch: Version actuelle avec CUDA 11.8" -ForegroundColor Gray
Write-Host "   - TensorFlow: 2.13.1 GPU" -ForegroundColor Gray
Write-Host "   - Optimise pour: RTX 4090" -ForegroundColor Gray

Write-Host "`n[COMMANDS] COMMANDES UTILES:" -ForegroundColor Cyan
Write-Host "   Activer environnement:" -ForegroundColor White
Write-Host "   .\venv_chessbot_gpu\Scripts\Activate.ps1" -ForegroundColor Gray
Write-Host "`n   Lancer le bot:" -ForegroundColor White
Write-Host "   python chess_bot.py" -ForegroundColor Gray
Write-Host "`n   Verifier utilisation GPU:" -ForegroundColor White
Write-Host "   nvidia-smi" -ForegroundColor Gray

Write-Host "`n[+] Votre ChessBot GPU est pret pour RTX 4090!" -ForegroundColor Green
