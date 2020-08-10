<#
.SYNOPSIS

Recursively removes duplicated files from a directorty.

.DESCRIPTION

Recursively removes duplicated files from a directorty, based on the hash (SHA-256) of the file. 
The version of the file preserved would be the one with the older creation time.
This script is a wrapper fro the Function exposed in the FileUtil library.

.PARAMETER path
Specifies the directory to scan.

.INPUTS

None.

.OUTPUTS

None.

.EXAMPLE

PS> Remove-DuplicatedFiles.ps1 -path ".\Pictures"

.LINK

https://github.com/necoc-yaotl/remove-duplicatefiles

#>
param(
    [string] $path
)

$lib = Join-Path $PSScriptRoot 'FileUtil.psd1'
Import-Module $lib
Remove-DuplicatedFiles -path $path -WhatIf
Remove-Module FileUtil