@echo off
setlocal
echo 🚀 [ ULTRA PUSH & BUILD : ZONE 14 ] 🚀

:: Nettoyage des index Git
echo [*] Nettoyage Git...
git gc --prune=now --quiet

:: Ajout de TOUS les fichiers (y compris les .github et fix_ios.bat)
echo [*] Preparation des fichiers...
git add .

:: Commit force (avec date/heure pour garantir une modification)
set MYDATE=%date% %time%
echo [*] Creation du commit de declenchement...
git commit -m "🚀 Force Build Trigger - %MYDATE%" || echo [INFO] Rien a committer, on force le push quand meme.

:: Push force vers les deux branches possibles
echo [*] Envoi vers GitHub (master)...
git push origin master:master --force

echo [*] Envoi vers GitHub (main)...
git push origin master:main --force

echo.
echo ✅ [ SUCCES ] Le build devrait maintenant demarrer !
echo Suivez la progression ici :
echo https://github.com/djenadimohamedamine-code/carte-nabil/actions
echo.
pause
