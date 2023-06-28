function Add-TextToImage {
    <#
    .SYNOPSIS
    Adds text to an image using machine information variables. Written by Grumpy Admin Version 0.01 28/06/2023
    
    .DESCRIPTION
    This function takes a background image and adds text to it using machine information variables, similar to the BGInfo application. The modified image is saved as a JPG.
    
    .PARAMETER BackgroundImagePath
    The path to the background image.
    
    .PARAMETER OutputImagePath
    The path to save the modified image.
    
    .PARAMETER Font
    The font to be used for the text. Default: "Arial".
    
    .PARAMETER Size
    The font size. Default: 14.
    
    .PARAMETER AntiAlias
    Specifies whether to enable anti-aliasing for the text. Default: $true.
    
    
    .PARAMETER SetAsDesktopBackground
    Specifies whether to set the modified image as the active desktop background. Default: $false.
    
    .EXAMPLE
    Add-TextToImage -BackgroundImagePath "C:\path\to\background.jpg" -OutputImagePath "C:\path\to\output.jpg" -Size 16 -AntiAlias $false  -SetAsDesktopBackground
    
    Adds text to the background image using machine information variables with a font size of 16, no anti-aliasing. Sets the modified image as the active desktop background.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Path to the background image.")]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [String]$BackgroundImagePath,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Path to save the modified image.")]
        [String]$OutputImagePath,

        [Parameter(Position = 2, HelpMessage = "The font to be used for the text.")]
        [String]$FontName = "Arial",

        [Parameter(Position = 3, HelpMessage = "The font size.")]
        [int]$Size = 16,

        [Parameter(Position = 4, HelpMessage = "Specifies whether to enable anti-aliasing for the text.")]
        [bool]$AntiAlias = $true,

        [Parameter(Position = 5, HelpMessage = "Specifies whether to set the modified image as the active desktop background.")]
        [switch]$SetAsDesktopBackground
    )
    
    
    # Get machine information
    $machineName = $env:COMPUTERNAME
    $operatingSystem = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $processor = (Get-CimInstance -ClassName Win32_Processor).Name
    $totalMemory = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    $ipAddress = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -ne 'Loopback' }).IPAddress





    # Additional machine information variables
    $LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $SystemUpTime = (Get-Date) - $LastBootUpTime

    $Days = $SystemUpTime.Days
    $Hours = $SystemUpTime.Hours
    $Minutes = $SystemUpTime.Minutes
    $Seconds = $SystemUpTime.Seconds
    
    $uptime = "$Days days, $Hours hours, $Minutes minutes"
    
    
    
    
    $defenderLastUpdated = (Get-MpComputerStatus).AntivirusSignatureLastUpdated 
    $domainName = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain 
    $currentLogonUser = $env:USERNAME

    # Create a hashtable to store the variable names and their corresponding values
    $variables = @{
    "Machine Name" = $machineName
    "Operating System" = $operatingSystem
    "Processor" = $processor
    "Total Memory (GB)" = "{0:N2}" -f $totalMemory
    "IP Address" = $ipAddress
    "Uptime" = $uptime
    "Defender Last Updated" = $defenderLastUpdated
    "Domain Name" = $domainName
    "Current Logon User" = $currentLogonUser
    }

  
    # Create a new Graphics object
    $image = [System.Drawing.Image]::FromFile($BackgroundImagePath)
    $graphic = [System.Drawing.Graphics]::FromImage($image)

    # Set the font properties
    $font = New-Object System.Drawing.Font($FontName, $Size, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

    # Set anti-aliasing
    if ($AntiAlias) {
        $graphic.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    }
   
    $positionX = 10
    $positionY = 10

    foreach ($variable in $variables.GetEnumerator()) {
        $variableName = $variable.Key
        $variableValue = $variable.Value

        # Draw the text
        $position = New-Object System.Drawing.PointF($positionX, $positionY)
        $graphic.DrawString($variableName +":" + $variableValue, $font, $brush, $position)

        # Increase the Y position for the next variable
        $positionY += 20
    }

    # Save the modified image
    $image.Save($OutputImagePath)

    # Clean up
    $graphic.Dispose()
    $font.Dispose()
    $brush.Dispose()

    # Set the wallpaper path in the registry
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $OutputImagePath

        # Set the wallpaper style in the registry
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 2

        # Refresh the desktop
        $user32Dll = Add-Type -MemberDefinition @"
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@ -Name "User32Dll" -Namespace "User32" -PassThru

        $SPI_SETDESKWALLPAPER = 20
        $SPIF_UPDATEINIFILE = 0x01
        $SPIF_SENDCHANGE = 0x02
        $result = $user32Dll::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $OutputImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

        }
