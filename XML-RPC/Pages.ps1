#Requires -Version 3.0
<#  Pages #>
function Get-Page {
    #Vector<PageSummary> getPages(String token, String spaceKey) - returns all the summaries in the space. Doesn't include pages which are in the Trash. Equivalent to calling Space.getCurrentPages().
    #Page getPage(String token, Long pageId) - returns a single Page
    #Page getPage(String token, String spaceKey, String pageTitle) - returns a single Page
    [CmdletBinding(DefaultParameterSetName="getPagesFromSpace")]
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
            ParameterSetName="getPagesFromSpace"
        )]
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getPageByTitle"
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="getPageById"
        )]
        [Parameter(
            Mandatory=$true,
            ParameterSetName="getPageHistory"
        )]
        [Alias("id")]
        [string[]]$PageId,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="getPageByTitle"
        )]
        [string[]]$PageTitle
    )

    Begin {
        $out = @()
    }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "getPagesFromSpace" {
                $out += ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPages" -Params ($token,$spacekey))
                break
            }
            "getPageById" {
                foreach ($id in $PageId) {
                    $out += ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPage" -Params ($token,([string]$id)))
                }
                break
            }
            "getPageByTitle" {
                foreach ($t in $PageTitle) {
                    $out += ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPage" -Params ($token,$spacekey,$t))
                }
                break
            }
        }
    }

    End {
        Write-Output $out
    }
}
function Set-Page {
    #Page storePage(String token, Page  page) - adds or updates a page. For adding, the Page given as an argument should have space, title and content fields at a minimum. For updating, the Page given should have id, space, title, content and version fields at a minimum. The parentId field is always optional. All other fields will be ignored. The content is in storage format. Note: the return value can be null, if an error that did not throw an exception occurred.  Operates exactly like updatePage() if the page already exists.
    #Page  updatePage(String token, Page  page, PageUpdateOptions pageUpdateOptions) - updates a page. The Page given should have id, space, title, content and version fields at a minimum. The parentId field is always optional. All other fields will be ignored. Note: the return value can be null, if an error that did not throw an exception occurred.
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
        $Page,

        [Parameter(
            Position=2
        )]
        [hashtable]$updateOptions = @{versionComment = ""; minorEdit = $false}
        
    )

    Begin {
        $o = @()
    }

    Process {
        if ($Page.id) {
            if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.updatePage" -Params ($token,$page,$updateOptions)) {
                $o += ConvertFrom-Xml $r
            }
        } else {
            if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.storePage" -Params ($token,$page)) {
                $o += ConvertFrom-Xml $r
            }
        }
    }

    End {
        $o
    }
}
function Remove-Page {
    #void removePage(String token, String pageId) - removes a page
    #void removePageVersionById(String token, String historicalPageId)  - removes a historical version of a page identified by that versions id.
    #void removePageVersionByVersion(String token, String pageId, int version) - removes a historical version of a page identified by the current page id and the version number you want to remove (with 1 being the first version)
    [CmdletBinding(DefaultParameterSetName="PageByPageId", SupportsShouldProcess=$True)]
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
            ValueFromPipeline=$true,
            Mandatory=$true,
            ParameterSetName="PageByPageId"
        )]
        [Parameter(
            Position=2,
            ValueFromPipeline=$true,
            Mandatory=$true,
            ParameterSetName="VersionByVersion"
        )]
        [Alias("id")]
        [string[]]$PageId,

        [Parameter(
            Position=2,
            ValueFromPipeline=$true,
            Mandatory=$true,
            ParameterSetName="PageByPage"
        )]
        $Page,

        [Parameter(
            Position=2,
            ValueFromPipeline=$true,
            Mandatory=$true,
            ParameterSetName="VersionById"
        )]
        [string]$historicalPageId,
        
        [Parameter(
            Position=2,
            ValueFromPipeline=$true,
            Mandatory=$true,
            ParameterSetName="VersionByVersion"
        )]
        [int]$version
    )

    Begin {
        $o = @()
    }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "PageByPageId" {
                $source = $pageid
            }
            "PageByPage" {
                $source = $page.id
            }
            "VersionById" {
                if ($PSCmdlet.ShouldProcess($source)) {
                    if ($global:r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePageVersionById" -Params ($token,[string]$historicalPageId)) {
                        $o += ConvertFrom-Xml $r
                    }
                }
            }
            "VersionByVersion" {
                if ($PSCmdlet.ShouldProcess($source)) {
                    if ($global:r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePageVersionByVersion" -Params ($token,([string]$PageId),$version)) {
                        $o += ConvertFrom-Xml $r
                    }
                }
            }
        }

        foreach ($id in $source) {
            if ($PSCmdlet.ShouldProcess($source)) {
                if ($global:r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePage" -Params ($token,([string]$id))) {
                    $o += ConvertFrom-Xml $r
                }
            }
        }
    }

    End {
        $o
    }
}
function Move-Page {
    #void movePage(String token, String sourcePageId, String targetPageId, String position)- moves a page's position in the hierarchy.
        #sourcePageId - the id of the page to be moved.
        #targetPageId - the id of the page that is relative to the sourcePageId page being moved.
        #position - "above", "below", or "append". (Note that the terms 'above' and 'below' refer to the relative vertical position of the pages in the page tree.)
    #void movePageToTopLevel(String pageId, String targetSpaceKey) - moves a page to the top level of the target space. This corresponds to PageManager - movePageToTopLevel.

    #above   |   source and target become/remain sibling pages and the source is moved above the target in the page tree.
    #below   |   source and target become/remain sibling pages and the source is moved below the target in the page tree.
    #append  |   source becomes a child of the target
    [CmdletBinding(
        DefaultParameterSetName="movePage",
        SupportsShouldProcess=$True
    )]
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
            ValueFromPipeline=$true,
            Mandatory=$true
        )]
        [Alias("id","PageId")]
        [string]$SourcePageId,

        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="movePage"
        )]
        [string]$TargetPageId,

        [Parameter(
            Position=4,
            Mandatory=$true,
            ParameterSetName="movePage"
        )]
        [ValidateSet("above","below","append")]
        [string]$position,
        
        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="movePageToTop"
        )]
        [Alias("Space")]
        [string]$SpaceKey
    )

    Begin {
        $o = @()
    }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "movePage" {
                if ($PSCmdlet.ShouldProcess($pageid)) {
                    if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.movePage" -Params ($token,([string]$SourcePageId),([string]$TargetPageId),$position)) {
                        return ConvertFrom-Xml $r
                    }
                }
                break
            }
            "movePageToTop" {
                if ($PSCmdlet.ShouldProcess($pageid)) {
                    if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.movePageToTopLevel" -Params (([string]$SourcePageId),$SpaceKey)) {
                        return ConvertFrom-Xml $r
                    }
                }
                break
            }
        }
    }

    End {
        $o
    }
}
function Get-ChildPage {
    #Vector<PageSummary> getChildren(String token, String pageId) - returns all the direct children of this page.
    #Vector<PageSummary> getDescendents(String token, String pageId) - returns all the descendants of this page (children, children's children etc).
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
        [string]$PageId,

        [Alias("s")]
        [switch]$Recurse
    )

    Process {
        if ($Recurse) {
            return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getDescendents" -Params ($token,$PageId))
        } else {
            return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getChildren" -Params ($token,$PageId))
        }
    }
}
function Get-PageHistory {
    #Vector<PageHistorySummary> getPageHistory(String token, String pageId) - returns all the PageHistorySummaries - useful for looking up the previous versions of a page, and who changed them.
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
        [string]$PageId
    )

    Process{
        return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPageHistory" -Params ($token,$PageId))
    }
}
function Get-Permissions {
    #Vector<ContentPermissionSet> getContentPermissionSets(String token, String contentId) - returns all the page level permissions for this page as ContentPermissionSets
    #TODO: Hashtable getContentPermissionSet(String token, String contentId, String permissionType) - returns the set of permissions on a page as a map of type to a list of ContentPermission, for the type of permission which is either 'View' or 'Edit'
    #TODO: Vector<ContentPermission> getPagePermissions(String token, String pageId) - Returns a Vector of permissions representing the permissions set on the given page.
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
            ValueFromPipeline=$true,
            Mandatory=$true
        )]
        [Alias("id")]
        [string[]]$PageId,

        [Parameter(
            Position=3,
            Mandatory=$true
        )]
        [ValidateSet("Edit","View")]
        [string[]]$permissionType
    )

    Begin {
        $o = @()
    }

    Process {
        foreach ($id in $PageId) {
            foreach ($pt in $permissionType) {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getContentPermissionSet" -Params ($token,([string]$id),$pt )) {
                    $o += ConvertFrom-Xml $r
                }
            }
        }
    }

    End {
        $o
    }
}
function Set-Permissions {
    #boolean setContentPermissions(String token, String contentId, String permissionType, Vector permissions) - sets the page-level permissions for a particular permission type (either 'View' or 'Edit') to the provided vector of ContentPermissions. If an empty list of permissions are passed, all page permissions for the given type are removed. If the existing list of permissions are passed, this method does nothing.
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
            ValueFromPipeline=$true,
            Mandatory=$true
        )]
        [Alias("id")]
        [string[]]$PageId,

        [Parameter(
            Position=3,
            Mandatory=$true
        )]
        [ValidateSet("Edit","View")]
        [string]$PermissionType,

        [Parameter(
            Position=4,
            Mandatory=$false
        )]
        [Object]$Permissions
    )

    Process {
        foreach ($id in $PageId) {
            if ($PSCmdlet.ShouldProcess($id)) {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.setContentPermissions" -Params ($token,([string]$id),$PermissionType,($Permissions))) {
                    return ConvertFrom-Xml $r
                }
            }
        }
    }
}
function Get-Attachment {
    #Attachment getAttachment(String token, String pageId, String fileName, String versionNumber) - get information about an attachment.
    #Vector<Attachment> getAttachments(String token, String pageId) - returns all the Attachments for this page (useful to point users to download them with the full file download URL returned).
    #byte[] getAttachmentData(String token, String pageId, String fileName, String versionNumber) - get the contents of an attachment.
    [CmdletBinding(DefaultParameterSetName="getAttachments")]
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
            ParameterSetName="getAttachments"
        )]
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getAttachment"
        )]
        [Alias("id")]
        $PageId,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="getAttachment"
        )]
        [string]$filename,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="getAttachment"
        )]
        [string]$version,

        [Parameter(
            ParameterSetName="getAttachment"
        )]
        [switch]$data
    )

    Begin {
        $o = @()
    }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "getAttachment" {
                if ($data)
                {
                    if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getAttachmentData" -Params ($token,([string]$pageid),$filename,([string]$version))) {
                        $o += ConvertFrom-Xml $r
                    }
                } else {
                    if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getAttachment" -Params ($token,([string]$pageid),$filename,([string]$version))) {
                        $o += ConvertFrom-Xml $r
                    }
                }
                break
            }
            default {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getAttachments" -Params ($token,([string]$pageid))) {
                    $o += ConvertFrom-Xml $r
                }
                break
            }
        }
    }

    End {
        $o
    }
}
<#function Get-Ancestors {
    #Vector<PageSummary> getAncestors(String token, String pageId) - returns all the ancestors of this page (parent, parent's parent etc).
}#>
<#function Get-Children {
    #Vector<PageSummary> getChildren(String token, String pageId) - returns all the direct children of this page.
}#>
function Get-Comment {
    #Vector<Comment> getComments(String token, String pageId) - returns all the comments for this page.
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
            ValueFromPipeline=$True
        )]
        [Alias("id")]
        [string[]]$PageId
    )

    Begin {
        $o = @()
    }

    Process {
        foreach ($id in $pageId) {
            if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getComments" -Params ($token,([string]$id))) {
                $o += ConvertFrom-Xml $r
            }
        }
    }

    End {
        $o
    }
}
<#function Add-Comment {
    #Comment addComment(String token, Comment comment) - adds a comment to the page.
}#>
<#function Set-Comment {
    #Comment editComment(String token, Comment comment) - Updates an existing comment on the page.
}#>
<#function Remove-Comment {
    #boolean removeComment(String token, String commentId) - removes a comment from the page.
}#>
<#function Render-Content {
    #String renderContent(String token, String spaceKey, String pageId, String content) - returns the HTML rendered content for this page. The behaviour depends on which arguments are passed:
        #If only pageId is passed then the current content of the page will be rendered.
        #If a pageId and content are passed then the content will be rendered as if it were the body of that page.
        #If a spaceKey and content are passed then the content will be rendered as if it were on a new page in that space.
        #Whenever a spaceKey and pageId are passed the spaceKey is ignored.
        #If neither spaceKey nor pageId are passed then an error will be returned.
    #String renderContent(String token, String spaceKey, String pageId, String content, Hashtable parameters)- Like the above renderContent(), but you can supply an optional hash (map, dictionary, etc) containing additional instructions for the renderer. Currently, only one such parameter is supported:
        #"style = clean" Setting the "style" parameter to "clean" will cause the page to be rendered as just a single block of HTML within a div, without the HTML preamble and stylesheet that would otherwise be added.
}#>
<# /Page #>