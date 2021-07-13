# SHOVE

CLI tool to distribute ordered files into subfolders of specified maximum size.

Tested with Posershell Core 7.0 and newer.

<picture>
<img alt="calculate manipulations" src="doc/JustCalc.png" style="width: 100%"/>
<caption>calculate manipulations</caption>
</picture>

<picture>
<img alt="MOVE files into subfolders" src="doc/MOVE.png" style="width: 100%"/>
<caption>MOVE files into subfolders</caption>
</picture>

## NAME

`shove.ps1`

## SYNOPSIS

Group files from specified folder by bunch size into subfolders


## SYNTAX

    shove.ps1 [[-SrcDir] <String>] [-TargetDir <String>] [[-Mask] <String>]
    [-MaxSubFolde rSize <Int32>] [-Move] [-e2eNumeration][-DoNotRename]
    [-JustCalc] [-Help] [-Recurse] [-WhatIf] [-Confir m] [<CommonParameters>]

## DESCRIPTION

New subfolders created as needed with ordinal numerated names.
    Numeration of files in each subfolder starts from `001`.
    Each subfolder will contain approx $MaxSubFolderSize in sum but not exceed.

`-e2eNumeration` is not mention when `-DoNotRename` is set


## PARAMETERS

###    -SrcDir <String>

Folder where to look for files

    Required?                    false
    Position?                    1
    Default value                $PWD   # Current directory
    Accept pipeline input?       false
    Accept wildcard characters?  false

###    -TargetDir <String>

Target folder where subfolders will be created

    Required?                    false
    Position?                    named
    Default value                $SrcDir  # Same as Souce Directory
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -Mask <String>

Mask of files which process to

    Required?                    false
    Position?                    2
    Default value                *
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -MaxSubFolderSize <Int32>

Max size of bunch, i.e. maximum size of files in each subfolder
Note: real size of bunches may overweiht this value, to preview
exact sizes use -WhatIf first

    Required?                    false
    Position?                    named
    Default value                262144000  # 250Mb
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -Move [<SwitchParameter>]

MOVE files instead of COPY

    Required?                    false
    Position?                    named
    Default value                False  # Use COPY
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -e2eNumeration [<SwitchParameter>]

By default SHOVE will start numerations in each subfolder.
When you do not want this but need to get the all processed files numerated
end-to-end then use this switch

    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -DoNotRename [<SwitchParameter>]

Do not use autonumeration for new names of files.
Leave file names as it was before processing

    Required?                    false
    Position?                    named
    Default value                False  # Use autonumeration
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -JustCalc [<SwitchParameter>]

Just calculate repositions and renames, almost like as use -WhatIf

    Required?                    false
    Position?                    named
    Default value                False  # Do the work without a peep
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -Help [<SwitchParameter>]

    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -Recurse [<SwitchParameter>]

This is It! Recursive search for the files in all subfolders of Source Directory

    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -WhatIf [<SwitchParameter>]

Don't actually COPY/MOVE files but get detailed information about what will be
done

    Required?                    false
    Position?                    named
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

### -Confirm [<SwitchParameter>]

Lets you check all action one by one

    Required?                    false
    Position?                    named
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

### <CommonParameters>

This cmdlet supports the common parameters: `Verbose`, `Debug`,
`ErrorAction`, `ErrorVariable`, `WarningAction`, `WarningVariable`,
`OutBuffer`, `PipelineVariable`, and `OutVariable`. For more information, see
`about_CommonParameters` (https://go.microsoft.com/fwlink/?LinkID=113216).

## EXAMPLES

#### EXAMPLE 1

```Powershell

    # Copy files by bunches about 80mb into subfolders

    shove -Max 80mb -E -D

```

#### Example 2

```Powershell

    # Show how SHOVE will MOVE files by banches about 100mb
    # -WhatIf can help to view how files will be distributed
    # by subfolders

    shove -max 97mb -NR -M -WhatIf

```

## RELATED LINKS

<https://github.com/syncap/>

