@echo off
chcp 65001 >nul
title VirtualBrowser 一键启动器
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║              VirtualBrowser 一键启动器                        ║
echo ║              基于 fingerprint-chromium (ungoogled-chromium)   ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

:: 检查必要依赖
echo [检查] 检查必要依赖...

:: 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)
echo [OK] Python 已安装

:: 检查 Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Node.js，请先安装 Node.js 14+
    pause
    exit /b 1
)
echo [OK] Node.js 已安装

:: 检查 Flask
pip show flask >nul 2>&1
if errorlevel 1 (
    echo [安装] 正在安装 Flask...
    pip install flask flask-cors
    if errorlevel 1 (
        echo [错误] Flask 安装失败
        pause
        exit /b 1
    )
)
echo [OK] Flask 已安装

:: 检查 fingerprint-chromium
echo.
echo [检查] 检查 fingerprint-chromium...
set "CHROMIUM_FOUND=0"
set "CHROMIUM_PATH="

if exist "%~dp0launcher\fingerprint-chromium\chrome.exe" (
    set "CHROMIUM_PATH=%~dp0launcher\fingerprint-chromium\chrome.exe"
    set "CHROMIUM_FOUND=1"
    echo [OK] 找到 chromium: launcher\fingerprint-chromium\
) else if exist "C:\fingerprint-chromium\chrome.exe" (
    set "CHROMIUM_PATH=C:\fingerprint-chromium\chrome.exe"
    set "CHROMIUM_FOUND=1"
    echo [OK] 找到 chromium: C:\fingerprint-chromium\
) else if exist "D:\fingerprint-chromium\chrome.exe" (
    set "CHROMIUM_PATH=D:\fingerprint-chromium\chrome.exe"
    set "CHROMIUM_FOUND=1"
    echo [OK] 找到 chromium: D:\fingerprint-chromium\
) else (
    echo [警告] 未找到 fingerprint-chromium！
    echo.
    echo 请下载并解压到以下位置之一：
    echo   - launcher\fingerprint-chromium\
    echo   - C:\fingerprint-chromium\
    echo   - D:\fingerprint-chromium\
    echo.
    echo 下载地址: https://github.com/adryfish/fingerprint-chromium/releases
    echo.
    echo 按任意键继续启动服务（但无法启动浏览器）...
    pause >nul
)

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║  即将启动以下服务：                                           ║
echo ║                                                               ║
echo ║  1. Launcher 服务  (Python Flask)  - http://localhost:9528   ║
echo ║  2. 管理界面      (Vue.js)         - http://localhost:9527   ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo 按任意键开始启动，或按 Ctrl+C 取消...
pause >nul

:: 创建日志目录
if not exist "%~dp0logs" mkdir "%~dp0logs"

:: 启动 Launcher 服务
echo.
echo [1/2] 正在启动 Launcher 服务...
echo        端口: 9528
echo        日志: logs\launcher.log
cd /d "%~dp0launcher"
start "VirtualBrowser Launcher" cmd /c "python launcher.py > ..\logs\launcher.log 2>&1"

:: 等待 Launcher 启动
timeout /t 3 /nobreak >nul

:: 检查 Launcher 是否启动成功
curl.exe -s http://localhost:9528/api/config >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Launcher 服务启动成功
) else (
    echo [警告] Launcher 服务可能未正常启动，请检查 logs\launcher.log
)

:: 检查 Server 依赖
if not exist "%~dp0server\node_modules" (
    echo.
    echo [安装] 检测到缺少 node_modules，正在安装依赖...
    echo        这可能需要几分钟时间...
    cd /d "%~dp0server"
    call npm install
    if errorlevel 1 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
)

:: 启动 Server 管理界面
echo.
echo [2/2] 正在启动管理界面...
echo        端口: 9527
echo        日志: logs\server.log
cd /d "%~dp0server"
start "VirtualBrowser Server" cmd /c "npm run dev > ..\logs\server.log 2>&1"

:: 等待 Server 启动
timeout /t 10 /nobreak >nul

:: 检查服务状态
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║  服务启动状态：                                               ║
echo ║                                                               ║
curl.exe -s http://localhost:9528/api/config >nul 2>&1
if %errorlevel% equ 0 (
echo ║  [OK] Launcher 服务    - http://localhost:9528              ║
) else (
echo ║  [X]  Launcher 服务    - 未启动                             ║
)
echo ║                                                               ║
echo ║  管理界面正在编译中，请等待 30-60 秒...                      ║
echo ║  编译完成后访问: http://localhost:9527                      ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝

echo.
echo 操作选项：
echo   [1] 打开管理界面 (http://localhost:9527)
echo   [2] 查看 Launcher 日志
echo   [3] 查看 Server 日志
echo   [4] 停止所有服务
echo   [Q] 退出
echo.

:menu
set /p choice="请选择操作 (1-4, Q): "

if "%choice%"=="1" (
    start http://localhost:9527
    goto menu
)

if "%choice%"=="2" (
    if exist "%~dp0logs\launcher.log" (
        type "%~dp0logs\launcher.log"
    ) else (
        echo 日志文件不存在
    )
    pause
    goto menu
)

if "%choice%"=="3" (
    if exist "%~dp0logs\server.log" (
        type "%~dp0logs\server.log"
    ) else (
        echo 日志文件不存在
    )
    pause
    goto menu
)

if "%choice%"=="4" (
    echo.
    echo 正在停止所有服务...
    taskkill /FI "WINDOWTITLE eq VirtualBrowser Launcher*" /F >nul 2>&1
    taskkill /FI "WINDOWTITLE eq VirtualBrowser Server*" /F >nul 2>&1
    taskkill /FI "WINDOWTITLE eq VirtualBrowser 一键启动器*" /F >nul 2>&1
    echo [OK] 所有服务已停止
    pause
    exit /b 0
)

if /i "%choice%"=="Q" (
    echo.
    echo 提示：服务仍在后台运行
    echo 如需停止服务，请重新运行此脚本并选择选项 4
    exit /b 0
)

goto menu
