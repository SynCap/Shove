$Files = @(
    'shove.psm1',
    'shove-deps.psm1'
)

$ShoveHomePath = "$(($env:PSModulePath -split ";")[0])\Shove"

function println([String[]]$s){[System.Console]::WriteLine($s -join '')}

function downloadFiles {
    param(
        [parameter(mandatory)]
        [String[]] $List,
        [String] $Dest = '.',
        [String] $BaseUrl = 'https://raw.github.com/syncap/shove/master/'
    )
    $Cnt = 0
    foreach ($Url in $List) {
        $r = Invoke-WebRequest $BaseUrl+$Url
        $m = (ParseUrl $Url)
        if ($m) {
            $FName = Join-Path -Path $Dest -ChildPath ('{0:d3}.{1}' -f ++$Cnt, ($m.Ext ?? (($r.Headers['Content-Type'] -split '/')[1] ?? '')) -join '')
            Set-Content -AsByteStream -Value $r.Content -Path $FName
        } else {
            Write-Error 'Bad URL'
            $False
        }
    }
    explorer.exe $Dest
}


println 'Create module directory'
New-Item -Type Container -Force -path $ShoveHomePath > $Null

println 'Download and install'
downloadFiles -List $Files -Dest $ShoveHomePath


println 'Installed!'
println 'Use "Import-Module shove" and then "shove -Help"'
