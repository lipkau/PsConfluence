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
    [OutputType()]
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
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,

        [Parameter(
            Mandatory=$false
        )]
        [string]$Method
    )

    Begin
    {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"

        [System.Collections.ArrayList]$commandList = Get-Command -Noun Confluence* | Where-Object {$_.Name -ne 'Set-ConfluenceEndpoint'}
        if ($Method -eq "pdfexport")
        {
            $commandList = @(Get-Command -Noun Confluence*PDF)
        }
        else
        {
            Get-Command -Noun Confluence*PDF | ForEach-Object {$commandList.Remove($_)}
        }
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
        $resultSet = Send-XmlRpcRequest -Url $apiURi -MethodName $MethodName -Params $Params -CustomTypes $ConfluenceObjects
        Write-Debug "Server answer: $resultSet"

        if ($resultSet.methodResponse.fault)
        {
            # Parse Remote Exception Object
            $re = $resultSet.methodResponse.fault.value.struct.member

            $exceptionId = $re[1].value.int # always 0: Confluence bug?
            $exceptionMessage = $re[0].value

            # Define most accurate exception category according to
            # https://msdn.microsoft.com/en-us/library/system.management.automation.errorcategory(v=vs.85).aspx
            switch -regex ($exceptionMessage)
            {
                "com\.atlassian\.confluence\.rpc\.AlreadyExistsException" {
                    $exceptionCategory = "ResourceExists"
                    break
                }
                "com\.atlassian\.confluence\.rpc\.(?:AuthenticationFailedException|InvalidSessionException)" {
                    $exceptionCategory = "AuthenticationError"
                    break
                }
                "com\.atlassian\.confluence\.rpc\.NotFoundException" {
                    $exceptionCategory = "ObjectNotFound"
                    break
                }
                "com\.atlassian\.confluence\.rpc\.NotPermittedException" {
                    $exceptionCategory = "PermissionDenied"
                    break
                }
                "com\.atlassian\.confluence\.rpc\.OperationTimedOutException" {
                    $exceptionCategory = "OperationTimeout"
                    break
                }
                "com\.atlassian\.confluence\.rpc\.NotFoundException" {
                    $exceptionCategory = "WriteError"
                    break
                }
                Default {
                    $exceptionCategory = "InvalidOperation"
                    break
                }
            }

            # generate Exception
            $hostException = New-Object -TypeName System.Management.Automation.Host.HostException -ArgumentList $exceptionMessage
            $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $hostException,$exceptionId,$exceptionCategory,$MethodName

            Throw $errorRecord
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
            Write-Base64ToFile -FilePath $FilePath -base64 $response.base64 -PassThru
            -----------
            Description
            Save Base64 string to File

        .LINK
            Get-ConfluenceAttachment
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
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        $Base64,

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
        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getServerInfo" -Params ($token)
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
        [string]$Markup
    )

    Begin {

    }

    Process {
        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.convertWikiToStorageFormat" -Params ($token,$Markup)
    }

    End {

    }
}
<# /General #>