
[string]$wanted = "Computer,Laptop,Desktop,NB,PC"
$event_type = "Warning"
$event_id = 500

function TagsToRegEx( [string]$s ){

    $tags = $s -split ','
    [string]$ret = "^(" + $tags[0] + ")"

    for( $i = 1; $i -lt $tags.Length; ++$i ){
        $ret += "|^(" + $tags[$i] + ")"
    }

    return $ret
}

$filter = TagsToRegEx($wanted)
if( $env:COMPUTERNAME.ToUpperInvariant() -match $filter.ToUpperInvariant() ){
    
    Write-Output ("Der Computername: " + $env:COMPUTERNAME.ToString() + " entspricht nicht den Vorgaben.")
    eventcreate.exe /L Application /T $event_type /SO FF-SAM /ID $event_id /D "Der Computername entspricht nicht den Vorgaben."
    if( !$? ){
        throw("Fehler: Eventlog konnte nicht geschrieben werden.")
    }

}else{
    Write-Output "Der Computername entspricht den Vorgaben."
}