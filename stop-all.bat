@echo off
chcp 65001 >nul
title VirtualBrowser 服务停止工具
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║              VirtualBrowser 服务停止工具                      ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

echo 正在停止所有 VirtualBrowser 服务...
echo.

:: 停止 Launcher 服务
echo [1/2] 停止 Launcher 服务...
taskkill /FI "WINDOWTITLE eq VirtualBrowser Launcher*" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq *launcher.py*" /F >nul 2>&1
echo [OK] Launcher 服务已停止

:: 停止 Server 服务
echo [2/2] 停止管理界面服务...
taskkill /FI "WINDOWTITLE eq VirtualBrowser Server*" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq *npm run dev*" /F >nul 2>&1
echo [OK] 管理界面服务已停止

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║              所有服务已停止                                   ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
pause
