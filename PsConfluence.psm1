#Requires -Version 3.0
<#
    .Synopsis
        This is a compilation of functions to simplify scripts to manage AD tasks
        
    .Description
        This compilation contains functions to simplify the management of Active Directories.
        Check the examples to see how to find computers, create new users, and much more.
    
    .Notes
        Author   : Oliver Lipkau <oliver@lipkau.net>
        
        ChangeLog:
            2015/07/06             Created
        
#>
param()

$ScriptPath = $MyInvocation.MyCommand.Path
$PsCOnfluenceModuleHome = split-path -parent $ScriptPath

$functions = Get-ChildItem "$PsCOnfluenceModuleHome\" *.ps1 -Recurse
$functions | foreach-object -begin {$i=0} -process `
{
    $name = $_.name.Replace(".ps1","")
    $path = $_.fullname
    . "$path"
    $i++
    Write-Progress -Activity "Loading Module" -Status $name -PercentComplete ($i/$functions.count*100)
    Start-Sleep -Milliseconds 200
}