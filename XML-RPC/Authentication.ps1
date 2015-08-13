#Requires -Version 3.0
<#  Authentications #>
function Invoke-ConfluenceLogin {
    <#
    .SYNOPSIS
        Authenticate with a Confluence Instance

    .DESCRIPTION
        Log in a user.
        Returns a String authentication token to be passed as authentication to all other remote calls.
        Must be called before any other method in a remote conversation. From 1.3 onwards, you can supply an empty string as the token to be treated as being the anonymous user.

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 0.0.1 - OL - Initial Code
                 1.0.0 - OL - Replaced hashtables with Objects

    .INPUTS
        string
        System.Management.Automation.PSCredential

    .OUTPUTS
        string

    .EXAMPLE
        Invoke-ConfluenceLogin -apiURi "http://example.com" -Credential (Get-Credential)
        -----------
        Description
        Log in to Confluence

    .LINK
        Atlassians's Docs:
            String login(String username, String password)

    #>
    [CmdletBinding(
    )]
    [OutputType(
        [string]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$apiURi,

        # Credentials with which to authentication
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [System.Management.Automation.PSCredential]$Credential
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Authenticate at $apiURi as $($Credential.UserName)"
        ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.login" -Params ([string]($Credential.UserName),[string]($Credential.getnetworkcredential().password)))
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Invoke-ConfluenceLogout {
    <#
    .SYNOPSIS
        Log off from Confluence Insatance

    .DESCRIPTION
        Remove this token from the list of logged in tokens.
        Returns true if the user was logged out, false if they were not logged in in the first place.

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 0.0.1 - OL - Initial Code
                 1.0.0 - OL - Replaced hashtables with Objects

    .INPUTS
        string

    .OUTPUTS
        bool

    .EXAMPLE
        Invoke-ConfluenceLogout -apiURi "http://example.com" -token "000000"
        -----------
        Description
        Log out of Confluence

    .LINK
        Atlassians's Docs:
            boolean logout(String token)

    #>
    [CmdletBinding(
    )]
    [OutputType(
        [bool]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [string]$Token
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Logging out"
        ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.logout" -Params ($token))
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Invoke-ConfluencePDFLogin {
    <#
    .SYNOPSIS
        Authenticate with a Confluence Instance for PDF services

    .DESCRIPTION
        Log in a user.
        Returns a String authentication token to be passed as authentication to all other remote calls.
        Must be called before any other method in a remote conversation. From 1.3 onwards, you can supply an empty string as the token to be treated as being the anonymous user.

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 0.0.1 - OL - Initial Code
                 1.0.0 - OL - Replaced hashtables with Objects

    .INPUTS
        string
        System.Management.Automation.PSCredential

    .OUTPUTS
        string

    .EXAMPLE
        Invoke-ConfluencePDFLogin -apiURi "http://example.com" -Credential (Get-Credential)
        -----------
        Description
        Log in to Confluence

    .LINK
        Atlassians's Docs:
            String login(String username, String password)

    #>
    [CmdletBinding(
    )]
    [OutputType(
        [string]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$apiURi,

        # Credentials with which to authentication
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [System.Management.Automation.PSCredential]$Credential
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Authenticate at $apiURi as $($Credential.UserName)"
        ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "pdfexport.login" -Params ([string]($Credential.UserName),[string]($Credential.getnetworkcredential().password)))
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<# /Authentications #>