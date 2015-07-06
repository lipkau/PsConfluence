#Requires -Version 3.0
<#  User Management #>
function Get-User {
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
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getUserInformation" -Params ($token,$user)) {
                    $o += ConvertFrom-Xml $r
                }
            } else {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getUser" -Params ($token,$user)) {
                    $o += ConvertFrom-Xml $r
                }
            }
        }
    }

    End {
        $o
    }
}
<#function Add-ConfluenceUser {
    #void addUser(String token, User  user, String password) - add a new user with the given password
    #void addUser(String token, User  user, String password, boolean notifyUser) - add a new user with the given password, and optionally send the user a welcome email (since 4.3)
}#>
<#function Test-User {
    #boolean hasUser(String token,  String username) - checks if a user exists
}#>
<#function Set-User {
    #boolean editUser(String token, RemoteUser remoteUser) - edits the details of a user
    #boolean setUserInformation(String token, UserInformation userInfo) - updates user information
    #boolean changeMyPassword(String token, String oldPass, String newPass) - changes the current user's password
    #boolean changeUserPassword(String token, String username, String newPass) - changes the specified user's password
    #boolean addProfilePicture(String token, String userName, String fileName, String mimeType, byte[] pictureData) - add and set the profile picture for a user.
}#>
<#function Enable-User {
    #boolean reactivateUser(String token, String username) - reactivates the specified user
}#>
<#function Disable-User {
    #boolean deactivateUser(String token, String username) - deactivates the specified user
}#>
<#function Remove-User {
    #boolean removeUser(String token, String username) - delete a user.
}#>
<#function Get-Group {
    #Vector<String> getGroups(String token) - gets all groups
}#>
<#function Add-Group {
    #void addGroup(String token, String group) - add a new group
}#>
<#function Test-Group {
    #boolean hasGroup(String token, String groupname) - checks if a group exists
}
<#function Remove-Group {
    #boolean removeGroup(String token, String groupname, String defaultGroupName) - remove a group. If defaultGroupName is specified, users belonging to groupname will be added to defaultGroupName.
}#>
<#function Get-GroupMembership {
    #Vector<String> getUserGroups(String token, String username) - get a user's current groups
}#>
<#function Add-GroupMember {
    #void addUserToGroup(String token, String username, String groupname) - add a user to a particular group
}#>
<#function Remove-GroupMember {
    #boolean removeUserFromGroup(String token, String username, String groupname) - remove a user from a group.
}#>
<# /User Management #>