# PowerShell Project: Automated Project Setup and GitHub Repository Creation

This PowerShell script automates the setup of Node.js and Spring Boot projects, including the creation of corresponding GitHub repositories to host the projects. It interacts with the GitHub API to create repositories and includes features such as checking for Node.js and npm installations, creating project folders, and setting up GitHub repositories.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)

## Prerequisites

Before running this script, ensure that the following prerequisites are met:

- PowerShell is installed on your system.
- You have a GitHub account.
- You have a GitHub Personal Access Token (PAT) with appropriate permissions (Make sure to check the repos section when creating the PAT).

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/houdasam/automate-project
    ```

2. Navigate to the directory containing the script:

    ```bash
    cd your-repository
    ```

## Usage

To use this script, follow these steps:

1. Open PowerShell.
2. Navigate to the directory containing the script.
3. Run the script with the following command:

    ```powershell
    .\automating-script.ps1 project-name project-type
    ```

    Replace `project-name` with the desired name for your project and `project-type` with either **node** or **spring-boot** depending on the type of project you want to create.

4. Follow the prompts to enter additional information such as GitHub credentials and repository visibility.


