
# Simple divider half screen width size
function hr {"`u{2014}"*(0 -bor [Console]::WindowWidth / 2)}

# Calculate sizes of ol subfolders
filter Get-SubfolderSizes {
    [CmdletBinding()]
    param (
        # Target path of parent folder in wich the immediate descendants' sizes need to be calculated
        [Parameter(position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $Path = $PWD,

        # Include Hidden and System folders
        [Switch] $Force = $False,

        # ExtraFields – include FullName of dirs and calculated human readable lingth as Size field
        [Switch] $ExtraFields,

        # Directories only
        [Switch] $DirsOnly,

        # Width of Size field to align within table view
        [UInt] $szWidth = 16 # to get proper length use doubled length because of color data
    )

    Get-ChildItem $Path -Directory:$DirsOnly -Force:$Force |
        ForEach-Object {
            $len = (Get-FolderSize $_ -Force:$Force)
            $rec = New-Object PSObject

            Add-Member -InputObject $rec -MemberType NoteProperty -Name "Name" -Value $_.Name
            if ($ExtraFields) {
                # Add-Member -InputObject $rec -MemberType NoteProperty -Name "FullName" -Value $_.FullName
                Add-Member -InputObject $rec -MemberType NoteProperty -Name "Date" -Value $_.LastWriteTime.ToShortDateString()
                Add-Member -InputObject $rec -MemberType NoteProperty -Name "Time" -Value ('{0,8}' -f ($_.LastWriteTime.ToLongTimeString()))
                Add-Member -InputObject $rec -MemberType NoteProperty -Name "Size" -Value ("{0,$szWidth}" -f (ShortSize $len))
            }
            Add-Member -InputObject $rec -MemberType NoteProperty -Name "Length" -Value $len

            $rec
        }
}

# Calc and show sizes in subfolders
function Show-FolderSizes {
    [CmdletBinding()]
    param (
        [Parameter(position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $Path = $PWD,

        [Switch] $DirsOnly,
        [Switch] $Force = $False,
        [Switch] $AscendingSort = $False,
        [Switch] $SortBySize = $False -or $AscendingSort
    )

    process {
        "`e[33m$(Resolve-Path $Path)`e[0m"
        if ($SortBySize) {
            Get-SubfolderSizes $Path -ExtraFields -DirsOnly:$DirsOnly -Force:$Force | Sort-Object Length -Descending:(!$AscendingSort) | Select-Object Name,Date,Time,Size
        } else {
            Get-SubfolderSizes $Path -ExtraFields -DirsOnly:$DirsOnly -Force:$Force | Select-Object Name,Date,Time,Size
        }
        hr;
        "Total size: `e[33m{0}`e[0m" -f (ShortSize (Get-FolderSize $Path -Force:$Force))
    }
}
