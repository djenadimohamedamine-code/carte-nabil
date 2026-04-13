@echo off
setlocal enabledelayedexpansion

echo.
echo  [42m[ ASSIMA-10 : Lancement du Build ] [0m
echo.

:: 1. Verification Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git n'est pas installe ou pas dans le PATH.
    pause
    exit /b
)

:: 2. Detection de changements
git status --short | findstr /R "^" >nul
if %errorlevel% equ 0 (
    echo [*] Changements detectes. Preparation du commit...
    git add .
    set "commit_msg=Build Trigger: %date% %time%"
    git commit -m "!commit_msg!"
) else (
    echo [*] Aucun changement detecte. Envoi de l'etat actuel...
)

:: 3. Push vers GitHub (Master et Main)
echo [*] Synchronisation avec GitHub (Saisie de mot de passe possible)...
echo.
:: On essaye de pousser la branche actuelle vers master et main
git push origin master:master --force
git push origin master:main --force
echo.

:: 4. Lien vers le monitoring
echo [SUCCESS] Operation terminee ! 
echo.
echo [*] Ouverture de la page de Actions...
start https://github.com/djenadimohamedamine-code/carte-nabil/actions

echo.
echo Appuyez sur une touche pour fermer...
pause >nul
