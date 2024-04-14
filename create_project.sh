#!/bin/bash
# Function to add run_project_command to .zshrc, create an alias, and source .zshrc
add_run_command_to_zshrc() {
  # Check if the run_project_command is already in .zshrc to avoid duplication
  if ! grep -q "run_project_command" ~/.zshrc; then
    echo 'Adding run_project_command to .zshrc...'
    # Function definition added to .zshrc
    echo 'run_project_command() {
      ./run "$@"
    }' >> ~/.zshrc
    # Alias definition added to .zshrc
    echo "alias run='run_project_command'" >> ~/.zshrc
    # Source .zshrc to make the changes effective immediately
    source ~/.zshrc
    echo 'run_project_command and alias added and sourced successfully.'
  else
    echo 'run_project_command already exists in .zshrc.'
  fi
}

# Creates the project structure with necessary directories
create_structure() {
  echo "Creating project structure..."
  mkdir -p "$1"/{.config,code,_tests,#build,#temp,-docs,!read} || { echo "Failed to create project structure"; exit 1; }
}

# Function to create a new file with initial content
create_file() {
  echo "$2" > "$1" || { echo "Failed to create file $1"; exit 1; }
}

# Function to update or create configuration files for the project
create_config_files() {
  echo "Updating configuration files..."
  local project_path="$1"
  local project_name="$2"
  
  # Makefile configuration
  cat <<EOF > "$project_path/.config/makefile"
all:
\t@echo "Building the project..."
\t# Commands to compile the project

test:
\t@echo "Executing tests..."
\t# Commands to run tests

clean:
\t@echo "Performing cleanup..."
\t@rm -rf $project_path/#temp/*
EOF

  # Environment setup file
  echo "# Project environment setup
export API_KEY=\"insert_api_key_here\"" > "$project_path/.config/setup.env"

  # README file with project information
  cat <<EOF > "$project_path/!read/README.md"
# Welcome to $project_name

This repository is designed with a focus on efficient development practices and a clear project structure.

## Project Organization

- **code/**: Contains the project's source code.
- **_tests/**: Houses test scripts.
- **.config/**: Holds configuration files and scripts.
- **-docs/**: Stores documentation.
- **#build/**: Contains build artifacts.
- **#temp/**: For temporary files.

## How to Use

- **Build**: Execute './run build' to compile the project.
- **Test**: Use './run test' for running tests.
- **Clean**: Apply './run clean' for cleanup operations.
EOF
}

# Function to handle setup operations based on command line arguments
operational_intercepter() {
  echo "Intercepting operational commands..."
  case "$1" in
    setup)
      echo "Setting up project environment..."
      create_structure "$2"
      create_config_files "$2" "$3"
      create_run_script "$2"
      initialize_git "$2"
      setup_docker "$2"
      echo "Project $3 setup complete."
      ;;
    *)
      echo "Usage: $0 setup <project_path> <project_name>"
      exit 1
      ;;
  esac
}

# Function to create a script for managing build, test, and clean operations
create_run_script() {
  local project_path="$1"
  cat <<EOF > "$project_path/run"
#!/bin/bash

# Importing environment variables
source "$project_path/.config/setup.env"

# Script for managing and redirecting commands
case "\$1" in
    build)
        echo "Processing build command..."
        make -C "$project_path/.config" all
        ;;
    test)
        echo "Processing test command..."
        make -C "$project_path/.config" test
        ;;
    clean)
        echo "Processing clean command..."
        make -C "$project_path/.config" clean
        ;;
    help)
        echo "Available commands:"
        echo "  build - Compiles the project."
        echo "  test  - Runs the test suite."
        echo "  clean - Cleans up temporary files."
        echo "  init  - Initializes the project environment."
        echo "  deploy - Deploys the project."
        echo "  update - Updates the project components."
        ;;
    init)
        echo "Initializing project environment..."
        create_structure "$project_path"
        create_config_files "$project_path" "\$(basename $project_path)"
        ;;
    deploy)
        echo "Deploying the project..."
        # Placeholder for deployment commands
        ;;
    update)
        echo "Updating project components..."
        # Placeholder for update commands
        ;;
    *)
        echo "Unrecognized command: \$1"
        echo "Use './run help' for a list of available commands."
        exit 1
        ;;
esac
EOF
  chmod +x "$project_path/run"
}

# Function to initialize a Git repository in the project directory
initialize_git() {
  echo "Initializing Git repository..."
  cd "$1" && git init && echo -e "#temp/\n" > "$1/.config/.gitignore" && git add . && git commit -m "Initial commit" || { echo "Failed to initialize Git repository"; exit 1; }
}

# Function to set up a Docker environment for the project
setup_docker() {
  local project_path="$1"
  cat <<EOF > "$project_path/.config/Dockerfile"
# Use an official Node runtime as a parent image
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install any needed packages specified in requirements.txt
RUN npm install

# Make port 4000 available to the world outside this container
EXPOSE 4000

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["node", "src/main.js"]
EOF
}

# Main Script
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_NAME=$1
BASE_DIR=$(pwd)/$PROJECT_NAME

create_structure "$BASE_DIR"
create_config_files "$BASE_DIR" "$PROJECT_NAME"
create_file "$BASE_DIR/code/main.js" "// Main application script"
create_file "$BASE_DIR/_tests/test_main.js" "// Basic test"
create_run_script "$BASE_DIR"
initialize_git "$BASE_DIR"
setup_docker "$BASE_DIR"

echo "Project '$PROJECT_NAME' created successfully."
echo "Navigate to the project directory with: cd $PROJECT_NAME"

