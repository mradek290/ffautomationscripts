
function RemoveWhitespace( [string]$s ){

    while( $s.IndexOf("  ") -ne -1 ){
        $s = $s.Replace("  ", " ")
    }

    return $s
}

class ActiveUser{

    [string]$Name
    [string]$SessionName
    [int32]$Id
    [bool]$Connected
    [timespan]$Idle
    [datetime]$LogOnTime
}

function Get-LoggedOnUsers(){

    $users = quser.exe
    $ret = [ActiveUser[]]::new($users.Length-1)

    for( $i = 0; $i -lt $ret.Length; ++$i ){

        [string]$val_str = RemoveWhitespace($users[$i+1])
        $v = $val_str -split ' '
        
        $offset = 0
        $ret[$i] = [ActiveUser]::new()

        if( $v[0] -eq "" ){
            ++$offset
        }

        $ret[$i].Name = $v[0+$offset].Replace(">","")

        if( $v[1+$offset] -match "^[0123456789]" ){
            
            $ret[$i].Id = $v[1+$offset]

        }else{
            
            $ret[$i].SessionName = $v[1+$offset]
            $ret[$i].Id = $v[2+$offset]
            ++$offset
        }

        $ret[$i].Connected = $v[2+$offset].ToUpperInvariant().StartsWith("A")

        <#
            Should attempt to parse $v[3+$offset] into 
            $ret[$i].Idle but parsing doesnt want to work
            and this information is not strictly required for this script.
            Therefore skipping
        #>

        [string]$time_str = $v[4+$offset].ToString() + "::" + $v[5+$offset].ToString()
        $ret[$i].LogOnTime = [datetime]::ParseExact( $time_str, "dd.MM.yyyy::HH:mm", $null )
    }

    return $ret
}

$white_list = $env:white_list
#load variable provided by rmm

$current_users = Get-LoggedOnUsers
[int32]$error_cnt = 0
[int32]$success_cnt = 0


if( $current_users.Length -eq 0 ){
    throw("Warning: Unable to find any logged on users.")
}

foreach( $user in $current_users ){
    if( !$user.Connected -and ($white_list.IndexOf($user.Name) -eq -1) ){

        logoff.exe $user.Id
        if( $? ){

            ++$success_cnt
            Write-Output ($user.Name + " wurde erfolgreich abgemeldet.")

        }else{

            ++$error_cnt
            Write-Output ($user.Name + " konnte nicht abgemeldet werden.")
        }
    }
}

if( $error_cnt -eq 0 ){
    if( $success_cnt -eq 0 ){
        Write-Output "Keine Inaktiven User gefunden die abgemeldet werden konnten."
    }else{
        Write-Output ($success_cnt.ToString() + " User erfolgreich abgemeldet.")
    }
}else{
    if( $success_cnt -eq 0 ){
        Write-Output "Keine User abgemeldet"
    }else{
        ($success_cnt.ToString() + " User erfolgreich abgemeldet.")
    }
    throw(("Error: " + $error_cnt.ToString() + " Users could not be logged off. Check log for errors"))
}
