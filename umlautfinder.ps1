<#
    #### requires ps-version 3.0 ####
    <#
    .SYNOPSIS
    searches for umlauts in folder and filenames only for logging or either changing them. 
    Replacement of these characters Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')
    .DESCRIPTION
    script searches for special characters in files and folders ('ä','ö','ü','Ä','Ö','Ü','ß')
    .PARAMETER checkpath
    path where to search for special characters
    .PARAMETER logpath
    path for logfiles
    .PARAMETER whatif
    creates protocoll but no changes
    .PARAMETER changeumlauts
    creates protocoll and changes umlauts
    .INPUTS
    -
    .OUTPUTS
    two logfiles will be created (files and folders)
    .NOTES
    Version:        0.1
    Author:         Alexander Koehler
    Creation Date:  Wednesday, March 31st 2021, 10:07:13 pm
    File: umlautfinder.ps1
    Copyright (c) 2021 blog.it-koehler.com
    HISTORY:
    Date      	          By	Comments
    ----------	          ---	----------------------------------------------------------

    .LINK
    https://blog.it-koehler.com/en/

    .COMPONENT
    Required Modules: 

    .LICENSE
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the Software), to deal
    in the Software without restriction, including without limitation the rights
    to use copy, modify, merge, publish, distribute sublicense and /or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
 
    .EXAMPLE
    .\umlautfinder.ps1 -checkpath \\server\share -logpath C:\temp\ -whatif 
    .\umlautfinder.ps1 -checkpath X:\ -logpath C:\log\ -changeumlauts
    .\umlautfinder.ps1 -checkpath X:\,\\server\share2,C:\documents -logpath C:\log\ -changeumlauts
    #

#>
[CmdletBinding()]
param (
  [Parameter(Mandatory = $true, HelpMessage='"w:\","x:\"',ValueFromPipeline,ValueFromPipelineByPropertyName)]
  #test if the folder exists, otherwise throw an error.Test if the user provides a full path to the folder
  [Object[]]
  [ValidateScript({
        #check if destination is a folder
        foreach($obj in $_){
          if(($_ | Test-Path -PathType Leaf)){
            
            throw "The path argument has to be a folder. File paths are not allowed."
          }
          else{
            return $true
          }
        }
        
  })]
  #check if it is a path to folder
  #[System.IO.DirectoryInfo]$checkpath,
  $checkpath,
  #test if the file exists, otherwise throw an error.Test if the user provides a full path to the file
  [Parameter(Mandatory = $true , HelpMessage="c:\logs\")]
  [ValidateScript({
       
        if(($_ | Test-path -PathType Leaf)){
          throw "path has to be a folder, no files allowed!"
        }
       
        return $true
        
  })]
  #check if it is a folder path
  [System.IO.DirectoryInfo]$logpath,
  #parameter for executing and changing special characters (with logging) 
  [Parameter(Mandatory = $false)]
  [switch]$changeumlauts,
  #whatif parameter (only logging) 
  [Parameter(Mandatory = $false)]
  [switch]$whatif=$false
)


#file logging
[string] $csvLogfilePath = "$logpath"
[string] $csvLogfileDate = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
[string] $csvLogfileNamePrefix = "umlaut-finder-files-"
[string] $csvLogfileName = $("$csvLogfileNamePrefix" + "$csvLogfileDate" + ".csv")
[string] $csvLogfile = $csvLogfilePath + "\" + $csvLogfileName

#folder logging
[string] $csvLogfilePathfolder = "$logpath"
[string] $csvLogfileNamePrefixfolder = "umlaut-finder-folder-"
[string] $csvLogfileName = $("$csvLogfileNamePrefixfolder" + "$csvLogfileDate" + ".csv")
[string] $csvLogfilefolder = $csvLogfilePathfolder + "\" + $csvLogfileName
#adding tableheader
Add-Content -Path "$csvLogfile" -Value "#### files with special characters" -Encoding UTF8
Add-Content -Path "$csvLogfile" -Value "folderpath;filename;duplicates;maxpathlengtherror" -Encoding UTF8
Add-Content -Path "$csvLogfilefolder" -Value "#### Folders with special characters" -Encoding UTF8
Add-Content -Path "$csvLogfilefolder" -Value "folderpath;duplicates;maxpathlengtherror" -Encoding UTF8

foreach($pathstocheck in $checkpath){
  #search patterns
  $pattern = 'ä','ö','ü','Ä','Ö','Ü','ß'
  foreach($folder in $pathstocheck){
    Write-Host "####Searching files with special characters in folder: $folder ..." -ForegroundColor Magenta
    #find all files/folders inside specified path  
    $files=Get-ChildItem  -Path "$Folder" -Recurse -File  | Sort-Object fullname 
    $folders = Get-ChildItem  -Path "$Folder" -Recurse -Directory | Sort-Object fullname
    ####searching for files
    foreach ($file in $files) {
      #check pathlength
      $fullpathlength = ($file).Fullname.Length
      
      
        #filename without file extension
        $umlautfile = $file.BaseName
        $umlauts = $(try {Select-String -InputObject $umlautfile -Pattern $pattern -AllMatches} catch {$null})
        #only rename files with umlauts
        If ($umlauts -ne $Null) {
          $filename1 = ($file).Name
          $path1 = ($file).DirectoryName
          Write-Host "files with special characters: $filename1  in folder: $path1" -ForegroundColor Yellow
          
          if($fullpathlength -lt 260){
                Add-Content -Path $csvLogfile -Value "$path1;$filename1" -Encoding UTF8
            
          
                  if(($whatif.IsPresent) -or ($whatif -eq $false)){
                    $NewName=$file.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+$file.Extension
                    if(Test-Path "$path1\$NewName"){
                      $NewName=$file.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+"--1"+$file.Extension
                      Write-Host "duplicated file name detected new name $NewName" -ForegroundColor Red
                      Add-Content -Path "$csvLogfile" -Value "$path1;$filename1;DUP--$NewName" -Encoding UTF8
                      $file | Rename-Item -NewName $NewName -WhatIf
                    }
                    else{
                      $file | Rename-Item -NewName $NewName -WhatIf
                    }
                   }
                  if($changeumlauts.IsPresent){
                    $NewName=$file.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+$file.Extension
                    if(Test-Path "$path1\$NewName"){
                      Write-Host "duplicated file with name $newname detected, adding --1" -ForegroundColor Red
                      $NewName=$file.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+"--1"+$file.Extension
            
                      $file | Rename-Item -NewName "$NewName"
                      Add-Content -Path "$csvLogfile" -Value "$path1;$filename1;DUP--$NewName" -Encoding UTF8
                    }
                    else{$file | Rename-Item -NewName $NewName}
          
                  }
          
          }
          else{
            #if path is more than 260 chars
            if(($whatif.IsPresent) -or ($whatif -eq $false)){
              $fullfilepath = ($file).fullname
              Write-Host "WARNING Special character found but path $fullfilepath more than 260 characterslong,length: $fullpathlength" -ForegroundColor Yellow
              #change path with .net function for long paths
              $pathtofile = ($file).Fullname
              $pathtoolong = "\\?\$pathtofile"
              $NewName=$file.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+$file.Extension
              #rename
              Rename-Item -LiteralPath "$pathtoolong" -NewName $NewName -WhatIf
              Add-Content -Path $csvLogfile -Value "$path1;$filename1;;WARNING MAX-Path-Length $fullpathlength (Rename done)" -Encoding UTF8
            }
            
            
             if($changeumlauts.IsPresent){
            
               $fullfilepath = ($file).fullname
               Write-Host "WARNING Special character found but path $fullfilepath more than 260 characterslong,length: $fullpathlength" -ForegroundColor Yellow
              #change path with .net function for long paths
               $pathtofile = ($file).Fullname
               $pathtoolong = "\\?\$pathtofile"
               $NewName=$file.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+$file.Extension
              #rename file
               Rename-Item -LiteralPath "$pathtoolong" -NewName $NewName
               Add-Content -Path $csvLogfile -Value "$path1;$filename1;;WARNING MAX-Path-Length $fullpathlength (Rename done)" -Encoding UTF8
             }
          
          
          }
          
          
   
        }
  
  
        else{
          $dateiohneumlaute = ($file).Name
          Write-Host "File: $dateiohneumlaute has no special characters" -ForegroundColor Green
  
        }
      
    }
    Write-Host "#### Searching for folders with special characters..." -ForegroundColor Magenta
    ##searching foldername
    foreach ($fold in $folders) {
      #checking folder length
      $fullpathlength = ($fold).Fullname.Length
      #getting foldername
      $umlautfolder = $fold.BaseName
      
      #check if folder contains special character
      $umlautfold = $(try {Select-String -InputObject $umlautfolder -Pattern $pattern -AllMatches} catch {$null})
      If ($umlautfold -ne $Null) {
        $ordnername = ($fold).Name
        #get full path
        $ordnerpfad = ($fold).FullName
        Write-Host "Folder with special character found: $ordnername  see path: $ordnerpfad" -ForegroundColor Yellow
        #logging
        #check if folderpath is longer than 260 chars
        if($fullpathlength -lt 260){
          Add-Content -Path "$csvLogfilefolder" -Value "$ordnerpfad" -Encoding UTF8
          #parameter whatif is set, no changes made to folder structure (simulation)
          if($whatif.IsPresent){
            $NewName=$fold.Name.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')
            $newpath = (($fold | Select-Object PSparentpath -ExpandProperty PSparentpath) + "\$NewName")
            if(Test-Path "$newpath"){
              Write-Host "duplicated folders detected, adding --1" -ForegroundColor Red
              $NewName=$fold.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')
              $Newname = "$NewName--1"
              $fold | Rename-Item -NewName "$NewName" -WhatIf
              #additional logging
              Add-Content -Path "$csvLogfilefolder" -Value "$ordnerpfad;DUP--$NewName (Rename done)" -Encoding UTF8
            }
            else{
              $fold | Rename-Item -NewName $NewName -WhatIf
            }
      
          }
          #if parameter is set
          if($changeumlauts.IsPresent){
            $NewName=$fold.Name.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')
            $newpath = (($fold | Select-Object PSparentpath -ExpandProperty PSparentpath) + "\$NewName")
            #check if the new folder name already exists
            if(Test-Path "$newpath"){
              Write-Host "duplicated folders detected, adding --1" -ForegroundColor Red
              $NewName=$fold.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')
              $Newname = "$NewName--1"
              $fold | Rename-Item -NewName "$NewName"
              #additional logging
              Add-Content -Path "$csvLogfilefolder" -Value "$ordnerpfad;DUP--$NewName (Rename done)" -Encoding UTF8
          
            }
            else{$fold | Rename-Item -NewName $NewName}
          
          }
      
        }
        else{
        
          
          if(($whatif.IsPresent) -or ($whatif -eq $false)){
              Write-Host "WARNING Special character found but path $ordnerpfad more than 260 characterslong,length: $fullpathlength" -ForegroundColor Yellow
              #change path with .net function for long paths
              $pathtoolong = "\\?\$ordnerpfad"
              $NewName=$fold.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+$file.Extension
              #rename
              $pathtoolong | Rename-Item -NewName "$NewName" -WhatIf
              Add-Content -Path $csvLogfile -Value "$ordnerpfad;WARNING MAX-Path-Length $fullpathlength (Rename done)" -Encoding UTF8
            }
            
            
             if($changeumlauts.IsPresent){
            
               Write-Host "WARNING Special character found but path $ordnerpfad more than 260 characterslong,length: $fullpathlength" -ForegroundColor Yellow
              #change path with .net function for long paths
              $pathtoolong = "\\?\$ordnerpfad"
              $NewName=$fold.BaseName.Replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß','ss')+$file.Extension
              #rename
              $pathtoolong | Rename-Item -NewName "$NewName"
              Add-Content -Path $csvLogfile -Value "$ordnerpfad;WARNING MAX-Path-Length $fullpathlength (Rename done)" -Encoding UTF8
             }
          
          }
      }
    
      else{
        $ordnerohneumlaute = ($fold).Name
    
        Write-Host "folder: $ordnerohneumlaute not containing special characters." -ForegroundColor Green
  
      }
    
  
 
    }
  }
}