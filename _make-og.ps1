Add-Type -AssemblyName System.Drawing
$out = 'C:\Users\USER\OneDrive\Desktop\GameHubXpe\source\og-image.png'

$W = 1200; $H = 630
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Background gradient (dark blue -> dark purple)
$rect = New-Object System.Drawing.Rectangle 0, 0, $W, $H
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.Color]::FromArgb(15,23,41)), ([System.Drawing.Color]::FromArgb(26,0,51)), ([System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
$g.FillRectangle($bgBrush, $rect)

# Decorative circles (subtle pattern)
$dot1 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(50, 255, 102, 179))
$dot2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 107, 70, 255))
$g.FillEllipse($dot1, 950, 60, 220, 220)
$g.FillEllipse($dot2, -50, 380, 320, 320)
$g.FillEllipse($dot1, 1000, 420, 160, 160)

# Logo box (gradient rounded square - left side)
$logoRect = New-Object System.Drawing.Rectangle 80, 90, 160, 160
$logoBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $logoRect, ([System.Drawing.Color]::FromArgb(255,102,179)), ([System.Drawing.Color]::FromArgb(107,70,255)), ([System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = 32
$path.AddArc(80, 90, $r*2, $r*2, 180, 90)
$path.AddArc(80+160-$r*2, 90, $r*2, $r*2, 270, 90)
$path.AddArc(80+160-$r*2, 90+160-$r*2, $r*2, $r*2, 0, 90)
$path.AddArc(80, 90+160-$r*2, $r*2, $r*2, 90, 90)
$path.CloseFigure()
$g.FillPath($logoBrush, $path)
# Big "G" letter as logo (avoid emoji issues)
$logoFont = New-Object System.Drawing.Font 'Arial Black', 110, ([System.Drawing.FontStyle]::Bold)
$logoTextBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString('G', $logoFont, $logoTextBrush, (New-Object System.Drawing.RectangleF 80, 85, 160, 160), $sf)

# Big title "GameHub" - gradient pink -> purple
$titleFont = New-Object System.Drawing.Font 'Arial Black', 100, ([System.Drawing.FontStyle]::Bold)
$titleRect = New-Object System.Drawing.Rectangle 270, 80, 900, 130
$titleBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $titleRect, ([System.Drawing.Color]::FromArgb(255,102,179)), ([System.Drawing.Color]::FromArgb(140,90,255)), ([System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
$g.DrawString('GameHub', $titleFont, $titleBrush, 265, 95)

# Subtitle (gold)
$subFont = New-Object System.Drawing.Font 'Arial', 36, ([System.Drawing.FontStyle]::Bold)
$subBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255,215,0))
$g.DrawString('Portal Game Online Gratis', $subFont, $subBrush, 270, 220)

# Description (light gray)
$descFont = New-Object System.Drawing.Font 'Arial', 26, ([System.Drawing.FontStyle]::Regular)
$descBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200,200,220))
$g.DrawString('15+ Game gratis di browser - tanpa download, langsung main', $descFont, $descBrush, 80, 320)

# Game pills (rounded rectangles with game names)
$games = @('Cash King', 'Snake', '2048', 'Tic Tac Toe', 'Memory', 'Slot CaiShen', 'Tebak Angka', 'Whack-a-Mole')
$pillFont = New-Object System.Drawing.Font 'Arial', 22, ([System.Drawing.FontStyle]::Bold)
$pillTextBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
$pillBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 107, 70, 255))
$pillBorder = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255,102,179)), 2

$x = 80; $y = 400; $padX = 26; $padY = 14
foreach ($name in $games) {
  $size = $g.MeasureString($name, $pillFont)
  $w = [int]$size.Width + $padX * 2
  $h = [int]$size.Height + $padY * 2
  if (($x + $w) -gt ($W - 80)) { $x = 80; $y += 70 }
  $pillPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pr = [Math]::Min(28, [int]($h/2))
  $pillPath.AddArc($x, $y, $pr*2, $pr*2, 180, 90)
  $pillPath.AddArc($x+$w-$pr*2, $y, $pr*2, $pr*2, 270, 90)
  $pillPath.AddArc($x+$w-$pr*2, $y+$h-$pr*2, $pr*2, $pr*2, 0, 90)
  $pillPath.AddArc($x, $y+$h-$pr*2, $pr*2, $pr*2, 90, 90)
  $pillPath.CloseFigure()
  $g.FillPath($pillBg, $pillPath)
  $g.DrawPath($pillBorder, $pillPath)
  $g.DrawString($name, $pillFont, $pillTextBrush, [single]($x + $padX), [single]($y + $padY))
  $x += $w + 14
}

# URL bar at bottom (gold)
$urlBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255,215,0))
$g.FillRectangle($urlBg, 0, $H - 70, $W, 70)
$urlFont = New-Object System.Drawing.Font 'Arial', 30, ([System.Drawing.FontStyle]::Bold)
$urlBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Black)
$urlSf = New-Object System.Drawing.StringFormat
$urlSf.Alignment = [System.Drawing.StringAlignment]::Center
$urlSf.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString('gamevirtual.netlify.app', $urlFont, $urlBrush, (New-Object System.Drawing.RectangleF 0, ($H-70), $W, 70), $urlSf)

$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

"Done: $out"
"Size: {0:N1} KB" -f ((Get-Item $out).Length / 1KB)
