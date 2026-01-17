# Generates minimal VS2022 project files in the current directory for Windows

# ---- Get project name ----
$projectName = if ($args[0]) { $args[0] } else { Split-Path -Leaf $PWD }

# ---- Fixed GUID ----
$projectGuid = "{11111111-1111-1111-1111-111111111111}"

# ---- Collect source and header files ----
$cppFiles = Get-ChildItem -Path . -Include *.cpp, *.c -File
$hFiles = Get-ChildItem -Path . -Include *.h, *.hpp -File

# Generate strings for vcxproj
$sourceIncludes = $cppFiles | ForEach-Object { "    <ClCompile Include=""$($_.Name)"" />" }
$headerIncludes = $hFiles | ForEach-Object { "    <ClInclude Include=""$($_.Name)"" />" }

# ---- Generate .sln ----
$slnContent = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "$projectName", "$projectName.vcxproj", "$projectGuid"
EndProject
Global
    GlobalSection(SolutionConfigurationPlatforms) = preSolution
        Debug|x64 = Debug|x64
        Release|x64 = Release|x64
    EndGlobalSection
    GlobalSection(ProjectConfigurationPlatforms) = postSolution
        $projectGuid.Debug|x64.ActiveCfg = Debug|x64
        $projectGuid.Debug|x64.Build.0 = Debug|x64
        $projectGuid.Release|x64.ActiveCfg = Release|x64
        $projectGuid.Release|x64.Build.0 = Release|x64
    EndGlobalSection
EndGlobal
"@
$slnContent | Out-File -FilePath "$projectName.sln" -Encoding utf8

# ---- Generate .vcxproj ----
$vcxprojContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|x64">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|x64">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <ProjectGuid>$projectGuid</ProjectGuid>
    <RootNamespace>$projectName</RootNamespace>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
  </PropertyGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
  </PropertyGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ItemGroup>
$($sourceIncludes -join "`r`n")
  </ItemGroup>
  <ItemGroup>
$($headerIncludes -join "`r`n")
  </ItemGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.targets" />
</Project>
"@
$vcxprojContent | Out-File -FilePath "$projectName.vcxproj" -Encoding utf8

# ---- Generate .vcxproj.filters ----
$filterContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup>
$($cppFiles | ForEach-Object { "    <ClCompile Include=""$($_.Name)""><Filter>Source Files</Filter></ClCompile>" } -join "`r`n")
  </ItemGroup>
  <ItemGroup>
$($hFiles | ForEach-Object { "    <ClInclude Include=""$($_.Name)""><Filter>Header Files</Filter></ClInclude>" } -join "`r`n")
  </ItemGroup>
  <ItemGroup>
    <Filter Include="Source Files" />
    <Filter Include="Header Files" />
  </ItemGroup>
</Project>
"@
$filterContent | Out-File -FilePath "$projectName.vcxproj.filters" -Encoding utf8

# ---- Done ----
Write-Host "✅ Generated Visual Studio 2022 (v143) project files:" -ForegroundColor Green
Write-Host " - $projectName.sln"
Write-Host " - $projectName.vcxproj"
Write-Host " - $projectName.vcxproj.filters"
Write-Host "Included $($cppFiles.Count) source and $($hFiles.Count) header files"