<#
    .Synopsis
        This module facilitates the interaction with Atlassian's Confluence using the APIs
        
    .Description
        This module facilitates the interaction with Atlassian's Confluence using the APIs
    
    .Notes
        Author   : Oliver Lipkau <oliver@lipkau.net>
        
        ChangeLog:
            2015/07/06             Created
        
#>

Get-ChildItem -Path $PSScriptRoot -recurse | Unblock-File
Get-ChildItem -Path $PSScriptRoot\*.ps1 -recurse | Foreach-Object{ . $_.FullName }