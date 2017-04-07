## Fetch all Pix/Mov from iphone
## ------

#Root dir to scan
$targetDir = "D:\iPhonePix\"

#Output file for Photo list
$fPix = "D:\iPhonePix\listPix2.txt"
"Fullname`tLength`tName" | Out-File $fPix

#Output file for Movie list
$fMov = "D:\iPhonePix\listMov2.txt"
"Fullname`tLength`tName" | Out-File $fMov

Get-ChildItem $targetDir -Recurse | Where {$_.extension -eq ".jpg" -or $_.extension -eq ".png" } | % {
     $_.FullName + "`t" + $_.Length + "`t" + $_.Name | Out-File $fPix -Append
}

Get-ChildItem $targetDir -Recurse | Where {$_.extension -eq ".mp4" -or $_.extension -eq ".mov" } | % {
     $_.FullName + "`t" + $_.Length + "`t" + $_.Name | Out-File $fMov -Append
}
