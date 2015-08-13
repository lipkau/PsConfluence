#Requires -Version 3.0
<#  Permissions #>
function Get-ConfluenceSpacePermissions {
    #Vector<String> getPermissionsForUser(String token, String spaceKey, String userName) - Returns a Vector of Strings representing the permissions the given user has for this space. (since 2.1.4)
    #SpacePermissionSet[] getSpacePermissionSets(String token, String spaceKey) - retrieves all permission sets specified for the space with given spaceKey.
    #TODO: SpacePermissionSet getSpacePermissionSet(String token, String spaceKey, String permissionType) - retrieves a specific permission set of type permissionType for the space with given spaceKey. Valid permission types are listed below, under "Space permissions".
    #TODO: Vector<String> getPermissions(String token, String spaceKey) - Returns a Vector of Strings representing the permissions the current user has for this space (a list of "view", "modify", "comment" and / or "admin").
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
            Mandatory=$true
        )]
        [Alias("space")]
        [string]$SpaceKey,

        [Parameter(
            Position=3
        )]
        [string[]]$userName
    )

    Begin {
        $o = @()
    }

    Process {
        if ($userName) {
            foreach ($user in $userName) {
                if ($global:r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPermissionsForUser" -Params ($token,$SpaceKey,$user )) {
                    $o += ConvertFrom-Xml $r
                }
            }
        } else {
            if ($global:r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpacePermissionSets" -Params ($token,$SpaceKey)) {
                $o += ConvertFrom-Xml $r
            }
        }
    }

    End {
        $o
    }
}
#getPagePermissions is in <Page/>
function Get-ConfluenceAvailableSpacePermissions {
    #Vector<String> getPermissionsForUser(String token, String spaceKey, String userName) - Returns a Vector of Strings representing the permissions the given user has for this space. (since 2.1.4)
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

    Begin {
        $o = @()
    }

    Process {
        if ($r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpaceLevelPermissions" -Params ($token)) {
            $o += ConvertFrom-Xml $r
        }
    }

    End {
        $o
    }
}
function Add-ConfluenceSpacePermissions {
    #boolean addPermissionToSpace(String token, String permission, String remoteEntityName, String spaceKey) - Give the entity named remoteEntityName (either a group or a user) the permission permission on the space with the key spaceKey.
    #boolean addPermissionsToSpace(String token, Vector permissions, String remoteEntityName, String spaceKey) - Give the entity named remoteEntityName (either a group or a user) the permissions permissions on the space with the key spaceKey.
    #TODO: boolean addAnonymousPermissionToSpace(String token, String permission, String spaceKey) - Give anonymous users the permission permission on the space with the key spaceKey. (since 2.0)
    #TODO: boolean addAnonymousPermissionsToSpace(String token, Vector permissions, String spaceKey) - Give anonymous users the permissions permissions on the space with the key spaceKey. (since 2.0)
    [CmdletBinding(SupportsShouldProcess=$True)]
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
            Mandatory=$true
        )]
        [Alias("space")]
        [string]$SpaceKey,

        [Parameter(
            Position=3,
            Mandatory=$true
        )]
        [string]$remoteEntityName,

        [Parameter(
            Position=4,
            Mandatory=$true
        )]
        $Permissions
    )

    Begin {
        $o = @()
    }

    Process {
        if ($Permissions.gettype().Name -eq "String") {
            if ($PSCmdlet.ShouldProcess($remoteEntityName)) {
                if ($global:r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addPermissionToSpace" -Params ($token,$Permissions,$remoteEntityName,$SpaceKey )) {
                    $o += ConvertFrom-Xml $r
                }
            }
        }
        if ($Permissions.GetType().BaseType -like "*Array") {
            if ($PSCmdlet.ShouldProcess($remoteEntityName)) {
                if ($r = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addPermissionsToSpace" -Params ($token,$Permissions,$remoteEntityName,$SpaceKey )) {
                    $o += ConvertFrom-Xml $r
                }
            }
        }
    }

    End {
        $o
    }
}
<#function Remove-ConfluenceSpacePermissions {
    #boolean removePermissionFromSpace(String token, String permission, String remoteEntityName, String spaceKey) - Remove the permission permission} from the entity named {{remoteEntityName (either a group or a user) on the space with the key spaceKey.
    #boolean removeAnonymousPermissionFromSpace(String token, String permission,String spaceKey) - Remove the permission permission} from anonymous users on the space with the key {{spaceKey. (since 2.0)
    #boolean removeAllPermissionsForGroup(String token, String groupname) - Remove all the global and space level permissions for groupname.
}#>

    #Space permissions
    #Names are as shown in Space Admin > Permissions. Values can be passed to remote API methods above which take a space permission parameter.
    #Permission name          |String value          |Description
    #View                     |VIEWSPACE             |View all content in the space
    #Pages - Create           |EDITSPACE             |Create new pages and edit existing ones
    #Pages - Export           |EXPORTPAGE            |Export pages to PDF, Word
    #Pages - Restrict         |SETPAGEPERMISSIONS    |Set page-level permissions
    #Pages - Remove           |REMOVEPAGE            |Remove pages
    #News - Create            |EDITBLOG              |Create news items and edit existing ones
    #News - Remove            |REMOVEBLOG            |Remove news
    #Comments - Create        |COMMENT               |Add comments to pages or news in the space
    #Comments - Remove        |REMOVECOMMENT         |Remove the user's own comments
    #Attachments - Create     |CREATEATTACHMENT      |Add attachments to pages and news
    #Attachments - Remove     |REMOVEATTACHMENT      |Remove attachments
    #Mail - Remove            |REMOVEMAIL            |Remove mail
    #Space - Export           |EXPORTSPACE           |Export space to HTML or XML
    #Space - Admin            |SETSPACEPERMISSIONS   |Administer the spac
<# /Permissions #>