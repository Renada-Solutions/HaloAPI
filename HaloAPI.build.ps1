<#
    .SYNOPSIS
        Homotechsual portable module build script.
#>
[CmdletBinding()]
Param (
    [String]$Configuration = 'Development',
    [String[]]$Remotes = @('homotechsual'),
    [Switch]$Push,
    [Switch]$UpdateHelp,
    [System.IO.DirectoryInfo]$DocusaurusPath,
    [Switch]$ForceUpdateCategoryFiles,
    [Switch]$CopyModuleFiles,
    [Switch]$Test,
    [Switch]$UpdateManifest,
    [Switch]$PublishModule,
    [Switch]$Clean
)

$ModuleName = 'HaloAPI'

# Install required modules
if (-Not(Get-Module -Name 'Install-RequiredModule')) {
    Install-Script -Name 'Install-RequiredModule' -Force -Scope CurrentUser
}
Install-RequiredModule -RequiredModulesFile ('{0}\RequiredModules.psd1' -f $PSScriptRoot) -Scope CurrentUser -TrustRegisteredRepositories -Import -Quiet
Import-Module 'R:\Development\Docusaurus.PowerShell\Output\Alt3.Docusaurus.PowerShell\1.0.34\Alt3.Docusaurus.PowerShell.psd1' -Force

# Use strict mode when building.
Set-StrictMode -Version Latest

if ($Push) {
    # Push to remote repositories.
    foreach ($Remote in $Remotes) {
        Start-Process -FilePath 'git' -ArgumentList @('push', $Remote) -Wait -NoNewWindow
        Start-Process -FilePath 'git' -ArgumentList @('push', $Remote, '--tags') -Wait -NoNewWindow
    }
}

# Update the PowerShell Module Help Files.
## Requires PlatyPS, Pester, PSScriptAnalyzer and Alt3.Docusaurus.PowerShell installed.

if ($UpdateHelp) {
    $DocsFolderPath = Join-Path -Path $DocusaurusPath -ChildPath 'docs' -AdditionalChildPath $Script:ModuleName
    if (-Not(Test-Path -Path $DocsFolderPath)) {
        New-Item -Path $DocsFolderPath -ItemType Directory | Out-Null
    }
    $MarkdownHeader = @'
:::powershell[Generated Cmdlet Help]
This page has been generated from the {0} PowerShell module source. To make changes please edit the appropriate PowerShell source file.
:::
'@ -f $Script:ModuleName
    $ExcludeFiles = Get-ChildItem -Path "$($PSScriptRoot)\Private" -Filter '*.ps1' -Recurse | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.FullName) }
    $NewDocusaurusHelpParams = @{
        Module = ('.\{0}.psd1' -f $Script:ModuleName)
        DocsFolder = $DocsFolderPath
        Exclude = $ExcludeFiles
        Sidebar = 'commandlets'
        # MetaDescription = 'Generated cmdlet help for the %1 commandlet.'
        GroupByVerb = $true
        UseDescriptionFromHelp = $true
        NoPlaceHolderExamples = $true
        UseCustomShortTitles = $false
        PrependMarkdown = $MarkdownHeader
        RemoveParameters = @('-ProgressAction', '-FakeParam')
    }
    New-DocusaurusHelp @NewDocusaurusHelpParams | Out-Null
    $CommandletDocsFolder = Join-Path -Path $DocusaurusPath -ChildPath 'docs' -AdditionalChildPath @($ModuleName, 'commandlets')
    $VerbFolders = Get-ChildItem -Path $CommandletDocsFolder -Directory
    $CategoryFileBase = @{
        position = 1
        collapsible = $true
        collapsed = $true
        link = @{
            type = 'generated-index'
        }
        customProps = @{
            description = ''
        }
    }
    foreach ($VerbFolder in $VerbFolders) {
        $HasCategoryFile = Get-ChildItem -Path $VerbFolder.FullName -Filter '_category_.*' -File -ErrorAction SilentlyContinue
        $CategoryFilePath = Join-Path -Path $VerbFolder.FullName -ChildPath '_category_.json'
        switch ($VerbFolder.Name) {
            'Connect' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Connect to Services'
                $CategoryFile.position = 0.1
                $CategoryFile.className = 'category-connect'
                $CategoryFile.link.title = 'Connect to Services'
                $CategoryFile.customProps.description = 'This category contains commands for connecting to services, retrieving and storing credentials and managing connections.'
            }
            'Find' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Find Information'
                $CategoryFile.position = 0.2
                $CategoryFile.className = 'category-find'
                $CategoryFile.link.title = 'Find Information'
                $CategoryFile.customProps.description = 'This category contains commands for finding information from services, this may include data, objects, settings and more.'
            }
            'Get' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Retrieve Information'
                $CategoryFile.position = 0.3
                $CategoryFile.className = 'category-get'
                $CategoryFile.link.title = 'Retrieve Information'
                $CategoryFile.customProps.description = 'This category contains commands for retrieving information from services, this may include data, objects, settings and more.'
            }
            'Invoke' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Invoke Actions'
                $CategoryFile.position = 0.4
                $CategoryFile.className = 'category-invoke'
                $CategoryFile.link.title = 'Invoke Actions'
                $CategoryFile.customProps.description = 'This category contains commands for invoking actions, this may include running scripts, executing commands and more. For API modules, this category will contain commands for sending arbitrary requests to the API - that is requests not covered by existing commands.'
            }
            'New' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Create Data'
                $CategoryFile.position = 0.5
                $CategoryFile.className = 'category-new'
                $CategoryFile.link.title = 'Create Data'
                $CategoryFile.customProps.description = 'This category contains commands for creating data, objects, settings and more.'
            }
            'Remove' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Remove Data'
                $CategoryFile.position = 0.6
                $CategoryFile.className = 'category-remove'
                $CategoryFile.link.title = 'Remove Data'
                $CategoryFile.customProps.description = 'This category contains commands for removing data, objects, settings and more.'
            }
            'Reset' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Reset State'
                $CategoryFile.position = 0.6
                $CategoryFile.className = 'category-reset'
                $CategoryFile.link.title = 'Reset State'
                $CategoryFile.customProps.description = 'This category contains commands for resetting state, this may include resetting settings, connections and more.'
            }
            'Restart' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Restart Services'
                $CategoryFile.position = 0.6
                $CategoryFile.className = 'category-restart'
                $CategoryFile.link.title = 'Restart Services'
                $CategoryFile.customProps.description = 'This category contains commands for restarting services, this may include restarting services, processes and more.'
            }
            'Restore' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Restore Data'
                $CategoryFile.position = 0.6
                $CategoryFile.className = 'category-restore'
                $CategoryFile.link.title = 'Restore Data'
                $CategoryFile.customProps.description = 'This category contains commands for restoring data, objects, settings and more. These commands will primarily be used for restoring data to a previous state.'
            }
            'Set' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Update Data (Set)'
                $CategoryFile.position = 0.4
                $CategoryFile.className = 'category-set'
                $CategoryFile.link.title = 'Update Data (Set)'
                $CategoryFile.customProps.description = 'This category contains commands for updating data, objects, settings and more. This category will overlap with the Update category.'
            }
            'Update' {
                $CategoryFile = $CategoryFileBase
                $CategoryFile.label = 'Update Data (Update)'
                $CategoryFile.position = 0.4
                $CategoryFile.className = 'category-update'
                $CategoryFile.link.title = 'Update Data (Update)'
                $CategoryFile.customProps.description = 'This category contains commands for updating data, objects, settings and more. This category will overlap with the Set category.'
            }
        }
        if (-Not($HasCategoryFile)) {
            $CategoryFile | ConvertTo-Json | Out-File -FilePath $CategoryFilePath -Force
        } else {
            if (-Not($ForceUpdateCategoryFiles)) {
                Write-Warning -Message ('Category file already exists in "{0}" verb folder. Use the ForceUpdateCategoryFiles switch to overwrite existing category files.' -f $VerbFolder.Name)
            } else {
                Set-Content -Path $CategoryFilePath -Value ($CategoryFile | ConvertTo-Json) -Force
            }
        }
    }
}

# Copy PowerShell Module files to output folder for release on PSGallery
if ($CopyModuleFiles) {
    # Copy Module Files to Output Folder
    if (-not (Test-Path "$($PSScriptRoot)\Output\$ModuleName")) {
        New-Item -Path "$($PSScriptRoot)\Output\$ModuleName" -ItemType Directory | Out-Null
    }
    if (Test-Path -Path "$($PSScriptRoot)\Classes\") {
        Copy-Item -Path "$($PSScriptRoot)\Classes\" -Filter *.* -Recurse -Destination "$($PSScriptRoot)\Output\$ModuleName" -Force
    }
    if (Test-Path -Path "$($PSScriptRoot)\Data\") {
        Copy-Item -Path "$($PSScriptRoot)\Data\" -Filter *.* -Recurse -Destination "$($PSScriptRoot)\Output\$ModuleName" -Force
    }
    Copy-Item -Path "$($PSScriptRoot)\Private\" -Filter *.* -Recurse -Destination "$($PSScriptRoot)\Output\$ModuleName" -Force
    Copy-Item -Path "$($PSScriptRoot)\Public\" -Filter *.* -Recurse -Destination "$($PSScriptRoot)\Output\$ModuleName" -Force

    # Copy module, manifest and scaffold files
    Copy-Item -Path @(
        "$($PSScriptRoot)\LICENSE.md"
        "$($PSScriptRoot)\CHANGELOG.md"
        "$($PSScriptRoot)\README.md"
        "$($PSScriptRoot)\$ModuleName.psd1"
        "$($PSScriptRoot)\$ModuleName.psm1"
    ) -Destination "$($PSScriptRoot)\Output\$ModuleName" -Force
}

# Run all Pester tests in folder .\Tests
if ($Test) {
    $Result = Invoke-Pester "$($PSScriptRoot)\Tests" -PassThru
    if ($Result.FailedCount -gt 0) {
        throw 'Pester tests failed'
    }
}

# Update the Module Manifest file with info from the Changelog.
if ($UpdateManifest) {
    # Import PlatyPS. Needed for parsing the versions in the Changelog.
    Import-Module -Name PlatyPS

    # Find Latest Version in Change log.
    $CHANGELOG = Get-Content -Path "$($PSScriptRoot)\CHANGELOG.md" -Raw
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$ReleaseRegex = '#{2}.*\d*\.\d*\.\d*$/m'
    $Releases = ($ReleaseRegex.Matches($MarkdownObject.ParseString($CHANGELOG).Children.Spans.Text))
    [regex]$VersionRegex = '\d*\.\d*\.\d*'
    $Versions = $Regex.Matches($MarkdownObject.ParseString($CHANGELOG).Children.Spans.Text) | ForEach-Object { $_.Value }
    $ChangeLogVersion = ($Versions | Measure-Object -Maximum).Maximum

    $ManifestPath = "$($PSScriptRoot)\$ModuleName.psd1"

    # Start by importing the manifest to determine the version, then add 1 to the Build
    $Manifest = Test-ModuleManifest -Path $ManifestPath
    [System.Version]$Version = $Manifest.Version

    if ($ChangeLogVersion -eq $Version) {
        Throw 'No new version found in CHANGELOG.md'
    }

    Write-Output -InputObject ("Current Module Version: $($Version)")
    Write-Output -InputObject ("New Module version: $($ChangeLogVersion)")

    # Update Manifest file with Release Notes
    $CHANGELOG = Get-Content -Path "$($PSScriptRoot)\CHANGELOG.md"
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    $ReleaseNotes = ((($MarkdownObject.ParseString($CHANGELOG).Children.Spans.Text) -Match '#{2}.*\d*\.\d*\.\d') -Split ' - ')[1]

    # Update Module with new version
    Update-ModuleManifest -ModuleVersion $ChangeLogVersion -Path "$($PSScriptRoot)\$ModuleName.psd1" -ReleaseNotes $ReleaseNotes
}

# Publish Module to PowerShell Gallery
if ($PublishModule -and $Configuration -eq 'Production') {
    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path = ("$($PSScriptRoot)\Output\$ModuleName")
            NuGetApiKey = $ENV:TF_BUILD ? $ENV:PSGalleryAPIKey : (Get-AzKeyVaultSecret -VaultName $ENV:PSGalleryVault -Name $ENV:PSGallerySecret -AsPlainText) # If running in Azure DevOps, use the Environment Variable, otherwise use the Key Vault
            ErrorAction = 'Stop'
        }
        $ManifestPath = "$($PSScriptRoot)\$ModuleName.psd1"
        $Manifest = Test-ModuleManifest -Path $ManifestPath
        [System.Version]$Version = $Manifest.Version
        Publish-Module @params
        Write-Output -InputObject ("$ModuleName PowerShell Module version $($Version) published to the PowerShell Gallery")
    } Catch {
        Throw $_
    }
}

# Clean up Output folder
if ($Clean) {
    # Clean output folder
    if ((Test-Path "$($PSScriptRoot)\Output")) {
        Remove-Item -Path "$($PSScriptRoot)\Output" -Recurse -Force
    }
}