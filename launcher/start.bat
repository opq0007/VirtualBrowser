@echo off
chcp 65001 >nul
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║     VirtualBrowser Launcher                                   ║
echo ║     for fingerprint-chromium (ungoogled-chromium)             ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

:: 检查Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到Python，请先安装Python 3.8+
    pause
    exit /b 1
)

:: 检查依赖
echo [1/4] 检查依赖...
pip show flask >nul 2>&1
if errorlevel 1 (
    echo 正在安装 Flask...
    pip install flask flask-cors
    if errorlevel 1 (
        echo [错误] 安装依赖失败
        pause
        exit /b 1
    )
)

:: 设置环境变量
echo [2/4] 配置环境...

:: 检测 chromium 路径（按优先级）
set "CHROMIUM_PATH="

:: 1. 检查环境变量
if defined CHROMIUM_PATH (
    if exist "%CHROMIUM_PATH%" (
        echo 使用环境变量 CHROMIUM_PATH
        goto :found_chromium
    )
)

:: 2. 检查 launcher 子目录
set "TEST_PATH=%~dp0fingerprint-chromium\chrome.exe"
if exist "%TEST_PATH%" (
    set "CHROMIUM_PATH=%TEST_PATH%"
    echo 找到 chromium: launcher/fingerprint-chromium/
    goto :found_chromium
)

:: 3. 检查 C 盘
set "TEST_PATH=C:\fingerprint-chromium\chrome.exe"
if exist "%TEST_PATH%" (
    set "CHROMIUM_PATH=%TEST_PATH%"
    echo 找到 chromium: C:\fingerprint-chromium\
    goto :found_chromium
)

:: 4. 检查 D 盘
set "TEST_PATH=D:\fingerprint-chromium\chrome.exe"
if exist "%TEST_PATH%" (
    set "CHROMIUM_PATH=%TEST_PATH%"
    echo 找到 chromium: D:\fingerprint-chromium\
    goto :found_chromium
)

:found_chromium

if not defined CHROMIUM_PATH (
    echo [警告] 未找到 fingerprint-chromium
    echo.
    echo 请下载并解压到以下位置之一：
    echo   - %~dp0fingerprint-chromium\  (推荐)
    echo   - C:\fingerprint-chromium\
    echo   - D:\fingerprint-chromium\
    echo.
    echo 下载地址: https://github.com/adryfish/fingerprint-chromium/releases
    echo.
    echo 或设置环境变量:
    echo   set CHROMIUM_PATH=你的浏览器路径
    echo.
    set "CHROMIUM_PATH=%~dp0fingerprint-chromium\chrome.exe"
)

:: 设置数据目录和端口
set "DATA_DIR=%~dp0profiles"
set "PORT=9528"

:: 创建数据目录
if not exist "%DATA_DIR%" (
    echo [3/4] 创建数据目录...
    mkdir "%DATA_DIR%"
) else (
    echo [3/4] 数据目录已存在
)

:: 显示配置
echo [4/4] 启动配置:
echo   浏览器路径: %CHROMIUM_PATH%
echo   数据目录:   %DATA_DIR%
echo   API端口:    %PORT%
echo.

:: 启动服务
cd /d %~dp0
echo 正在启动 Launcher 服务...
echo 管理界面: http://localhost:9527 (需单独启动)
echo API地址:  http://localhost:%PORT%
echo.
echo 按 Ctrl+C 停止服务
echo.

python launcher.py

pause
