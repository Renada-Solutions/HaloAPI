#Requires -Version 7
function Get-HaloAssetGroup {
    <#
        .SYNOPSIS
            Gets asset types from the Halo API.
        .DESCRIPTION
            Retrieves asset types from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Asset Type ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [int64]$AssetGroupID,
        # Paginate results
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('pageinate')]
        [switch]$Paginate,
        # Number of results per page.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_size')]
        [int32]$PageSize = $Script:HAPIDefaultPageSize,
        # Which page to return.
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('page_no')]
        [int32]$PageNo,
        # Which field to order results based on.
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Order,
        # Order results in descending order (respects the field choice in '-Order')
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$OrderDesc,
        # Filter by AssetGroups with an asset type group like your search
        [Parameter( ParameterSetName = 'Multi' )]
        [string]$Search,
        # Filter by Asset Types belonging to a particular Asset group
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('assetgroup_id')]
        [int64]$AssetGroupID,
        # Include inactive Asset Types in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [Switch]$includeinactive,
        # Include active Asset Types in the response
        [Parameter( ParameterSetName = 'Multi' )]
        [Switch]$includeactive,
        # Parameter to return the complete objects.
        [Parameter( ParameterSetName = 'Multi' )]
        [switch]$FullObjects,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Include the last action in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDiagramDetails,
        # Show all assets, including those that have been deleted.
        [Parameter( ParameterSetName = 'Multi')]
        [Switch]$ShowAll
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'AssetGroupid=' parameter by removing it from the set parameters.
    if ($AssetGroupID) {
        $Parameters.Remove('AssetGroupID') | Out-Null
    }
    # Similarly we don't want a `fullobjects=` parameter
    if ($FullObjects) {
        $Parameters.Remove('FullObjects') | Out-Null
    }
    try {
        if ($AssetGroupID) {
            Write-Verbose "Running in single-asset type mode because '-AssetGroupID' was provided."
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
            $Resource = "api/AssetGroup/$($AssetGroupID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = $Null
            }
        } else {
            Write-Verbose 'Running in multi-asset type mode'
            $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters -IsMulti
            $Resource = 'api/AssetGroup'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $False
                QSCollection = $QSCollection
                ResourceType = $Null
            }
        }    
        $AssetGroupResults = New-HaloGETRequest @RequestParams

        if ($FullObjects) {
            $AllAssetGroupResults = $AssetGroupResults | ForEach-Object {             
                Get-HaloAssetGroup -AssetGroupID $_.id
            }
            $AssetGroupResults = $AllAssetGroupResults
        }

        Return $AssetGroupResults
    } catch {
        New-HaloError -ErrorRecord $_
    }
}
