Add-Type -AssemblyName System.Drawing

$src = 'C:\Users\USER\OneDrive\Desktop\GameHubXpe\desktop-app\icon-source.png'
$out = 'C:\Users\USER\OneDrive\Desktop\GameHubXpe\source\icons'
New-Item -ItemType Directory -Path $out -Force | Out-Null

if (-not (Test-Path $src)) { Write-Host "Source not found: $src"; exit 1 }

$img = [System.Drawing.Image]::FromFile($src)
Write-Host "Source: $($img.Width) x $($img.Height)"

# Center-crop ke square
$sq = [Math]::Min($img.Width, $img.Height)
$cropX = [int](($img.Width - $sq) / 2)
$cropY = [int](($img.Height - $sq) / 2)
$square = New-Object System.Drawing.Bitmap $sq, $sq
$cg = [System.Drawing.Graphics]::FromImage($square)
$cg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$cg.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $sq, $sq), $cropX, $cropY, $sq, $sq, [System.Drawing.GraphicsUnit]::Pixel)
$cg.Dispose()
$img.Dispose()
Write-Host "Cropped to square: $sq x $sq"

# Generate regular icons di berbagai size (sesuai PWA standard)
$sizes = @(72, 96, 128, 144, 152, 192, 384, 512)
foreach ($sz in $sizes) {
  $bmp = New-Object System.Drawing.Bitmap $sz, $sz
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.DrawImage($square, 0, 0, $sz, $sz)
  $bmp.Save("$out\icon-$sz.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Host "  icon-$sz.png"
}

# Generate MASKABLE icon (PWA Android requirement)
# Maskable = ikon di center 80% dengan padding bg di sekeliling
# Android akan crop dengan shape mask (circle/squircle), jadi outer 20% bisa hilang
$maskSize = 512
$safeZone = [int]($maskSize * 0.8)  # 410px
$padding = [int](($maskSize - $safeZone) / 2)  # 51px

$maskBmp = New-Object System.Drawing.Bitmap $maskSize, $maskSize
$mg = [System.Drawing.Graphics]::FromImage($maskBmp)
$mg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$mg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

# Background dark (sama dengan theme_color GameHub)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.Rectangle 0, 0, $maskSize, $maskSize), ([System.Drawing.Color]::FromArgb(15, 23, 41)), ([System.Drawing.Color]::FromArgb(26, 0, 51)), ([System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
$mg.FillRectangle($bgBrush, 0, 0, $maskSize, $maskSize)

# Draw ikon di safe zone center
$mg.DrawImage($square, $padding, $padding, $safeZone, $safeZone)
$maskBmp.Save("$out\icon-512-maskable.png", [System.Drawing.Imaging.ImageFormat]::Png)
$mg.Dispose(); $maskBmp.Dispose()
Write-Host "  icon-512-maskable.png (with safe-zone padding)"

$square.Dispose()

Write-Host ""
Write-Host "DONE. Files in: $out"
Get-ChildItem $out | Select-Object Name, @{n='KB';e={[math]::Round($_.Length/1KB, 1)}} | Format-Table -AutoSize
