@echo off

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

@echo off
netsh advfirewall set allprofiles state on
echo Windows Firewall has been enabled for all profiles.

REM Set audit policies
auditpol /set /category:"System" /success:enable /failure:enable
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
auditpol /set /category:"Object Access" /success:enable /failure:enable

REM add secpols

echo Password complexity requirements have been enabled.

REM Set minimum password length to 10 characters
net accounts /minpwlen:10

REM Set maximum password age to 60 days
net accounts /maxpwage:60

REM Set minimum password age to 1 day
net accounts /minpwage:1

REM Set password history to remember 24 passwords
net accounts /uniquepw:24

REM Set account lockout threshold to 10 attempts
net accounts /lockoutthreshold:10

REM Set account lockout duration to 30 minutes
net accounts /lockoutduration:30

REM Set account lockout observation window to 30 minutes
net accounts /lockoutwindow:30

echo Password policy has been updated.

REM Set all audit categories to log both success and failure events
echo Auditing the maching now
	auditpol /set /category:* /success:enable
	auditpol /set /category:* /failure:enable

echo Audit policy has been updated to log both success and failure events for all categories.

REM Modify security policy settings
echo.
echo Modifying security policy…

REM Modify the security policy to block Microsoft accounts
powershell -Command "(gc C:\secpol.cfg) -replace 'NoConnectedUser = 3', 'NoConnectedUser = 4' | Out-File C:\secpol.cfg"

REM Modify the security policy to limit blank password use
powershell -Command "(gc C:\secpol.cfg) -replace 'LimitBlankPasswordUse=4,3', 'LimitBlankPasswordUse=4,1' | Out-File C:\secpol.cfg"

REM Disable auditing of access to global system objects
auditpol /set /category:"Object Access" /subcategory:"Global System Objects" /success:disable /failure:disable

REM Disable auditing for Backup and Restore privileges
auditpol /set /category:"Privilege Use" /subcategory:"Backup and Restore" /success:disable /failure:disable

REM Enable "Audit: Force audit policy subcategory settings to override audit policy category settings"
auditpol /set /subcategory:"Audit Policy Change" /success:enable /failure:enable

REM Verify the change
auditpol /get /subcategory:"Audit Policy Change"



echo DCOM Machine Launch Restrictions have been set to disallow remote access for all accounts.

echo Local security policies have been updated.

setlocal enabledelayedexpansion

REM Function to generate a random complex password
:generatePassword
Set chars=”ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
set password=""
for /L %%i in (1,1,16) do (
    set /a rand=!random! %% 92
    for %%j in (!rand!) do set password=!password!!chars:~%%j,1!
)
exit /b

REM Main script
for %%a in ('net user') do (
    set user=%%a
    if not !user!==%username% (
        if not !user!=="Administrator" (
            if not !user!=="Guest" (
                    call :generatePassword
                    echo Changing password for user: !user!
                    net user !user! !password!
                    echo New password for !user!: !password!
                    echo.

            )
        )
    )
)

echo Password change process completed.
Pause
:MENU
cls 
echo =========== Forensic Menu ===========
echo 1. Find a Backdoor Connection
echo 2. Find the Hash Number of an Image (MD5 SHA1 SHA256 RIPEMD160)
echo 3. Authorize Administrators and Users
echo 4. Exit
echo ======================================

set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" goto backdoor
if "%choice%"=="2" goto imgHash
if "%choice%"=="3" goto authUse
if "%choice%"=="4" exit

goto MENU


REM Backdoor Finder
:backdoor
echo Searching for potential backdoors...

:: List all TCP connections and their associated processes
netstat -ano -p tcp > connections.txt

:: Search for suspicious connections (adjust as needed)
findstr /i "ESTABLISHED" connections.txt > suspicious.txt

:: Display results
echo Potential backdoors found:
type suspicious.txt

:: Clean up temporary files
del connections.txt
del suspicious.txt

echo.
echo To investigate further, check the Process IDs (PIDs) listed above.
echo Use 'tasklist | find "PID"' to identify the associated programs.
Pause
Goto MENU

REM Image Hash Finder
:imgHash
setlocal enabledelayedexpansion
goto input

:input
Pause
set /p "imagepath=Enter the full path of the image file: "
if not exist "!imagepath!" (
    echo File not found. Please try again.
    goto input
)

echo.
echo Calculating hashes for %imagepath%...
echo.

for %%h in (MD5 SHA1 SHA256) do (
    for /f "skip=1 tokens=* delims=" %%a in ('certutil -hashfile "!imagepath!" %%h') do (
        set "hash=%%a"
        set "hash=!hash: =!"
        echo %%h: !hash!
    )
)

echo.
Pause
Goto MENU

:authUse
echo Creating files admin.txt and users.txt
echo Type authorized admins separated by lines > admin.txt
echo Type authorized users separated by lines > user.txt

move admin.txt %USERPROFILE%\Desktop
move users.txt %USERPROFILE%\Desktop

echo Press enter once you have filled out the text files.
Pause

setlocal enabledelayedexpansion

set userfile=users.txt
set tempfile=%temp%\tempusers.txt

REM Create a temporary file with all existing user accounts
net user > %tempfile%

REM Read the user file and mark existing users
for %%a in (%userfile%) do (
    set found=0
    for /f skip=4 tokens=1,* %%b in (%tempfile%) do (
        if %%b==%%a set found=1
    )
    if !found!==1 (
        echo User %%a exists and will not be disabled.
    ) else (
        echo User %%a not found in the system.
    )
)

:: Disable accounts not in the user file
for /f skip=4 tokens=1,* %%b in (%tempfile%) do (
    set disable=1
    for /f usebackq delims= %%a in (%userfile%) do (
        if %%b==%%a set disable=0
    )
    if !disable!==1 (
        if not %%b==%username% (
            if not %%b=="Administrator" (
                if not %%b=="Guest" (
                    echo Disabling user: %%b
                    net user %%b /active:no
                )
            )
        )
    )
)

:: Clean up
del %tempfile%

setlocal enabledelayedexpansion

set userfile=admin.txt
set tempfile=%temp%\tempadmins.txt

:: Get current Administrators group members
net localgroup Administrators > %tempfile%

:: Remove users not in the allowed list
for /f skip=6 tokens=* %%a in (%tempfile%) do (
    set user=%%a
    set found=0
    for /f usebackq delims= %%b in (%userfile%) do (
        if !user!==%%b set found=1
    )
    if !found!==0 (
        if not !user!=="Administrator" (
            if not !user!==%username% (
                echo Removing !user! from Administrators group
                net localgroup Administrators !user! /delete
            )
        )
    )
)

:: Clean up
del %tempfile%

echo Process completed.
Pause
goto MENU




