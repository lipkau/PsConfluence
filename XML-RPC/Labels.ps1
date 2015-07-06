#Requires -Version 3.0
<#  Labels #>
function Get-Labels {
    #Vector getLabelsById(String token, long objectId) - Returns all labels for the given ContentEntityObject ID
    #Vector getMostPopularLabels(String token, int maxCount) - Returns the most popular labels for the Confluence instance, with a specified maximum number.
    #Vector getMostPopularLabelsInSpace(String token, String spaceKey, int maxCount) - Returns the most popular labels for the given spaceKey, with a specified maximum number of results.
    #Vector getRecentlyUsedLabels(String token, int maxResults) - Returns the recently used labels for the Confluence instance, with a specified maximum number of results.
    #Vector getRecentlyUsedLabelsInSpace(String token, String spaceKey, int maxResults) - Returns the recently used labels for the given spaceKey, with a specified maximum number of results.
    #TODO: Vector getLabelsByDetail(String token, String labelName, String namespace, String spaceKey, String owner) - Retrieves the labels matching the given labelName, namespace, spaceKey or owner.
    [CmdletBinding(DefaultParameterSetName="getLabelsById")]
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
            ValueFromPipeline=$true,
            ParameterSetName="getLabelsById"
        )]
        [long]$objectId,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getMostPopularLabelsInSpace"
        )]
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getRecentlyUsedLabelsInSpace"
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getMostPopularLabels"
        )]
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getRecentlyUsedLabels"
        )]
        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="getMostPopularLabelsInSpace"
        )]
        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="getRecentlyUsedLabelsInSpace"
        )]
        [int]$maxCount
    )

    Begin {
        $o = @()
    }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "getLabelsById" {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getLabelsById" -Params ($token,$objectId)) {
                    $o += ConvertFrom-Xml $r
                }
                break
            }
            "getMostPopularLabelsInSpace" {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getMostPopularLabelsInSpace" -Params ($token,$SpaceKey,$maxCount)) {
                    $o += ConvertFrom-Xml $r
                }
                break
            }
            "getRecentlyUsedLabelsInSpace" {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getRecentlyUsedLabelsInSpace" -Params ($token,$SpaceKey,$maxCount)) {
                    $o += ConvertFrom-Xml $r
                }
                break
            }
            "getMostPopularLabels" {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getMostPopularLabels" -Params ($token,$maxCount)) {
                    $o += ConvertFrom-Xml $r
                }
                break
            }
            "getRecentlyUsedLabels" {
                if ($r = Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getRecentlyUsedLabels" -Params ($token,$maxCount)) {
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
#getSpacesWithLabel is in <Space/>
<#function Get-RelatedLabel {
    #Vector getRelatedLabels(String token, String labelName, int maxResults) - Returns the labels related to the given label name, with a specified maximum number of results.
    #Vector getRelatedLabelsInSpace(String token, String labelName, String spaceKey, int maxResults) - Returns the labels related to the given label name for the given spaceKey, with a specified maximum number of results.
}#>
<#function Get-LabelContent {
    #Vector getLabelContentById(String token, long labelId) - Returns the content for a given label ID
    #Vector getLabelContentByName(String token, String labelName) - Returns the content for a given label name.
    #Vector getLabelContentByObject(String token, Label labelObject) - Returns the content for a given Label  object.
}#>
#getSpacesContainingContentWithLabel os om <Space/>
<#function Add-eLabel {
    #boolean addLabelByName(String token, String labelName, long objectId) - Adds label(s) to the object with the given ContentEntityObject ID. For multiple labels, labelName should be in the form of a space-separated or comma-separated string.
    #boolean addLabelById(String token, long labelId, long objectId) - Adds a label with the given ID to the object with the given ContentEntityObject ID.
    #boolean addLabelByObject(String token, Label  labelObject, long objectId) - Adds the given label object to the object with the given ContentEntityObject ID.
    #boolean addLabelByNameToSpace(String token, String labelName, String spaceKey) - Adds a label to description of a space with the given space key. Prefix labelName with "team:" in order to make it a space category.
}#>
<#function Remove-Label {
    #boolean removeLabelByName(String token, String labelName, long objectId) - Removes the given label from the object with the given ContentEntityObject ID.
    #boolean removeLabelById(String token, long labelId, long objectId) - Removes the label with the given ID from the object with the given ContentEntityObject ID.
    #boolean removeLabelByObject(String token, Label  labelObject, long objectId) - Removes the given label object from the object with the given ContentEntityObject ID.
    #boolean removeLabelByNameFromSpace(String token, String labelName, String spaceKey) - Removes the given label from the given spaceKey.
}#>
<# /Labels #>