# server-stats.ps1
# Limpar tela
Clear-Host

Write-Host "+---------------------------------------+" -ForegroundColor Cyan
Write-Host "¦   SERVER PERFORMANCE STATS ANALYZER   ¦" -ForegroundColor Cyan
Write-Host "+---------------------------------------+" -ForegroundColor Cyan
Write-Host ""
Write-Host "Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Hostname: $env:COMPUTERNAME"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "SYSTEM INFORMATION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Informações do Sistema Operacional
$OS = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Host "Operating System: $($OS.Caption) $($OS.Version)"

# System Uptime
$LastBootUpTime = $OS.LastBootUpTime
$Uptime = (Get-Date) - $LastBootUpTime
$UptimeString = "{0} days, {1} hours, {2} minutes" -f $Uptime.Days, $Uptime.Hours, $Uptime.Minutes
Write-Host "System Uptime: $UptimeString"

# CPU Information
$CPU = Get-CimInstance -ClassName Win32_Processor
$CPUCores = $CPU.NumberOfCores
$CPULogicalProcessors = $CPU.NumberOfLogicalProcessors
Write-Host "CPU Cores: $CPUCores (Logical Processors: $CPULogicalProcessors)"

# Usuários Logados
try {
    $LoggedUsers = (query user 2>$null | Select-Object -Skip 1 | Measure-Object).Count
    if ($LoggedUsers -eq $null) { $LoggedUsers = 0 }
} catch {
    $LoggedUsers = 0
}
Write-Host "Logged in Users: $LoggedUsers"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "CPU USAGE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# CPU Usage (média dos últimos segundos)
try {
    $CPUUsage = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 3 -ErrorAction SilentlyContinue | 
                 Select-Object -ExpandProperty CounterSamples | 
                 Measure-Object -Property CookedValue -Average).Average

    $CPUUsed = [math]::Round($CPUUsage, 1)
    $CPUIdle = [math]::Round(100 - $CPUUsage, 1)
} catch {
    $CPUUsed = "N/A"
    $CPUIdle = "N/A"
}

Write-Host "Total CPU Usage: $CPUUsed%"
Write-Host "CPU Idle: $CPUIdle%"
Write-Host "CPU Cores: $CPUCores"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "MEMORY USAGE (RAM)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Memória RAM
$TotalMemoryGB = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
$FreeMemoryGB = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
$UsedMemoryGB = [math]::Round($TotalMemoryGB - $FreeMemoryGB, 2)
$MemoryPercent = [math]::Round(($UsedMemoryGB / $TotalMemoryGB) * 100, 1)

Write-Host "Total Memory: $TotalMemoryGB GB"
Write-Host "Used Memory: $UsedMemoryGB GB ($MemoryPercent%)"
Write-Host "Free Memory: $FreeMemoryGB GB"

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "DISK USAGE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Disco C: (principal)
$Disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
$DiskTotalGB = [math]::Round($Disk.Size / 1GB, 2)
$DiskFreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
$DiskUsedGB = [math]::Round($DiskTotalGB - $DiskFreeGB, 2)
$DiskPercent = [math]::Round(($DiskUsedGB / $DiskTotalGB) * 100, 1)

Write-Host "Total Disk Space (C:): $DiskTotalGB GB"
Write-Host "Used Disk Space: $DiskUsedGB GB ($DiskPercent%)"
Write-Host "Free Disk Space: $DiskFreeGB GB"

Write-Host ""
Write-Host "All Mounted Filesystems:"
Write-Host ("{0,-10} {1,10} {2,10} {3,10} {4,6}" -f "Drive", "Total(GB)", "Used(GB)", "Free(GB)", "Use%")
Write-Host ("-" * 60)

Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $TotalGB = [math]::Round($_.Size / 1GB, 2)
    $FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
    $UsedGB = [math]::Round($TotalGB - $FreeGB, 2)
    if ($TotalGB -gt 0) {
        $Percent = [math]::Round(($UsedGB / $TotalGB) * 100, 0)
    } else {
        $Percent = 0
    }
    Write-Host ("{0,-10} {1,10} {2,10} {3,10} {4,5}%" -f $_.DeviceID, $TotalGB, $UsedGB, $FreeGB, $Percent)
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "TOP 5 PROCESSES BY CPU USAGE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

Write-Host ("{0,-10} {1,10} {2,12} {3}" -f "PID", "CPU(s)", "MEM(MB)", "COMMAND")
Write-Host ("-" * 70)

Get-Process | Where-Object {$_.CPU -ne $null} | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
    $MemoryMB = [math]::Round($_.WorkingSet64 / 1MB, 1)
    $CPUTime = [math]::Round($_.CPU, 1)
    Write-Host ("{0,-10} {1,10:N1} {2,12:N1} {3}" -f $_.Id, $CPUTime, $MemoryMB, $_.ProcessName)
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "TOP 5 PROCESSES BY MEMORY USAGE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

Write-Host ("{0,-10} {1,10} {2,12} {3}" -f "PID", "CPU(s)", "MEM(MB)", "COMMAND")
Write-Host ("-" * 70)

Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 | ForEach-Object {
    $MemoryMB = [math]::Round($_.WorkingSet64 / 1MB, 1)
    $CPUTime = if ($_.CPU) { [math]::Round($_.CPU, 1) } else { 0 }
    Write-Host ("{0,-10} {1,10:N1} {2,12:N1} {3}" -f $_.Id, $CPUTime, $MemoryMB, $_.ProcessName)
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "NETWORK STATISTICS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Conexões estabelecidas
try {
    $EstablishedConn = (Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Measure-Object).Count
} catch {
    $EstablishedConn = 0
}
Write-Host "Established Connections: $EstablishedConn"

# Portas em listening
try {
    $ListeningPorts = (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Measure-Object).Count
} catch {
    $ListeningPorts = 0
}
Write-Host "Listening Ports: $ListeningPorts"

Write-Host ""
Write-Host "Top 5 Listening Ports:"
Write-Host ("{0,-10} {1,-25} {2}" -f "Port", "Process", "PID")
Write-Host ("-" * 70)

try {
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | 
        Select-Object LocalPort, OwningProcess -Unique | 
        Sort-Object LocalPort | 
        Select-Object -First 5 | 
        ForEach-Object {
            $Process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            $ProcessName = if ($Process) { $Process.ProcessName } else { "Unknown" }
            Write-Host ("{0,-10} {1,-25} {2}" -f $_.LocalPort, $ProcessName, $_.OwningProcess)
        }
} catch {
    Write-Host "Unable to retrieve listening ports information"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Analysis completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""