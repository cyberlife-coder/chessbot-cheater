# Configuration GPU pour ChessBot Cheater

## Prérequis Windows 11

### 1. CUDA Toolkit 11.8
- Télécharger: https://developer.nvidia.com/cuda-11-8-0-download-archive
- Installer la version complète (pas juste le runtime)

### 2. cuDNN SDK 8.6
- Télécharger: https://developer.nvidia.com/cudnn-archive
- Extraire dans le dossier CUDA (C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8)

### 3. Variables d'environnement
```
CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
PATH=%CUDA_PATH%\bin;%CUDA_PATH%\libnvvp;%PATH%
```

## Installation

```bash
# Cloner le projet
git clone https://github.com/cyberlife-coder/chessbot-cheater.git
cd chessbot-cheater

# Installer les dépendances
pip install -r chess-snapshot-api/requirements.txt

# Tester la configuration GPU
python benchmark_gpu.py
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

### Erreur CUDA non trouvé
1. Vérifier l'installation CUDA 11.8
2. Redémarrer après installation
3. Vérifier les variables d'environnement

### Erreur TensorFlow GPU
1. Installer tensorflow-gpu==2.13.1
2. Vérifier cuDNN 8.6 installation
3. Redémarrer Python

### Performance dégradée
1. Vérifier que le GPU est utilisé avec `nvidia-smi`
2. Fermer autres applications GPU-intensives
3. Augmenter la mémoire GPU disponible

## Test rapide

```bash
# Test configuration GPU
python -c "from gpu_config import GPUConfig; gpu = GPUConfig(); print('GPU:', gpu.cuda_available); print('Info:', gpu.get_device_info())"

# Test complet
python benchmark_gpu.py
```
