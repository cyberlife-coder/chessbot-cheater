# Configuration GPU pour ChessBot Cheater

## Prérequis Windows 11

### 1. Python 3.9-3.11 (recommandé: 3.10)
- Télécharger depuis: https://www.python.org/downloads/
- ⚠️ **Important**: Cocher "Add Python to PATH" lors de l'installation
- Vérifier: `python --version` dans PowerShell

### 2. CUDA Toolkit 11.8
- Télécharger: https://developer.nvidia.com/cuda-11-8-0-download-archive
- Installer la version complète (pas juste le runtime)
- Redémarrer après installation

### 3. cuDNN SDK 8.6
- Télécharger: https://developer.nvidia.com/cudnn-archive
- Extraire dans le dossier CUDA (C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8)

### 4. Variables d'environnement
```
CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
PATH=%CUDA_PATH%\bin;%CUDA_PATH%\libnvvp;%PATH%
```

## Configuration de l'environnement Python

### Option 1: Environnement virtuel Python (Recommandé)

```powershell
# Cloner le projet
git clone https://github.com/cyberlife-coder/chessbot-cheater.git
cd chessbot-cheater

# Créer un environnement virtuel dédié
python -m venv venv_chessbot_gpu

# Activer l'environnement (Windows)
.\venv_chessbot_gpu\Scripts\Activate.ps1

# Mettre à jour pip
python -m pip install --upgrade pip

# Installer les dépendances GPU
pip install -r chess-snapshot-api/requirements.txt

# Tester la configuration GPU
python benchmark_gpu.py
```

### Option 2: Conda (Alternative)

```powershell
# Installer Miniconda: https://docs.conda.io/en/latest/miniconda.html

# Créer environnement avec Python 3.10
conda create -n chessbot_gpu python=3.10
conda activate chessbot_gpu

# Installer PyTorch avec CUDA 11.8
conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia

# Installer TensorFlow GPU
pip install tensorflow-gpu==2.13.1

# Installer autres dépendances
pip install -r chess-snapshot-api/requirements.txt
```

## Activation quotidienne

```powershell
# Naviguer vers le projet
cd C:\path\to\chessbot-cheater

# Activer l'environnement virtuel
.\venv_chessbot_gpu\Scripts\Activate.ps1

# Vérifier que l'environnement est actif (doit afficher le nom)
# (venv_chessbot_gpu) PS C:\path\to\chessbot-cheater>

# Lancer le bot
python chess_bot.py
```

## Vérification de l'installation

### Test rapide GPU
```powershell
# Activer l'environnement
.\venv_chessbot_gpu\Scripts\Activate.ps1

# Test configuration GPU
python -c "from gpu_config import GPUConfig; gpu = GPUConfig(); print('GPU:', gpu.cuda_available); print('Info:', gpu.get_device_info())"

# Test PyTorch CUDA
python -c "import torch; print(f'PyTorch CUDA: {torch.cuda.is_available()}')"

# Test TensorFlow GPU
python -c "import tensorflow as tf; print(f'TensorFlow GPU: {len(tf.config.list_physical_devices(\"GPU\"))}')"
```

### Test complet
```powershell
# Benchmark performance
python benchmark_gpu.py

# Test du bot complet
python chess_bot.py
```

## Utilisation

```python
from chess_bot import main
from gpu_config import GPUConfig

# Vérifier la configuration GPU
gpu_config = GPUConfig()
print(f"GPU disponible: {gpu_config.cuda_available}")
print(f"Device: {gpu_config.device}")

# Lancer le bot avec optimisations GPU
main(loop=True, interval=5.0)
```

## Performances attendues

- **RTX 4090**: ~2-5ms par détection
- **RTX 3080**: ~5-10ms par détection  
- **CPU seulement**: ~50-100ms par détection

## Dépannage

### Erreur "ModuleNotFoundError"
```powershell
# Vérifier que l'environnement est activé
.\venv_chessbot_gpu\Scripts\Activate.ps1

# Réinstaller les dépendances
pip install -r chess-snapshot-api/requirements.txt
```

### Erreur CUDA non trouvé
1. Vérifier l'installation CUDA 11.8: `nvcc --version`
2. Redémarrer après installation CUDA
3. Vérifier les variables d'environnement
4. Réinstaller PyTorch: `pip install torch --index-url https://download.pytorch.org/whl/cu118`

### Erreur TensorFlow GPU
1. Vérifier cuDNN 8.6 dans le dossier CUDA
2. Réinstaller: `pip uninstall tensorflow tensorflow-gpu && pip install tensorflow-gpu==2.13.1`
3. Redémarrer PowerShell

### Performance dégradée
1. Vérifier utilisation GPU: `nvidia-smi`
2. Fermer autres applications GPU-intensives
3. Augmenter mémoire GPU disponible dans les paramètres NVIDIA

### Erreur d'exécution PowerShell
```powershell
# Si erreur "execution policy"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Puis réessayer l'activation
.\venv_chessbot_gpu\Scripts\Activate.ps1
```

## Scripts utiles

### Activation rapide (créer un .bat)
Créer `start_chessbot.bat`:
```batch
@echo off
cd /d "C:\path\to\chessbot-cheater"
call venv_chessbot_gpu\Scripts\activate.bat
echo Environnement GPU activé!
echo Tapez: python chess_bot.py
cmd /k
```

### Test automatique
Créer `test_gpu.bat`:
```batch
@echo off
cd /d "C:\path\to\chessbot-cheater"
call venv_chessbot_gpu\Scripts\activate.bat
python benchmark_gpu.py
pause
```
