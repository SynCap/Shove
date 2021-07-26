<#
.description

	Following functions included into Shove pack for independancy of Shove itself. Same time
	this functions is part of Evereday ps collection -- <https://github.com/syncap/ps-everyday>
#>

# Fast Console output
function print([Parameter(ValueFromPipeline)][String[]]$Params){[System.Console]::Write($Params -join '')}
function println([Parameter(ValueFromPipeline)][String[]]$Params){[System.Console]::WriteLine($Params -join '')}

# Simple divider half screen width size
function hr {"`u{2014}"*(0 -bor [Console]::WindowWidth / 2)}

# Calculate sizes of ol subfolders
filter Get-SubfolderSizes {
	[CmdletBinding()]
	param (
		# Target path of parent folder in wich the immediate descendants sizes are calculated
		[Parameter(position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
		[string] $Path = $PWD,

		# Include Hidden and System folders
		[Switch] $Force,
		# ExtraFields – FullName of dirs and calculated human readable lingth as Size field
		[Switch] $ExtraFields,
		# Directories only
		[Switch] $DirsOnly,
		# Width of Size field to align with table view
		[UInt] $szWidth = 16 # to get proper length use doubled length because of color data
	)

	# function hlm ($s) {return $s.Insert($s.Length - 1, "`e[96m") + "`e[0m"}

	Get-ChildItem $Path -Directory:$DirsOnly -Force:$Force |
		ForEach-Object {
			$len = (Get-FolderSize $_ -Force:$Force)
			$rec = New-Object PSObject

			Add-Member -InputObject $rec -MemberType NoteProperty -Name "Name" -Value $_.Name
			if ($ExtraFields) {
				Add-Member -InputObject $rec -MemberType NoteProperty -Name "RelativeName" -Value (Resolve-Path -Relative $_.FullName)
				Add-Member -InputObject $rec -MemberType NoteProperty -Name "Date" -Value $_.LastWriteTime.ToShortDateString()
				Add-Member -InputObject $rec -MemberType NoteProperty -Name "Time" -Value ('{0,8}' -f ($_.LastWriteTime.ToLongTimeString()))
				Add-Member -InputObject $rec -MemberType NoteProperty -Name "Size" -Value ("{0,$szWidth}" -f (ShortSize $len))
			}
			Add-Member -InputObject $rec -MemberType NoteProperty -Name "Length" -Value $len

			$rec
		}
}

# Calc and show subfolders' sizes
filter Show-FolderSizes {
	[CmdletBinding()]
	param (
		[Parameter(position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
		[string] $Path = $PWD,

		[Switch] $DirsOnly,
		[Switch] $Force,
		[Switch] $DescendingSort,
		[Switch] $SortBySize
	)

	print "`e[33m$($Path)`e[0m"
	if ($SortBySize) {
		Get-SubfolderSizes $Path -ExtraFields -DirsOnly:$DirsOnly -Force:$Force |
			Sort-Object Length -Descending:($DescendingSort) |
				Select-Object Name,Date,Time,Size
	} else {
		Get-SubfolderSizes $Path -ExtraFields -DirsOnly:$DirsOnly -Force:$Force |
			Sort-Object RelativeName,Name -Descending:($DescendingSort) |
				Select-Object RelativeName,Date,Time,Size
	}
	hr;
	("Total size: `e[33m{0}`e[0m" -f (ShortSize (Get-FolderSize $Path -Force:$Force)))
}
