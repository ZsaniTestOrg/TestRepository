BeforeAll { 
    . $PSScriptRoot/Find-PackagesToDelete.ps1
}

Describe "Unit tests" {
    It "Should delete the older packages which are younger than the retention age but over the hard limit" {

        # Arrange
        $oldestPackageUploadTime = (Get-Date).AddDays(-5)
        $packageList = @()
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = $oldestPackageUploadTime; tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-4); tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-3); tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-2); tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-1); tags = @{ info = @("released") } }

        # Act
        $result = Find-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge 14 -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 1
        $result[0].uploaded_at | Should -Be $oldestPackageUploadTime
    }
}