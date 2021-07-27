<#
	.synopsis
		Group files from specified folder by bunch size into subfolders

	.description
		New subfolders created and each subfolder will contain approx `MaxSubFolderSize` in sum.

		*_NOTE_* that you must specify max size in bytes or use `Kb/Mb/GB/..` notation.

		Numeration of files starts from 01. You may restart numeration in each subfolder with
		use `SubfolderCounters` switch.

		*_NOTE_* before you'll actually Move/Copy files try to use `WhatIf` switch to viw
		how the Shove will distribute and rename your files

		Also you can gather files from subfolders using `Recurse` switch even you had used
		the Shove earlier

	.example

		-- Example 1 --

		# Copy files by bunches about 80mb into subfolders
		# and rename files by ordinal number
		# with restarting numeration in each subfolder

		`shove -Max 315mb -N -S -C`

		-- Example 2 --

		# Show how SHOVE will MOVE files by banches about 100mb
		# -WhatIf can help to view how files will be distributed
		# by subfolders and tells about additional actions

		`shove . *.mp3 -r -max 205mb -N -K -WhatIf`

		# OR

		`shove . *.mp3 -r -max 205mb -n -k -j`
#>

[CmdletBinding(
	# ConfirmImpact = 'Medium',
	SupportsShouldProcess = $true
)]

param (
	# Folder where to look for files
	[Parameter (Position = 0)]
	[String] $SrcDir = $PWD,

	# Target folder where subfolders will be created
	[String] $TargetDir = $SrcDir,

	# Mask of files which process to
	[Parameter (Position = 1)]
	[String] $Mask = '*',

	# Max size of bunch, i.e. maximum size of files in each subfolder
	# Note: real size of bunches may overweiht this value, to preview
	# exact sizes use -WhatIf first
	[Alias('Max')]
	[int] $MaxSubFolderSize = 250Mb,

	# COPY files instead of MOVE
	[Alias('c')]
	[Switch] $Copy,

	# Use autonumeration for new names of files.
	[Alias('N')]
	[Switch] $Numeration,

	# SHOVE will restart numerations in each subfolder.
	[Alias('S')]
	[Switch] $SubfolderCounters,

	# Just calculate repositions and renames, almost like to use `-WhatIf`
	# or `-Verbose` but less verbose
	[Alias('J')]
	[Switch] $JustCalc,

	[Alias('H')]
	[Switch] $Help,

	# This is It!
	[Alias('R')]
	[Switch] $Recurse,

	# Find and Remove all Empty subfolders
	[Alias('K')]
	[Switch] $KillEmpty
)

# if ($PSCmdlet.ShouldProcess((Join-Path $PSScriptRoot 'shove-deps.psm1'), 'Load dependancies')) {
# 	Import-Module (Join-Path $PSScriptRoot 'shove-deps.psm1') -Force
# }

if ($Help) {
	$MyInvocation
	hr
	Get-Help $MyInvocation.MyCommand
	Exit
}

# разделитель с указанием размера
filter div($sz) {
	"$(hr)`e[33m {0:n1}`e[36mM`e[0m" -f ($sz / 1Mb)
}

hr
"Source `e[33m$SrcDir`e[0m"
hr


$FileList = Get-ChildItem $SrcDir -Filter $Mask -File -Recurse:$Recurse

$CntFls = 1;
$CntDir = 1;
$SzAcc = 0;

$TemplateSubFName = '{0:d3}';

foreach($File in $FileList) {
	$RelativeFileName = Resolve-Path -Relative $File.FullName
	Write-Debug "File - $RelativeFileName"
	if(($SzAcc + $File.Length) -gt $MaxSubFolderSize){
		div $SzAcc
		$CntDir++
		$SzAcc = 0
		if ($SubfolderCounters) {
			$CntFls = 1
		}
	};
	$NewName = $Numeration ? "{0:d2}{1}" -f $CntFls,$File.Extension : $File.Name
	$TargetFileName = ( Join-Path -Path $TargetDir -ChildPath ("$TemplateSubFName\{1}" -f $CntDir,$NewName) )
	$DestDir =($TemplateSubFName -f $CntDir)
	$Destination = (Join-Path $TargetDir $DestDir)
	$SzAcc += $File.Length
	$CntFls++
	"{0} `e[35m`u{f553}`e[33m {1}`t`e[36m{2,7:n1}`e[0m" -f $RelativeFileName,$TargetFileName,($File.Length / 1Mb)
	if (-not $JustCalc -and -not (Test-Path $Destination) -and $PSCmdlet.ShouldProcess($DestDir, 'Create subfolder')) {
		New-Item -Path $Destination -ItemType "directory" > $null
	}
	if(
		-not $JustCalc -and $PSCmdlet.ShouldProcess(
			($RelativeFileName),
			"$( $Copy ? 'Copy' :  'Move' ) file to `e[36m$DestDir`e[0m\`e[96m$($File.Name)`e[0m"
		)
	) {
		$Params = @{
			Path = $File.FullName;
			Destination = $TargetFileName;
			Force = $true;
			Confirm = $false
		}
		if (!$Copy) {Move-Item @Params} else {Copy-Item @Params}
	}
}

div $SzAcc

if ($KillEmpty) {
	Remove-EmptySubfolders $Path -JustCalc:$JustCalc
}

Show-FolderSizes $SrcDir | Format-Table
