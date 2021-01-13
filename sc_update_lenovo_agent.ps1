
Set-ExecutionPolicy RemoteSigned -Force

$version_key = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\System Update"
$choco_url = "https://chocolatey.org/install.ps1"
$choco_sc = ($PSScriptRoot + "\install_choco_latest.ps1")
$wc = New-Object System.Net.WebClient
$wc.DownloadFile( $choco_url, $choco_sc )
& $choco_sc

choco feature enable -n allowGlobalConfirmation

if( Test-Path $version_key ){
    [string]$pre_ver = (Get-ItemProperty -Path $version_key).Version
    choco -y upgrade lenovo-thinkvantage-system-update
    [string]$post_ver = (Get-ItemProperty -Path $version_key).Version
    if( $post_ver.Replace(".","") -ge $pre_ver.Replace(".","") ){
        Write-Host "Update successful."
    }else{
        Write-Host "Update failed."
    }
}else{
    choco -y install lenovo-thinkvantage-system-update
    if( Test-Path $version_key ){
        Write-Host "Lenovo update agent installation successfull."
    }else{
        Write-Host "Lenovo update agent installation failed."
    }
}

Remove-Item $choco_sc
#maybe clean up enviorment variable modification and choco client