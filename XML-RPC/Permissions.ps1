#Requires -Version 3.0
<#  Permissions #>
function Get-ConfluenceSpacePermissions {
    <#
        .SYNOPSIS
            Retrieve the permissions a User has on a specific Space

        .DESCRIPTION
            Retrieve the permissions a User has on a specific Space

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Refactoring

        .INPUTS
            string

        .OUTPUTS
            String[]
            PSObject
            Confluence.SpacePermissionSet

        .EXAMPLE
            Get-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC"
            -----------
            Description
            Fetch all Space Permissions as Confluence.SpacePermissionSet from Space "ABC"

        .EXAMPLE
            Get-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC" -PermissionType "VIEWSPACE"
            -----------
            Description
            Fetch all Space Permissions of type "View Space" as Confluence.SpacePermissionSet from Space "ABC"

        .EXAMPLE
            Get-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC" -CurrentUser
            -----------
            Description
            Fetch all Space Permissions the current user has for Space "ABC"

        .EXAMPLE
            @("user1", "user2") | Get-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC"
            -----------
            Description
            Fetch all Space Permissions for user1 and user2 for Space "ABC"

        .LINK
            Get-ConfluenceAvailableSpacePermissions

        .LINK
            Atlassians's Docs:
                Vector<String> getPermissionsForUser(String token, String spaceKey, String userName) - Returns a Vector of Strings representing the permissions the given user has for this space. (since 2.1.4)
                SpacePermissionSet[] getSpacePermissionSets(String token, String spaceKey) - retrieves all permission sets specified for the space with given spaceKey.
                SpacePermissionSet getSpacePermissionSet(String token, String spaceKey, String permissionType) - retrieves a specific permission set of type permissionType for the space with given spaceKey. Valid permission types are listed below, under "Space permissions".
                TODO: Vector<String> getPermissions(String token, String spaceKey) - Returns a Vector of Strings representing the permissions the current user has for this space (a list of "view", "modify", "comment" and / or "admin").
    #>
    [CmdletBinding(
        DefaultParameterSetName="getSpacePermissionSets"
    )]
    [OutputType(
        [string],
        ParameterSetName=('getPermissions')
    )]
    [OutputType(
        [PSObject],
        ParameterSetName=('getPermissionsForUser')
    )]
    [OutputType(
        [Confluence.SpacePermissionSet],
        ParameterSetName=('getSpacePermissionSet','getSpacePermissionSets')
    )]
    param(
        # The URi of the API interface.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Key of the Space to be searched.
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$SpaceKey,

        # One or more Usernames from which the permissions will be fetched.
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName="getPermissionsForUser",
            ValueFromPipeline=$true
        )]
        [string[]]$userName,

        # One or more Space Permissions which will be fetched.
        # List of available permissions can be retrieve with Get-ConfluenceAvailableSpacePermissions
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName="getSpacePermissionSet"
        )]
        [ValidateSet(
            'VIEWSPACE',
            'EDITSPACE',
            'EXPORTPAGE',
            'SETPAGEPERMISSIONS',
            'REMOVEPAGE',
            'EDITBLOG',
            'REMOVEBLOG',
            'COMMENT',
            'REMOVECOMMENT',
            'CREATEATTACHMENT',
            'REMOVEATTACHMENT',
            'REMOVEMAIL',
            'EXPORTSPACE',
            'SETSPACEPERMISSIONS'
        )]
        [Alias('Type')]
        [string]$PermissionType,

        # Fetch permissions only of the current user
        [Parameter(
            ParameterSetName="getPermissions"
        )]
        [switch]$CurrentUser
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        switch ($PsCmdlet.ParameterSetName)
        {
            "getPermissionsForUser" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Collection of SpacePermission for $SpaceKey"
                foreach ($user in $userName) {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Collection of SpacePermission for user $user"
                    New-Object -TypeName PSObject -Prop @{
                        username = $user
                        permission = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPermissionsForUser" -Params ($token, $SpaceKey, $user)
                    }
                }
                break
            }
            "getPermissions" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting current user's Space permissions for $SpaceKey"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPermissions" -Params ($token, $SpaceKey)
                break
            }
            "getSpacePermissionSet" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting $PermissionType permissions for $SpaceKey"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpacePermissionSet" -Params ($token,$SpaceKey, $PermissionType) | ForEach-Object -Process {
                    New-Object -TypeName Confluence.SpacePermissionSet -Prop @{
                        type = $_.type
                        contentPermissions = $_.spacePermissions | ForEach-Object { $_ -as "Confluence.ContentPermission"}
                    }

                }
                break
            }
            "getSpacePermissionSets" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Space permissions for $SpaceKey"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpacePermissionSets" -Params ($token, $SpaceKey) | ForEach-Object -Process {
                    New-Object -TypeName Confluence.SpacePermissionSet -Prop @{
                        type = $_.type
                        contentPermissions = $_.spacePermissions | ForEach-Object { $_ -as "Confluence.ContentPermission"}
                    }
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
#getPagePermissions is in <Page/>
function Get-ConfluenceAvailableSpacePermissions {
    <#
        .SYNOPSIS
            Retrieve available Space permissions

        .DESCRIPTION
            Retrieve available Space permissions

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS
            string[]

        .EXAMPLE
            Get-ConfluenceAvailableSpacePermissions -apiURi "http://example.com" -token "000000"
            -----------
            Description
            Fetch all available Space permissions

        .EXAMPLE
            Get-ConfluenceAvailableSpacePermissions -apiURi "http://example.com" -token "000000" -WithDescription
            -----------
            Description
            Fetch all available Space permissions with an extra description

        .LINK
            Atlassians's Docs:
                Vector<String> getPermissionsForUser(String token, String spaceKey, String userName) - Returns a Vector of Strings representing the permissions the given user has for this space. (since 2.1.4)
    #>
    [CmdletBinding()]
    [OutputType(
        [string[]]
    )]
    param(
        # The URi of the API interface.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Show as cutome Object with additional descriptions.
        [switch]$WithDescription
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        if ($WithDescription)
        {
            $permissions = @(
                @{DisplayName="View"; Value="VIEWSPACE";Description="View all content in the space"},
                @{DisplayName="Pages - Create"; Value="EDITSPACE";Description="Create new pages and edit existing ones"},
                @{DisplayName="Pages - Export"; Value="EXPORTPAGE";Description="Export pages to PDF, Word"},
                @{DisplayName="Pages - Restrict"; Value="SETPAGEPERMISSIONS";Description="Set page-level permissions"},
                @{DisplayName="Pages - Remove"; Value="REMOVEPAGE";Description="Remove pages"},
                @{DisplayName="News - Create"; Value="EDITBLOG";Description="Create news items and edit existing ones"},
                @{DisplayName="News - Remove"; Value="REMOVEBLOG";Description="Remove news"},
                @{DisplayName="Comments - Create"; Value="COMMENT";Description="Add comments to pages or news in the space"},
                @{DisplayName="Comments - Remove"; Value="REMOVECOMMENT";Description="Remove the user's own comments"},
                @{DisplayName="Attachments - Create"; Value="CREATEATTACHMENT";Description="Add attachments to pages and news"},
                @{DisplayName="Attachments - Remove"; Value="REMOVEATTACHMENT";Description="Remove attachments"},
                @{DisplayName="Mail - Remove"; Value="REMOVEMAIL";Description="Remove mail"},
                @{DisplayName="Space - Export"; Value="EXPORTSPACE";Description="Export space to HTML or XML"},
                @{DisplayName="Space - Admin"; Value="SETSPACEPERMISSIONS";Description="Administer the spac"}
            )
            $permissions | % {New-Object -TypeName PSObject -Prop $_}
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name):: Retrieve available Space permissions"
            Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpaceLevelPermissions" -Params ($token)
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Add-ConfluenceSpacePermissions {
    <#
        .SYNOPSIS
            Set Space Permissions

        .DESCRIPTION
            Set Space Permissions

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS
            Boolean

        .EXAMPLE
            Add-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC" -RemoteEntityName "user1" -Permission "VIEWSPACE"
            -----------
            Description
            Add the Space permission "View Space" to user1

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            @("user1", "user2") | Add-ConfluenceSpacePermissions @param -spacekey "ABC" -Permissions @("VIEWSPACE", "EDITSPACE")
            -----------
            Description
            Add multiple Space permissions to multiple users

        .EXAMPLE
            Add-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC" -Permission "VIEWSPACE"
            -----------
            Description
            Add the Space permission "View Space" to anonymous users

        .LINK
            Atlassians's Docs:
                boolean addPermissionToSpace(String token, String permission, String remoteEntityName, String spaceKey) - Give the entity named remoteEntityName (either a group or a user) the permission permission on the space with the key spaceKey.
                boolean addPermissionsToSpace(String token, Vector permissions, String remoteEntityName, String spaceKey) - Give the entity named remoteEntityName (either a group or a user) the permissions permissions on the space with the key spaceKey.
                boolean addAnonymousPermissionToSpace(String token, String permission, String spaceKey) - Give anonymous users the permission permission on the space with the key spaceKey. (since 2.0)
                boolean addAnonymousPermissionsToSpace(String token, Vector permissions, String spaceKey) - Give anonymous users the permissions permissions on the space with the key spaceKey. (since 2.0)
    #>
    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    [OutputType(
        [Boolean]
    )]
    param(
        # The URi of the API interface.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Key of the Space.
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [Alias("space")]
        [string]$SpaceKey,

        # Name of the Entity in question. Can be an User or Group.
        # If no User or Group is provided, the permissions will be assigned to anonymous users
        [Parameter(
            Position=1,
            ValueFromPipeline=$true
        )]
        [Alias('UserName','GroupName')]
        [string]$RemoteEntityName,

        # Permission to be added.
        [Parameter(
            Position=2,
            Mandatory=$true
        )]
        [ValidateSet(
            'VIEWSPACE',
            'EDITSPACE',
            'EXPORTPAGE',
            'SETPAGEPERMISSIONS',
            'REMOVEPAGE',
            'EDITBLOG',
            'REMOVEBLOG',
            'COMMENT',
            'REMOVECOMMENT',
            'CREATEATTACHMENT',
            'REMOVEATTACHMENT',
            'REMOVEMAIL',
            'EXPORTSPACE',
            'SETSPACEPERMISSIONS'
        )]
        [string[]]$Permissions
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        if ($Permissions.count -gt 1)
        {
            if ($RemoteEntityName)
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding multiple Space permissions to $RemoteEntityName"
                if ($PSCmdlet.ShouldProcess($RemoteEntityName, "Assign Permission $($Permissions -join ',')"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addPermissionsToSpace" -Params ($token, $Permissions, $RemoteEntityName, $SpaceKey)
                }
            }
            else
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding multiple Space permissions to anonymous users"
                if ($PSCmdlet.ShouldProcess("anonymous users", "Assign Permission $($Permissions -join ',')"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addAnonymousPermissionToSpace" -Params ($token, $Permissions, $SpaceKey)
                }
            }
        }
        elseif ($Permissions.count -eq 1)
        {
            if ($RemoteEntityName)
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding a Space permission to $RemoteEntityName"
                if ($PSCmdlet.ShouldProcess($RemoteEntityName, "Assign Permission $Permissions"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addPermissionToSpace" -Params ($token, $Permissions, $RemoteEntityName, $SpaceKey)
                }
            }
            else
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding a Space permission to anonymous users"
                if ($PSCmdlet.ShouldProcess("anonymous users", "Assign Permission $Permissions"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addAnonymousPermissionsToSpace" -Params ($token, $Permissions, $SpaceKey)
                }
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Remove-ConfluenceSpacePermissions {
    <#
        .SYNOPSIS
            Set Space Permissions

        .DESCRIPTION
            Set Space Permissions

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS
            Boolean

        .EXAMPLE
            Remove-ConfluenceSpacePermissions -apiURi "http://example.com" -token "000000" -spacekey "ABC" -RemoteEntityName "user1" -Permission "VIEWSPACE"
            -----------
            Description
            Remove user1's permission to View the Space ABC

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            @("group2", "group2") | Remove-ConfluenceSpacePermissions @param -all
            -----------
            Description
            Remove all Space and Global permissions of group1 and group2

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Remove-ConfluenceSpacePermissions @param -Permission "VIEWSPACE"
            -----------
            Description
            Remove the Space permission "View Space" from anonymous users

        .LINK
            Atlassians's Docs:
                boolean removePermissionFromSpace(String token, String permission, String remoteEntityName, String spaceKey) - Remove the permission permission} from the entity named {{remoteEntityName (either a group or a user) on the space with the key spaceKey.
                boolean removeAnonymousPermissionFromSpace(String token, String permission,String spaceKey) - Remove the permission permission} from anonymous users on the space with the key {{spaceKey. (since 2.0)
                boolean removeAllPermissionsForGroup(String token, String groupname) - Remove all the global and space level permissions for groupname.
    #>
    [CmdletBinding(
        SupportsShouldProcess=$True,
        DefaultParameterSetName="removePermissionFromSpace"
    )]
    [OutputType(
        [Boolean]
    )]
    param(
        # The URi of the API interface.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        # Value can be set persistently with Set-ConfluenceEndpoint.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Key of the Space.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ParameterSetName="removePermissionFromSpace"
        )]
        [Alias("space")]
        [string]$SpaceKey,

        # Name of the Entity in question. Can be an User or Group.
        [Parameter(
            Position=1,
            ValueFromPipeline=$true
        )]
        [Alias('UserName','GroupName')]
        [string]$RemoteEntityName,

        # One or more permissions which will be removed.
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="removePermissionFromSpace"
        )]
        [ValidateSet(
            'VIEWSPACE',
            'EDITSPACE',
            'EXPORTPAGE',
            'SETPAGEPERMISSIONS',
            'REMOVEPAGE',
            'EDITBLOG',
            'REMOVEBLOG',
            'COMMENT',
            'REMOVECOMMENT',
            'CREATEATTACHMENT',
            'REMOVEATTACHMENT',
            'REMOVEMAIL',
            'EXPORTSPACE',
            'SETSPACEPERMISSIONS'
        )]
        [string[]]$Permissions,

        # Remove all Permissions the Group has on the Space.
        [Parameter(
            Mandatory=$true,
            ParameterSetName="removeAllPermissionsForGroup"
        )]
        [switch]$All
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        switch ($PsCmdlet.ParameterSetName)
        {
            "removePermissionFromSpace" {
                foreach ($permission in $Permissions)
                {
                    if ($RemoteEntityName)
                    {
                        Write-Verbose "$($MyInvocation.MyCommand.Name):: Removing Space permission [$permission] in $SpaceKey from $RemoteEntityName"
                        if ($PSCmdlet.ShouldProcess($RemoteEntityName, "Removing Permission $permission"))
                        {
                            Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePermissionFromSpace" -Params ($token, $permission, $RemoteEntityName, $SpaceKey)
                        }
                    }
                    else
                    {
                        Write-Verbose "$($MyInvocation.MyCommand.Name):: Removing Space permission [$permission] in $SpaceKey from anonymous users"
                        if ($PSCmdlet.ShouldProcess("anonymous users", "Removing Permission $permission"))
                        {
                            Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.removeAnonymousPermissionFromSpace" -Params ($token, $permission, $SpaceKey)
                        }
                    }
                }
                break
            }
            "removeAllPermissionsForGroup" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Removing all Space and Global permissions from $RemoteEntityName"
                if ($PSCmdlet.ShouldProcess($RemoteEntityName, "Removing all Permissions"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.removeAllPermissionsForGroup" -Params ($token, $RemoteEntityName)
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<# /Permissions #>