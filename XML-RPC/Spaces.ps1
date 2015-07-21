#Requires -Version 3.0
<#  Spaces #>
function Get-Spaces {
    #Vector<SpaceSummary> getSpaces(String token) - returns all the summaries that the current user can see.
    #Space getSpace(String token, String spaceKey) - returns a single Space. If the spaceKey does not exist: earlier versions of Confluence will throw an Exception. Later versions (3.0+) will return a null object.
    #String getSpaceStatus(String token, String spaceKey) - returns the status of a space, either CURRENT or ARCHIVED.
    #Vector getSpacesWithLabel(String token, String labelName) - Returns an array of spaces that have been labelled with labelName.
    #Vector getSpacesContainingContentWithLabel(String token, String labelName) - Returns all spaces that have content labelled with labelName.
    [CmdletBinding(DefaultParameterSetName="getSpaces")]
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
            ParameterSetName="getSpace"
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        [Parameter(
            ParameterSetName="getSpace"
        )]
        [switch]$status,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="getSpacesWithLabel"
        )]
        [string]$Label,

        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="getSpacesWithLabel"
        )]
        [switch]$ContainingContent
    )

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "getSpaces" {
                return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpaces" -Params ($token))
            }
            "getSpace" {
                if ($status) {
                    return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpaceStatus" -Params ($token,$SpaceKey))
                } else {
                    return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpace" -Params ($token,$SpaceKey))
                }
                break
            }
            "getSpacesWithLabel" {
                if ($ContainingContent) {
                    return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpacesContainingContentWithLabel" -Params ($token,$Label))
                } Write-Output {
                    return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.getSpacesWithLabel" -Params ($token,$Label))
                }
                break
            }
        }
    }
}
function Export-Space {
    #String exportSpace(String token, String spaceKey, String exportType) - exports a space and returns a String holding the URL for the download. The export type argument indicates whether or not to export in XML or HTML format - use "TYPE_XML" or "TYPE_HTML" respectively. (Note: In Confluence 3.0, the remote API specification for PDF exports changed. You can no longer use this 'exportSpace' method to export a space to PDF. Please refer to Remote API Specification for PDF Export for current remote API details on this feature.)
    #String exportSpace(String token, String spaceKey, String exportType, boolean exportAll) - exports a space and returns a String holding the URL for the download. In the version 2 API you can set exportAll to true to export the entire contents of the space.
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
            ValueFromPipeline=$true
        )]
        [Alias("Space")]
        [string[]]$SpaceKey,

        [Parameter(
            Position=3
        )]
        [ValidateSet("XML","HTML")]
        [Alias("Type","Format")]
        [string]$exportType = "XML",
        

        [Alias("All")]
        [switch]$exportAll   
    )

    Begin {
        $out = @()
        $exportType = $exportType.insert(0,"TYPE_")
    }

    Process {
        $out += ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.exportSpace" -Params ($token,$SpaceKey, $exportType, $exportAll))
    }

    End {
        Write-Output $out
    }
}
function Export-SpaceToPDF {
    #public String exportSpace(String token, String spaceKey) - exports the entire space as a PDF. Returns a url to download the exported PDF. Depending on how you have Confluence set up, this URL may require you to authenticate with Confluence. Note that this will be normal Confluence authentication, not the token based authentication that the web service uses.
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
            ValueFromPipeline=$true
        )]
        [Alias("Space")]
        [string[]]$SpaceKey 
    )

    Begin {
        $out = @()
    }

    Process {
        $out += ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.pdfexport" -Params ($token,$SpaceKey))
    }

    End {
        Write-Output $out
    }
}
function Add-Space {
    #Space addSpace(String token, Space space) - create a new space, passing in name, key and description.
    #Space addPersonalSpace(String token, Space personalSpace, String userName) - add a new space as a personal space.
    [CmdletBinding(DefaultParameterSetName="addSpace")]
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
            ParameterSetName="addSpace"
        )]
        $Space,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="addPersonalSpace"
        )]
        $personalSpace,
        
        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="addPersonalSpace"
        )]
        [Alias("User")]
        [switch]$userName   
    )

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "addSpace" {
                return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.addSpace" -Params ($token,$SpaceKey))
            }
            "addPersonalSpace" {
                return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.addPersonalSpace" -Params ($token,$personalSpace, $userName))
            }
        }
    }
}
function Remove-Space {
    #Boolean removeSpace(String token, String spaceKey) - remove a space completely.
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
            ValueFromPipeline=$true
        )]
        [Alias("Space")]
        [string]$SpaceKey
    )

    Process {
        if ($PSCmdlet.ShouldProcess($SpaceKey)) {
            return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.removeSpace" -Params ($token,$SpaceKey))
        }
    }
}
function ConvertTo-PersonalSpace {
    #boolean convertToPersonalSpace(String token, String userName, String spaceKey, String newSpaceName, boolean updateLinks) - convert an existing space to a personal space.
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
        [Alias("User")]
        [switch]$userName,

        [Parameter(
            Position=3,
            Mandatory=$true
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        [Parameter(
            Position=3,
            Mandatory=$true
        )]
        [Alias("NewName")]
        [string]$newSpaceName,

        [switch]$updateLinks
    )

    Process {
        if ($PSCmdlet.ShouldProcess($SpaceKey)) {
            return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.convertToPersonalSpace" -Params ($token,$userName, $spaceKey,$newSpaceName,$updateLinks))
        }
    }
}
function Set-Space {
    #Space storeSpace(String token, Space space) - create a new space if passing in a name, key and description or update the properties of an existing space. Only name, homepage or space group can be changed.
    ##Boolean setSpaceStatus(String token, String spaceKey, String status) - set a new status for a space. Valid values for status are "CURRENT" and "ARCHIVED".
    [CmdletBinding(DefaultParameterSetName="storeSpace")]
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
            ParameterSetName="storeSpace"
        )]
        $Space,

        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="setSpaceStatus"
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="setSpaceStatus"
        )]
        [ValidateSet("CURRENT","ARCHIVED")]
        [string]$status
    )

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "storeSpace" {
                return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.storeSpace" -Params ($token,$Space))
            }
            "setSpaceStatus" {
                return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.setSpaceStatus" -Params ($token,$SpaceKey,$status))
            }
        }
    }
}
<#function Import-ConfluenceSpace {
    #boolean importSpace(String token, byte[] zippedImportData) - import a space into Confluence. Note that this uses a lot of memory - about 4 times the size of the upload. The data provided should be a zipped XML backup, the same as exported by Confluence.
}#>
function Get-TrashContent {
    #ContentSummaries getTrashContents(String token, String spaceKey, int offset, int count) - get the contents of the trash for the given space, starting at 'offset' and returning at most 'count' items.
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
        $Space
    )

    Process {
        if ($PSCmdlet.ShouldProcess($SpaceKey)) {
            return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.storeSpace" -Params ($token,$Space))
        }
    }
}
function Remove-TrashItem {
    #boolean purgeFromTrash(String token, String spaceKey, long contentId) - remove some content from the trash in the given space, deleting it permanently.
    #boolean emptyTrash(String token, String spaceKey) - remove all content from the trash in the given space, deleting them permanently.
    [CmdletBinding(DefaultParameterSetName="purgeFromTrash")]
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
            ParameterSetName="purgeFromTrash"
        )]
        [Parameter(
            Position=2,
            Mandatory=$true,
            ParameterSetName="emptyTrash"
        )]
        [Alias("Space")]
        [string]$SpaceKey,

        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="purgeFromTrash"
        )]
        [long]$contentId,

        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="emptyTrash"
        )]
        [Alias("All")]
        [switch]$RemoveAll
    )

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "purgeFromTrash" {
                if ($PSCmdlet.ShouldProcess($SpaceKey)) {
                    return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.storeSpace" -Params ($token,$Space))
                }
                break
            }
            "emptyTrash" {
                if ($RemoveAll) {
                    if ($PSCmdlet.ShouldProcess($SpaceKey)) {
                        return ConvertFrom-Xml (Perform-ConfluenceCall -Url $apiURi -MethodName "confluence2.storeSpace" -Params ($token,$Space))
                    }
                }
                break
            }
        }
    }
}
<# /Spaces #>