# TrendRadar OpenClaw 打包脚本
# 用途：创建适合OpenClaw自动部署的ZIP包

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TrendRadar OpenClaw 打包工具" -ForegroundColor Cyan
Write-Host "  版本：6.0.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Get-Location
$version = Get-Content "version" -Raw
$version = $version.Trim()
$outputZip = "TrendRadar-$version-openclaw.zip"

Write-Host "项目路径: $projectRoot" -ForegroundColor Yellow
Write-Host "版本号: $version" -ForegroundColor Yellow
Write-Host "输出文件: $outputZip" -ForegroundColor Yellow
Write-Host ""

# 检查必需文件
Write-Host "[1/4] 检查必需文件..." -ForegroundColor Green

$requiredFiles = @(
    "pyproject.toml",
    "requirements.txt",
    "README.md",
    "version",
    "install-openclaw.bat",
    "install-openclaw.sh",
    "trendradar\__init__.py",
    "trendradar\__main__.py",
    "mcp_server\__init__.py",
    "mcp_server\server.py",
    "config\config.yaml",
    "config\frequency_words.txt",
    "config\timeline.yaml"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $projectRoot $file
    if (-not (Test-Path $filePath)) {
        $missingFiles += $file
        Write-Host "  [X] 缺少: $file" -ForegroundColor Red
    } else {
        Write-Host "  [OK] 存在: $file" -ForegroundColor Green
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "错误：缺少必需文件，打包终止！" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 创建临时目录
Write-Host "[2/4] 准备打包内容..." -ForegroundColor Green

$tempDir = Join-Path $env:TEMP "TrendRadar-Pack-$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# 复制文件
$filesToCopy = @(
    "pyproject.toml",
    "requirements.txt",
    "README.md",
    "version",
    "install-openclaw.bat",
    "install-openclaw.sh",
    "trendradar",
    "mcp_server",
    "config"
)

foreach ($item in $filesToCopy) {
    $sourcePath = Join-Path $projectRoot $item
    $destPath = Join-Path $tempDir $item
    
    if (Test-Path $sourcePath -PathType Container) {
        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
        Write-Host "  [OK] 复制目录: $item" -ForegroundColor Green
    } else {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  [OK] 复制文件: $item" -ForegroundColor Green
    }
}

Write-Host ""

# 清理临时目录中的不需要文件
Write-Host "[3/4] 清理不需要的文件..." -ForegroundColor Green

$excludePatterns = @(
    "__pycache__",
    "*.pyc",
    ".git",
    ".pytest_cache",
    ".iflow",
    "output",
    "uv.lock"
)

$excludeFiles = @()
Get-ChildItem -Path $tempDir -Recurse | ForEach-Object {
    foreach ($pattern in $excludePatterns) {
        if ($_.Name -like $pattern -or $_.FullName -like "*$pattern*") {
            $excludeFiles += $_.FullName
            break
        }
    }
}

$excludeFiles = $excludeFiles | Sort-Object -Unique
foreach ($file in $excludeFiles) {
    Remove-Item -Path $file -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  [DEL] 删除: $file" -ForegroundColor Gray
}

Write-Host ""

# 创建ZIP
Write-Host "[4/4] 创建ZIP包..." -ForegroundColor Green

$outputPath = Join-Path $projectRoot $outputZip
Compress-Archive -Path "$tempDir\*" -DestinationPath $outputPath -Force

# 清理临时目录
Remove-Item -Path $tempDir -Recurse -Force

# 显示结果
$fileSize = (Get-Item $outputPath).Length / 1MB
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  打包完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "输出文件: $outputZip" -ForegroundColor Yellow
Write-Host "文件大小: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Yellow
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Cyan
Write-Host "  1. 上传 $outputZip 到HTTP服务器" -ForegroundColor White
Write-Host "  2. 使用 OpenClaw 部署提示词进行部署" -ForegroundColor White
Write-Host "  3. 查看详细说明: DEPLOY_OPENCLAW.md" -ForegroundColor White
Write-Host ""