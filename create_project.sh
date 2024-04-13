#!/bin/bash

# Check if a project name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

# Variables
PROJECT_NAME=$1
BASE_DIR=$(pwd)/$PROJECT_NAME

# Create directory structure
echo "Creating project structure..."
mkdir -p "$BASE_DIR"/{.config,src,tests,_private,\#temp,\!read}

# Create the Makefile in the .config directory
echo "Creating Makefile..."
cat <<EOF > "$BASE_DIR/.config/makefile"
all:
\t@echo "Building the project..."
\t# Placeholder for build commands

test:
\t@echo "Running tests..."
\t# Placeholder for test commands

clean:
\t@echo "Cleaning up..."
\t@rm -rf $BASE_DIR/#temp/*
EOF

# Create the setup.env file in the .config directory
echo "Setting up environment variables..."
cat <<EOF > "$BASE_DIR/.config/setup.env"
# Environment configuration
EXPORT API_KEY="your_api_key_here"
EOF

# Create the README.md file in the !read directory
echo "Creating README.md..."
cat <<EOF > "$BASE_DIR/!read/README.md"
# $PROJECT_NAME

Welcome to the $PROJECT_NAME repository! This project is structured to support a robust development workflow.

## Structure

- **src/**: Source files for the project.
- **tests/**: Test scripts.
- **.config/**: Configuration files and scripts.

## Usage

- **Build**: Run './run build' to build the project.
- **Test**: Run './run test' to execute tests.
- **Clean**: Run './run clean' to clean the project.
EOF

# Create a simple main.js in the src directory (or main.py, main.cpp, etc.)
echo "Creating a placeholder source file..."
echo "// Main application script" > "$BASE_DIR/src/main.js"

# Create a simple test file in the tests directory
echo "Creating a placeholder test file..."
echo "// Basic test" > "$BASE_DIR/tests/test_main.js"

# Create the run script in the project root
echo "Creating the run script..."
cat <<EOF > "$BASE_DIR/run"
#!/bin/bash

# Load environment variables
source .config/setup.env

# Command management script
case "\$1" in
    build)
        make -C .config all
        ;;
    test)
        make -C .config test
        ;;
    clean)
        make -C .config clean
        ;;
    *)
        echo "Usage: \$0 {build|test|clean}"
        exit 1
        ;;
esac
EOF
chmod +x "$BASE_DIR/run"

echo "Project '$PROJECT_NAME' created successfully."
echo "Navigate to the project directory with: cd $PROJECT_NAME"
