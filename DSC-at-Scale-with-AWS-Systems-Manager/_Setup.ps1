<#
    Execute this script first to create and setup S3 Buckets for the demo.

    Use this for each execution. S3 Buckets will be re-used.
#>
$global:DemoRoot = $PSScriptRoot

# Set default AWS Region
$global:awsRegion = 'us-east-1'
Set-DefaultAWSRegion -Region $global:awsRegion

# Find or Create the S3 Buckets
$global:s3BucketName = (Get-S3Bucket | Where-Object {$_.BucketName -like 'potr-dsc-mofs*'}).BucketName
if (-not $global:s3BucketName) {
    $global:s3BucketName = 'potr-dsc-mofs-{0}' -f ([guid]::NewGuid())
    New-S3Bucket -BucketName $global:s3BucketName
}

$global:reportBucket = (Get-S3Bucket | Where-Object {$_.BucketName -like 'potr-dsc-report*'}).BucketName
if (-not $global:reportBucket) {
    $global:reportBucket = 'potr-dsc-report-{0}' -f ([guid]::NewGuid())
    New-S3Bucket -BucketName $global:reportBucket
}

$global:statusBucket = (Get-S3Bucket | Where-Object {$_.BucketName -like 'potr-dsc-status*'}).BucketName
if (-not $global:statusBucket) {
    $global:statusBucket = 'potr-dsc-status-{0}' -f ([guid]::NewGuid())
    New-S3Bucket -BucketName $global:statusBucket
}

$global:ssmOutputBucket = (Get-S3Bucket | Where-Object {$_.BucketName -like 'potr-dsc-ssm*'}).BucketName
if (-not $global:ssmOutputBucket) {
    $global:ssmOutputBucket = 'potr-dsc-ssm-{0}' -f ([guid]::NewGuid())
    New-S3Bucket -BucketName $global:ssmOutputBucket
}

Set-Location -Path $global:DemoRoot
