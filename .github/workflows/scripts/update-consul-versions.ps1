$workflow = ".github/workflows/ci.yml"
$owner = "hashicorp"
$repo = "consul"

# Fetch all the latest stable Consul releases
$releases = Get-GitHubRelease -OwnerName $owner -RepositoryName $repo | Where-Object { ! $_.PreRelease }

# Find the latest version for each minor release
$latest = @{}
foreach ($release in $releases)
{
  $version = [version]($release.tag_name.Substring(1))
  $minor = "$($version.Major).$($version.Minor)"
  if (!$latest.ContainsKey($minor) -or $latest[$minor] -lt $version)
  {
    $latest[$minor] = $version
  }
}

# Update the CI workflow with the latest versions
(Get-Content $workflow) -Replace "consul: \[(\d+\.\d+\.\d+(, )?)+\]", "consul: [$($latest.Values | Sort-Object | ForEach-Object { [string]$_ } | Join-String -Separator ", ")]" | Set-Content $workflow
