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

    [CmdletBinding()]
    [OutputType([String[]])]
    param(
        [ValidateNotNullOrEmpty()]
        [String[]] $RelativePaths,
        [Switch]   $RealPathsOnly
    )

    if($RealPathsOnly){
        return $(Resolve-Path -LiteralPath $RelativePaths);
    }

    return $(
        $RelativePaths.ForEach{[System.IO.Path]::GetFullPath($_)}
    );
}

Export-ModuleMember -Function *;