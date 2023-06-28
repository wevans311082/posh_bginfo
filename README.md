# posh_bginfo
A basic BGINFO clone in Powershell


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
