@echo off
setlocal
echo 🔴 [ RESTAURATION iOS : ZONE 14 ] 🔴

set FLUTTER_EXE=C:\flutter\bin\flutter.bat

if not exist "%FLUTTER_EXE%" (
    echo [ERREUR] Flutter est introuvable sur ce PC (C:\flutter).
    echo Veuillez verifier l'emplacement de Flutter.
    pause
    exit /b 1
)

echo [*] Regeneration du dossier 'ios' en cours...
"%FLUTTER_EXE%" create --platforms=ios .

if %errorlevel% neq 0 (
    echo [ERREUR] La commande flutter create a echoue.
    pause
    exit /b 1
)

echo [*] Enregistrement du dossier dans Git...
git add ios/
git commit -m "chore: Restore stable ios folder"

echo.
echo ✅ [ SUCCES ] Le dossier iOS est restaure et pret pour le build.
echo Vous n'avez PAS besoin de faire de 'git pull'.
echo Appuyez sur une touche pour terminer.
pause
