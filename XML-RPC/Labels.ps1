#Requires -Version 3.0
<#  Labels #>
function Get-ConfluenceLabels {
    <#
    .SYNOPSIS
        Remove Page from Confluence

    .DESCRIPTION
        Remove a Page from Confluence

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 0.0.1 - OL - Initial Code
                 1.0.0 - OL - Replaced hashtables with Objects

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
            Vector getLabelsById(String token, long objectId) - Returns all labels for the given ContentEntityObject ID
            Vector getMostPopularLabels(String token, int maxCount) - Returns the most popular labels for the Confluence instance, with a specified maximum number.
            Vector getMostPopularLabelsInSpace(String token, String spaceKey, int maxCount) - Returns the most popular labels for the given spaceKey, with a specified maximum number of results.
            Vector getRecentlyUsedLabels(String token, int maxResults) - Returns the recently used labels for the Confluence instance, with a specified maximum number of results.
            Vector getRecentlyUsedLabelsInSpace(String token, String spaceKey, int maxResults) - Returns the recently used labels for the given spaceKey, with a specified maximum number of results.
            TODO: Vector getLabelsByDetail(String token, String labelName, String namespace, String spaceKey, String owner) - Retrieves the labels matching the given labelName, namespace, spaceKey or owner.

    #>
    [CmdletBinding(
        DefaultParameterSetName='getRecentlyUsedLabels'
    )]
    [OutputType(
        [Confluence.Label],
        [Confluence.Label[]]
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
        [string]$Token,

        # Id of the object from which to retrieve the Labels
        [Parameter(
            Position=2,
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="getLabelsById"
        )]
        [Alias('id')]
        [long]$objectId,

        # Spapce from which to retrieve the Labels
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getMostPopularLabels"
        )]
        [Parameter(
            Position=2,
            ParameterSetName="getRecentlyUsedLabels"
        )]
        [Parameter(
            ParameterSetName="getLabelsByDetail"
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        # Limit the numer of resutls
        [Parameter(
            ParameterSetName="getMostPopularLabels"
        )]
        [Parameter(
            ParameterSetName="getRecentlyUsedLabels"
        )]
        [int16]$maxCount = 100,

        # Whether to get Most Popular or Most Recent Labels
        [Parameter(
            ParameterSetName="getMostPopularLabels"
        )]
        [Parameter(
            ParameterSetName="getRecentlyUsedLabels"
        )]
        [ValidateSet(
            "recent",
            "popular"
        )]
        [string]$Condition = "recent",

        # Name of a specific Label
        [Parameter(
            ParameterSetName="getLabelsByDetail"
        )]
        [string]$LabelName = "",

        #
        [Parameter(
            ParameterSetName="getLabelsByDetail"
        )]
        [string]$NameSpace = "",

        #
        [Parameter(
            ParameterSetName="getLabelsByDetail"
        )]
        [string]$Owner =""
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "getLabelsById" {
                $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getLabelsById" -Params ($token,$objectId))
                if ($response)
                {
                    foreach ($Label in $response)
                    {
                        [Confluence.Label]$Label
                    }
                }
                break
            }
            {"getRecentlyUsedLabels","getMostPopularLabels" -contains $_} {
                if ($Condition -eq "recent")
                {
                    if ($spaceKey)
                    {
                        $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getRecentlyUsedLabelsInSpace" -Params ($token,$SpaceKey,$maxCount))
                        if ($response)
                        {
                            foreach ($Label in $response)
                            {
                                [Confluence.Label]$Label
                            }
                        }
                        break
                    } else {
                        $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getRecentlyUsedLabels" -Params ($token,$maxCount))
                        if ($response)
                        {
                            foreach ($Label in $response)
                            {
                                [Confluence.Label]$Label
                            }
                        }
                        break
                    }
                } else {
                    if ($spaceKey)
                    {
                        $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getMostPopularLabelsInSpace" -Params ($token,$SpaceKey,$maxCount))
                        if ($response)
                        {
                            foreach ($Label in $response)
                            {
                                [Confluence.Label]$Label
                            }
                        }
                        break
                    } else {
                        $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getMostPopularLabels" -Params ($token,$maxCount))
                        if ($response)
                        {
                            foreach ($Label in $response)
                            {
                                [Confluence.Label]$Label
                            }
                        }
                        break
                    }
                }
            }
            "getLabelsByDetail" {
                $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getLabelsByDetail" -Params ($token,$labelName,$namespace,$spaceKey, $owner))
                if ($response)
                {
                    foreach ($Label in $response)
                    {
                        [Confluence.Label]$Label
                    }
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
#getSpacesWithLabel is in <Space/>
<#function Get-ConfluenceRelatedLabel {
    #Vector getRelatedLabels(String token, String labelName, int maxResults) - Returns the labels related to the given label name, with a specified maximum number of results.
    #Vector getRelatedLabelsInSpace(String token, String labelName, String spaceKey, int maxResults) - Returns the labels related to the given label name for the given spaceKey, with a specified maximum number of results.
}#>
<#function Get-ConfluenceLabelContent {
    #Vector getLabelContentById(String token, long labelId) - Returns the content for a given label ID
    #Vector getLabelContentByName(String token, String labelName) - Returns the content for a given label name.
    #Vector getLabelContentByObject(String token, Label labelObject) - Returns the content for a given Label  object.
}#>
#getSpacesContainingContentWithLabel is in <Space/>
function Add-ConfluenceLabel {
    <#
        .SYNOPSIS
            Adds Label to Confluence Content

        .DESCRIPTION
            Adds Label to Confluence Content

        .NOTES
            AUTHOR : Oliver Lipkau <oliver@lipkau.net>
            VERSION: 1.0.0 - OL - Initial Code

        .INPUTS
            string
            Confluence.Label

        .OUTPUTS
            Boolean

        .EXAMPLE


        .LINK
            Atlassians's Docs:
                boolean addLabelByName(String token, String labelName, long objectId) - Adds label(s) to the object with the given ContentEntityObject ID. For multiple labels, labelName should be in the form of a space-separated or comma-separated string.
                boolean addLabelById(String token, long labelId, long objectId) - Adds a label with the given ID to the object with the given ContentEntityObject ID.
                boolean addLabelByObject(String token, Label  labelObject, long objectId) - Adds the given label object to the object with the given ContentEntityObject ID.
                boolean addLabelByNameToSpace(String token, String labelName, String spaceKey) - Adds a label to description of a space with the given space key. Prefix labelName with "team:" in order to make it a space category.
    #>
    [CmdletBinding(
        ConfirmImpact = 'Low',
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'byString'
    )]
    [OutputType(
        [bool]
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
            ValueFromPipeline=$true,
            ParameterSetName = 'byString',
            ValueFromPipelinebyPropertyName = $true
        )]
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ParameterSetName = 'byLabelObject',
            ValueFromPipelinebyPropertyName = $true
        )]
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ParameterSetName = 'byLabelId',
            ValueFromPipelinebyPropertyName = $true
        )]
        [Alias("id")]
        $Object,

        # Key of the Space to be labeled
        [Parameter(
            Position=0,
            Mandatory=$true,
            ParameterSetName = 'onSpace'
        )]
        [string]$SpaceKey,

        # Label as text string
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName = 'onSpace'
        )]
        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName = 'byString'
        )]
        [string[]]$LabelName,


        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName = 'byLabelId'
        )]
        [long]$LabelId,

        [Parameter(
            Position=1,
            Mandatory=$true,
            ParameterSetName = 'byLabelObject'
        )]
        [Confluence.Label]$Label
    )

    Begin
    {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
    }

    Process
    {
        # Ensure ValueByPipeProperty is of a valid Type
        Write-Debug "$($MyInvocation.MyCommand.Name):: Value from Pipe $(if ($_ -ne $null) { "is of Type $($_.getType())" } else { "was not provided" })"
        if ($_ `
            -and $PsCmdlet.ParameterSetName -in @('byString', 'byLabelObject', 'byLabelId') `
            -and (!(
                $_ -is [Confluence.PageSummary] `
                -or $_ -is [Confluence.Page] `
                -or $_ -is [Confluence.BlogEntrySummary] `
                -or $_ -is [Confluence.BlogEntry] `
                -or $_ -is [Confluence.Attachment] `
                -or $_ -is [Confluence.ContentSummary] `
            ))
        )
        {
            Throw "Invalid object provided"
        }

        if ($PsCmdlet.ParameterSetName -in @('byString', 'byLabelObject', 'byLabelId') -and (!($Object.id)))
        {
            throw "Invalid object provided"
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "byString"
            {
                foreach ($labelAsString in $LabelName)
                {
                    Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding Label $LabelName to $($Object.id)"
                    if ($PSCmdlet.ShouldProcess("Object $($Object.id)","Add Label"))
                    {
                        Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addLabelByName" -Params ($token, $labelAsString, $Object.id) -OutputType "bool"
                    }
                }
            }
            "byLabelObject"
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding Label $($Label.name) to $($Object.id)"
                if ($PSCmdlet.ShouldProcess("Object $($Object.id)","Add Label"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addLabelByObject" -Params ($token, $Label, $Object.id) -OutputType "bool"
                }
            }
            "byLabelId"
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding Label $LabelId to $($Object.id)"
                if ($PSCmdlet.ShouldProcess("Object $($Object.id)","Add Label"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addLabelById" -Params ($token, $LabelId, $Object.id) -OutputType "bool"
                }
            }
            "onSpace"
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Adding Label $LabelName to Space $SpaceKey"
                if ($PSCmdlet.ShouldProcess("Space $SpaceKey","Add Label"))
                {
                    Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.addLabelByNameToSpace" -Params ($token, $LabelName, $SpaceKey) -OutputType "bool"
                }
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<#function Remove-ConfluenceLabel {
    #boolean removeLabelByName(String token, String labelName, long objectId) - Removes the given label from the object with the given ContentEntityObject ID.
    #boolean removeLabelById(String token, long labelId, long objectId) - Removes the label with the given ID from the object with the given ContentEntityObject ID.
    #boolean removeLabelByObject(String token, Label  labelObject, long objectId) - Removes the given label object from the object with the given ContentEntityObject ID.
    #boolean removeLabelByNameFromSpace(String token, String labelName, String spaceKey) - Removes the given label from the given spaceKey.
}#>
<# /Labels #>