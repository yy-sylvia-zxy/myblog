# Lab06-Lab08 验收脚本：逐条发请求，把真实响应写进 evidence 原始日志
# 用法：pwsh -File scripts\verify-lab06-08.ps1
$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080'
$out  = Join-Path (Get-Location) 'docs\evidence-raw.log'
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }

function Log($title, $text) {
    $line = "`n=== $title ===" + "`n" + $text
    $line | Tee-Object -FilePath $out -Append | Out-Host
}

function PostJson($path, $obj) {
    $json = $obj | ConvertTo-Json -Depth 5 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    try {
        $r = Invoke-WebRequest -Uri "$base$path" -Method Post -Body $bytes -ContentType 'application/json; charset=utf-8' -UseBasicParsing
        return @{ status = $r.StatusCode; body = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray()) }
    } catch {
        return @{ status = $_.Exception.Response.StatusCode.value__; body = $_.ErrorDetails.Message }
    }
}

function Send($method, $path, $obj = $null) {
    try {
        $params = @{ Uri = "$base$path"; Method = $method; UseBasicParsing = $true }
        if ($obj) {
            $bytes = [Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json -Depth 5 -Compress))
            $params.Body = $bytes
            $params.ContentType = 'application/json; charset=utf-8'
        }
        $r = Invoke-WebRequest @params
        return @{ status = $r.StatusCode; body = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray()) }
    } catch {
        return @{ status = $_.Exception.Response.StatusCode.value__; body = $_.ErrorDetails.Message }
    }
}

Log 'Lab06-1 POST /messages（第一条）' (PostJson '/messages' @{ content = '赵熙语的博客开张了：第一条来自浏览器的留言' } | ConvertTo-Json -Compress)
Log 'Lab06-2 POST /messages（第二条）' (PostJson '/messages' @{ content = '第二条留言——这次写进 MySQL，不是内存' } | ConvertTo-Json -Compress)
Log 'Lab06-3 GET /messages（读库）' (Send 'GET' '/messages?page=1&size=5' | ConvertTo-Json -Compress)
Log 'Lab07-1 GET /messages?keyword=MySQL' (Send 'GET' '/messages?keyword=MySQL' | ConvertTo-Json -Compress)
Log 'Lab07-2 GET /messages?keyword=不存在的词' (Send 'GET' ('/messages?keyword=' + [uri]::EscapeDataString('不存在的词')) | ConvertTo-Json -Compress)
Log 'Lab07-3 GET /messages?page=2&size=1' (Send 'GET' '/messages?page=2&size=1' | ConvertTo-Json -Compress)

Log 'Lab08-1 POST /articles' (PostJson '/articles' @{ title = '第一篇文章'; content = '这是 MyBlog 的第一篇可修订的文章。' } | ConvertTo-Json -Compress)
Log 'Lab08-2 POST /articles（第二篇，供分页用）' (PostJson '/articles' @{ title = '第二篇文章'; content = '用于验证发现列表与分页。' } | ConvertTo-Json -Compress)
Log 'Lab08-3 GET /articles' (Send 'GET' '/articles?page=1&size=5' | ConvertTo-Json -Compress)
Log 'Lab08-4 GET /articles?keyword=修订' (Send 'GET' ('/articles?keyword=' + [uri]::EscapeDataString('修订')) | ConvertTo-Json -Compress)
Log 'Lab08-5 GET /articles/1' (Send 'GET' '/articles/1' | ConvertTo-Json -Compress)
Log 'Lab08-6 PUT /articles/1（改标题）' (Send 'PUT' '/articles/1' @{ title = '第一篇文章（已修订）' } | ConvertTo-Json -Compress)
Log 'Lab08-7 GET /articles/1（确认修订生效）' (Send 'GET' '/articles/1' | ConvertTo-Json -Compress)
Log 'Lab08-8 DELETE /articles/2' (Send 'DELETE' '/articles/2' | ConvertTo-Json -Compress)
Log 'Lab08-9 GET /articles/2（删除后再读）' (Send 'GET' '/articles/2' | ConvertTo-Json -Compress)
Log 'Lab08-10 GET /articles/999（从未存在）' (Send 'GET' '/articles/999' | ConvertTo-Json -Compress)
Log 'Lab08-11 GET /messages（旧接口是否分毫未动）' (Send 'GET' '/messages?page=1&size=5' | ConvertTo-Json -Compress)
