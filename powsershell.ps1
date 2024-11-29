# clipboard-watcher.ps1

# 设置循环间隔（单位：秒）
$interval = 1

# 已处理磁链的存储文件路径
$magnetHandledFile = "C:\Users\20460\repo\pikpakcli\handled-magnets.txt"

# 检测磁链的正则表达式
$magnetRegex = "^magnet:\?"

# 加载已处理的磁链
function Load-HandledMagnets {
    if (Test-Path $magnetHandledFile) {
        return Get-Content $magnetHandledFile
    } else {
        return @()
    }
}

# 保存新处理的磁链
function Save-HandledMagnet($magnetLink) {
    $magnetLink | Out-File -FilePath $magnetHandledFile -Append -Encoding UTF8
}

# 检查剪贴板内容
function Check-Clipboard {
    $clip = Get-Clipboard -TextFormatType Text -Raw
    if ($handledMagnets -notcontains $clip -and $clip -match $magnetRegex) {
        Write-Host "检测到磁链: $clip"
        Run-MagnetCommand $clip
        Save-HandledMagnet $clip
        $script:handledMagnets += $clip
    }
}


# 运行命令
function Run-MagnetCommand($magnetLink) {
    $command = @"
pikpakcli new url -p "/My Pack" '$magnetLink'
"@
    try {
        Invoke-Expression $command
        Write-Host "命令执行成功"
    } catch {
        Write-Host "命令执行失败: $_"
    }
}

# 初始化已处理磁链列表
$handledMagnets = Load-HandledMagnets

# 主循环
while ($true) {
    Check-Clipboard
    Start-Sleep -Seconds $interval
}
