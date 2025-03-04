@echo off
setlocal

echo Synchronizing local directory with 'tries' branch from GitHub...

:: Save current branch name
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i

:: Fetch the latest changes from remote
git fetch origin

:: Stash any local changes (optional, but prevents conflicts)
git stash

:: Checkout the tries branch
git checkout tries

:: Pull the latest changes from the tries branch
git pull origin tries

:: Return to the original branch (optional)
:: Uncomment the next line if you want to return to your original branch
:: git checkout %current_branch%

:: Apply stashed changes if needed (optional)
:: Uncomment the next line if you want to apply your stashed changes
:: git stash pop

echo.
echo Local directory is now synchronized with 'tries' branch from GitHub.
echo.
pause