$ErrorActionPreference = 'Continue'
$proj = 'D:\computercourse\web程序设计\lec01\web程序设计lab01\temp-check\myblog'
Set-Location -LiteralPath $proj
$mvn  = 'D:\computercourse\IntelliJ IDEA 2026.1.2\plugins\maven\lib\maven3\bin\mvn.cmd'
$log  = Join-Path $proj 'docs\confirm-evidence2.log'
if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log -Force }
function Emit($t) { $t | Tee-Object -FilePath $log -Append | Out-Host }

function KillJava { Get-CimInstance Win32_Process -Filter "Name='java.exe'" | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; Start-Sleep -Seconds 3 }

function StartApp($tag) {
    $rl = Join-Path $proj "run-$tag.log"
    Start-Process -FilePath $mvn -ArgumentList '-B','-DskipTests','spring-boot:run' -WorkingDirectory $proj `
        -RedirectStandardOutput $rl -RedirectStandardError "$rl.err" -WindowStyle Hidden | Out-Null
    for ($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Seconds 2
        try { $null = Invoke-WebRequest 'http://localhost:8080/hello' -TimeoutSec 2 -UseBasicParsing; break } catch {}
    }
    return $rl
}

function WaitFor($rl, $pattern, $seconds = 40) {
    for ($i = 0; $i -lt ($seconds / 2); $i++) {
        Start-Sleep -Seconds 2
        $m = Select-String -LiteralPath $rl -Pattern $pattern
        if ($m) { return $m }
    }
    return $null
}

# ---------- 破坏实验 A：@RestController -> @Controller ----------
$hc = Join-Path $proj 'src\main\java\com\myblog\controller\HelloController.java'
Copy-Item -LiteralPath $hc -Destination "$hc.bak" -Force
$t = [IO.File]::ReadAllText($hc)
$t = $t.Replace('import org.springframework.web.bind.annotation.RestController;', 'import org.springframework.stereotype.Controller;')
$t = [regex]::Replace($t, '(?m)^@RestController', '@Controller')
[IO.File]::WriteAllText($hc, $t, (New-Object Text.UTF8Encoding $false))
Emit "`n########## 破坏实验A：@RestController -> @Controller（编译已修正）##########"
Emit ("改后注解：" + ((Select-String -LiteralPath $hc -Pattern '^@Controller|^@RestController').Line -join ' '))
KillJava
$rl = StartApp 'A'
Emit "启动结果："
$err = WaitFor $rl 'Could not resolve|APPLICATION FAILED|Started MyblogApplication|Circular view|ERROR' 30
Emit (($err | Select-Object -First 8).Line -join "`n")
try {
    $r = Invoke-WebRequest 'http://localhost:8080/hello' -TimeoutSec 5 -UseBasicParsing
    Emit ("GET /hello -> HTTP " + $r.StatusCode + " CT=" + $r.Headers['Content-Type'])
} catch {
    Emit ("GET /hello -> " + $_.Exception.Message + " | body=" + $_.ErrorDetails.Message)
}
KillJava
Copy-Item -LiteralPath "$hc.bak" -Destination $hc -Force
Remove-Item -LiteralPath "$hc.bak" -Force
(Get-Item -LiteralPath $hc).LastWriteTime = Get-Date
$null = StartApp 'A-restored'
Emit ("还原后 GET /hello -> " + (Invoke-WebRequest 'http://localhost:8080/hello' -UseBasicParsing).Content)

# ---------- 破坏实验 E：注释掉 @Service ----------
$ms = Join-Path $proj 'src\main\java\com\myblog\service\MessageService.java'
Copy-Item -LiteralPath $ms -Destination "$ms.bak" -Force
$t = [IO.File]::ReadAllText($ms)
$t = [regex]::Replace($t, '(?m)^@Service', '// [破坏实验] @Service')
[IO.File]::WriteAllText($ms, $t, (New-Object Text.UTF8Encoding $false))
Emit "`n########## 破坏实验E：注释掉 MessageService 的 @Service ##########"
Emit ("改后：" + ((Select-String -LiteralPath $ms -Pattern '@Service' | Select-Object -First 2).Line -join ' '))
KillJava
$rlE = StartApp 'E'
$errE = WaitFor $rlE 'APPLICATION FAILED|required a bean|Started MyblogApplication' 40
Emit (($errE | Select-Object -First 10).Line -join "`n")
if ($errE -match 'required a bean') {
    $ctx = Select-String -LiteralPath $rlE -Pattern 'required a bean|Description:|Action:' -Context 0,1
    Emit (($ctx | ForEach-Object { $_.Line }) -join "`n")
}
KillJava
Copy-Item -LiteralPath "$ms.bak" -Destination $ms -Force
Remove-Item -LiteralPath "$ms.bak" -Force
(Get-Item -LiteralPath $ms).LastWriteTime = Get-Date
$null = StartApp 'E-restored'
Emit ("还原后 GET /messages -> HTTP " + (Invoke-WebRequest 'http://localhost:8080/messages?page=1&size=5' -UseBasicParsing).StatusCode)

Emit "`n########## git status（工作区不应有源码改动）##########"
Emit ((& 'D:\Git\cmd\git.exe' status --short) -join "`n")
