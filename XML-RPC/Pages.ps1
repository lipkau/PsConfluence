#Requires -Version 3.0
<#  Pages #>
function Get-ConfluencePage {
    <#
        .SYNOPSIS
            Retrieve Page from Confluence

        .DESCRIPTION
            Retrieve a single Page or a set of Pages from Confluence

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string
            Confluence.PageSummary

        .OUTPUTS
            Confluence.Page
            Confluence.Page[]
            Confluence.PageSummary[]

        .EXAMPLE
            Get-ConfluencePage -apiURi "http://example.com" -token "000000" -spacekey "ABC"
            -----------
            Description
            Fetch all pages as Confluence.PageSummary from Space "ABC"

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePage @param -spacekey "ABC" | Get-ConfluencePage @param
            -----------
            Description
            Fetch all pages as Confluence.PageSummary and exapand to Confluence.Page

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePage @param -pageId "12345678"
            -----------
            Description
            Fetch a specific Page

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePage @param -spacekey "ABC" -pageTitle "Page Title"
            -----------
            Description
            Fetch a specific Page by Title

        .LINK
            Atlassians's Docs:
                Vector<PageSummary> getPages(String token, String spaceKey) - returns all the summaries in the space. Doesn't include pages which are in the Trash. Equivalent to calling Space.getCurrentPages().
                Page getPage(String token, Long pageId) - returns a single Page
                Page getPage(String token, String spaceKey, String pageTitle) - returns a single Page
    #>
    [CmdletBinding(
        DefaultParameterSetName="getPagesFromSpace"
    )]
    [OutputType(
        [Confluence.Page],
        ParameterSetName=('getPageByTitle', 'getPageById')
    )]
    [OutputType(
        [Confluence.PageSummary[]],
        ParameterSetName='getPagesFromSpace'
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
            Mandatory=$true,
            ParameterSetName="getPagesFromSpace"
        )]
        [Parameter(
            Position=0,
            Mandatory=$true,
            ParameterSetName="getPageByTitle"
        )]
        [string]$SpaceKey,

        # Id of the Page. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ParameterSetName="getPageById",
            ValueFromPipelineByPropertyName=$true
        )]
        #[Parameter(
        #    Mandatory=$true,
        #    ParameterSetName="getPageHistory"
        #)]
        [Alias("id")]
        $PageId,

        # Title of the Page to be searched.
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName="getPageByTitle"
        )]
        [Alias('Title','Name')]
        [string[]]$PageTitle
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and $PsCmdlet.ParameterSetName -in @('getPageById') `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page] `
                -or $_ -is [Confluence.PageHistorySummary]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "getPagesFromSpace" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Retrieving all Pages from Space: $spacekey"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPages" -Params ($token,$spacekey) -OutputType "Confluence.PageSummary"
                break
            }
            "getPageById" {
                foreach ($id in $PageId)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Retrieving Page with id: $id"
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPage" -Params ($token,([string]$id)) -OutputType "Confluence.Page"
                }
                break
            }
            "getPageByTitle" {
                foreach ($title in $PageTitle)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Retrieving Page with Title: $t in Space: $spacekey"
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPage" -Params ($token,$spacekey,$title) -OutputType "Confluence.Page"
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Set-ConfluencePage {
    <#
        .SYNOPSIS
            Set Page to Confluence

        .DESCRIPTION
            Set a Page to Confluence

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects
                     1.2.0 - OL - Fix output object

        .INPUTS
            string
            Confluence.Page
            Confluence.PageUpdateOptions

        .OUTPUTS
            Confluence.Page

        .EXAMPLE
            $NewPage = New-Object Confluence.Page
            $NewPage.title ="My new Title"
            $NewPage.content = "<h1>Title</h1><p>Lorem ipsum</p>"
            $NewPage.space = "ABC"
            Set-ConfluencePage -apiURi "http://example.com" -token "000000" -page $NewPage
            -----------
            Description
            Create a new Page


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            $Page = Get-ConfluencePage @param -spacekey "ABC" -pagetitle "My new Title"
            $Page.title = "Revised Page Title"
            $Page.content = $Page.content -replace "<p>(.+)</p>","<p><b>`$1</b></p>"
            $UpdateOptions = New-Object Confluence.PageUpdateOptions
            $Updateoptions.versionComment = "Changed Title && made text bold"
            Set-ConfluencePage @param -page $Page -updateOptions $Updateoptions
            -----------
            Description
            Fetch a Page, updating it and leave a comment for the update

        .LINK
            Atlassians's Docs:
                Page storePage(String token, Page  page) - adds or updates a page. For adding, the Page given as an argument should have space, title and content fields at a minimum. For updating, the Page given should have id, space, title, content and version fields at a minimum. The parentId field is always optional. All other fields will be ignored. The content is in storage format. Note: the return value can be null, if an error that did not throw an exception occurred.  Operates exactly like updatePage() if the page already exists.
                Page updatePage(String token, Page  page, PageUpdateOptions pageUpdateOptions) - updates a page. The Page given should have id, space, title, content and version fields at a minimum. The parentId field is always optional. All other fields will be ignored. Note: the return value can be null, if an error that did not throw an exception occurred.
    #>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='Low'
    )]
    [OutputType(
        [Confluence.Page]
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

        # Confluence Page.
        # Can be sent though the pipe, in which case an object of type Confluence.Page is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        $Page,

        # Update Options (like comment for the update)
        [Parameter(
            Position=1,
            Mandatory=$false
        )]
        [Confluence.PageUpdateOptions]$updateOptions

    )

    Begin
    {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"

        if (!$updateOptions)
        {
            $updateOptions = New-Object Confluence.PageUpdateOptions
            $updateOptions.versionComment = ""
            $updateOptions.minorEdit = $false
        }
    }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and $PsCmdlet.ParameterSetName -in @('getPageById') `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        if ($Page.id)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name):: Updating Page $($Page.title)"
            if ($pscmdlet.ShouldProcess($page.title, "Update"))
            {
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.updatePage" -Params ($token,$page,$updateOptions) -OutputType "Confluence.Page"
            }
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name):: Creating Page $($Page.title)"
            if ($pscmdlet.ShouldProcess($page.title, "Create"))
            {
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.storePage" -Params ($token,$page) -OutputType "Confluence.Page"
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Remove-ConfluencePage {
    <#
        .SYNOPSIS
            Remove Page from Confluence

        .DESCRIPTION
            Remove a Page from Confluence

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string
            int
            Confluence.Page
            Confluence.PageSummary

        .OUTPUTS


        .EXAMPLE
            Remove-ConfluencePage -apiURi "http://example.com" -token "000000" -pageId 12345678
            -----------
            Description
            Remove a specific Page by it's ID


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            $Page = Get-ConfluencePage @param -spacekey "ABC" -pagetitle "My new Title"
            Remove-ConfluencePage @param -page $page
            -----------
            Description
            Fetch a Page and remove it

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePage @param -spacekey "ABC" | Remove-ConfluencePage @param
            -----------
            Description
            Fetch all Pages in a Space and remove them

        .LINK
            Atlassians's Docs:
                void removePage(String token, String pageId) - removes a page
                void removePageVersionById(String token, String historicalPageId)  - removes a historical version of a page identified by that versions id.
                void removePageVersionByVersion(String token, String pageId, int version) - removes a historical version of a page identified by the current page id and the version number you want to remove (with 1 being the first version)
    #>
    [CmdletBinding(
        DefaultParameterSetName="PageByPageId",
        SupportsShouldProcess=$True,
        ConfirmImpact='Low'
    )]
    [OutputType(
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

        # Page ID to be deleted or on of it's versions. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true,
            ParameterSetName="PageByPageId"
        )]
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="VersionByVersion"
        )]
        [Alias("id")]
        [string[]]$PageId,

        # Delete a historical Page by it's ID
        [Parameter(
            Mandatory=$true,
            ParameterSetName="VersionByhistoricalPageId"
        )]
        [string[]]$historicalPageId,

        # Delete a historical Page by it's version
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName="VersionByVersion"
        )]
        [int]$version
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and $PsCmdlet.ParameterSetName -in @('getPageById') `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        # $source = @()
        switch ($PsCmdlet.ParameterSetName)
        {
            "PageByPageId" {
                foreach ($id in $PageId)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Removing Page $id"
                    if ($PSCmdlet.ShouldProcess("Page $id","Delete"))
                    {
                        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePage" -Params ($token,([string]$id)) -OutputType "bool"
                    }
                }
            }
            "VersionByhistoricalPageId" {
                foreach ($pageId in $historicalPageId)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Removing Historical Page $pageId"
                    if ($PSCmdlet.ShouldProcess($pageId,"Delete"))
                    {
                        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePageVersionById" -Params ($token,[string]$pageId) -OutputType "bool"
                    }
                }
            }
            "VersionByVersion" {
                # Ensure ValueByPipeProperty is of a valid Type
                if (!($_ -is [Confluence.PageSummary] -or $_ -is [Confluence.Page])) {Throw "Invalid object provided"}

                if ($PageId.Count -gt 1) {throw "Unable to delete Page versions of multiple pages at once"}

                Write-Verbose "$($MyInvocation.MyCommand.Name):: Removing Page $PageId version $version"
                if ($PSCmdlet.ShouldProcess("$PageId version $version","Delete"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.removePageVersionByVersion" -Params ($token,([string]$pageId),$version) -OutputType "bool"
                }
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Move-ConfluencePage {
    <#
        .SYNOPSIS
            Move a Page in Confluence

        .DESCRIPTION
            Move a Page to a new Parent or Space

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS


        .EXAMPLE
            $NewPage = New-Object Confluence.Page
            $NewPage.title ="My new Title"
            $NewPage.content = "<h1>Title</h1><p>Lorem ipsum</p>"
            $NewPage.space = "ABC"
            Set-ConfluencePage -apiURi "http://example.com" -token "000000" -page $NewPage
            Move-ConfluencePage -apiURi "http://example.com" -token "000000" -SourcePageId $NewPage.id -SpaceKey "DEF"
            -----------
            Description
            Create a new Page and move it to Top Level in Space "DEF"


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            $sourcePage = Get-ConfluencePage @param -spacekey "ABC" -pagetitle "Page Title"
            $targetPage = Get-ConfluencePage @param -spacekey "DEF" -pagetitle "Page Title 2"
            Move-ConfluencePage @param -SourcePageId $sourcePage.id -TargetPageId $targetPage
            -----------
            Description
            Fetch source and target Pages and move source page so it is a child of target page

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            $sourcePage = Get-ConfluencePage @param -spacekey "ABC" -pagetitle "Page Title"
            $targetPage = Get-ConfluencePage @param -spacekey "DEF" -pagetitle "Page Title 2"
            Move-ConfluencePage @param -SourcePageId $sourcePage.id -TargetPageId $targetPage -position "above"
            -----------
            Description
            Fetch source and target Pages and move source page so it is a sibling placed above the target page

        .LINK
            Atlassians's Docs:
                void movePageToTopLevel(String pageId, String targetSpaceKey) - moves a page to the top level of the target space. This corresponds to PageManager - movePageToTopLevel.
                void movePage(String token, String sourcePageId, String targetPageId, String position)- moves a page's position in the hierarchy.

                sourcePageId - the id of the page to be moved.
                targetPageId - the id of the page that is relative to the sourcePageId page being moved.
                position - "above", "below", or "append". (Note that the terms 'above' and 'below' refer to the relative vertical position of the pages in the page tree.)

                above   |   source and target become/remain sibling pages and the source is moved above the target in the page tree.
                below   |   source and target become/remain sibling pages and the source is moved below the target in the page tree.
                append  |   source becomes a child of the target
    #>
    [CmdletBinding(
        DefaultParameterSetName="movePage",
        SupportsShouldProcess=$True
    )]
    [OutputType()]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page Id to be moved. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id","PageId")]
        [string]$SourcePageId,

        # Page in the new location to be used as referenced.
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName="movePage"
        )]
        [string]$TargetPageId,

        # Position of the moved page in relation to the TargetPage. "Above" and "Below" will make the moved page a sibbling of the TargetPage, while "append" makes it a child page.
        [Parameter(
            Position=2,
            ParameterSetName="movePage"
        )]
        [ValidateSet("above","below","append")]
        [string]$Position = "append",

        # Key of the Space where the Page will be moved to. This makes the moved Page a Top Level page of the Space.
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName="movePageToTop"
        )]
        [Alias("Space")]
        [string]$SpaceKey
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "movePage" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Moving Page $SourcePageId to $position target page $TargetPageId"
                if ($PSCmdlet.ShouldProcess($SourcePageId, "Moving")) {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.movePage" -Params ($token,([string]$SourcePageId),([string]$TargetPageId),$position) -OutputType "bool"
                }
                break
            }
            "movePageToTop" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Moving Page $SourcePageId to Top Level in Space $spacekey"
                if ($PSCmdlet.ShouldProcess($SourcePageId, "Moving to Top Level")) {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.movePageToTopLevel" -Params (([string]$SourcePageId),$SpaceKey) -OutputType "bool"
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Get-ConfluenceChildPage {
    <#
        .SYNOPSIS
            Get all child pages of a Confluence Page

        .DESCRIPTION
            Get all child pages of a Confluence Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS
            Confluence.PageSummary[]

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
                Vector<PageSummary> getChildren(String token, String pageId) - returns all the direct children of this page.
                Vector<PageSummary> getDescendents(String token, String pageId) - returns all the descendants of this page (children, children's children etc).
    #>
    [CmdletBinding(
    )]
    [OutputType(
        [Confluence.PageSummary[]]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page's id from which to get the children. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id")]
        [string]$PageId,

        # Whether the search of children should be recursive.
        [Alias("s")]
        [switch]$Recurse
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        if ($Recurse) {
            Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting all children of $PageId"
            Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getDescendents" -Params ($token,$PageId) -OutputType "Confluence.PageSummary"
        } else {
            Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting all children of $PageId recursively"
            Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getChildren" -Params ($token,$PageId) -OutputType "Confluence.PageSummary"
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Get-ConfluencePageHistory {
    <#
        .SYNOPSIS
            Get the history of a Confluence Page

        .DESCRIPTION
            Get the history of a Confluence Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS
            Confluence.PageHistorySummary[]

        .EXAMPLE
            Get-ConfluencePageHistory -apiURi "http://example.com" -token "000000" -pageId 12345678
            -----------
            Description
            Fetch the history of a specific page


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePageHistory @param -pageid 12345678
            -----------
            Description
            Fetch the history of a specific page

        .LINK
            Atlassians's Docs:
                Vector<PageHistorySummary> getPageHistory(String token, String pageId) - returns all the PageHistorySummaries - useful for looking up the previous versions of a page, and who changed them.
    #>
    [CmdletBinding(
    )]
    [OutputType(
        [Confluence.PageHistorySummary[]]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page Id from which to retrieve the history. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id")]
        [string]$PageId
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name):: Retrieving History of page $PageId"
        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getPageHistory" -Params ($token,$PageId) -OutputType "Confluence.PageHistorySummary"
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Get-ConfluencePermission {
    <#
        .SYNOPSIS
            Get permissions/restrictions of a Confluence Page

        .DESCRIPTION
            Get permissions/restrictions of a Confluence Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string
            switch

        .OUTPUTS
            Hashtable
            Confluence.ContentPermission[]
            Confluence.ContentPermissionSet[]

        .EXAMPLE
            Get-ConfluencePermissions -apiURi "http://example.com" -token "000000" -pageId 12345678
            -----------
            Description
            Fetch page restrictions of a specific page


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePermissions @param -pageid 12345678 -permissionType "View"
            -----------
            Description
            Fetch all view restrictions for a specific page

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluencePermissions @param -pageId 12345678 -AsPagePermissions
            -----------
            Description
            Fetch page restrictions of a specific page without grouping into a Set

        .LINK
            Atlassians's Docs:
                Vector<ContentPermissionSet> getContentPermissionSets(String token, String contentId) - returns all the page level permissions for this page as ContentPermissionSets
                Hashtable getContentPermissionSet(String token, String contentId, String permissionType) - returns the set of permissions on a page as a map of type to a list of ContentPermission, for the type of permission which is either 'View' or 'Edit'
                Vector<ContentPermission> getPagePermissions(String token, String pageId) - Returns a Vector of permissions representing the permissions set on the given page.
    #>
    [CmdletBinding(
        DefaultParameterSetName='getContentPermissionSets'
    )]
    [OutputType(
        [Hashtable],
        ParameterSetName='getContentPermissionSet'
    )]
    [OutputType(
        [Confluence.ContentPermission],
        ParameterSetName='getPagePermissions'
    )]
    [OutputType(
        [Confluence.ContentPermissionSet[]],
        ParameterSetName='getContentPermissionSets'
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page id from where to retrieve the permissions. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true
        )]
        [Alias("id")]
        [string]$PageId,

        # Type of permissions which should be retrieved.
        [Parameter(
            Position=1,
            ParameterSetName='getContentPermissionSet'
        )]
        [ValidateSet("Edit","View")]
        [Alias('Type')]
        [string]$permissionType,

        # Return a list of Permissions instead of a grouped set by permission type.
        [Parameter(
            ParameterSetName='getPagePermissions'
        )]
        [switch]$AsPagePermissions
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "getContentPermissionSets" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting ContentPermissionSet for $pageId"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getContentPermissionSets" -Params ($token,([string]$pageid)) | ForEach-Object {
                    New-Object -TypeName Confluence.ContentPermissionSet -Prop @{
                        type = $_.type
                        contentPermissions = $_.contentPermissions | ForEach-Object { $_ -as "Confluence.ContentPermission"}
                    }
                }
                break
            }
            "getContentPermissionSet" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Hashtable with permissions for $pageId"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getContentPermissionSet" -Params ($token,([string]$pageid),$permissionType)
            }
            "getPagePermissions" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Collection of ContentPermission for $pageid"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getContentPermissionSets" -Params ($token,([string]$pageid)) | ForEach-Object {
                    $_.contentPermissions | ForEach-Object { $_ -as "Confluence.ContentPermission"}
                    }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Set-ConfluencePermission {
    <#
        .SYNOPSIS
            Set permissions/restrictions for a Confluence Page

        .DESCRIPTION
            Set permissions/restrictions for a Confluence Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string
            Confluence.ContentPermissionSet

        .OUTPUTS
            bool

        .EXAMPLE
            $permissions = Get-ConfluencePermissions -apiURi "http://example.com" -token "000000" -pageId 12345678
            Set-ConfluencePermissions -apiURi "http://example.com" -token "000000" -pageId 87654321 -PermissionType $permissions.type -Permissions $permissions
            -----------
            Description
            Sets the same page restrictions of a specific page as from the example page


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            $permissions = New-Object Confluence.ContentPermission
            $permissions.type = "View"
            $permissions.groupName = "Administrators"
            $permissionSet = New-Object Confluence.ContentPermissionSet
            $permissionSet.type = "View"
            $permissionSet.contentPermissions = $permissions
            Set-ConfluencePermissions @param -pageid 12345678 -PermissionType $permissionSet.type -Permissions $permissionSet
            -----------
            Description
            Sets the restrictions of a specific page so only members of the group "Administrators" can view it

        .LINK
            Atlassians's Docs:
                boolean setContentPermissions(String token, String contentId, String permissionType, Vector permissions) - sets the page-level permissions for a particular permission type (either 'View' or 'Edit') to the provided vector of ContentPermissions. If an empty list of permissions are passed, all page permissions for the given type are removed. If the existing list of permissions are passed, this method does nothing.
    #>
    [CmdletBinding(
        ConfirmImpact='Low',
        SupportsShouldProcess=$True,
        DefaultParameterSetName="setPagePermissionsFromObject"
    )]
    [OutputType(
        [bool]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page id for which the permissions should be set. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id")]
        $PageId,

        # Content Permission Set
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName='setPagePermissionsFromObject'
        )]
        [Confluence.ContentPermissionSet]$PermissionSet,

        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName='setPagePermissionsFromXML'
        )]
        [string]$Type,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName='setPagePermissionsFromXML'
        )]
        [xml]$PermissionSetAsXML
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        if ($PSCmdlet.ShouldProcess($PageId,"Set Permissions"))
        {
            foreach ($page in $PageId)
            {
                switch ($PsCmdlet.ParameterSetName) {
                    "setPagePermissionsFromObject" {
                        Write-Verbose "$($MyInvocation.MyCommand.Name):: Setting permissions for $page"
                        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.setContentPermissions" -Params ($token,([string]$page),($PermissionSet.type),$PermissionSet.contentPermissions)
                }
                    "setPagePermissionsFromXML" {
                        Write-Verbose "$($MyInvocation.MyCommand.Name):: Setting permissions for $page"
                        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.setContentPermissions" -Params ($token,([string]$page),$Type,$PermissionSetAsXML)
                    }
                }
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
function Get-ConfluenceAttachment {
    <#
        .SYNOPSIS
            Get Attachments from a Confluence Page

        .DESCRIPTION
            Get Attachments from a Confluence Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code
                     1.1.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string
            switch

        .OUTPUTS
            System.IO.FileInfo
            Confluence.Attachment
            Confluence.Attachment[]

        .EXAMPLE
            Get-ConfluenceAttachment -apiURi "http://example.com" -token "000000" -pageId 12345678
            -----------
            Description
            Retrieve all Attachments of a specific page


        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluenceAttachment @param -pageid 12345678 -pageId 12345678 -fileName "Data.xls" -verions 10
            -----------
            Description
            Gets the meta information of the Data.xls version 10 files attached to a specific page

        .EXAMPLE
            $param = @{apiURi = "http://example.com"; token = "000000"}
            Get-ConfluenceAttachment @param -pageid 12345678 -pageId 12345678 -fileName "Data.xls" -Filepath "c:\data.xls"
            -----------
            Description
            Downloads the latest version of the Data.xls file to the local disk

        .LINK
            Atlassians's Docs:
                Attachment getAttachment(String token, String pageId, String fileName, String versionNumber) - get information about an attachment.
                Vector<Attachment> getAttachments(String token, String pageId) - returns all the Attachments for this page (useful to point users to download them with the full file download URL returned).
                byte[] getAttachmentData(String token, String pageId, String fileName, String versionNumber) - get the contents of an attachment.
    #>
    [CmdletBinding(
        DefaultParameterSetName="getAttachments"
    )]
    [OutputType(
        [System.IO.FileInfo],
        ParameterSetName='getAttachmentData'
    )]
    [OutputType(
        [Confluence.Attachment],
        ParameterSetName=('getAttachment', 'getAttachments')
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page Id where the File was attached to. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id")]
        $PageId,

        # Name of the attached file.
        [Parameter(
            Mandatory=$true,
            ParameterSetName="getAttachment",
            ValueFromPipelineByPropertyName=$true
        )]
        [Parameter(
            Mandatory=$true,
            ParameterSetName="getAttachmentData",
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$FileName,

        # Version of the attachment. "0" is the latest version.
        [Parameter(
            ParameterSetName="getAttachment",
            ValueFromPipelineByPropertyName=$true
        )]
        [Parameter(
            ParameterSetName="getAttachmentData",
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Version = "0",

        # Local path where the attachment should be saved to.
        [Parameter(
            Mandatory=$true,
            Position=2,
            ParameterSetName="getAttachmentData"
        )]
        [ValidateScript({Test-path $_ -IsValid})]
        [string]$FilePath
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "getAttachmentData" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Attachment Data of $FileName"
                $response = Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getAttachmentData" -Params ($token,([string]$pageid),$filename,([string]$version))
                if ($response)
                {
                    Write-Base64ToFile -FilePath $FilePath -base64 $response.base64 -PassThru
                }
            }
            "getAttachment" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Attachment of $FileName"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getAttachment" -Params ($token,([string]$pageid),$filename,([string]$version)) -OutputType "Confluence.Attachment"
            }
            "getAttachments" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting all Attachment of $PageId"
                Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getAttachments" -Params ($token,([string]$pageid)) -OutputType "Confluence.Attachment"
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<#function Get-ConfluenceAncestors {
    #Vector<PageSummary> getAncestors(String token, String pageId) - returns all the ancestors of this page (parent, parent's parent etc).
}#>
<#function Get-ConfluenceChildren {
    #Vector<PageSummary> getChildren(String token, String pageId) - returns all the direct children of this page.
}#>
function Get-ConfluenceComment {
    <#
        .SYNOPSIS
            Get all comments of a Confluence Page

        .DESCRIPTION
            Get all comments of a Confluence Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 0.0.1 - OL - Initial Code
                     1.0.0 - OL - Replaced hashtables with Objects

        .INPUTS
            string

        .OUTPUTS
            Confluence.Comment

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
                Vector<Comment> getComments(String token, String pageId) - returns all the comments for this page.
    #>
    [CmdletBinding(
    )]
    [OutputType(
        [Confluence.Comment]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Mandatory=$true
        )]
        [string]$Token,

        # Page id from where to fetch the Comments. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id")]
        [string]$PageId
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name):: Getting Comments from $PageId"
        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getComments" -Params ($token,([string]$pageid)) -OutputType "Confluence.Comment"
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<#function Add-ConfluenceComment {
    #Comment addComment(String token, Comment comment) - adds a comment to the page.
}#>
<#function Set-ConfluenceComment {
    #Comment editComment(String token, Comment comment) - Updates an existing comment on the page.
}#>
<#function Remove-ConfluenceComment {
    #boolean removeComment(String token, String commentId) - removes a comment from the page.
}#>
function Resolve-ConfluenceContent {
    <#
        .SYNOPSIS
            Render HTML content for Page

        .DESCRIPTION
            Render HTML content for Page

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code

        .INPUTS
            string
            Confluence.Page
            Confluence.PageSummary

        .OUTPUTS
            string

        .EXAMPLE
            Get-ConfluencePage -apiURi "http://example.com" -token "000000" -PageId 12345678 | Render-ConfluenceContent
            -----------
            Description
            Render HTML content for a specific Page

        .EXAMPLE
            Render-ConfluenceContent -apiURi "http://example.com" -token "000000" -PageId 12345678 -Parameter @{style = "clean"}
            -----------
            Description
            Render HTML content for a specific Page with Parameter

        .LINK
            Atlassians's Docs:
                String renderContent(String token, String spaceKey, String pageId, String content) - returns the HTML rendered content for this page. The behaviour depends on which arguments are passed:
                If only pageId is passed then the current content of the page will be rendered.
                If a pageId and content are passed then the content will be rendered as if it were the body of that page.
                If a spaceKey and content are passed then the content will be rendered as if it were on a new page in that space.
                Whenever a spaceKey and pageId are passed the spaceKey is ignored.
                If neither spaceKey nor pageId are passed then an error will be returned.
                String renderContent(String token, String spaceKey, String pageId, String content, Hashtable parameters)- Like the above renderContent(), but you can supply an optional hash (map, dictionary, etc) containing additional instructions for the renderer. Currently, only one such parameter is supported:
                "style = clean" Setting the "style" parameter to "clean" will cause the page to be rendered as just a single block of HTML within a div, without the HTML preamble and stylesheet that would otherwise be added.
    #>
    [CmdletBinding(
        DefaultParameterSetName="renderContentFromPage"
    )]
    [OutputType(
        [string]
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
            Mandatory=$true,
            ParameterSetName="renderPageAsNew"
        )]
        [string]$SpaceKey,

        # Id of the Page. Can be the numeric ID of a Page (collection is supported).
        # Can be sent though the pipe, in which case an object of type Confluence.Page or Confluence.PageSummary is expected.
        [Parameter(
            Position=0,
            Mandatory=$true,
            ParameterSetName="renderContentFromPage",
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("id")]
        $PageId,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="renderPageAsNew"
        )]
        [String]$Content,

        [hashtable]$Parameter
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and $PsCmdlet.ParameterSetName -in @('renderContentFromPage') `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page]
            ))
        )
        {
            Throw "Invalid object provided"
        }
        elseif ($_ -and $_ -is [Confluence.PageSummary] -or $_ -is [Confluence.Page])
        {
            $Page = $_
        }
        elseif ($PageId -is [Confluence.PageSummary] -or $PageId -is [Confluence.Page])
        {
            $Page = $PageId
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "renderContentFromPage" {
                if (!($Page))
                {
                    $Page = Get-ConfluencePage -apiURi $apiURi -Token $Token -PageId $PageId
                }

                if ($Parameter)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Rendering Content from [$($Page.title)] with Parameters"
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.renderContent" -Params ($token,$Page.space, $Page.id, $Page.content, $Parameter)
                } else {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Rendering Content from [$($Page.title)]"
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.renderContent" -Params ($token,$Page.space, $Page.id, $Page.content)
                }
                break
            }
            "renderPageAsNew" {
                if ($Parameter)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Rendering Content as new Page with Parameters"
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.renderContent" -Params ($token,$SpaceKey, $null, $Content, $Parameter)
                } else {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Rendering Content from [$($Page.title)]"
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.renderContent" -Params ($token,$Spacekey, $null, $Content)
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<# /Page #>
