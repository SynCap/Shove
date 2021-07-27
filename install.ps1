[CmdletBinding(SupportsShouldProcess=$true)]
# $GitHubRepoUrl = 'https://raw.github.com/syncap/shove/master/'
$GitHubRepoUrl = 'https://raw.githubusercontent.com/SynCap/Shove/master/'

$Files = @(
    'shove.ps1',
    'shove-deps.ps1'
)

$SavePath = "$(Split-Path $PROFILE)\Scripts"

function println([String[]]$s){[System.Console]::WriteLine($s -join '')}

function downloadFiles {
    param(
        [parameter(mandatory)]
        [String[]] $List,
        [String] $Dest = '.',
        [String] $BaseUrl = ''
    )
    $Cnt = 0
    foreach ($File in $List) {
        println ("{0,2}/{1} Download file: `e[33m{2}`e[0m" -f ++$Cnt,$List.Count,$File)
        $Url = "$BaseUrl$File"
        $r = Invoke-WebRequest $Url
        if ($r -and $r.StatusDescription -eq 'OK') {
            $FName = Join-Path -Path $Dest -ChildPath $File
            Write-Debug $FName
            Set-Content -Path $FName -Value $r.Content -Encoding utf8
        } else {
            throw 'Bad URL'
            $False
        }
    }
    explorer.exe $Dest
}

function AddPathToEnvPATH {
    param(
        [Parameter(Mandatory=$true)][String[]] $PathToAdd
    )
    $UserPathes = [System.Environment]::GetEnvironmentVariable('PATH',[System.EnvironmentVariableTarget]::User) -split ';'
    $CurrentPathes = $Env:PATH -split ';'
    $cntAddToUser = 0
    $PathToAdd.ForEach( {
        if(-not $_ -in $UserPathes) {
            $UserPathes += $_
            $cntAddToUser ++
        }
        if (-not $_ -in $CurrentPathes) {
            $CurrentPathes += $_
        }
    })

    # Current User Environment PATH wich will available in future started processes
    if ($cntAddToUser) {
        [System.Environment]::SetEnvironmentVariable('PATH',$UserPathes -join ';',[System.EnvironmentVariableTarget]::User)
    }

    # Set Environment for current terminal process
    $Env:PATH = $CurrentPathes -join ';'
}

println 'Create module directory — ',"`e[36m",$SavePath,"`e[0m"
New-Item -Type Container -Force -path $SavePath > $Null

try {
    downloadFiles -List $Files -Dest $SavePath -BaseUrl $GitHubRepoUrl
}
catch {
    println "`e[91m",'Installation failed',"`e[0m"
    exit 1
}

try {
    AddPathToEnvPATH $SavePath
} catch {
    throw "Can't modify PATH Environment variable."
}

println "`e[33m",'Installation complete.',"`e[0m"
println 'Use "',"`e[36m",'shove',"`"`e[0m",' more info "',"`e[36m",'shove -Help',"`e[0m`""
