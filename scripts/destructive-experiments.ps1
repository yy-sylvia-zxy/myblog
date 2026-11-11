# 破坏性实验（取证用）：去掉分页拦截器 / 去掉 @RestControllerAdvice 到底会发生什么
# 原则：备份用复制、还原用复制，绝不重写文件内容（避免编码与换行被改动）
$ErrorActionPreference = 'Continue'
$proj = 'D:\computercourse\web程序设计\lec01\web程序设计lab01\temp-check\myblog'
Set-Location -LiteralPath $proj
$mvn  = 'D:\computercourse\IntelliJ IDEA 2026.1.2\plugins\maven\lib\maven3\bin\mvn.cmd'
$cfg  = Join-Path $proj 'src\main\java\com\myblog\config\MybatisPlusConfig.java'
$adv  = Join-Path $proj 'src\main\java\com\myblog\controller\ApiExceptionAdvice.java'
$log  = Join-Path $proj 'docs\evidence-destructive.log'
if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log -Force }

function Restart {
    Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
        Where-Object { $_.CommandLine -like '*myblog*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 3
    $runlog = Join-Path $proj ("run-" + [guid]::NewGuid().ToString('N').Substring(0,8) + ".log")
    Start-Process -FilePath $mvn -ArgumentList '-B','-DskipTests','spring-boot:run' -WorkingDirectory $proj `
        -RedirectStandardOutput $runlog -RedirectStandardError "$runlog.err" -WindowStyle Hidden | Out-Null
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 2
        try { $null = Invoke-WebRequest 'http://localhost:8080/hello' -TimeoutSec 3 -UseBasicParsing; return $runlog } catch {}
    }
    return $runlog
}

function Show($title, $path) {
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:8080$path" -UseBasicParsing
        $body = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
        $text = "status=$($r.StatusCode) | Content-Type=$($r.Headers['Content-Type'])`n$($body.Substring(0, [Math]::Min(600, $body.Length)))"
    } catch {
        $text = "status=$($_.Exception.Response.StatusCode.value__) | Content-Type=$($_.Exception.Response.Content.Headers.ContentType)`n$($_.ErrorDetails.Message)"
    }
    "`n=== $title ===`n$text" | Tee-Object -FilePath $log -Append | Out-Host
}

function SqlLines($runlog, $pattern) {
    ((Get-Content -LiteralPath $runlog | Select-String -Pattern $pattern | Select-Object -Last 4).Line -join "`n")
}

# ===== 实验 A：注释掉分页拦截器 =====
Copy-Item -LiteralPath $cfg -Destination "$cfg.bak" -Force
$t = [IO.File]::ReadAllText($cfg)
$t = $t.Replace('interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));',
                '// [破坏实验] interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));')
[IO.File]::WriteAllText($cfg, $t, (New-Object Text.UTF8Encoding $false))

"`n########## 实验 A：注释掉 PaginationInnerInterceptor ##########" | Tee-Object -FilePath $log -Append | Out-Host
$rA = Restart
Show 'A-1 GET /messages?page=2&size=1' '/messages?page=2&size=1'
"--- 这段实例日志里的 SQL ---`n$((SqlLines $rA 'Preparing:.*(COUNT|LIMIT)'))" | Tee-Object -FilePath $log -Append | Out-Host

Copy-Item -LiteralPath "$cfg.bak" -Destination $cfg -Force
Remove-Item -LiteralPath "$cfg.bak" -Force
"`n########## 恢复拦截器 ##########" | Tee-Object -FilePath $log -Append | Out-Host
$rB = Restart
Show 'B-1 GET /messages?page=2&size=1' '/messages?page=2&size=1'
"--- 这段实例日志里的 SQL ---`n$((SqlLines $rB 'Preparing:.*(COUNT|LIMIT)'))" | Tee-Object -FilePath $log -Append | Out-Host

# ===== 实验 C：注释掉 @RestControllerAdvice =====
Copy-Item -LiteralPath $adv -Destination "$adv.bak" -Force
$t2 = [IO.File]::ReadAllText($adv)
$t2 = $t2.Replace('@RestControllerAdvice', '// [破坏实验] @RestControllerAdvice')
[IO.File]::WriteAllText($adv, $t2, (New-Object Text.UTF8Encoding $false))

"`n########## 实验 C：注释掉 @RestControllerAdvice ##########" | Tee-Object -FilePath $log -Append | Out-Host
$rC = Restart
Show 'C-1 GET /articles/999' '/articles/999'
"--- 这段实例日志里的异常 ---`n$((SqlLines $rC 'Exception|ERROR'))" | Tee-Object -FilePath $log -Append | Out-Host

Copy-Item -LiteralPath "$adv.bak" -Destination $adv -Force
Remove-Item -LiteralPath "$adv.bak" -Force
"`n########## 恢复 advice ##########" | Tee-Object -FilePath $log -Append | Out-Host
$rD = Restart
Show 'D-1 GET /articles/999' '/articles/999'

# 收尾：确保工作区里这两个文件与提交版本一致
& 'D:\Git\cmd\git.exe' checkout -- src/main/java/com/myblog/config/MybatisPlusConfig.java src/main/java/com/myblog/controller/ApiExceptionAdvice.java
