function New-YuGiOhCardCollage {
    param(
        [switch]$DownloadSprites,
        [int]$DownloadDelayTime = 0, #Time in seconds; Time to wait before starting next download; Helps prevent server rejection.
        [switch]$CropSprites,
        [switch]$CollageSprites,
        [int]$CollageWidth = 1920, #Width in px
        [int]$CollageHeight = 1080, #Height in px
        [string]$Path = ".\"
    )

    $rawSpritesPath = Join-Path -Path $Path -ChildPath "raw"
    $croppedSpritesPath = Join-Path -Path $Path -ChildPath "cropped"
    $collageOutputPath = Join-Path -Path $Path -ChildPath "collage"

    $croppedSpriteWidth = 64
    $croppedSpriteHeight = 80

    if($DownloadSprites) {
        $url = "https://yugipedia.com/wiki/Gallery_of_Yu-Gi-Oh!_Duel_Monsters_4:_Battle_of_Great_Duelist_cards"

        $webData = Invoke-WebRequest $url
        $cardImages = $webData.Images | 
            Where-Object -Property width -EQ 160 | 
            Where-Object -Property height -EQ 144

        $currentCard = 1
        $totalCards = $cardImages.Count
        foreach($image in $cardImages) {
            $percentComplete = ($currentCard / $totalCards) * 100
            Write-Progress -Activity "Downloading card sprites..." -Status "Current Card #: $currentCard / $totalCards" -PercentComplete $percentComplete
    
            Write-Host "Requesting webData from " -ForegroundColor Yellow -NoNewline
            Write-Host $image.src -ForegroundColor Cyan

            if(-not(Test-Path -Path $rawSpritesPath)) {
                New-Item -Path $rawSpritesPath -ItemType Directory
            }

            $outputPath = Join-Path -Path $rawSpritesPath -ChildPath $image.src.Split("/")[-1]
            Invoke-WebRequest $image.src -OutFile $outputPath

            Start-Sleep -Seconds $DownloadDelayTime

            $currentCard++
        }
    }

    if($CropSprites) {
        $RawSprites = Get-ChildItem $rawSpritesPath -File | Where-Object -Property Extension -Like ".png"

        
        if(-not(Test-Path -Path $croppedSpritesPath)) {
            New-Item -Path $croppedSpritesPath -ItemType Directory
        }

        $startX = 8
        $startY = 16

        foreach($RawSprite in $RawSprites) {
            Add-Type -AssemblyName System.Drawing
            $image = [System.Drawing.Image]::FromFile($RawSprite.FullName)
            $cropRectangle = New-Object System.Drawing.Rectangle($startX, $startY, $croppedSpriteWidth, $croppedSpriteHeight)

            # Create the cropped image
            $croppedImage = $image.Clone($cropRectangle, $image.PixelFormat)

            $outputPath = Join-Path -Path $croppedSpritesPath -ChildPath $RawSprite.Name
            # Save the cropped image
            $croppedImage.Save($outputPath)

            # Clean up
            $image.Dispose()
            $croppedImage.Dispose()
        }
    }

    if($CollageSprites) {
        if(-not(Test-Path -Path $collageOutputPath)) {
            New-Item -Path $collageOutputPath -ItemType Directory
        }

        $CollageHoriCount = [int]([Math]::Ceiling($CollageWidth / $croppedSpriteWidth))
        $CollageVertCount = [int]([Math]::Ceiling($CollageHeight / $croppedSpriteHeight))

        $CollageOutput = New-Object System.Drawing.Bitmap (($CollageHoriCount * $croppedSpriteWidth), ($CollageVertCount * $croppedSpriteHeight))

        $allCroppedSprites = gci $croppedSpritesPath -File
        $allCroppedSprites = $allCroppedSprites | Get-Random -Count $allCroppedSprites.Count

        $spriteIndex = 0
        for ($y = 0; $y -lt $CollageVertCount; $y++) {
            for ($x = 0; $x -lt $CollageHoriCount; $x++) {
                $imagePath = $allCroppedSprites[$spriteIndex].FullName
                $subImage = [System.Drawing.Image]::FromFile($imagePath)
                $graphics = [System.Drawing.Graphics]::FromImage($CollageOutput)
                $graphics.DrawImage($subImage, ($x * $croppedSpriteWidth), ($y * $croppedSpriteHeight), $croppedSpriteWidth, $croppedSpriteHeight)
                $subImage.Dispose()
                $graphics.Dispose()

                $spriteIndex++
                if($spriteIndex -ge $allCroppedSprites.count) {
                    $spriteIndex = 0
                }
            }
        }

        # Save the final collage
        $timestamp = (Get-Date).ToString("yyMMddHHmmss")
        $CollageOutputPath = Join-Path -Path $collageOutputPath -ChildPath "collage_$timestamp.png"
        $CollageOutput.Save($CollageOutputPath)

        # Clean up
        $CollageOutput.Dispose()
    }
}