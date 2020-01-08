function bluechecker { # Remove this for script

Write-Output ""
Write-Output "__________.__                _________ .__                   __                 "
Write-Output "\______   \  |  __ __   ____ \_   ___ \|  |__   ____   ____ |  | __ ___________ "
Write-Output " |    |  _/  | |  |  \_/ __ \/    \  \/|  |  \_/ __ \_/ ___\|  |/ // __ \_  __ \"
Write-Output " |    |   \  |_|  |  /\  ___/\     \___|   Y  \  ___/\  \___|    <\  ___/|  | \/"
Write-Output " |______  /____/____/  \___  >\______  /___|  /\___  >\___  >__|_ \\___  >__|   "
Write-Output "        \/                 \/        \/     \/     \/     \/     \/    \/       "
Write-Output "Author: https://securethelogs.com"
Write-Output "`n"


<#

Should you wish to trust this script, remember to codesign

#Location of certificate
$cert=(dir cert:currentuser\my\ -CodeSigningCert)

#Sign
#Set-AuthenticodeSignature .\location\thisscript.ps1 $cert



#>


# --------- Change this location if wanted to remotely output info ---------------

$locationfile = "C:\temp\v2-computers.txt"


# Gather Details

$computername = hostname
$version = $PSVersionTable.PSVersion.Major 
$remotepowershellstatus = (Get-Service WinRm).status


# Check If Server or Client

$featurestatus = (Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).state

if ($featurestatus -eq $null){

$featurestatusserver = Get-WindowsFeature PowerShell-V2

}


# Is there History Of Downgrade v2

$CheckPSReadLine = Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\PSReadline"

if ($CheckPSReadLine -eq "True") {

$downgradedcheck = Select-String -Pattern '-version 2','-v 2' -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

}




# ---------- Display results -----------------
Write-Output "`n"
Write-Output "----------- PowerShell Status -----------"
Write-Output "`n"

Write-Output "Hostname: $computername"
Write-Output "Current Version: $version"
Write-Output "Remote PowerShell Status (WinRM): $remotepowershellstatus"


# ------ Display Feature Based on Server Or Client ---------

if ($featurestatus -eq $null){

Write-Output "PowerShell v2 State:" $featurestatusserver
Write-Output "`n"

} 

else {

Write-Output "PowerShell v2 State: $featurestatus"

}

Write-Output "`n"




# ----------- If downgrading has been done, show commands ---------------

Write-Output "----------- Checking Downgrading History -----------"
Write-Output "`n"

if ($downgradedcheck -eq $null){

Write-Output "- No Evidence Of Downgrading Found. (The PSReadLine Module might not be installed) "
Write-Output "`n"

} else {

Write-Output "- Evidence Of Downgrading Found:"
Write-Output "$downgradedcheck"
Write-Output "`n"

}


#-------------- Checking For Auditing --------------------------

Write-Output "----------- Checking Auditing -----------"
Write-Output "`n"

$modkey = ""
$modscript = ""

$CheckIfModule = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging -erroraction SilentlyContinue
$CheckIfScript = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -erroraction SilentlyContinue
$CheckIfCmd = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit -erroraction SilentlyContinue


# ------------- Module Logging --------------------

if ($CheckIfModule -eq $null) {

$CheckIfModuleWoW = Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging -erroraction SilentlyContinue

if ($CheckIfModuleWoW -eq $null) {

$modkey = "empty"

} else {

$modkey = "2"

}

} else {

# First Check Passed

$modkey = "1"

}

# ------------ BlockScripting ------------


if ($CheckIfScript -eq $null) {



$CheckIfScriptWoW = Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -erroraction SilentlyContinue

if ($CheckIfScriptWoW -eq $null) {

$modscript = "empty"


} else {

$modscript = "2"

}

} else {

$modscript = "1"

}



# -------------- Get ScriptBlocking Results and Return them -----------------------


if ($modscript -eq "1") {

# Is ScriptBlockLogging Set to 1
$EBS = (Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging).EnableScriptBlockLogging


}

if ($modscript -eq "2") {

# Is ScriptBlockLogging Set to 1
$EBS = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging).EnableScriptBlockLogging

}


if ($modscript -eq "empty") {

Write-Output "ScriptBlockLogging: No Registry Keys Found For Script Block Logging. It May Be A User Policy Or Disabled"


} else {

Write-Output "ScriptBlockLogging: EnableScriptBlockLogging is set to: $EBS"


}


# -------------- Get ProcessCreationIncludeCmdLine_Enabled Result and Return -----------------------

if ($CheckIfCmd -eq $null) {

Write-Output "ProcessCreationLogging: No Registry Keys Found For ProcessCreationIncludeCmdLine"


} else {

# Is Command Line Creation Events Logging Set To 1
$PCIC = (Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit).ProcessCreationIncludeCmdLine_Enabled

Write-Output "ProcessCreationLogging: ProcessCreationIncludeCmdLine is set to: $PCIC"

}





# -------------- Get ModuleLogging Results and Return them -----------------------

if ($modkey -eq "1") {

# Is ModuleLogging Set to 1
$EML = (Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging).EnableModuleLogging

# What Modules are Monitored
$MNames = Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames


}

if ($modkey -eq "2") {

# Is ModuleLogging Set to 1
$EML = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging).EnableModuleLogging

# What Modules are Monitored
$MNames = Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames

}


if ($modkey -eq "empty") {


Write-Output "No Module Logging Registry Keys Found.It May Be A User Policy Or Disabled"


} else {


Write-Output "Module Logging: EnableModuleLogging is set to: $EML"
Write-Output "`n"
Write-Output "Module Logging: ModuleNames is set to:"
Write-Output $MNames
Write-Output "`n"

}




# ------------ Check History For Common Exploit Scripts ------------------------

Write-Output " ---------- Checking Malicious Keywords ------------"
Write-Output "`n"

if ($CheckPSReadLine -eq "True") {

$Checkforscripts = Select-String -Pattern 'nishang','powersploit','mimikatz','mimidogz','mimiyakz' -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
$Checkforinvoke = Select-String -Pattern 'invoke' -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"


if ($Checkforscripts -eq $null){

Write-Output "No Keywords Found"
Write-Output "`n"

} else {

Write-Output "- Malicious PowerShell Commands Found:"
Write-Output "$Checkforscripts"
Write-Output "`n"

}

Write-Output " ---------- Checking For Invoke Commands  ------------"
Write-Output "`n"


if ($Checkforinvoke -eq $null){

Write-Output "No Invoke Commands Found"

} else {

Write-Output "- PowerShell Invoke Commands Found:"
Write-Output "$Checkforinvoke"
Write-Output "`n"

}

}



# ------------------ Check Events Logs ---------------------

# Module Logging EventID 4103
#Script Block EventID 4105 and 4106

Write-Output "---------- Checking For Event Logs  ------------"
Write-Output "`n"


$4103 = Get-WinEvent -LogName 'Microsoft-Windows-Powershell/Operational'| Where-Object {$_.ID -eq 4103}
$4104 = Get-WinEvent -LogName 'Microsoft-Windows-Powershell/Operational'| Where-Object {$_.ID -eq 4104}
$4105 = Get-WinEvent -LogName 'Microsoft-Windows-Powershell/Operational'| Where-Object {$_.ID -eq 4105}
$4106 = Get-WinEvent -LogName 'Microsoft-Windows-Powershell/Operational'| Where-Object {$_.ID -eq 4106}

if ($4103 -eq $null){

Write-Output "Event ID 4103 Not Found (Module Logging)  ------------"

} else {

Write-Output "- Event ID 4103 Found (Module Logging)  ------------"

}

if ($4104 -eq $null){

Write-Output "Event ID 4104 Not Found (Script Block Logging)  ------------"

} else {

Write-Output "- Event ID 4104 Found (Script Block Logging)  ------------"

}

if ($4105 -eq $null){

Write-Output "Event ID 4105 Not Found (Script Block Logging)  ------------"

} else {

Write-Output "- Event ID 4105 Found (Script Block Logging)  ------------"

}

if ($4106 -eq $null){

Write-Output "Event ID 4106 Not Found (Script Block Logging)  ------------"

} else {

Write-Output "- Event ID 4106 Found (Script Block Logging)  ------------"

}


<# ---------- Remove this line if you wish to output file ---------------

if ($featurestatus -eq "Enabled") { 

echo "$computername has Powershell V2 enabled | Installed version is version: $version | WinRm Service: $remotepowershellstatus"  >> "$locationfile"

}

#> # ---------- Remove this line if you wish to output file ---------------





<# ------------ Remove this line to disable v2 ---------------

$featurestatus = (Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).state

if ($featurestatus -eq "Enabled") { 

Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root

}

#> # ------------ Remove this line to disable v2 ---------------

} # Remove this for script