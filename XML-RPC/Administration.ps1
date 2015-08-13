#Requires -Version 3.0
<#  Administration #>
function Export-ConfluenceSite {
    #String exportSite(String token, boolean exportAttachments) - exports a Confluence instance and returns a String holding the URL for the download. The boolean argument indicates whether or not attachments ought to be included in the export. This method respects the property admin.ui.allow.manual.backup.download (as described on this page in confluence documentation); if the property is not set, or is set to false, this method will not return the download link, but instead return a string containing the actual path on the server where the export is located.
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

        [switch]$includeAttachments
    )

    Process {
        return ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.exportSite" -Params ($token,$includeAttachments))
    }
}
function Get-ConfluenceClusterInformation {
    #ClusterInformation getClusterInformation(String token) - returns information about the cluster this node is part of.
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
        return ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getClusterInformation" -Params ($token))
    }
}
function Get-ConfluenceClusterNodeStatuses {
    #Vector getClusterNodeStatuses(String token) - returns a Vector of NodeStatus objects containing information about each node in the cluster.
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
        return ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.getClusterNodeStatuses" -Params ($token))
    }
}
function Test-ConfluencePluginEnabled {
    #boolean isPluginEnabled(String token, String pluginKey) - returns true if the plugin is installed and enabled, otherwise false.
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
        [Alias("Name")]
        [string]$Plugin
    )

    Begin {
        $out = @()
    }

    Process {
        foreach ($p in $Plugin) {
            $out += ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.isPluginEnabled" -Params ($token,$p))
        }
    }

    End {
        Write-Output $out
    }
}
<#function Install-ConfluencePlugin {
    #boolean installPlugin(String token, String pluginFileName, byte[] pluginData) - installs a plugin in Confluence. Returns false if the file is not a JAR or XML file. Throws an exception if the installation fails for another reason.
}#>
<# /Administration #>