function ConvertTo-RelativePaths{
    <#
    .SYNOPSIS
        This function converts absolute paths into their relative path counterparts.
    .DESCRIPTION
        This function has following merits:
            1. 
    .PARAMETER AbsolutePaths
        
    .PARAMETER RealPathsOnly

    .INPUTS

    .OUTPUTS

    .EXAMPLE
    
    #>

    [OutputType([String[]])]
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [String[]] $AbsolutePaths,
        [ValidateNotNullOrEmpty()]
        [String]   $BasePath = $(Get-Location),
        [Switch]   $RealPathsOnly
    )

    $originalLocation = $(Get-Location)
    [System.IO.Directory]::SetCurrentDirectory($originalLocation)

    if($RealPathsOnly){
        Set-Location -LiteralPath $BasePath
        $relativePaths = $(Resolve-Path -Relative -LiteralPath $AbsolutePaths);
        Set-Location -LiteralPath $originalLocation
        return $relativePaths
    }

    return $(
        $AbsolutePaths.ForEach{
            $rawRelativePath = [System.IO.Path]::GetRelativePath($BasePath, $_)
            if($rawRelativePath -match "[^.]*\.[^.]+"){
                $rawRelativePath
            }else{
                $rawRelativePath + "\"
            }
        }
    );
}

Export-ModuleMember -Function *;