<##
 # @brief This script builds a program.
 #
 # @param -clean             - Cleans the project by removing the 'build' directory.
 # @param -build <ALL|TESTS> - Compiles the project.
 # @param -install           - Installs the project.
 # @param -run               - Runs unit tests after the build.
 #
 # SDIR: REPOSITORY/scripts>
 # EDIR: REPOSITORY/scripts>
 #
 # @author Sergey Baigudin, sergey@baigudin.software
 #>
param(
    [switch]$clean,
    [string]$build,
    [switch]$install,
    [switch]$run,
    [switch]$coverage
)

Import-Module -Name .\functions.psm1

[string]$pathScriptToBuildDir = ".\..\build"
[string]$pathBuildToScriptDir = ".\..\scripts"

<## 
 # @brief Outs a message.
 #>
function Out-Note([string]$string, [switch]$Block, [switch]$say, [switch]$ok, [switch]$err, [switch]$inf)
{
    Out-Message -String ("[BUILD] " + $string) -Block:$block.IsPresent -Say:$say.IsPresent -Ok:$ok.IsPresent -Err:$err.IsPresent -Inf:$inf.IsPresent
} 

<## 
 # @brief Builds the project.
 #
 # CDIR: REPOSITORY/scripts>
 # EDIR: REPOSITORY/scripts> 
 #>
function Build()
{
    Out-Message -String "Build is started" -Inf -Block
    if($clean)
    {
        Out-Note -String "EOOS build clean is set" -Inf
        if( Test-Path -Path $pathScriptToBuildDir )
        {
            Out-Note "Remove build directory" -Inf
            Remove-Item -Path $pathScriptToBuildDir -Recurse -Force
        }
    }
    if( (Test-Path -Path $pathScriptToBuildDir) -eq $false )
    {
        Out-Note -String "Create build directory" -Inf
        New-Item -ItemType "directory" -Path $pathScriptToBuildDir
        New-Item -ItemType "directory" -Path ($pathScriptToBuildDir + "/CMakeInstallDir")
    }
    
    cd -Path $pathScriptToBuildDir # CDIR: REPOSITORY/build>
       
    Out-Note -String "Generate CMake project" "INF" -Inf
    cmake -D CMAKE_INSTALL_PREFIX=CMakeInstallDir ..
    
    if($build)
    {
        if( Test-Path -Path ".\codebase\tests\Debug\EoosTests.exe" )
        {
            Out-Note -String "Remove Unit Tests executable file" -Inf
            Remove-Item -Path ".\codebase\tests\Debug\EoosTests.exe"
        }
        if($build -eq "ALL")
        {
            Out-Note -String "Build CMake project" -Inf
            cmake --build . --config Debug
        }        
        else
        {
            if($build -eq "TESTS")
            {
                Out-Note -String "Built CMake Unit Tests target only" -Inf
                MSBuild.exe .\codebase\tests\target-eoos-unit-tests.vcxproj -maxCpuCount:8  -verbosity:minimal
            }
            else
            {
                Out-Note -String "Argument -build is wrong. ALL or TESTS is accessible" -Err
                cd -Path $pathBuildToScriptDir # CDIR: REPOSITORY/scripts>
                exit;
            }
        }            
    }
    
    if($install)
    {    
        Out-Note -String "Install CMake project" -Inf
        cmake --install . --config Debug
    }
    
    if($run)
    {
        Out-Note -String "Run unit tests" -Inf
        if($install)
        {
            if( Test-Path -Path ".\CMakeInstallDir\bin\EoosTests.exe" )
            {
                .\CMakeInstallDir\bin\EoosTests.exe --gtest_shuffle
            }                
            else
            {
                Out-Note "The unit tests executable file does not exist" -Err
            }
            
        }
        else
        {
            if( Test-Path -Path ".\codebase\tests\Debug\EoosTests.exe" )
            {
                # @note Remove --gtest_filter key if it set
                # --gtest_filter=test_Main*
                # --gtest_filter=test_lib_String*
                # --gtest_filter=test_lib_Thread*
                #
                # --gtest_shuffle
                .\codebase\tests\Debug\EoosTests.exe --gtest_shuffle
            }                
            else
            {
                Out-Note "The unit tests executable file does not exist" -Err
            }        
            
        }
    }
    
    if($coverage)
    {
        Out-Note -String "Run test coverage" -Inf
        cd -Path .. # CDIR: REPOSITORY/>
        if( Test-Path -Path ".\CoverageReport*" )
        {
            Out-Note -String "Remove old temp test coverage report" -Inf
            Remove-Item -Path ".\CoverageReport*" -Recurse -Force
        }
        if( Test-Path -Path ".\build\CoverageReport" )
        {
            Out-Note -String "Remove old test coverage report" -Inf
            Remove-Item -Path ".\build\CoverageReport" -Recurse -Force
        }        
        if( Test-Path -Path ".\build\codebase\tests\Debug\EoosTests.exe" )
        {
            OpenCppCoverage --sources codebase\interface --sources codebase\library --sources codebase\system -- .\build\codebase\tests\Debug\EoosTests.exe
        }                
        else
        {
            Out-Note "The unit tests executable file does not exist" -Err
        }
        Out-Note -String "Move new test coverage report" -Inf
        Move-Item -Path ".\CoverageReport*" -Destination ".\build\CoverageReport"        
        cd -Path build # CDIR: REPOSITORY/build>        
    }
    
    cd -Path $pathBuildToScriptDir # CDIR: REPOSITORY/scripts>
}

Out-Message -String "BUILDING OF PROJECT HAS BEEN INVOKED" -Ok -Block
Build
Out-Message -String "BUILDING OF PROJECT HAS BEEN COMPLETED" -OK -Block
Get-Module | Remove-Module
