<#
    .Synopsis
        This module facilitates the interaction with Atlassian's Confluence using the APIs

    .Description
        This module facilitates the interaction with Atlassian's Confluence using the APIs

    .Notes
        Author   : Oliver Lipkau <oliver@lipkau.net>

        ChangeLog:
            2015/07/06             Created

    .Documentation
        https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-methods
        https://developer.atlassian.com/confdev/confluence-rest-api/remote-api-specification-for-pdf-export
        http://www.k15t.com/display/SUPPORT/Changing+all+pages+in+a+space+to+unversioned+pages

#>

# Unblock files (if downloaded from ZIP)
Get-ChildItem -Path $PSScriptRoot -recurse | Unblock-File

# Import Structures
. "$PSScriptRoot\Import-Types.ps1"

# Import each file individualy to avoid injections
#XML-RPC
$XMLRPCfiles = @(
    'Administration.ps1', `
    'Attachement.ps1', `
    'Authentication.ps1', `
    'Blog.ps1', `
    'General.ps1', `
    'Labels.ps1', `
    'Notifications.ps1', `
    'Pages.ps1', `
    'Permissions.ps1', `
    'Search.ps1', `
    'Spaces.ps1', `
    'UserManagement.ps1'
)
foreach ($file in $XMLRPCfiles)
    {. "$PSScriptRoot\XML-RPC\$file"}

##REST
#$RESTfiles = @('Authentication.ps1', `
#               'Pages.ps1', `
#               'Scroll.ps1')
#foreach ($file in $RESTfiles)
#    {. "$PSScriptRoot\REST\$file"}