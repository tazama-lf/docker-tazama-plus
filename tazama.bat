@echo off
setlocal enabledelayedexpansion

:menu
set "type="

set "volumes=[ ]"
set "auth=[ ]"
set "basiclogs=[ ]"
set "relay=[ ]"
set "ui=[ ]"
set "natsutils=[ ]"
set "batchppa=[ ]"
set "cms=[ ]"
set "trs=[ ]"
set "tcs=[ ]"
set "deapi_dems=[ ]"
set "opensearch=[ ]"
rem These options default to enabled
set "pgadmin=[X]"
set "hasura=[X]"

set "IS_GITHUB_DEPLOYMENT=0"
set "IS_FULL_DEPLOYMENT=0"
set "IS_MULTITENANT_DEPLOYMENT=0"

cls
echo.
echo Select docker deployment type:
echo.
echo 1. Public (GitHub)
echo 2. Public (DockerHub)
echo 3. Full-service (DockerHub)
echo 4. Multi-Tenant Public (DockerHub)
echo 5. Docker Utilities
echo 6. Database Utilities
echo 7. Consoles
echo.
echo Select option (1-7), or (q)uit:
set /p "type=Enter your choice: "

if /i "%type%"=="q" goto :quit
if /i "%type%"=="" goto :menu

if /i "%type%"=="1" (
    set "IS_GITHUB_DEPLOYMENT=1"
    set "IS_FULL_DEPLOYMENT=0"
    set "IS_MULTITENANT_DEPLOYMENT=0"
    set "relay=[X]"
    set "nats=[X]"
    goto :addons
)
if /i "%type%"=="2" (
    set "IS_GITHUB_DEPLOYMENT=0"
    set "IS_FULL_DEPLOYMENT=0"
    set "IS_MULTITENANT_DEPLOYMENT=0"
    set "relay=[X]"
    set "nats=[X]"
    goto :addons
)
if /i "%type%"=="3" (
    set "IS_GITHUB_DEPLOYMENT=0"
    set "IS_FULL_DEPLOYMENT=1"
    set "IS_MULTITENANT_DEPLOYMENT=0"
    set "relay=[X]"
    set "nats=[X]"
    goto :addons
)
if /i "%type%"=="4" (
    set "IS_GITHUB_DEPLOYMENT=0"
    set "IS_FULL_DEPLOYMENT=0"
    set "IS_MULTITENANT_DEPLOYMENT=1"
    set "auth=[X]"
    set "relay=[X]"
    set "nats=[X]"
    goto :addons
)
if /i "%type%"=="5" (
    goto :utils
)
if /i "%type%"=="6" (
    goto :dbutils
)
if /i "%type%"=="7" (
    goto :consoles
)

:addons
set "choice="
cls
echo.
echo Enable optional deployment configuration addons:
echo.
echo CORE ADDONS:
echo.
echo 1. %auth% Authentication
echo 2. %relay% Relay services (NATS)
echo 3. %basiclogs% Basic Logs
if %IS_MULTITENANT_DEPLOYMENT% NEQ 1 echo 4. %ui% Demo UI
echo.
echo UTILITY ADDONS:
echo.
echo 5. %natsutils% NATS Utilities
echo 6. %batchppa% Batch PPA
echo 7. %pgadmin% pgAdmin for PostgreSQL
echo 8. %hasura% Hasura GraphQL API for PostgreSQL
if %IS_GITHUB_DEPLOYMENT% EQU 1 (
    echo.
    echo GITHUB EXTENDED ADDONS ^(AUTH REQUIRED^):
    echo.
    echo 9.  %cms% CMS
    echo 10. %trs% TRS
    echo 11. %tcs% TCS
    echo 12. %deapi_dems% DEAPI ^& DEMS
    echo 13. %opensearch% OpenSearch
)
echo.
if %IS_GITHUB_DEPLOYMENT% EQU 1 (
    echo Toggle addons (1-13), (a)pply current selection, (r)eturn, or (q)uit
) else (
    echo Toggle addons (1-8), (a)pply current selection, (r)eturn, or (q)uit
)
set /p "choice=Enter your choice: "

if /i "%choice%"=="a" goto :apply
if /i "%choice%"=="r" goto :menu
if /i "%choice%"=="q" goto :quit

set "auth_required=0"
if "%cms%"=="[X]" set "auth_required=1"
if "%trs%"=="[X]" set "auth_required=1"
if "%tcs%"=="[X]" set "auth_required=1"
if "%deapi_dems%"=="[X]" set "auth_required=1"
if "%opensearch%"=="[X]" set "auth_required=1"

rem If multitenant, can't unset auth or relay...
if "%choice%"=="1" (
    if %IS_MULTITENANT_DEPLOYMENT% NEQ 1 (
        if "%auth%" == "[X]" if "%auth_required%"=="1" (
            echo.
            echo Authentication is required while CMS/TRS/TCS/DEAPI^&DEMS/OpenSearch is enabled.
            echo.
            timeout /t 1 >nul
        ) else (
            if "%auth%" == "[ ]" (set "auth=[X]") else (set "auth=[ ]")
        )
    )
)
if "%choice%"=="2" if %IS_MULTITENANT_DEPLOYMENT% NEQ 1 if "%relay%" == "[ ]" (set "relay=[X]") else (set "relay=[ ]")
if "%choice%"=="3" if "%basiclogs%" == "[ ]" (set "basiclogs=[X]") else (set "basiclogs=[ ]")
if "%choice%"=="4" if %IS_MULTITENANT_DEPLOYMENT% NEQ 1 if "%ui%" == "[ ]" (
    if "%auth_required%"=="1" (
        echo.
        echo Demo UI cannot be enabled while CMS/TRS/TCS/DEAPI^&DEMS/OpenSearch is selected because those require Authentication.
        echo.
        timeout /t 2 >nul
        goto :addons
    )
    rem If enabling UI, disable auth and relay
    set "ui=[X]"
    set "auth=[ ]"
    set "relay=[ ]"
    echo.
    echo Note: Enabling the Demo UI addon will disable Authentication and Relay services.
    echo You can re-enable these services again, but the Demo UI will not function correctly.
    echo.
    pause
    ) else (set "ui=[ ]")
if "%choice%"=="5" if "%natsutils%" == "[ ]" (set "natsutils=[X]") else (set "natsutils=[ ]")
if "%choice%"=="6" if "%batchppa%" == "[ ]" (set "batchppa=[X]") else (set "batchppa=[ ]")
if "%choice%"=="7" if "%pgadmin%" == "[ ]" (set "pgadmin=[X]") else (set "pgadmin=[ ]")
if "%choice%"=="8" if "%hasura%" == "[ ]" (set "hasura=[X]") else (set "hasura=[ ]")
if "%choice%"=="9" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        if "%cms%" == "[ ]" (set "cms=[X]") else (set "cms=[ ]")
        if "%cms%"=="[X]" (
            set "auth=[X]"
            set "opensearch=[X]"
        )
    ) else (
        echo.
        echo These addons are currently available only for Public ^(GitHub^) deployment.
        echo.
        timeout /t 1 >nul
    )
)
if "%choice%"=="10" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        if "%trs%" == "[ ]" (set "trs=[X]") else (set "trs=[ ]")
        if "%trs%"=="[X]" (
            set "auth=[X]"
            set "opensearch=[X]"
        )
    ) else (
        echo.
        echo These addons are currently available only for Public ^(GitHub^) deployment.
        echo.
        timeout /t 1 >nul
    )
)
if "%choice%"=="11" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        if "%tcs%" == "[ ]" (
            set "tcs=[X]"
            set "deapi_dems=[X]"
            set "opensearch=[X]"
            set "auth=[X]"
            echo.
            echo TCS requires DEAPI ^& DEMS, OpenSearch, and Authentication. All were enabled automatically.
            echo.
            timeout /t 1 >nul
        ) else (
            set "tcs=[ ]"
        )
    ) else (
        echo.
        echo These addons are currently available only for Public ^(GitHub^) deployment.
        echo.
        timeout /t 1 >nul
    )
)
if "%choice%"=="12" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        if "%deapi_dems%" == "[X]" if "%tcs%" == "[X]" (
            echo.
            echo DEAPI ^& DEMS cannot be disabled while TCS is enabled.
            echo.
            timeout /t 1 >nul
        ) else (
            if "%deapi_dems%" == "[ ]" (set "deapi_dems=[X]") else (set "deapi_dems=[ ]")
            if "%deapi_dems%"=="[X]" set "auth=[X]"
        )
    ) else (
        echo.
        echo These addons are currently available only for Public ^(GitHub^) deployment.
        echo.
        timeout /t 1 >nul
    )
)
if "%choice%"=="13" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        if "%opensearch%" == "[X]" if "%cms%" == "[X]" (
            echo.
            echo OpenSearch cannot be disabled while CMS/TRS/TCS is enabled.
            echo.
            timeout /t 1 >nul
        ) else if "%opensearch%" == "[X]" if "%trs%" == "[X]" (
            echo.
            echo OpenSearch cannot be disabled while CMS/TRS/TCS is enabled.
            echo.
            timeout /t 1 >nul
        ) else if "%opensearch%" == "[X]" if "%tcs%" == "[X]" (
            echo.
            echo OpenSearch cannot be disabled while CMS/TRS/TCS is enabled.
            echo.
            timeout /t 1 >nul
        ) else (
            if "%opensearch%" == "[ ]" (set "opensearch=[X]") else (set "opensearch=[ ]")
            if "%opensearch%"=="[X]" set "auth=[X]"
        )
    ) else (
        echo.
        echo These addons are currently available only for Public ^(GitHub^) deployment.
        echo.
        timeout /t 1 >nul
    )
)

goto :addons

:apply
set "auth_required=0"
if "%cms%"=="[X]" set "auth_required=1"
if "%trs%"=="[X]" set "auth_required=1"
if "%tcs%"=="[X]" set "auth_required=1"
if "%deapi_dems%"=="[X]" set "auth_required=1"
if "%opensearch%"=="[X]" set "auth_required=1"
if "%tcs%"=="[X]" if "%deapi_dems%"=="[ ]" (
    echo.
    echo TCS requires DEAPI ^& DEMS. Enabling DEAPI ^& DEMS automatically.
    echo.
    set "deapi_dems=[X]"
)
if "%cms%"=="[X]" if "%opensearch%"=="[ ]" (
    echo.
    echo CMS/TRS/TCS require OpenSearch. Enabling OpenSearch automatically.
    echo.
    set "opensearch=[X]"
)
if "%trs%"=="[X]" if "%opensearch%"=="[ ]" (
    echo.
    echo CMS/TRS/TCS require OpenSearch. Enabling OpenSearch automatically.
    echo.
    set "opensearch=[X]"
)
if "%tcs%"=="[X]" if "%opensearch%"=="[ ]" (
    echo.
    echo CMS/TRS/TCS require OpenSearch. Enabling OpenSearch automatically.
    echo.
    set "opensearch=[X]"
)
if "%auth_required%"=="1" if "%auth%"=="[ ]" (
    echo.
    echo Authentication is required for CMS/TRS/TCS/DEAPI^&DEMS/OpenSearch. Enabling Authentication automatically.
    echo.
    set "auth=[X]"
)

rem Base command for all options
set "cmd=docker compose -f docker-compose.base.infrastructure.yaml -f docker-compose.base.override.yaml"

rem Add core processors and configuration
if %IS_GITHUB_DEPLOYMENT% EQU 1 (
    set "cmd=!cmd! -f docker-compose.dev.cfg.yaml -f docker-compose.dev.core.yaml"
) else (
    if %IS_MULTITENANT_DEPLOYMENT% EQU 1 (
        set "cmd=!cmd! -f docker-compose.multitenant.cfg.yaml"
    ) else (
        if %IS_FULL_DEPLOYMENT% EQU 1 (
            set "cmd=!cmd! -f docker-compose.full.cfg.yaml"
        ) else (
            set "cmd=!cmd! -f docker-compose.hub.cfg.yaml"
        )
    )
    set "cmd=!cmd! -f docker-compose.hub.core.yaml"
    if %IS_FULL_DEPLOYMENT% EQU 1 (
        set "cmd=!cmd! -f docker-compose.full.rules.yaml"
    ) else (
        set "cmd=!cmd! -f docker-compose.hub.rules.yaml"
    )
)

rem Add authentication services (mandatory for multitenancy)
if "%auth%" == "[X]" (
    set "cmd=!cmd! -f docker-compose.base.auth.yaml"
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        set "cmd=!cmd! -f docker-compose.dev.auth.yaml"
    )
)

rem Add relay services (mandatory for multitenancy)
if "%relay%" == "[X]" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        set "cmd=!cmd! -f docker-compose.dev.relay.yaml"
    ) else (
        if %IS_MULTITENANT_DEPLOYMENT% EQU 1 (
            set "cmd=!cmd! -f docker-compose.multitenant.relay.yaml"
        ) else (
            set "cmd=!cmd! -f docker-compose.hub.relay.yaml"
        )
    )
)

rem Add basic logging services
if "%basiclogs%" == "[X]" (
    if %IS_GITHUB_DEPLOYMENT% EQU 1 (
        set "cmd=!cmd! -f docker-compose.dev.logs.base.yaml"
    ) else (
        set "cmd=!cmd! -f docker-compose.hub.logs.base.yaml"
    )
)

if "%ui%" == "[X]" set "cmd=!cmd! -f docker-compose.hub.ui.yaml"
if "%natsutils%" == "[X]" set "cmd=!cmd! -f docker-compose.utils.nats-utils.yaml"
if "%batchppa%" == "[X]" set "cmd=!cmd! -f docker-compose.utils.batch-ppa.yaml"
if "%pgadmin%" == "[X]" set "cmd=!cmd! -f docker-compose.utils.pgadmin.yaml"
if "%hasura%" == "[X]" set "cmd=!cmd! -f docker-compose.utils.hasura.yaml"

if %IS_GITHUB_DEPLOYMENT% EQU 1 (
    if "%cms%" == "[X]" set "cmd=!cmd! -f docker-compose.cms.yaml"
    if "%trs%" == "[X]" set "cmd=!cmd! -f docker-compose.trs.yaml"
    if "%tcs%" == "[X]" set "cmd=!cmd! -f docker-compose.tcs.yaml"
    if "%deapi_dems%" == "[X]" set "cmd=!cmd! -f docker-compose-deapi-dems.yaml"
    if "%opensearch%" == "[X]" set "cmd=!cmd! -f docker-compose.opensearch.yaml"
)

echo.
echo Command to run: !cmd! -p tazama up -d
echo.
set /p "confirm=Press (e) to execute, (q) to quit or any other key to go back: "
echo.
if "%confirm%"=="e" (
    echo stopping existing Tazama containers...
    echo.
    docker compose -p tazama down --volumes --remove-orphans
    echo.
    echo Deploying Tazama from Docker Hub...
    echo.
    !cmd! -p tazama up -d --remove-orphans --force-recreate
    goto :end
) else ( 
    if "%confirm%"=="q" (
        goto :end
    )
    if "%confirm%"=="" (
        goto :addons
    )
) 
goto :end

:utils
set "choice="
cls
echo.
echo Execute some Docker commands:
echo.
echo 1. Stop and restart ED, TP and TADP (reload network configuration)
echo 2. Stop and remove Tazama project containers and volumes
echo 3. Remove all unused containers, networks, images and volumes
echo 4. List all images
echo 5. List all containers
echo 6. List all volumes
echo 7. List all networks
echo.
echo Select function (1-7), (r)eturn or (q)uit
set /p "choice=Enter your choice: "

if /i "%choice%"=="q" goto :quit
if /i "%choice%"=="r" goto :menu
if /i "%choice%"=="" goto :utils

if "%choice%"=="1" (
    set "cmd=docker restart tazama-tp-1 tazama-tadp-1 tazama-ed-1"
)
if "%choice%"=="2" (
    set "cmd=docker compose -p tazama down --volumes"
)
if "%choice%"=="3" (
    set "cmd=docker system prune -a -f --volumes"
)
if "%choice%"=="4" (
    set "cmd=docker image ls"
)
if "%choice%"=="5" (
    set "cmd=docker container ls"
)
if "%choice%"=="6" (
    set "cmd=docker volume ls"
)
if "%choice%"=="7" (
    set "cmd=docker network ls"
)

echo Executing command: !cmd!
echo.
call !cmd!
echo.
pause

goto :utils

:dbutils
set "choice="
cls
echo.
echo Database utilities:
echo.
echo 1. List all PostgreSQL databases
echo 2. List all PostgreSQL tables in all databases
echo 3. Reset Hasura metadata
echo 4. Reinitialize Hasura
echo.
echo Select function (1-4), (r)eturn or (q)uit
set /p "choice=Enter your choice: "

if /i "%choice%"=="q" goto :quit
if /i "%choice%"=="r" goto :menu
if /i "%choice%"=="" goto :dbutils

echo Executing command...
echo.

if "%choice%"=="1" (
    call docker exec -it tazama-postgres-1 psql -U postgres -c "\l"
)
if "%choice%"=="2" (

    for %%d in (event_history raw_history configuration evaluation) do (
    echo.
    echo === %%d ===
    call docker exec -it tazama-postgres-1 psql -U postgres -d %%d -c "\dt"
    )
)
if "%choice%"=="3" (
    echo.
    echo Stopping Hasura containers...
    call docker stop tazama-hasura-1 tazama-hasura-init-1 2>nul
    echo.
    echo Removing Hasura containers...
    call docker rm tazama-hasura-1 tazama-hasura-init-1 2>nul
    echo.
    echo Dropping Hasura metadata database...
    call docker exec tazama-postgres-1 psql -U postgres -c "DROP DATABASE IF EXISTS hasura;"
    call docker exec tazama-postgres-1 psql -U postgres -c "CREATE DATABASE hasura;"
)
if "%choice%"=="4" (
    echo.
    echo Restarting Hasura-init container...
    call docker restart tazama-hasura-init-1
)
echo.
pause

goto :dbutils

:consoles
set "choice="
cls
echo.
echo Access a service web console:
echo.
echo 1. pgAdmin - localhost:15050
echo 2. hasura - localhost:6100
echo 3. Keycloak - localhost:8080
echo 4. TMS-service Swagger - localhost:5000/documentation
echo 5. Admin-service Swagger - localhost:5100/documentation
echo.
echo Select function (1-5), (r)eturn or (q)uit
set /p "choice=Enter your choice: "

if /i "%choice%"=="q" goto :quit
if /i "%choice%"=="r" goto :menu
if /i "%choice%"=="" goto :consoles

echo Executing command...
echo.

if "%choice%"=="1" (
    start http://localhost:15050
)
if "%choice%"=="2" (
    start http://localhost:6100
)
if "%choice%"=="3" (
    start http://localhost:8080
)
if "%choice%"=="4" (
    start http://localhost:5000/documentation
)
if "%choice%"=="5" (
    start http://localhost:5100/documentation
)

echo.
pause

goto :consoles

:end
echo.
echo All done!
echo.
pause

goto :menu

:quit
exit /b 0
