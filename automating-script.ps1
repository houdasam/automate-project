# Passing the name and the project type as an argument
$project_name = $args[0]
$project_type = $args[1]

#Function to check if Node.js is installed
function CheckInstallation {
    param(
        [string]$applicationName
    )
    if(Get-Command $applicationName -ErrorAction SilentlyContinue){
       return "true"
    }
    else {
        return "false"
    }
}

#Function to create the project folder
function CreateProjectFolder{
    param(
        [string]$projectName
    )
    # Test if the folder already exists
    while (Test-Path -Path $PWD/$projectName) {
        Write-Host "Folder exists. Please provide another name: " -ForegroundColor Red -NoNewline
        $projectName = Read-Host
    }
    # Create project directory
    mkdir $projectName
    cd $projectName
}

#For node projects 
if($project_type -eq "node"){
    $isNodeInstalled = CheckInstallation -applicationName "node"
    $isNpmIntalled = CheckInstallation -applicationName "npm"
    if($isNodeInstalled -eq "false"){
        Write-Host "Node.js is not installed. Please install it before proceeding"
        exit 1
    }
    elseif ($isNpmIntalled -eq "false") {
        Write-Host "npm is not installed. Please install it before proceeding"
        exit 1
    }
    else{   
        Write-Host "*******************Creating the folder step*******************"
        CreateProjectFolder -projectName $project_name

        Write-Host "*******************Initiliazing the node project*******************"
        npm init -y 

        Write-Host "*******************Creating the repository step*******************"
        # Github username and personal access token
        $PAT = Read-Host "Please enter your Personal Access Token"
        $username = Read-Host "Please enter your GitHub username"
    
        # Base URL for GitHub API
        $baseUrl = "https://api.github.com"
    
        # Choose the visibility of the repo (private or public)
        $visibility = Read-Host "Should the repository be public or private ? (Enter 'public' or 'private')"
        while($visibility -ne "public" -and $visibility -ne "private"){
            $visibility = Read-Host "Should the repository be public or private"
        }
    
        # Determine if the repository is private
        $isPrivate = if ($visibility -eq "private") { $true } else { $false }
    
        # Determine if the repository already exists
        try {
            $uri = "$baseUrl/repos/$username/$project_name"
            $response = Invoke-WebRequest -Uri $uri -Method Get -Headers @{Authorization = "token $PAT"} -ErrorAction Stop
    
            # Check response status code
            if ($response.StatusCode -eq 200) {
                Write-Host "Repository '$project_name' already exists on GitHub."
            }
        } catch {
            # Handle error if repository doesn't exist
            if ($_.Exception.Response.StatusCode.value__ -eq 404) {
                # Create a new repository payload
                $payload = @{
                    name = $project_name
                    auto_init = $true
                    private = $isPrivate
                } | ConvertTo-Json
                
                # Create a new repository using GitHub API
                $uri = "$baseUrl/user/repos"
                $response = Invoke-RestMethod -Uri $uri -Method Post -Headers @{Authorization = "token $PAT"} -Body $payload -ContentType "application/json"
                
                if ($response) {
                    Write-Host "Repository created successfully." -ForegroundColor Green
    
                    #Creating a local Git repository
                    $isGitInstalled = CheckInstallation -applicationName "git"
                    if($isGitInstalled -eq "true"){
                        Write-Host "Git is installed. Initializing a new Git Repository." -ForegroundColor Green
                        git init
                    }
                    else{
                        Write-Host "Git is not installed." -ForegroundColor Red
                    }
    
                    #Creating the .gitignore file
                    Write-Host "Creating the .gitignore file"
                    New-Item -Path $PWD/.gitignore -ItemType File 
    
                    # Check if 'code' command is available
                    $isVsCodeInstalled = CheckInstallation -applicationName "code"
                    if ($isVsCodeInstalled -eq "true") {
                        Write-Host "Visual Studio Code is installed. Opening the current directory." -ForegroundColor Green
                        code .
                    } else {
                        Write-Host "Visual Studio Code is not installed." -ForegroundColor Red
                        # You can provide an alternative action here if desired
                    }
                } else {
                    Write-Host "Failed to create repository." -ForegroundColor Red
                }
            } else {
                Write-Host "An unexpected error occurred while checking repository existence. Status code: $($_.Exception.Response.StatusCode.value__)"
            }
        }
    }
}
elseif ($project_type -eq "spring-boot") {
    Write-Host "*******************Creating the folder step*******************"
    CreateProjectFolder -projectName $project_name

    Write-Host "*****************Spring Boot Project Metadata*****************"
    #Defining the project parameters
    $groupId = Read-Host "Please provide the group "
    $artifactId = Read-Host "Please provide the artifact"
    $buildId = Read-Host "Do you want a maven or a gradle based project? [Enter 'maven' or 'gradle']"
    
    if($buildId -eq "maven"){
        $build ="maven-project"
    }
    elseif($buildId -eq "gradle"){
        $build = "gradle-project"
    }

    # Construct the URL for Spring Initializr
    $downloadUrl = "https://start.spring.io/starter.zip?type=$build&groupId=$groupId&artifactId=$artifactId"

    # Download the project zip file
    Invoke-WebRequest -Uri $downloadUrl -OutFile "$artifactId.zip"

    # Unzip the downloaded file
    Expand-Archive -Path "$artifactId.zip" -DestinationPath .\

    # Clean up the zip file
    Remove-Item "$artifactId.zip"

    Write-Host "*******************Creating the repository step*******************"

    # Github username and personal access token
    $PAT = Read-Host "Please enter your Personal Access Token"
    $username = Read-Host "Please enter your GitHub username"

    # Base URL for GitHub API
    $baseUrl = "https://api.github.com"

    # Choose the visibility of the repo (private or public)
    $visibility = Read-Host "Should the repository be public or private ? (Enter 'public' or 'private')"
    while($visibility -ne "public" -and $visibility -ne "private"){
        $visibility = Read-Host "Should the repository be public or private"
    }

    # Determine if the repository is private
    $isPrivate = if ($visibility -eq "private") { $true } else { $false }

    # Determine if the repository already exists
    try {
        $uri = "$baseUrl/repos/$username/$project_name"
        $response = Invoke-WebRequest -Uri $uri -Method Get -Headers @{Authorization = "token $PAT"} -ErrorAction Stop

        # Check response status code
        if ($response.StatusCode -eq 200) {
            Write-Host "Repository '$project_name' already exists on GitHub."
        }
    } catch {
        # Handle error if repository doesn't exist
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            # Create a new repository payload
            $payload = @{
                name = $project_name
                auto_init = $true
                private = $isPrivate
            } | ConvertTo-Json
            
            # Create a new repository using GitHub API
            $uri = "$baseUrl/user/repos"
            $response = Invoke-RestMethod -Uri $uri -Method Post -Headers @{Authorization = "token $PAT"} -Body $payload -ContentType "application/json"
            
            if ($response) {
                Write-Host "Repository created successfully." -ForegroundColor Green

                #Creating a local Git repository
                $isGitInstalled = CheckInstallation -applicationName "git"
                if($isGitInstalled -eq "true"){
                    Write-Host "Git is installed. Initializing a new Git Repository." -ForegroundColor Green
                    git init
                }
                else{
                    Write-Host "Git is not installed." -ForegroundColor Red
                }

                # Check if 'code' command is available
                $isVsCodeInstalled = CheckInstallation -applicationName "code"
                if ($isVsCodeInstalled -eq "true") {
                    Write-Host "Visual Studio Code is installed. Opening the current directory." -ForegroundColor Green
                    code .
                } else {
                    Write-Host "Visual Studio Code is not installed." -ForegroundColor Red
                    # You can provide an alternative action here if desired
                }
            } else {
                Write-Host "Failed to create repository." -ForegroundColor Red
            }
        } else {
            Write-Host "An unexpected error occurred while checking repository existence. Status code: $($_.Exception.Response.StatusCode.value__)"
        }
    }
}