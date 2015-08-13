#Requires -Version 3.0
<#  User Management #>
function Get-ConfluenceUser {
    #User getUser(String token, String username) - get a single user
    #UserInformation getUserInformation(String token, String username) - Retrieves user information
    #TODO: Vector<String> getActiveUsers(String token, boolean viewAll) - returns all registered users
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

        [parameter(mandatory=$true)]
        [string[]]$userName,

        [switch]$extended
    )

    Begin {
        $o = @()
    }

    Process {
        foreach ($user in $username) {
            if ($extended) {
                if ($r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getUserInformation" -Params ($token,$user)) {
                    $o += ConvertFrom-Xml $r
                }
            } else {
                if ($r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getUser" -Params ($token,$user)) {
                    $o += ConvertFrom-Xml $r
                }
            }
        }
    }

    End {
        $o
    }
}
<#function Add-ConfluenceConfluenceUser {
    #void addUser(String token, User  user, String password) - add a new user with the given password
    #void addUser(String token, User  user, String password, boolean notifyUser) - add a new user with the given password, and optionally send the user a welcome email (since 4.3)
}#>
<#function Test-ConfluenceUser {
    #boolean hasUser(String token,  String username) - checks if a user exists
}#>
<#function Set-ConfluenceUser {
    #boolean editUser(String token, RemoteUser remoteUser) - edits the details of a user
    #boolean setUserInformation(String token, UserInformation userInfo) - updates user information
    #boolean changeMyPassword(String token, String oldPass, String newPass) - changes the current user's password
    #boolean changeUserPassword(String token, String username, String newPass) - changes the specified user's password
    #boolean addProfilePicture(String token, String userName, String fileName, String mimeType, byte[] pictureData) - add and set the profile picture for a user.
}#>
<#function Enable-ConfluenceUser {
    #boolean reactivateUser(String token, String username) - reactivates the specified user
}#>
<#function Disable-ConfluenceUser {
    #boolean deactivateUser(String token, String username) - deactivates the specified user
}#>
<#function Remove-ConfluenceUser {
    #boolean removeUser(String token, String username) - delete a user.
}#>
<#function Get-ConfluenceGroup {
    #Vector<String> getGroups(String token) - gets all groups
}#>
<#function Add-ConfluenceGroup {
    #void addGroup(String token, String group) - add a new group
}#>
<#function Test-ConfluenceGroup {
    #boolean hasGroup(String token, String groupname) - checks if a group exists
}
<#function Remove-ConfluenceGroup {
    #boolean removeGroup(String token, String groupname, String defaultGroupName) - remove a group. If defaultGroupName is specified, users belonging to groupname will be added to defaultGroupName.
}#>
<#function Get-ConfluenceGroupMembership {
    #Vector<String> getUserGroups(String token, String username) - get a user's current groups
}#>
<#function Add-ConfluenceGroupMember {
    #void addUserToGroup(String token, String username, String groupname) - add a user to a particular group
}#>
<#function Remove-ConfluenceGroupMember {
    #boolean removeUserFromGroup(String token, String username, String groupname) - remove a user from a group.
}#>
<# /User Management #>