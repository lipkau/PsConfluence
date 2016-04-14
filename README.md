# PsConfluence  

## Table of Contents  
* [Description](#description)
* [Examples](#examples)
* [Authors/Contributors](#authorscontributors)
* [Documentation](#documentation)

## Description  
PowerShell library to interact with Atlassian's Confluence API  

>This Module uses Confluence's SOAP (XML-RPC); which was deprecated by Atlassian with Confluence v5.5.
>As the suggested replacement (REST) does not support all methods this Module uses, it was not yet migrated.

**THIS MODULE DEPENDENT OF [XmlRpc](https://github.com/lipkau/XmlRpc)**

## Examples  
* Remove all Pages in a Space:
```PowerShell
Import-Module "PsConfluence"
Connect-Confluence -apiURi "https://confluence.mycompany.com/rpc/xmlrpc" -Credential (Get-Credential)
Get-ConfluencePage -SpaceKey "ABC" | Remove-ConfluencePage
```
* Get all Pages in Space and replace "User" with "Customer"
```PowerShell
Import-Module "PsConfluence"
Connect-Confluence -apiURi "https://confluence.mycompany.com/rpc/xmlrpc" -Credential (Get-Credential)
Get-ConfluencePage -SpaceKey "ABC" | Get-ConfluencePage | Foreach {$_.content -replace "[uU]ser" "Customer"} | Set-ConfluencePage
```
* Download all XML files attached to a Page:
```PowerShell
Import-Module "PsConfluence"
$apiUri = "https://confluence.mycompany.com/rpc/xmlrpc"
Connect-Confluence -apiURi $apiUri -Credential (Get-Credential)
Get-ConfluencePage -SpaceKey "ABC" -title "XML container" | 
    Get-ConfluenceAttachment | 
    Where {$_.contentType -eq "text/xml"} | 
    Foreach {
        $_ | Get-ConfluenceAttachment -FilePath "c:\folder\$($_.title)"
    }
```

## Authors/Contributors  
 * [Oliver Lipkau](http://oliver.lipkau.net)

## Documentation  
_Git Repo Wiki yet to be written_