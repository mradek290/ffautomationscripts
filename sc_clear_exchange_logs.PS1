#Set-Executionpolicy RemoteSigned

$days=0
$regentry = "HKLM:\software\microsoft\ExchangeServer\v15\Setup"

$IISLogPath="C:\inetpub\logs\LogFiles\"
#default none

[string]$ExchangeLoggingPath = ""
#default "D:\Program Files\Microsoft\Exchange Server\V15\Logging\"

[string]$ETLLoggingPath = ""
#default "D:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\ETLTraces\"

[string]$ETLLoggingPath2 = ""
#default "D:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\Logs"

[string]$ETLLoggingPath3 = ""
#default automatic

Function CleanLogfiles([string]$TargetFolder){   

    $delete_count = 0
    $storage = 0

    if (Test-Path $TargetFolder) {
        $Now = Get-Date
        $LastWrite = $Now.AddDays(-$days)
        $Files = Get-ChildItem $TargetFolder -Include *.log,*.blg,*.etl,*.txt -Recurse | Where-Object {$_.LastWriteTime -le "$LastWrite"}
        foreach ($File in $Files){

            #printing file names to console can be a bottleneck when dealing with ALOT of files
            #Write-Host "Deleting file $File" -ForegroundColor "white"

            $filesize = $File.Length
            $filepath = $File.FullName
            Remove-Item $File -ErrorAction SilentlyContinue | out-null
            if( !(Test-Path $filepath) ){
                $delete_count = ($delete_count + 1)
                $storage = ($storage+$filesize)
            }
        }

    }else{
        Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "white"
    }

    if( $storage -eq 0 ){
        Write-Host $TargetFolder + " does not contain any logfiles."
    }else{
        $units = @("Bytes","KB","MB","GB","TB","PB")
        $magnitude = [Math]::Floor([Math]::Log($storage,1000))
        $storage = [Math]::Floor(($storage/[Math]::Pow(1000,$magnitude)))
        Write-Host ("Deleted " + $delete_count + " logs from " + $TargetFolder + " freeing up " + $storage + $units[$magnitude])
    }
}

if( !(Test-Path $regentry) ){
    throw("Windows exchange server not installed.")
}

$app_path = (Get-ItemProperty -Path $regentry).MsiInstallPath
$ExchangeLoggingPath = $app_path + "Logging\"
$ETLLoggingPath = $app_path + "Bin\Search\Ceres\Diagnostics\ETLTraces\"
$ETLLoggingPath2 = $app_path + "Bin\Search\Ceres\Diagnostics\Logs\"

$ETLLoggingPath3 = "C:\Program Files (x86)\Microsoft\Exchange Server\V15\Logging"
if( !(Test-Path $ETLLoggingPath3) ){
    $ETLLoggingPath3 = "C:\Program Files\Microsoft\Exchange Server\V15\Logging"
}

CleanLogfiles($IISLogPath)
CleanLogfiles($ExchangeLoggingPath)
CleanLogfiles($ETLLoggingPath)
CleanLogfiles($ETLLoggingPath2)
CleanLogfiles($ETLLoggingPath3)
