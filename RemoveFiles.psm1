function Get-FileDups {
    param(
        [string] $path
    )

    $dict = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[string]]]'

    Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
        $name = $_.Name
        Write-Progress  -Activity 'Parsing files' -Status "Processing" -CurrentOperation "$name"

        $file = $_.FullName
        $key = (Get-FileHash -LiteralPath "$file" -Algorithm SHA256 ).Hash

        $list = New-Object 'system.collections.generic.list[string]'
        $newItem = $true
        if( $dict.ContainsKey($key) ) {
            $list = $dict["$key"]
            $newItem = $false
        }

        $list.Add($_.FullName)

        if( $newItem ) {
            $dict.Add( "$key", $list )
        }
    }
    Write-Progress -Activity 'Parsing files' -Completed
 

    $max = $dict.Count
    $i = 0

    $dups = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[string]]]'

    foreach( $key in $dict.Keys ) {
        $i++
        Write-Progress -Id 0 -Activity 'Finding dups' -PercentComplete (100*$i/$max) 
        $list = $dict["$key"]
        if( $list.Count -gt 1 ) {
            $dups.Add( "$key", $list )
        }
    }

    Write-Progress -Id 0 -Activity 'Finding dups' -Completed

    $dups
}

function Get-DedupAutoPick {
    param(
        [system.collections.generic.dictionary[[string],[system.collections.generic.list[string]]]] $dups
    )

    $keep = New-Object 'system.collections.generic.dictionary[[string],[string]]'
    $dispose = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[string]]]'

    foreach( $key in $dups.Keys ) {
        $tbd = New-Object 'system.collections.generic.list[string]'
        $list = $dups["$key"]
        $targetId = 0
        $targetDate = (Get-Item $list[$targetId]).CreationTimeUtc

        for( $i = 1; $i -lt $list.Count; $i++) {
            $candidateDate = (Get-Item $list[$i]).CreationTimeUtc
            if( $candidateDate -lt $targetDate ){
                $tbd.Add($list[$targetId])
                $targetId = $i
            }
            else {
                $tbd.Add($list[$i])
            }
        }

        $keep.Add($key, $list[$targetId])
        $dispose.Add($key, $tbd)
    }
 
    $keep, $dispose   
}

function Remove-dupFilesInternal {
    [cmdletbinding(SupportsShouldProcess=$True)]
    param(
        [system.collections.generic.dictionary[[string],[string]]] $keep,
        [system.collections.generic.dictionary[[string],[system.collections.generic.list[string]]]] $dups
    )

    if ($PSCmdlet.ShouldProcess("dup files")) {
        Write-Host "Deleting file simulation..."
    }
    else {
        Write-Host "Deleting files..."
    }

    foreach($key in $keep.Keys) {
        $file = $keep["$key"]
        Write-Host "Keepinng file: $file"
        foreach($file in $dups["$key"]) 
        {
            Write-Host "....deleting $file"
            Remove-Item $file -WhatIf`
        }
    }
}

function Remove-DuplicatedFiles {
<#
.SYNOPSIS

Recursively removes duplicated files from a directorty.

.DESCRIPTION

Recursively removes duplicated files from a directorty, based on the hash (SHA-256) of the file. 
The version of the file preserved would be the one with the older creation time.

.PARAMETER path
Specifies the directory to scan.

.INPUTS

None.

.OUTPUTS

None.

.EXAMPLE

PS> Remove-DuplicatedFiles -path ".\Pictures"

.LINK

https://github.com/necoc-yaotl/remove-duplicatefiles

#>
[cmdletbinding(
    SupportsShouldProcess=$True,
    HelpURI='https://github.com/necoc-yaotl/remove-duplicatefiles')]
param(
    [string] $path
)

    $o = Get-FileDups $path  | Get-DedupAutoPick

    if($o[1].Count -gt 0) {
        Remove-dupFilesInternal $o[0] $o[1] -WhatIf
    }
}