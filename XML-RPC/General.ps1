#Requires -Version 3.0
<#  General #>
function Get-ServerInfo {
    #ServerInfo getServerInfo(String token) - retrieve some basic information about the server being connected to. Useful for clients that need to turn certain features on or off depending on the version of the server. (Since 1.0.3)
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$apiURi,

        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [string]$Token
    )

    Process {
        return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getServerInfo" -Params ($token))
    }
}
function ConvertTo-StorageFormat {
    #String convertWikiToStorageFormat(String token, String markup) - converts wiki markup to the storage format and returns it. (Since 4.0)
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$apiURi,

        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [string]$Token,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        [string[]]$Markup
    )

    Begin {
        $out = @()
    }

    Process {
        foreach ($m in $Markup) {
            $out += ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.convertWikiToStorageFormat" -Params ($token,$m))
        }
    }

    End {
        Write-Output $out
    }
}
<# /General #>