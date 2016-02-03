#Requires -Version 3.0

<#  Helper Functions #>
function Set-ConfluenceEndpoint {
    <#
    .SYNOPSIS
        Set API's Endpoint information as default

    .DESCRIPTION
        Set API's Endpoint parameters as default parameters in order to avoid having to send them excplicitly with every call

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 1.0.0 - OL - initail code

    .INPUTS
        string
        System.Management.Automation.PSCredential
        Microsoft.PowerShell.Commands.WebRequestSession

    .OUTPUTS
        string
        Microsoft.PowerShell.Commands.WebRequestSession

    .EXAMPLE
        Set-ConfluenceEndpoint -apiURi "http://example.com" -token "000000"
        Get-ConfluencePage -spaceKey ABC
        -----------
        Description
        Set API Endpoint globally to avoid having to sent it with each command
    #>
    [CmdletBinding()]
    [OutputType(
        [string],
        [System.Management.Automation.PSCredential],
        [Microsoft.PowerShell.Commands.WebRequestSession]
    )]
    param(
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [string]$apiURi,

        [Parameter(
            Mandatory=$false
        )]
        [string]$Token,

        [Parameter(
            Mandatory=$false
        )]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(
            Mandatory = $false
        )]
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
    )

    Begin
    {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"

        $commandList = Get-Command -Noun Confluence* | Where-Object {$_.Name -ne 'Set-ConfluenceEndpoint'}
        $commandList += 'Invoke-ConfluenceCall'
    }
    Process
    {
        foreach ($cmd in $commandList)
        {
            Write-Verbose "Setting Default value for command ${cmd}"
            $global:PSDefaultParameterValues["${cmd}:ApiUri"] = $apiURi

            if ($Token)
            {
                $global:PSDefaultParameterValues["${cmd}:Token"] = $Token
            }

            if ($Credential)
            {
                $global:PSDefaultParameterValues["${cmd}:Credential"] = $Credential
            }

            if ($WebSession)
            {
                $global:PSDefaultParameterValues["${cmd}:WebSession"] = $WebSession
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Invoke-ConfluenceCall {
    <#
    .SYNOPSIS
        Wrapper to execute calls to Confluence API

    .DESCRIPTION
        Wrapper to execute calls to Confluence API

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 1.0.0 - OL - initail code

    .INPUTS
        string
        Object
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [Alias('URL')]
        [string]$apiURi,

        [Parameter(
            Position=2,
            Mandatory=$true
        )]
        [string]$MethodName,

        [Parameter(
            Position=3,
            Mandatory=$true
        )]
        [Object]$Params,

        [Parameter(
            Mandatory=$false
        )]
        [string]$OutputType
    )

    Begin
    {
        $ConfluenceObjects = @(
            'ServerInfo',
            'SpaceSummary',
            'Space',
            'PageSummary',
            'Page',
            'PageUpdateOptions',
            'PageHistorySummary',
            'BlogEntrySummary',
            'BlogEntry',
            'SearchResult',
            'Attachment',
            'Comment',
            'User',
            'ContentPermission',
            'ContentPermissionSet',
            'SpacePermissionSet',
            'Label',
            'UserInformation',
            'ClusterInformation',
            'NodeStatus',
            'ContentSummaries',
            'ContentSummary'
        )
    }

    Process {
        $global:resultSet = Send-XmlRpcRequest -Url $apiURi -MethodName $MethodName -Params $Params -CustomTypes $ConfluenceObjects
        Write-Debug "Server answer: $resultSet"

        if ($resultSet.methodResponse.fault)
        {
            $re = $resultSet.methodResponse.fault.value.struct.member
            $msg = $re[0].value
            $errid = $re[1].value.int # not used yet
            Throw $msg
        }
        else
        {
            if ($OutputType)
            {
                foreach ($object in (ConvertFrom-Xml $resultSet))
                {
                    $object -as $OutputType
                }
            }
            else
            {
                ConvertFrom-Xml $resultSet
            }
        }
    }
}
function Write-Base64ToFile {
    <#
    .SYNOPSIS
        Write Base64 string to File

    .DESCRIPTION
        Write Base64 string to File

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 1.0.0 - OL - Initial Code

    .INPUTS
        string
        ArrayListEnumeratorSimple

    .OUTPUTS
        FileInfo

    .EXAMPLE
        Get-ConfluenceChildPage -apiURi "http://example.com" -token "000000" -pageId 12345678
        -----------
        Description
        Fetch all children of a specific page


    .EXAMPLE
        $param = @{apiURi = "http://example.com"; token = "000000"}
        Get-ConfluenceChildPage @param -pageid 12345678 -recurse
        -----------
        Description
        Fetch recursively all children of a specific page

    .LINK
        Atlassians's Docs:
            Attachment getAttachment(String token, String pageId, String fileName, String versionNumber) - get information about an attachment.
            Vector<Attachment> getAttachments(String token, String pageId) - returns all the Attachments for this page (useful to point users to download them with the full file download URL returned).
            byte[] getAttachmentData(String token, String pageId, String fileName, String versionNumber) - get the contents of an attachment.

    #>
    [CmdletBinding(
    )]
    [OutputType(
        [System.IO.FileInfo]
    )]
    param(
        [Parameter(
            Mandatory=$true
        )]
        [string]$FilePath,

        [Parameter(
            Mandatory=$true
        )]
        $base64,

        [switch]$PassThru
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Writing Base64 stream to File $FilePath"
        [byte[]]$toDecodeByte = [System.Convert]::FromBase64String($base64)
        [System.IO.File]::WriteAllBytes($FilePath, $toDecodeByte)
        if ($PassThru) { Get-Item $FilePath }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<# /Helper Functions #>

<#  General #>
function Get-ConfluenceServerInfo {
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
        return ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getServerInfo" -Params ($token))
    }
}
function ConvertTo-ConfluenceStorageFormat {
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
            $out += ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.convertWikiToStorageFormat" -Params ($token,$m))
        }
    }

    End {
        Write-Output $out
    }
}
<# /General #>