
#Configuration Section
$reg_ver_key = "HKLM:\SOFTWARE\ESET\ESET Security\CurrentVersion\Info"
$dl_path = "https://download.eset.com/com/eset/apps/business/eea/windows/v7/latest/eea_nt64.msi"

$package = (Split-Path -Parent $PSCommandPath) + "\eset_update.msi"

#-----------------------------------------------
#Function definitions

function Assert-AdminSession(){
	#return 1 -eq 1
	return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
}

function TimedMsg( [string]$msg, [int32]$tim ){
	Write-Output $msg
	Start-Sleep $tim
}

function CleanUp(){
	Remove-Item "eset_update.msi"
	Remove-Item "eset_update.log"
}

#----------------------------------------------
#main script

if( !(Test-Path $reg_ver_key) ){
	TimedMsg -msg "Fatal: Eset not installed. Closing in 3 seconds." -tim 3
	return
}

if( !(Assert-AdminSession) ){
	TimedMsg -msg "Error: Script must be run in elevated session (run as administrator)." -tim 3
	return
}

if( !(Test-Path $package) ){

	Write-Output "Downloading package..."
	$wc = New-Object System.Net.WebClient
	$wc.DownloadFile( $dl_path, $package )
	Write-Output "Done."
}

[string]$pre_ver = (Get-ItemProperty -Path $reg_ver_key).ProductVersion

Write-Output "Deploying package"
msiexec.exe /i eset_update.msi /qn /l* eset_update.log

#Need to wait because for some reason the log file 
#cant be accessed right after msiexec concludes
Start-Sleep 10

[string]$log_entry = Select-String -Path "eset_update.log" -Pattern "Installation completed successfully"
if( $log_entry.Length -ne 0 ){

	CleanUp
	Write-Output "Installation succesful."
    return
}

$log_entry = Select-String -Path "eset_update.log" -Pattern "PackageInfo"
if ( $log_entry.Contains($pre_ver) ) {

	CleanUp
	Write-Output "Latest version already installed. No change."
	return
}

TimedMsg -msg "Installation failed! Check eset_update.log" -tim 10