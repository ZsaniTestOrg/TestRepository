function Find-PackagesToDelete {
    param (
        [Parameter(Mandatory)]
        [object[]] $packageList,

        [Parameter(Mandatory)]
        [int] $retentionCount,

        [Parameter(Mandatory)]
        [int] $retentionAge,

        [Parameter(Mandatory)]
        [int] $retentionHardLimit
    )

    
    $packagesToDelete = @()

    $packageRetentionDate = (Get-Date).AddDays(-$retentionAge)
    $retainedPackageCount = 0

    $packageList = $packageList | Sort-Object uploaded_at -Descending
   
    foreach ($package in $packageList) {
        if ($retainedPackageCount -ge $retentionCount) {
            if ($package.uploaded_at -lt $packageRetentionDate) {
                $packagesToDelete += $package
            } elseif ($retainedPackageCount -ge $retentionHardLimit) {
                $packagesToDelete += $package
            } else {
                $retainedPackageCount++
            }
        } else {
            $retainedPackageCount++
        }
    }

    return ,$packagesToDelete
}