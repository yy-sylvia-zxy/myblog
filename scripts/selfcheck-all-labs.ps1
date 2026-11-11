# 八周接口全量自检：一条一条打，只看"能不能跑、跑出来对不对"
$ErrorActionPreference = 'Continue'
$base = 'http://localhost:8080'
$out  = 'D:\computercourse\web程序设计\lec01\web程序设计lab01\temp-check\myblog\docs\selfcheck.log'
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }

function Hit($method, $path, $body = $null) {
    try {
        $p = @{ Uri = "$base$path"; Method = $method; UseBasicParsing = $true }
        if ($body) {
            $p.Body = [Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json -Compress))
            $p.ContentType = 'application/json; charset=utf-8'
        }
        $r = Invoke-WebRequest @p
        $txt = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
        return @{ code = $r.StatusCode; ct = $r.Headers['Content-Type']; body = $txt }
    } catch {
        return @{ code = $_.Exception.Response.StatusCode.value__; ct = $_.Exception.Response.Content.Headers.ContentType; body = $_.ErrorDetails.Message }
    }
}

function Check($lab, $name, $method, $path, $expect, $body = $null) {
    $h = Hit $method $path $body
    $bodyShort = ($h.body -replace "`r`n", ' ' -replace "`n", ' ')
    if ($bodyShort.Length -gt 120) { $bodyShort = $bodyShort.Substring(0, 120) + '…' }
    $ok = 'FAIL'
    if ($h.code -eq $expect) { $ok = 'PASS' }
    $line = "{0,-6} {1,-3} {2,-30} HTTP {3,-4} expect {4,-4} {5,-28} {6}" -f $lab, $ok, $name, $h.code, $expect, $h.ct, $bodyShort
    $line | Tee-Object -FilePath $out -Append | Out-Host
    return ($h.code -eq $expect)
}

$all = @()
$all += Check 'Lab01' '/hello 纯文本'        'GET' '/hello'  200
$all += Check 'Lab02' '/me 变 JSON'          'GET' '/me'     200
$all += Check 'Lab02' '/profile 三字段以上'   'GET' '/profile' 200
$all += Check 'Lab03' '/profile 五字段'       'GET' '/profile' 200
$all += Check 'Lab04' 'POST /messages #1'    'POST' '/messages' 201 @{ content = '自检留言 A' }
$all += Check 'Lab04' 'POST /messages #2'    'POST' '/messages' 201 @{ content = '自检留言 B（含 MySQL 这个词）' }
$all += Check 'Lab04' 'GET /messages 列表'   'GET' '/messages' 200
$all += Check 'Lab04' 'GET /messages/1'      'GET' '/messages/1' 200
$all += Check 'Lab04' 'GET /messages/999999' 'GET' '/messages/999999' 404
$all += Check 'Lab07' 'keyword 过滤'         'GET' '/messages?keyword=MySQL' 200
$all += Check 'Lab07' 'keyword 空结果'       'GET' '/messages?keyword=zzzznotexist' 200
$all += Check 'Lab07' '分页 page=2&size=1'   'GET' '/messages?page=2&size=1' 200
$all += Check 'Lab08' 'POST /articles'       'POST' '/articles' 200 @{ title = '自检文章'; content = '用于验证发布/读取/修订/撤回' }
$all += Check 'Lab08' 'GET /articles'        'GET' '/articles' 200
$all += Check 'Lab08' 'GET /articles/999999' 'GET' '/articles/999999' 404
$all += Check 'Lab08' 'PUT /articles/1'      'PUT' '/articles/1' 200 @{ title = '自检文章（已修订）' }
$all += Check 'Lab08' 'DELETE /articles/1'   'DELETE' '/articles/1' 200
$all += Check 'Lab08' 'GET /articles/1 删除后' 'GET' '/articles/1' 404
$all += Check 'Lab08' 'GET /article (少个s)'  'GET' '/article' 404

$pass = ($all | Where-Object { $_ }).Count
"`n总计 {0} 项，通过 {1} 项，失败 {2} 项" -f $all.Count, $pass, ($all.Count - $pass) | Tee-Object -FilePath $out -Append | Out-Host
