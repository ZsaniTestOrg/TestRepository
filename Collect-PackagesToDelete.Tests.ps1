. "$PSScriptRoot/Collect-PackagesToDelete.ps1"

Describe "Collect-PackagesToDelete tests" {

    It "Should not delete anything when there are older packages than the retention age but less than the retention count" {

        # Arrange
        $retentiionAge = 2
        $packageUploadedDate = (Get-Date).AddDays(-($retentionAge+5))
        $packageList = @()
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = $packageUploadedDate; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge $retentiionAge -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 0
    }

    It "Should not delete anything when there are younger than the retention age and less than the retention count" {

        # Arrange
        $packageList = @()
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = Get-Date; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge 2 -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 0
    }

    It "Should not delete anything when there are younger than the retention date, more than the retention count but less than the hard limit" {

        # Arrange
        $packageList = @()
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = Get-Date; tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = Get-Date; tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = Get-Date; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge 2 -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 0
    }

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
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge 14 -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 1
        $result[0].uploaded_at | Should -Be $oldestPackageUploadTime
    }

    It "Should delete the older packages which are older than the retention age and over the retention count when there no younger packages" {

        # Arrange
        $retentionAge = 3
        $oldestUploadedTime = (Get-Date).AddDays(-($retentionAge+5))
        $olderUploadedTime = (Get-Date).AddDays(-($retentionAge+2))

        $packageList = @()
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = $oldestUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = $olderUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ name = "package1"; format = "helm"; uploaded_at = $olderUploadedTime; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge $retentionAge -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 1
        $result[0].uploaded_at | Should -Be $oldestUploadedTime
    }

    It "Should delete the older packages which are older than the retention age and over the retention count when there are younger packages less than the retention count" {

        # Arrange
        $retentionAge = 3
        $retentionDate = (Get-Date).AddDays(-($retentionAge))
        $oldestUploadedTime = $retentionDate.AddDays(-5)
        $olderUploadedTime = $retentionDate.AddDays(-4)
        $youngerUploadedTime = $retentionDate.AddDays(+3)

        $packageList = @()
        $packageList += @{ id = 2; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 1; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 2; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 5; name = "package1"; format = "helm"; uploaded_at = $olderUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 6; name = "package1"; format = "helm"; uploaded_at = $oldestUploadedTime; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 4 -retentionAge $retentionAge -retentionHardLimit 6

        # Assert
        $result | Should -HaveCount 1
        $result[0].uploaded_at | Should -Be $oldestUploadedTime
    }

    It "Should delete the older packages which are older than the retention age and over the retention count when there are younger packages, same number as the retention count" {

        # Arrange
        $retentionAge = 3
        $retentionDate = (Get-Date).AddDays(-($retentionAge))
        $oldestUploadedTime = $retentionDate.AddDays(-5)
        $youngerUploadedTime = $retentionDate.AddDays(+3)

        $packageList = @()
        $packageList += @{ id = 1; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 2; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 1; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 2; name = "package1"; format = "helm"; uploaded_at = $youngerUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 5; name = "package1"; format = "helm"; uploaded_at = $oldestUploadedTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 6; name = "package1"; format = "helm"; uploaded_at = $oldestUploadedTime; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 4 -retentionAge $retentionAge -retentionHardLimit 6

        # Assert
        $result | Should -HaveCount 2
        $result | Where-Object { $_.uploaded_at -eq $oldestUploadedTime } | Should -HaveCount 2
        $result | Where-Object { $_.uploaded_at -ne $oldestUploadedTime } | Should -BeNullOrEmpty
    }

    It "Should delete the older packages which are over the hard limit and which are older then the retention age" {

        # Arrange
        $retentionAge = 6
        $retentionDate = (Get-Date).AddDays(-$retentionAge)

        $packageList = @()
        $packageList += @{ id = 1; name = "package1"; format = "helm"; uploaded_at = $retentionDate.AddDays(-2); tags = @{ info = @("released") } }
        $packageList += @{ id = 2; name = "package1"; format = "helm"; uploaded_at = $retentionDate.AddDays(-1); tags = @{ info = @("released") } }
        $packageList += @{ id = 3; name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-5); tags = @{ info = @("released") } }
        $packageList += @{ id = 4; name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-4); tags = @{ info = @("released") } }
        $packageList += @{ id = 5; name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-3); tags = @{ info = @("released") } }
        $packageList += @{ id = 6; name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-2); tags = @{ info = @("released") } }
        $packageList += @{ id = 7; name = "package1"; format = "helm"; uploaded_at = (Get-Date).AddDays(-1); tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge 5 -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 3
        $result | Where-Object { $_.id -eq 1 } | Should -Not -BeNullOrEmpty
        $result | Where-Object { $_.id -eq 2 } | Should -Not -BeNullOrEmpty
        $result | Where-Object { $_.id -eq 3 } | Should -Not -BeNullOrEmpty
    }


    It "Should delete the older packages whend there are younger packages between the retention count and hard limit and also there are older packages than the retention age" {

        # Arrange
        $retentionAge = 6
        $retentionDate = (Get-Date).AddDays(-$retentionAge)
        $youngerUploadTime = $retentionDate.AddDays(+3)
        $oldestUploadTime = $retentionDate.AddDays(-3)

        $packageList = @()
        $packageList += @{ id = 1; name = "package1"; format = "helm"; uploaded_at = $youngerUploadTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 2; name = "package1"; format = "helm"; uploaded_at = $youngerUploadTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 3; name = "package1"; format = "helm"; uploaded_at = $youngerUploadTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 4; name = "package1"; format = "helm"; uploaded_at = $oldestUploadTime; tags = @{ info = @("released") } }
        $packageList += @{ id = 5; name = "package1"; format = "helm"; uploaded_at = $oldestUploadTime; tags = @{ info = @("released") } }

        # Act
        $result = Collect-PackagesToDelete -packageList $packageList -retentionCount 2 -retentionAge 5 -retentionHardLimit 4

        # Assert
        $result | Should -HaveCount 2
        $result | Where-Object { $_.uploaded_at -eq $oldestUploadTime } | Should -HaveCount 2
        $result | Where-Object { $_.uploaded_at -ne $oldestUploadTime } | Should -BeNullOrEmpty
    }
}