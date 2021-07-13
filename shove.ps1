<#
.synopsis
	Group files from specified folder by bunch size into subfolders

.description
	New subfolders created as needed and has ordinal numerated names.
	Numeration of files in each subfolder starts from 01.
	Each subfolder will contain approx $MaxSubFolderSize in sum.

	-e2eNumeration is not mention when -DoNotRename is set
.example

	-- Example 1 --

	# Copy files by bunches about 80mb into subfolders

	shove -Max 80mb -NR -DR

	-- Example 2 --

	# Show how SHOVE will MOVE files by banches about 100mb
	# -WhatIf can help to view how files will be distributed
	# by subfolders

	shove -max 97mb -NR -M -WhatIf

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

	# MOVE files instead of COPY
	[Alias('M')]
	[Switch] $Move,

	# By default SHOVE will start numerations in each subfolder.
	# If you do not want this but get the all processed files numerated
	# end-to-end then use this switch
	[Alias('E')]
	[Switch] $e2eNumeration,

	# Do not use autonumeration for new names of files.
	# Leave file names as it was before processing
	[Alias('D,DNR')]
	[Switch] $DoNotRename,

	# Just calculate repositions and renames, almost like as use -WhatIf
	[Alias('J')]
	[Switch] $JustCalc,

	[Alias('H')]
	[Switch] $Help,

	# This is It!
	[Switch] $Recurse
)

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
		if (!$e2eNumeration) {
			$CntFls = 1
		}
	};
	$NewName = $DoNotRename ? $File.Name : "{0}{1}" -f $CntFls,$File.Extension
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
			$File.Name,
			"$( $Move ? 'Move' : 'Copy' ) file from `e[35m$(Resolve-Path -Relative $File.FullName)`e[0m to subfolder `e[36m$DestDir`e[0m"
		)
	) {
		$Params = @{
			Path = $File.FullName;
			Destination = $TargetFileName;
			Force = $true;
			Confirm = $false
		}
		if ($Move) {Move-Item @Params} else {Copy-Item @Params}
	}
}

div $SzAcc

Show-FolderSizes -DirsOnly $SrcDir | Format-Table
