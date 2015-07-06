#Requires -Version 3.0
<#  Authentications #>
function Perform-Login {
    #String login(String username, String password) - log in a user. Returns a String authentication token to be passed as authentication to all other remote calls. Must be called before any other method in a remote conversation. From 1.3 onwards, you can supply an empty string as the token to be treated as being the anonymous user.
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
        [System.Management.Automation.PSCredential]$Credential
    )

    Process {
        return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.login" -Params ([string]($Credential.UserName),[string]($Credential.getnetworkcredential().password)))
    }
}
function Perform-Logout {
    #boolean logout(String token) - remove this token from the list of logged in tokens. Returns true if the user was logged out, false if they were not logged in in the first place.
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
        return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.logout" -Params ($token))
    }
}
function Perform-PDFLogin {
    #https://developer.atlassian.com/confdev/confluence-rest-api/remote-api-specification-for-pdf-export
    #String login(String username, String password) - log in a user. Returns a String authentication token to be passed as authentication to all other remote calls. Must be called before any other method in a remote conversation. From 1.3 onwards, you can supply an empty string as the token to be treated as being the anonymous user.
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
        [System.Management.Automation.PSCredential]$Credential
    )

    Process {
        return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "pdfexport.login" -Params ([string]($Credential.UserName),[string]($Credential.getnetworkcredential().password)))
    }
}
<# /Authentications #>