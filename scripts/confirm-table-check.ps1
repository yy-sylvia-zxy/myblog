# 按《前八次实战核心任务确认表》补齐证据
# 每个破坏实验：改 → 重启 → 取现象 → 还原 → 重启 → 确认复原
$ErrorActionPreference = 'Continue'
$proj = 'D:\computercourse\web程序设计\lec01\web程序设计lab01\temp-check\myblog'
Set-Location -LiteralPath $proj
$mvn  = 'D:\computercourse\IntelliJ IDEA 2026.1.2\plugins\maven\lib\maven3\bin\mvn.cmd'
$log  = Join-Path $proj 'docs\confirm-evidence.log'
if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log -Force }

function Emit($text) { $text | Tee-Object -FilePath $log -Append | Out-Host }

function Restart {
    Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
        Where-Object { $_.CommandLine -like '*myblog*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 3
    $rl = Join-Path $proj ("run-" + [guid]::NewGuid().ToString('N').Substring(0,6) + ".log")
    $p = Start-Process -FilePath $mvn -ArgumentList '-B','-DskipTests','spring-boot:run' -WorkingDirectory $proj `
         -RedirectStandardOutput $rl -RedirectStandardError "$rl.err" -WindowStyle Hidden -PassThru
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 2
        try { $null = Invoke-WebRequest 'http://localhost:8080/hello' -TimeoutSec 3 -UseBasicParsing; return $rl } catch {}
    }
    return $rl
}

function Hit($method, $path, $body = $null, $base = 'http://localhost:8080') {
    try {
        $p = @{ Uri = "$base$path"; Method = $method; UseBasicParsing = $true }
        if ($body) {
            $p.Body = [Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json -Compress))
            $p.ContentType = 'application/json; charset=utf-8'
        }
        $r = Invoke-WebRequest @p
        $txt = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
        return @{ code = $r.StatusCode; ct = "$($r.Headers['Content-Type'])"; body = $txt }
    } catch {
        return @{ code = $_.Exception.Response.StatusCode.value__; ct = "$($_.Exception.Response.Content.Headers.ContentType)"; body = $_.ErrorDetails.Message }
    }
}

function Show($title, $method, $path, $body = $null) {
    $h = Hit $method $path $body
    $b = ($h.body -replace "`r`n",' ' -replace "`n",' ')
    if ($b.Length -gt 320) { $b = $b.Substring(0,320) + '…' }
    Emit ("`n=== $title ===`nHTTP $($h.code) | CT=$($h.ct)`n$b")
}

# ========== 阶段 1：确认表 Lab01①、Lab07③、Lab08③ 的现状 ==========
Emit "`n########## 阶段1：现状取证 ##########"
$rl = Restart
Show 'Lab01① 根路径 /（应 404：服务活着、尚无路由）' 'GET' '/'
Show 'Lab01② GET /hello' 'GET' '/hello'
Show 'Lab01③ GET /me' 'GET' '/me'
Show 'Lab03① GET /profile' 'GET' '/profile'

Emit "`n--- Lab07③ 八项测试矩阵 ---"
$m1 = Hit 'GET' '/messages?page=1&size=5'
$m2 = Hit 'GET' '/messages?page=2&size=2'
$m3 = Hit 'GET' '/messages?keyword=MySQL'
$m4 = Hit 'GET' '/messages?keyword=MySQL&page=2&size=1'
$m5 = Hit 'GET' '/messages?keyword=zzzznotexist'
$m6 = Hit 'GET' '/messages?size=1000'
$m7 = Hit 'GET' '/messages/1'
$m8 = Hit 'POST' '/messages' @{ content = '确认表取证：这一条来自 11 月 11 日自检' }
foreach ($i in 1..8) {
    $h = Get-Variable "m$i" -ValueOnly
    $b = ($h.body -replace "`r`n",' ' -replace "`n",' ')
    if ($b.Length -gt 240) { $b = $b.Substring(0,240) + '…' }
    Emit ("M$i HTTP $($h.code)  $b")
}

Emit "`n--- Lab08③ 收工后"照片"（开工前那份需你补，见说明）---"
$after = @{
    profile  = (Hit 'GET' '/profile').body
    messages = (Hit 'GET' '/messages?keyword=MySQL&page=1&size=5').body
}
[IO.File]::WriteAllText((Join-Path $proj 'docs\snapshot-after.json'), ($after | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding $false))
Emit "已写入 docs\snapshot-after.json"

# ========== 阶段 2：Lab02 破坏实验 A（@RestController -> @Controller）==========
$hc = Join-Path $proj 'src\main\java\com\myblog\controller\HelloController.java'
$t = [IO.File]::ReadAllText($hc)
[IO.File]::WriteAllText("$hc.bak", $t, (New-Object Text.UTF8Encoding $false))
$t2 = $t.Replace('@RestController`npublic class HelloController', '@Controller`npublic class HelloController').Replace('import org.springframework.web.bind.annotation.RestController;', "import org.springframework.stereotype.Controller;`nimport org.springframework.web.bind.annotation.Controller;")
# 上面替换容易出错，改用精准两处
$t2 = $t -replace 'import org\.springframework\.web\.bind\.annotation\.RestController;', 'import org.springframework.stereotype.Controller;'
$t2 = $t2 -replace '@RestController\r?\npublic class HelloController', '@Controller`npublic class HelloController'
[IO.File]::WriteAllText($hc, $t2, (New-Object Text.UTF8Encoding $false))
Emit "`n########## Lab02破坏实验A：@RestController 换成 @Controller ##########"
Emit ("改后注解行：" + ((Select-String -LiteralPath $hc -Pattern '@Controller|@RestController' | Select-Object -Last 1).Line))
$rlA = Restart
Show 'A-1 GET /profile（@Controller 下）' 'GET' '/profile'
Emit ("该实例日志尾部：" + (((Get-Content -LiteralPath $rlA -Tail 6) -join ' / ')))
Copy-Item -LiteralPath "$hc.bak" -Destination $hc -Force
Remove-Item -LiteralPath "$hc.bak" -Force
(Get-Item -LiteralPath $hc).LastWriteTime = Get-Date
$rlB = Restart
Show 'A-2 GET /profile（还原 @RestController 后）' 'GET' '/profile'

# ========== 阶段 3：Lab02 破坏实验 B（改字段名 owner -> author）==========
$pp = Join-Path $proj 'src\main\java\com\myblog\model\PersonalProfile.java'
$t = [IO.File]::ReadAllText($pp)
[IO.File]::WriteAllText("$pp.bak", $t, (New-Object Text.UTF8Encoding $false))
$t2 = $t -replace 'owner', 'author'
[IO.File]::WriteAllText($pp, $t2, (New-Object Text.UTF8Encoding $false))
Emit "`n########## Lab02破坏实验B：字段 owner 改名为 author ##########"
$rlC = Restart
Show 'B-1 GET /profile（字段改名后，看 JSON key）' 'GET' '/profile'
Copy-Item -LiteralPath "$pp.bak" -Destination $pp -Force
Remove-Item -LiteralPath "$pp.bak" -Force
(Get-Item -LiteralPath $pp).LastWriteTime = Get-Date
$rlD = Restart
Show 'B-2 GET /profile（还原后）' 'GET' '/profile'

# ========== 阶段 4：Lab05 破坏实验（删 @Service）==========
$ms = Join-Path $proj 'src\main\java\com\myblog\service\MessageService.java'
$t = [IO.File]::ReadAllText($ms)
[IO.File]::WriteAllText("$ms.bak", $t, (New-Object Text.UTF8Encoding $false))
$t2 = $t -replace '^@Service', '// [破坏实验] @Service'
[IO.File]::WriteAllText($ms, $t2, (New-Object Text.UTF8Encoding $false))
Emit "`n########## Lab05破坏实验：注释掉 @Service ##########"
Get-CimInstance Win32_Process -Filter "Name='java.exe'" | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 3
$rlE = Join-Path $proj 'run-noservice.log'
$p2 = Start-Process -FilePath $mvn -ArgumentList '-B','-DskipTests','spring-boot:run' -WorkingDirectory $proj `
      -RedirectStandardOutput $rlE -RedirectStandardError "$rlE.err" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 35
Emit "启动输出（找 bean / required a bean of type）："
Emit (((Get-Content -LiteralPath $rlE | Select-String -Pattern 'APPLICATION FAILED|required a bean|Description:|Action:|Started MyblogApplication' | Select-Object -First 8).Line) -join "`n")
Get-CimInstance Win32_Process -Filter "Name='java.exe'" | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Copy-Item -LiteralPath "$ms.bak" -Destination $ms -Force
Remove-Item -LiteralPath "$ms.bak" -Force
(Get-Item -LiteralPath $ms).LastWriteTime = Get-Date
$rlF = Restart
Show 'E-1 GET /messages（还原 @Service 后）' 'GET' '/messages?page=1&size=5'

Emit "`n########## 收尾：工作区应无改动 ##########"
Emit ((& 'D:\Git\cmd\git.exe' status --short) -join "`n")
