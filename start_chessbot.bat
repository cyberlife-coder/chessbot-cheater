@echo off
echo 🚀 Démarrage ChessBot GPU...
cd /d "%~dp0"
call venv_chessbot_gpu\Scripts\activate.bat
echo ✅ Environnement GPU activé!
echo.
echo 💡 Commandes disponibles:
echo   python chess_bot.py          - Lancer le bot
echo   python benchmark_gpu.py      - Test performance GPU
echo   nvidia-smi                   - Vérifier utilisation GPU
echo.
cmd /k
