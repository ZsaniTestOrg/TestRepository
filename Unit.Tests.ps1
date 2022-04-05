Describe "Unit tests" {

    It "Test whether README exists" {
        Test-Path README.md | Should -Be $true
    }
}