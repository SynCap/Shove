# $GitHubRepoUrl = 'https://raw.github.com/syncap/shove/master/'
$GitHubRepoUrl = 'https://raw.githubusercontent.com/SynCap/Shove/master/'

$Files = @(
    'shove.psm1',
    'shove.psd1',
    'shove-deps.psm1',
    'shove-deps.psd1'
)

$ShoveHomePath = "$(($env:PSModulePath -split ";")[0])\Shove"

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
            Set-Content -Path $FName -Value $r.Content -Encoding utf8
        } else {
            throw 'Bad URL'
            $False
        }
    }
    explorer.exe $Dest
}


println 'Create module directory — ',"`e[36m",$ShoveHomePath,"`e[0m"
New-Item -Type Container -Force -path $ShoveHomePath > $Null

try {
    downloadFiles -List $Files -Dest $ShoveHomePath -BaseUrl $GitHubRepoUrl
}
catch {
    println "`e[91m",'Installation failed',"`e[0m"
    exit 1
}

println "`e[33m",'Installation complete.',"`e[0m"
println 'Use "',"`e[36m",'Import-Module shove',"`"`e[0m",' and then "',"`e[36m",'shove -Help',"`e[0m`""
