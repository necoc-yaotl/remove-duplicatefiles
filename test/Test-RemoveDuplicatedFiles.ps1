<#
.SYNOPSIS

Test for Remove-Duplicated Files.

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

PS> Remove-DuplicatedFiles.ps1 -path ".\Pictures"

.LINK

https://github.com/necoc-yaotl/remove-duplicatefiles

#>