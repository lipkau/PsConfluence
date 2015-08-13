#Requires -Version 3.0

<#  Support Functions #>
function Invoke-ConfluenceCall {
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$Url,

        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [string]$MethodName,

        [Parameter(Position=1,Mandatory=$true)]
        [Object]$Params
    )

    Begin {
        $ConfluenceObjects = @('ServerInfo', 'SpaceSummary', 'Space', 'PageSummary', 'Page', 'PageUpdateOptions', 'PageHistorySummary', 'BlogEntrySummary', 'BlogEntry', 'SearchResult', 'Attachment', 'Comment', 'User', 'ContentPermission', 'ContentPermissionSet', 'SpacePermissionSet', 'Label', 'UserInformation', 'ClusterInformation', 'NodeStatus', 'ContentSummaries', 'ContentSummary')
    }

    Process {
        $global:t = $params
        $r = Send-XmlRpcRequest -Url $apiURi -MethodName $MethodName -Params $Params -CustomTypes $ConfluenceObjects
        $global:s = $r
        if ($r.methodResponse.fault) {
            $re = $r.methodResponse.fault.value.struct.member
            $msg = $re.value[0]
            $errid = $re.value[1].int
            Throw $msg
        } else {
            return $r
        }
    }
}

function Write-Base64ToFile
{
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
<# /Support Functions #>

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