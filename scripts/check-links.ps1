param([string]$Dir, [string]$Out, [string]$Filter = '*.md')
# Extract every http(s) URL from the result files in $Dir and probe each one.
# 404/410 = page does not exist (drop the claim); 401/403/429 or no response = blocked (confirm manually).
$urls = @{}
Get-ChildItem $Dir -Filter $Filter -File | ForEach-Object {
    $file = $_.Name
    [regex]::Matches((Get-Content $_.FullName -Raw), 'https?://[^\s\)\]>`"''|]+') | ForEach-Object {
        $u = $_.Value.TrimEnd('.', ',', ';', ':')
        if (-not $urls.ContainsKey($u)) { $urls[$u] = $file }
    }
}
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36'
$rows = foreach ($u in $urls.Keys) {
    $status = ''
    try {
        $r = Invoke-WebRequest -Uri $u -UserAgent $ua -Method Get -TimeoutSec 15 -MaximumRedirection 5 -UseBasicParsing
        $status = [int]$r.StatusCode
    } catch {
        if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode } else { $status = 'NO-RESPONSE' }
    }
    [pscustomobject]@{ File = $urls[$u]; Status = $status; Url = $u }
}
$rows | Sort-Object File, Status | Export-Csv $Out -NoTypeInformation -Encoding utf8
$rows | Group-Object File | ForEach-Object {
    $g = $_.Group
    '{0}: total {1}, ok {2}, dead 404/410 {3}, blocked 401/403/429 {4}, no-response {5}' -f $_.Name, $g.Count,
        ($g | Where-Object { $_.Status -is [int] -and $_.Status -lt 400 }).Count,
        ($g | Where-Object { $_.Status -in 404, 410 }).Count,
        ($g | Where-Object { $_.Status -in 401, 403, 429 }).Count,
        ($g | Where-Object { $_.Status -eq 'NO-RESPONSE' }).Count
}
'--- dead links (drop these claims):'
$rows | Where-Object { $_.Status -in 404, 410 } | ForEach-Object { '{0}  {1}' -f $_.File, $_.Url }
