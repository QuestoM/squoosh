@echo off
setlocal

:: Get current date and time for commit message
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set YYYY=%datetime:~0,4%
set MM=%datetime:~4,2%
set DD=%datetime:~6,2%
set HH=%datetime:~8,2%
set Min=%datetime:~10,2%
set Sec=%datetime:~12,2%

:: Format commit message with timestamp
set TIMESTAMP=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%

:: Add all changes
git add .

:: Commit with timestamp
git commit -m "Auto commit %TIMESTAMP%"

:: Push to dev branch
git push origin dev

echo Changes pushed to dev branch successfully!
pause