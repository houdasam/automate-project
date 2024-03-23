Write-Host "*******************Creating the folder step*******************"

#Passing the name of the project as an argument
$project_name = $args[0]
mkdir $project_name
cd $project_name
Write-Host "*******************Creating the repository step*******************"

#Github username and personal access token
$PAT = Read-Host "Please enter your Personal Access Token"
$username = Read-Host "Please enter your GitHub username"

#Base URL for GitHub API
$baseUrl = "https://api.github.com"

#Choose the visibility of the repo (private or public)
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
            Write-Host "Repository created successfully."
        } else {
            Write-Host "Failed to create repository."
        }
    } else {
        Write-Host "An unexpected error occurred while checking repository existence. Status code: $($_.Exception.Response.StatusCode.value__)"
    }
}



