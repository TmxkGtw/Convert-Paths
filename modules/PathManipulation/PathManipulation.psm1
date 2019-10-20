function ConvertTo-RelativePaths{
    <#
    .SYNOPSIS
        This function converts absolute paths into their relative path counterparts.
    .DESCRIPTION
        This function has following merits:
            1. It can convert paths into the absolutes no matter whether they really exist or not
            2. It can accept direct pipeline input of `Get-ChildItem` commandlet
            3. It can change the basepath of relative path calculation by the parameter `BasePath`

        In contrast, native `Resolve-Path -Relative` has following demerits:            
            1. It can not convert unexistent paths
            2. It can not accept direct pipeline input of `Get-ChildItem` commandlet
            3. It can only calculate relativepath based on the current location
    .PARAMETER AbsolutePaths
        This parameter accepts absolute paths.
    .PARAMETER BasePath
        This parameter accepts basal path for calculating relative paths.
    .PARAMETER RealPathsOnly
        This switch parameter decides whether all paths are conveted or only really existent paths are converted.
    .INPUTS
        In this function, the parameter `AbsolutePaths` accepts pipeline inputs of absolute paths.
        The parameter can also accepts pipeline inputs of FullName attribute values by its alias `FullName`
    .OUTPUTS
        This function returns `[string[]]` typed array of relative paths.
    .EXAMPLE
        PS C:\sample> ConvertTo-RelativePaths -AbsolutePaths C:\aaa.txtS, C:\bbb.txt
    .EXAMPLE
        PS C:\sample> ConvertTo-RelativePaths -AbsolutePaths C:\aaa.txt, C:\bbb.txt -BasePath ..\
    .EXAMPLE
        PS C:\sample> ConvertTo-RelativePaths -AbsolutePaths C:\aaa.txt, C:\bbb.txt -RealPathsOnly
    .EXAMPLE
        PS C:\sample> @("C:\aaa.txt", "C:\bbb.txt")|ConvertTo-RelativePaths
    .EXAMPLE
        PS C:\sample> $(Get-ChildItem)|ConvertTo-RelativePaths    
    #>

    [Alias("relpath")]
    [OutputType([String[]])]
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("FullName")]
        [String[]] $AbsolutePaths,

        [ValidateNotNullOrEmpty()]
        [String]   $BasePath = $(Get-Location),
        
        [Switch]   $RealPathsOnly
    )

    begin{
        $originalLocation = $(Get-Location)
        [System.IO.Directory]::SetCurrentDirectory($originalLocation)

        if($RealPathsOnly){
            Set-Location -LiteralPath $BasePath
        }
    }

    process{
        if($RealPathsOnly){            
            return $(Resolve-Path -Relative -LiteralPath $AbsolutePaths);
        }
    
        return $(
            $AbsolutePaths.ForEach{
                $rawRelativePath = [System.IO.Path]::GetRelativePath($BasePath, $_)
                if($rawRelativePath -match "[^.\\/]*\.[^.\\/]+"){
                    $rawRelativePath
                }else{
                    "${rawRelativePath}\"
                }
            }
        );
    }

    end{
        if($RealPathsOnly){
            Set-Location -LiteralPath $originalLocation
        }
    }    
}

function ConvertTo-AbsolutePaths{
    <#
        .SYNOPSIS
            This function converts relative paths into absolute path counterparts.
        .DESCRIPTION
            This has merits shown below:
                1. You can convert nonexisting relative paths into the absolutes.

            Unfortunately, `Resolve-Path` and `Convert-Path` have demerits as below:
                1. You can not convert not-yet-existing paths.
        .PARAMETER RelativePaths
            You can input relative file paths no matter whether they really exist or not.
        .PARAMETER RealPathsOnly
            If you add this switch parameter, you can get the same result to `Resolve-Path`
        .INPUTS
            This function does not accept pipeline inputs.
        .OUTPUTS
            This function returns `string[]` typed array of absolute paths.
        .EXAMPLE
            PS C:\sample> ConvertTo-AbsolutePaths -RelativePaths ./aaa.txt
        .EXAMPLE
            PS C:\sample> ConvertTo-AbsolutePaths -RelativePaths ./aaa.txt -RealPathsOnly
    #>

    [Alias("abspath")]
    [CmdletBinding()]
    [OutputType([String[]])]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline)]
        [String[]] $RelativePaths,

        [Switch]   $RealPathsOnly
    )

    [System.IO.Directory]::SetCurrentDirectory($(Get-Location))

    if($RealPathsOnly){
        return $(Resolve-Path -LiteralPath $RelativePaths);
    }

    return $(
        $RelativePaths.ForEach{[System.IO.Path]::GetFullPath($_)}
    );
}

Export-ModuleMember -Function *;