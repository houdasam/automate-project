Write-Host "*******************Creating the folder step*******************"

# Passing the name of the project as an argument
$project_name = $args[0]

#Test if the folder already exists 
while(Test-Path $PWD/$project_name ){
    Write-Host "Folder exists, Please provide another name : "  -ForegroundColor Red -NoNewline
    $project_name = Read-Host 

}

mkdir $project_name
cd $project_name
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
            if(Get-Command git -ErrorAction SilentlyContinue){
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
            if (Get-Command code -ErrorAction SilentlyContinue) {
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



