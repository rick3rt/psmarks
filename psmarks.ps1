function _PSMarks_Initalize() {
    $script:_marksPath = Get-ProfileDataFile bookmarks "PSMarks"
    $script:_knownBookmarks = Import-PSMarkKeys
}

function Get-ProfileDataFile {
    param (
        [string]$file,
        [string]$moduleName = $null
    )
    return Join-Path (Get-ProfileDir $moduleName) $file
    
} 

function Get-ProfileDir {
    param (
        [string]$moduleName = $null,
        [string]$profileFolder = $null
    )
    
    $profileDir = $ENV:AppData

    if ( Test-Empty $moduleName ) {

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.psm1') ) {
            $moduleName = $script:MyInvocation.MyCommand.Name
        }

        if ( $script:MyInvocation.MyCommand.Name.EndsWith('.ps1') ) {
            $modulePath = Split-Path -Path $script:MyInvocation.MyCommand.Path
            $moduleName = Split-Path -Path $modulePath -Leaf
        }
    }

    if ( Test-Empty $moduleName ) {
        throw "Unable to read module name."             
    }
    
    $scriptProfile = Merge-Path $profileDir '.ps1' 'ScriptData' $moduleName

    if ( Test-Empty $profileFolder) {
        $scriptProfile = Merge-Path $profileDir '.ps1' 'ScriptData' $moduleName $profileFolder

    }
    if ( ! (Test-Path $scriptProfile -PathType Container )) { 
        New-Item -Path $scriptProfile  -ItemType 'Directory'
    }

    return $scriptProfile
}


function Test-Empty {
    param (
        [Parameter(Position = 0)]
        [string]$string
    )
    return [string]::IsNullOrWhitespace($string) 
}

function Merge-Path {
    param (
        [string]$baseDir,
        [string]$path
    )
    $allArgs = $PsBoundParameters.Values + $args

    [IO.Path]::Combine([string[]]$allArgs)
}
# ==============================================================================

function Import-PSMarks {
    $_marks = @{ }
    if (test-path "$script:_marksPath" -PathType leaf) {
        Import-Csv  $script:_marksPath | ForEach-Object { $_marks[$_.key] = $_.value }
    }
    return $_marks

}

function Import-PSMarkKeys {
    $_marks = Import-PSMarks
    # get only keys from marks 
    # Write-Output $_marks
    # Write-Output $_marks.GetType()
    return $_marks.Keys
}

function Save-PSMarks {
    param (
        $marks
    )    
    $marks.getenumerator() | export-csv "$_marksPath" -notype
    $script:_knownBookmarks = Import-PSMarkKeys # and update the known keys 
}


function Add-PSMark () {
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Bookmark")]
        $BookmarkName,
        [Parameter(Position = 1, ValueFromPipeline = $True)]
        [Alias("Path")]
        [string]$dir = $null
    )

    $dir = (Get-Location).Path # get current dir 
    $_marks = Import-PSMarks

    if ( $_marks.ContainsKey("$BookmarkName") ) {
        Write-Output( "Folder bookmark ''$BookmarkName'' already exist")
        return 
    }

    $_marks["$BookmarkName"] = $dir
    Save-PSMarks $_marks
    Write-Output ("Location '{1}' saved to bookmark '{0}'" -f $BookmarkName, $dir) 	
}


function Remove-PSMark () {
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Bookmark")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                return @($_marks) -like "$WordToComplete*"
            }
        )]
        $BookmarkName
    )

    $_marks = Import-PSMarks

    $_marks.Remove($BookmarkName)
    Save-PSMarks $_marks
    Write-Output ("Location '{0}' removed from bookmarks" -f $BookmarkName) 	
}


# List all available psmarks
function List-PSMarks {
    $_marks = Import-PSMarks
    $_marks | Format-Table -AutoSize
}

function Get-PSMark {
    Param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Bookmark")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                return @($_marks) -like "$WordToComplete*"
            }
        )]
        $BookmarkName
    )
    $_marks = Import-PSMarks
    Write-Output $_marks["$BookmarkName"]
}

function Open-PSMark {
    Param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [Alias("Bookmark")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                return @($_marks) -like "$WordToComplete*"
            }
        )]
        $BookmarkName
    )
    $_marks = Import-PSMarks
    Set-Location $_marks["$BookmarkName"]
}


# autocompletion with tab
Register-ArgumentCompleter -CommandName 'Open-PSMark' -ParameterName 'BookmarkName' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    
    if ($wordToComplete) {
        # Filter options matching the entered text
        $filteredOptions = $Script:_knownBookmarks -like "$wordToComplete*"
        $filteredOptions
    }
    else {
        # Display all options if no text is entered
        $Script:_knownBookmarks
    }
}

Register-ArgumentCompleter -CommandName 'Remove-PSMark' -ParameterName 'BookmarkName' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    
    if ($wordToComplete) {
        # Filter options matching the entered text
        $filteredOptions = $Script:_knownBookmarks -like "$wordToComplete*"
        $filteredOptions
    }
    else {
        # Display all options if no text is entered
        $Script:_knownBookmarks
    }
}

Register-ArgumentCompleter -CommandName 'Get-PSMark' -ParameterName 'BookmarkName' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    
    if ($wordToComplete) {
        # Filter options matching the entered text
        $filteredOptions = $Script:_knownBookmarks -like "$wordToComplete*"
        $filteredOptions
    }
    else {
        # Display all options if no text is entered
        $Script:_knownBookmarks
    }
}


# ==============================================================================
# initialize bookmark file location
_PSMarks_Initalize

# ==============================================================================
# Aliases
Set-Alias l List-PSMarks -Scope Global
Set-Alias g Open-PSMark -Scope Global
Set-Alias p Get-PSMark -Scope Global
Set-Alias s Add-PSMark -Scope Global
Set-Alias d Remove-PSMark -Scope Global
