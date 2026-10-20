@echo off
setlocal
for %%I in ("%~dp0.") do set "PROJECT=%%~nxI"
for %%I in ("%~dp0..\..") do set "ROOT=%%~fI"
docker compose -f "%ROOT%\stack\docker-compose.yml" exec -w "/var/www/projects/%PROJECT%" php composer %*
exit /b %ERRORLEVEL%