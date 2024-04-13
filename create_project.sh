
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
\t# Add actual build commands here

clean:
\t@echo "Cleaning up..."
\t@rm -rf $BASE_DIR/#temp/*
EOF

# Create the README.md file in the !read directory
echo "Creating README.md..."
echo "# New Project" > "$BASE_DIR/!read/README.md"

# Create a simple main.js in the src directory (or main.py, main.cpp, etc.)
echo "Creating a placeholder source file..."
echo "// Main application script" > "$BASE_DIR/src/main.js"

# Create the run script in the project root
echo "Creating the run script..."
cat <<EOF > "$BASE_DIR/run"
#!/bin/bash

# Command management script
case "\$1" in
    build)
        make -C .config all
        ;;
    clean)
        make -C .config clean
        ;;
    *)
        echo "Usage: \$0 {build|clean}"
        exit 1
        ;;
esac
EOF
chmod +x "$BASE_DIR/run"

echo "Project '$PROJECT_NAME' created successfully."
echo "Navigate to the project directory with: cd $PROJECT_NAME"
