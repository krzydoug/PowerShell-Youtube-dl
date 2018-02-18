<#
.SYNOPSIS 
	Download audio and video from the internet, mainly from youtube.com
	
.DESCRIPTION 
	This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a command using parameters, or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.
	
.PARAMETER Video 
	Download the video of the provided URL. Output file formats will vary.
.PARAMETER Audio 
	Download only the audio of the provided URL. Output file format will be mp3.
.PARAMETER FromFiles 
	Download playlist URL's listed in videoplaylists.txt and audioplaylists.txt 
.PARAMETER Convert
	Convert the downloaded video to the default file format using the default settings.
.PARAMETER URL 
	The video URL to download from.
.PARAMETER OutputPath 
	The directory where to save the output file.
.PARAMETER Install
	Install the script to "C:\Users\%USERNAME%\Scripts\Youtube-dl" and create desktop and Start Menu shortcuts.
.PARAMETER Update
	Update youtube-dl.exe and the ffmpeg files to the most recent versions.

.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1
	Runs the script in GUI mode.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads the video at the specified URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads only the audio of the specified video URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -FromFiles
	Downloads video URL's listed in videoplaylists.txt and audioplaylists.txt files. These files are generated when the script is ran for the first time.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -OutputPath "C:\Users\%USERNAME%\Desktop"
	Downloads the audio of the specified video URL to the user provided location.
	
.NOTES 
	Requires Windows 7 or higher and PowerShell 5.0 or greater.
	Author: mpb10
	Updated: January 27th, 2018
	Version: 2.0.0

.LINK 
	https://github.com/mpb10/PowerShell-Youtube-dl
#>


# ======================================================================================================= #
# ======================================================================================================= #


Param(
	[Switch]$Video,
	[Switch]$Audio,
	[Switch]$FromFiles,
	[Switch]$Convert,
	[String]$URL,
	[String]$OutputPath,
	[Switch]$Install,
	[Switch]$UpdateExe,
	[Switch]$UpdateScript
)


# ======================================================================================================= #
# ======================================================================================================= #
#
# SCRIPT SETTINGS
#
# ======================================================================================================= #

$AudioSaveLocation = "$ENV:USERPROFILE\Music\Youtube-dl"
$VideoSaveLocation = "$ENV:USERPROFILE\Videos\Youtube-dl"
$UseArchiveFile = $False
$EntirePlaylist = $False

$ConvertFile = $False
$FileExtension = "webm"
$VideoBitrate = "-b:v 800k"
$AudioBitrate = "-b:a 128k"
$Resolution = "-s 640x360"
$StartTime = ""
$StopTime = ""
$StripAudio = ""
$StripVideo = ""


# ======================================================================================================= #
# ======================================================================================================= #
#
# FUNCTIONS
#
# ======================================================================================================= #

# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	If ($NumOfParams -eq 0) {
		Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
		$Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}



Function DownloadFile {
	Param(
		[String]$URLToDownload,
		[String]$SaveLocation
	)
	(New-Object System.Net.WebClient).DownloadFile($URLToDownload, $SaveLocation)
}



Function DownloadYoutube-dl {
	DownloadFile "http://yt-dl.org/downloads/latest/youtube-dl.exe" "$BinFolder\youtube-dl.exe"
}



Function DownloadFfmpeg {
	If (([environment]::Is64BitOperatingSystem) -eq $True) {
		DownloadFile "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.4.1-win64-static.zip" "$RootFolder\ffmpeg_3.4.1.zip"
	}
	Else {
		DownloadFile "http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-3.4.1-win32-static.zip" "$RootFolder\ffmpeg_3.4.1.zip"
	}

	Expand-Archive -Path "$RootFolder\ffmpeg_3.4.1.zip" -DestinationPath "$RootFolder"

	$ffmpegBinFolder = $RootFolder + "\ffmpeg-3.4.1-win64-static\bin\*"
	$ffmpegExtractedFolder = $RootFolder + "\ffmpeg-3.4.1-win64-static"
	Copy-Item -Path "$ffmpegBinFolder" -Destination "$BinFolder" -Recurse -Filter "*.exe" -ErrorAction Silent
	Remove-Item -Path "$RootFolder\ffmpeg_3.4.1.zip"
	Remove-Item -Path "$ffmpegExtractedFolder" -Recurse 
}



Function InstallScript {
	
	$Script:RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
	$Script:BinFolder = $RootFolder + "\bin"
	$ENV:Path += ";$BinFolder"
	$ScriptsFolder = $RootFolder + "\scripts"
	$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
	$DesktopFolder = $ENV:USERPROFILE + "\Desktop"
	
	If ((Test-Path "$RootFolder") -eq $True) {
		Remove-Item -Path "$RootFolder\bin" -Filter "*.exe" -Recurse -ErrorAction Silent
		Remove-Item -Path "$RootFolder\scripts" -Filter "*.ps1" -Recurse -ErrorAction Silent
	}
	Else {
		New-Item -Type Directory -Path "$RootFolder"
	}
	
	New-Item -Type Directory -Path "$BinFolder" -ErrorAction Silent
	New-Item -Type Directory -Path "$ScriptsFolder" -ErrorAction Silent
	New-Item -Type Directory -Path "$StartFolder" -ErrorAction Silent
	
	DownloadYoutube-dl
	DownloadFfmpeg
	
	Copy-Item "$PSScriptRoot\youtube-dl.ps1" -Destination "$ScriptsFolder"
	
	DownloadFile "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/Youtube-dl.lnk" "$RootFolder\Youtube-dl.lnk"
	Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$DesktopFolder"
	Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$StartFolder"
	
	DownloadFile "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/LICENSE" "$RootFolder\LICENSE"
	
	DownloadFile "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/README.md" "$RootFolder\README.md"
	
	Write-Host "`nInstallation complete. Please restart the script.`n" -ForegroundColor "Yellow"
	PauseScript
}



Function UpdateExe {
	Remove-Item -Path "$RootFolder\bin" -Filter "*.exe" -Recurse -ErrorAction Silent
	DownloadYoutube-dl
	DownloadFfmpeg
	Write-Host "`nUpdate .exe files complete. Please restart the script." -ForegroundColor "Yellow"
	PauseScript
}



Function UpdateScript {
	DownloadFile "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/scripts/youtube-dl.ps1" "$RootFolder\youtube-dl.ps1"
	Copy-Item "$RootFolder\youtube-dl.ps1" -Destination "$RootFolder\scripts"
	Remove-Item "$RootFolder\youtube-dl.ps1"
	Write-Host "`nUpdate script file complete. Please restart the script." -ForegroundColor "Yellow"
	PauseScript
}



Function SettingsInitialization {
	If ($UseArchiveFile -eq $True) {
		$Script:SetUseArchiveFile = "--download-archive ""$ArchiveFile"""
	}
	Else {
		$Script:SetUseArchiveFile = ""
	}
	
	If ($EntirePlaylist -eq $True) {
		$Script:SetEntirePlaylist = "--yes-playlist"
	}
	Else {
		$Script:SetEntirePlaylist = "--no-playlist"
	}
	
	If ($StripVideo -eq $True) {
		$SetStripVideo = "-vn"
	}
	Else {
		$SetStripVideo = ""
	}
	
	If ($StripAudio -eq $True) {
		$SetStripAudio = "-an"
	}
	Else {
		$SetStripAudio = ""
	}
	
	If ($ConvertFile -eq $True -or $Convert -eq $True) {
		$Script:FfmpegCommand = "--recode-video $FileExtension --postprocessor-args ""$VideoBitrate $AudioBitrate $Resolution $StartTime $StopTime $SetStripVideo $SetStripAudio"" --prefer-ffmpeg"		
	}
	Else {
		$Script:FfmpegCommand = ""
	}
}



Function DownloadVideo {
	Param(
		[String]$URLToDownload
	)
	Write-Host "`nDownloading video from: $URLToDownload`n"
	If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
		$YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors $FfmpegCommand --yes-playlist $SetUseArchiveFile ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
	Else {
		$YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(title)s.%(ext)s"" --ignore-errors $FfmpegCommand $SetEntirePlaylist ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
}



Function DownloadAudio {
	Param(
		[String]$URLToDownload
	)
	Write-Host "`nDownloading audio from: $URLToDownload`n"
	If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
		$YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist $SetUseArchiveFile ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
	Else {
		$YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(title)s.%(ext)s"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg $SetEntirePlaylist ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
}



Function DownloadPlaylists {
	Write-Host "`nDownloading playlist URLs listed in:`n   $VideoPlaylistFile`n   $AudioPlaylistFile"
	
	Get-Content $VideoPlaylistFile | ForEach-Object {
		Write-Host "`nDownloading playlist: $_`n" -ForegroundColor "Gray"
		DownloadVideo "$_"
	}

	Get-Content $AudioPlaylistFile | ForEach-Object {
		Write-Host "`nDownloading playlist: $_`n" -ForegroundColor "Gray"
		DownloadAudio "$_"
	}

	
}



Function CommandLineMode {
	If ($Install -eq $True) {
		Write-Host "`nInstalling Youtube-dl to: ""$ENV:USERPOFILE\Scripts\Youtube-dl""`n"
		InstallScript
		Write-Host "`nExiting in 5 seconds ...`n" -ForegroundColor "Gray"
		Start-Sleep -s 5
		Exit
	}
	ElseIf ($UpdateExe -eq $True -and $UpdateScript -eq $True) {
		Write-Host "`nUpdating youtube-dl.exe and ffmpeg.exe files ..."
		UpdateExe
		Write-Host "`nUpdating youtube-dl.ps1 script file ..."
		UpdateScript
		Write-Host "`nExiting in 5 seconds ...`n" -ForegroundColor "Gray"
		Start-Sleep -s 5
		Exit
	}
	ElseIf ($UpdateExe -eq $True) {
		Write-Host "`nUpdating youtube-dl.exe and ffmpeg files ..."
		UpdateExe
		Write-Host "`nExiting in 5 seconds ...`n" -ForegroundColor "Gray"
		Start-Sleep -s 5
		Exit
	}
	ElseIf ($UpdateScript -eq $True) {
		Write-Host "`nUpdating youtube-dl.ps1 script file ..."
		UpdateScript
		Write-Host "Exiting in 5 seconds ...`n" -ForegroundColor "Gray"
		Start-Sleep -s 5
		Exit
	}
	
	If (($OutputPath.Length -gt 0) -and ((Test-Path "$OutputPath") -eq $False)) {
		New-Item -Type directory -Path "$OutputPath"
		$Script:VideoSaveLocation = $OutputPath
		$Script:AudioSaveLocation = $OutputPath
	}
	ElseIf ($OutputPath.Length -gt 0) {
		$Script:VideoSaveLocation = $OutputPath
		$Script:AudioSaveLocation = $OutputPath
	}
	
	SettingsInitialization
	
	If ($FromFiles -eq $True -and $Video -eq $False -and $Audio -eq $False) {
		DownloadPlaylists
		Write-Host "`nDownloads complete.`nDownloaded to: ""$VideoSaveLocation"" and ""$AudioSaveLocation""`n" -ForegroundColor "Yellow"
	}
	ElseIf ($FromFiles -eq $True -and ($Video -eq $True -or $Audio -eq $True)) {
		Write-Host "`n[ERROR]: The parameter -FromFiles can't be used with -Video or -Audio.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $False) {
		DownloadVideo "$URL"
		Write-Host "`nDownload complete.`nDownloaded to: ""$VideoSaveLocation""`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Audio -eq $True -and $Video -eq $False) {
		DownloadAudio "$URL"
		Write-Host "`nDownload complete.`nDownloaded to: ""$AudioSaveLocation`n""" -ForegroundColor "Yellow"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $True) {
		Write-Host "`n[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	Else {
		Write-Host "`n[ERROR]: Invalid parameters provided." -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}



Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 0) {
		$URL = ""
		Clear-Host
		Write-Host "================================================================"
		Write-Host "                Youtube-dl Download Script v2.0.0               " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Download Video"
		Write-Host "  2   - Download Audio"
		Write-Host "  3   - Download from Playlist Files"
		Write-Host "  4   - Settings"
		Write-Host "`n  0   - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Switch ($MenuOption) {
			1 {
				Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$URL = (Read-Host "URL").Trim()
				
				If ($URL.Length -gt 0) {
					Clear-Host
					SettingsInitialization
					DownloadVideo $URL
					Write-Host "`nFinished downloading video to: ""$VideoSaveLocation""" -ForegroundColor "Yellow"
					PauseScript
				}
				$MenuOption = 99
			}
			2 {
				Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$URL = (Read-Host "URL").Trim()
				
				If ($URL.Length -gt 0) {
					Clear-Host
					SettingsInitialization
					DownloadAudio $URL
					Write-Host "`nFinished downloading audio to: ""$AudioSaveLocation""" -ForegroundColor "Yellow"
					PauseScript
				}
				$MenuOption = 99
			}
			3 {
				Clear-Host
				SettingsInitialization
				DownloadPlaylists
				Write-Host "`nFinished downloading URLs from playlist files." -ForegroundColor "Yellow"
				PauseScript
				$MenuOption = 99
			}
			4 {
				Clear-Host
				SettingsMenu
				$MenuOption = 99
			}
			0 {
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
}



Function SettingsMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================"
		Write-Host "                         Settings Menu                          " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Install script to: ""$ENV:USERPOFILE\Scripts\Youtube-dl"""
		Write-Host "  2   - Update youtube-dl.exe and ffmpeg.exe"
		Write-Host "  3   - Update youtube-dl.ps1 script file."
		Write-Host "`n  0   - Return to Main Menu`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Switch ($MenuOption) {
			1 {
				Write-Host "`nInstalling Youtube-dl to: ""$ENV:USERPOFILE\Scripts\Youtube-dl"""
				InstallScript
				Write-Host "`nExiting in 5 seconds ...`n" -ForegroundColor "Gray"
				Start-Sleep -s 5
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			2 {
				Write-Host "`nUpdating youtube-dl.exe and ffmpeg.exe files ..."
				UpdateExe
				Write-Host "Exiting in 5 seconds ...`n" -ForegroundColor "Gray"
				Start-Sleep -s 5
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			3 {
				Write-Host "`nUpdating youtube-dl.ps1 script file ..."
				UpdateScript
				Write-Host "Exiting in 5 seconds ...`n" -ForegroundColor "Gray"
				Start-Sleep -s 5
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			0 {
				Return
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
}


# ======================================================================================================= #
# ======================================================================================================= #

If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[NOTE]: Your PowerShell installation is not version 5.0 or greater.`n        This script requires PowerShell version 5.0 or greater to run.`n        You can download PowerShell version 5.0 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
	PauseScript
	Exit
}
Else {
	Write-Verbose "PowerShell is up to date."
}

If ($PSScriptRoot -eq "$ENV:USERPOFILE\Scripts\Youtube-dl\scripts") {
	$RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
}
Else {
	$RootFolder = "$PSScriptRoot\.."
}

$ArchiveFile = $RootFolder + "\downloadarchive.txt"
If ((Test-Path "$ArchiveFile") -eq $False) {
	New-Item -Type file -Path "$ArchiveFile"
}

$VideoPlaylistFile = $RootFolder + "\videoplaylists.txt"
If ((Test-Path "$VideoPlaylistFile") -eq $False) {
	New-Item -Type file -Path "$VideoPlaylistFile"
}

$AudioPlaylistFile = $RootFolder + "\audioplaylists.txt"
If ((Test-Path "$AudioPlaylistFile") -eq $False) {
	New-Item -Type file -Path "$AudioPlaylistFile"
}

$BinFolder = $RootFolder + "\bin"
If ((Test-Path "$BinFolder") -eq $False) {
	New-Item -Type Directory -Path "$BinFolder"
}
$ENV:Path += ";$BinFolder"

$NumOfParams = ($PSBoundParameters.Count)

If ((Test-Path "$BinFolder\youtube-dl.exe") -eq $False -or (Test-Path "$BinFolder\ffmpeg.exe") -eq $False -or (Test-Path "$BinFolder\ffplay.exe") -eq $False -or (Test-Path "$BinFolder\ffprobe.exe") -eq $False) {
	Write-Host "`n.exe files not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	Remove-Item -Path "$RootFolder\bin" -Filter "*.exe" -Recurse -ErrorAction Silent
	DownloadYoutube-dl
	DownloadFfmpeg
}


# ======================================================================================================= #
# ======================================================================================================= #


If ($NumOfParams -gt 0) {
	CommandLineMode
}
Else {
	$BackgroundColorBefore = $HOST.UI.RawUI.BackgroundColor
	$ForegroundColorBefore = $HOST.UI.RawUI.ForegroundColor

	$HOST.UI.RawUI.BackgroundColor = "Black"
	$HOST.UI.RawUI.ForegroundColor = "White"

	MainMenu
	
	$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
	$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore

	Write-Host "End GUI mode."
	PauseScript
	Exit
}






# $ENV:USERPROFILE is empty for some reason. 
























