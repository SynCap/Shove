
$ShoveHomePath = "$(($env:PSModulePath -split ";")[0])\Shove"

function downloadList {
    param(
        [parameter(mandatory,position=0)] [String[]] $urlList,
        [parameter(position=1)] [String] $Dest = '.'
    )
    $Cnt = 1
    foreach ($Url in $urlList) {
        $r = Invoke-WebRequest $Url
        $m = (ParseUrl $Url)
        if ($m) {
            $FName = Join-Path -Path $Dest -ChildPath ('{0:d3}.{1}' -f $Cnt, ($m.Ext ?? (($r.Headers['Content-Type'] -split '/')[1] ?? '')) -join '')
            Set-Content -AsByteStream -Value $r.Content -Path $FName
        } else {
            Write-Error 'Bad URL'
            $False
        }
        $Cnt++
    }
    explorer.exe $Dest
}


Write-Host "Creating module directory"
New-Item -Type Container -Force -path $ShoveHomePath > $Null

Write-Host "Download and install"
(New-Object Net.WebClient).DownloadString("https://raw.github.com/syncap/shove/master/shove.psm1") | Out-File "$ShoveHomePath\shove.psm1"
(New-Object Net.WebClient).DownloadString("https://raw.github.com/syncap/shove/master/shove-deps.psm1") | Out-File "$ShoveHomePath\shove-deps.psm1"

Write-Host "Installed!"
Write-Host 'Use "Import-Module pswatch" and then "watch"'