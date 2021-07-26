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

# простой разделитель
function hr {"`u{2014}"*(0 -bor [Console]::WindowWidth / 2)}

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
	Write-Debug "File - $($File.FullName)"
	if(($SzAcc + $File.Length) -gt $MaxSubFolderSize){
		div $SzAcc
		$CntDir++
		$SzAcc = 0
		if ($SubfolderCounters) {
			$CntFls = 1
		}
	};
	$NewName = $Numeration ? "{0}{1}" -f $CntFls,$File.Extension : $File.Name
	$TargetFileName = ( Join-Path -Path $TargetDir -ChildPath ("$TemplateSubFName\{1}" -f $CntDir,$NewName) )
	$DestDir =($TemplateSubFName -f $CntDir)
	$Destination = (Join-Path $TargetDir $DestDir)
	$SzAcc += $File.Length
	$CntFls++
	"{0} `e[35m`u{f553}`e[33m {1}`t`e[36m{2,3:n1}`e[0mM" -f $File.Name,$TargetFileName,($File.Length / 1Mb)
	if (-not $JustCalc -and -not (Test-Path $Destination) -and $PSCmdlet.ShouldProcess($DestDir, 'Create subfolder')) {
		New-Item -Path $Destination -ItemType "directory" > $null
	}
	if(
		-not $JustCalc -and $PSCmdlet.ShouldProcess(
			(Resolve-Path -Relative $File.FullName),
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
	$cntErased = 0
	$toSkip = @()
	println (hr),"`nErase empty dirs"
	for(;;) {
		$dirs = Get-ChildItem $Path -Directory -Recurse |
			Where-Object { -not ($_.FullName -in $toSkip) -and ( 0 -eq (Get-ChildItem $_).Count ) }
		if (0 -lt $dirs.Count) {
			$dirs | ForEach-Object {
				println $_.Name;
				if (-not $JustCalc -and $PSCmdlet.ShouldProcess( $_.Name, "Remove folder" ) ) {
					Remove-Item $_
					$cntErased += $dirs.Count
				} else { $toSkip += $_.FullName }
			}
		} else { break }
	}
	println "Empty folders erased: `e[33m",$cntErased,"`e[0m"
	if ($JustCalc -or $toSkip.Count) {
		println "Empty folders that CAN be erased: `e[33m",$toSkip.Count,"`e[0m"
	}
}

Show-FolderSizes $SrcDir | Format-Table
