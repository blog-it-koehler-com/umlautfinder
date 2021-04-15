# umlautfinder
#
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

