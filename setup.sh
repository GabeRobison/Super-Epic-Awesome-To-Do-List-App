#!/bin/bash
# Simple Todo App Setup

# Colors and styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper functions for formatted output
print_header() {
  echo -e "\n${BOLD}${BLUE}==== $1 ====${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

print_prompt() {
  echo -e "${YELLOW}➤ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Display welcome banner
echo -e "\n${BOLD}${BLUE}┌────────────────────────────────────┐${NC}"
echo -e "${BOLD}${BLUE}│      TODO APP SETUP ASSISTANT      │${NC}"
echo -e "${BOLD}${BLUE}└────────────────────────────────────┘${NC}\n"

print_header "Installing Dependencies"
print_info "Installing npm packages..."
npm install

# check if MySQL is installed
if ! command -v mysql &> /dev/null; then
  print_info "MySQL not found. Installing..."
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    print_info "Installing MySQL via Homebrew for macOS..."
    brew install mysql
    brew services start mysql
    sleep 5
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    print_info "Installing MySQL via apt for Linux..."
    sudo apt update
    sudo apt install -y mysql-server
    sudo systemctl start mysql
    sleep 5
  else
    print_error "Please install MySQL manually for your OS."
    exit 1
  fi
fi

# ensure MySQL is running
print_header "Configuring MySQL"
print_info "Ensuring MySQL service is running..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew services start mysql
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo systemctl start mysql
fi

# get password from user
print_prompt "Please enter a password for the database user:"
read -s DB_PASSWORD
echo
print_prompt "Confirm password:"
read -s DB_PASSWORD_CONFIRM
echo

if [[ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]]; then
  print_error "Passwords do not match. Please run setup again."
  exit 1
fi

DB_USER="todoapp"

print_info "Attempting to connect to MySQL..."

# try connect as root without a password
if mysql -u root -e "SELECT 1" &>/dev/null; then
  print_success "Connected to MySQL successfully."

  print_info "Creating database and user..."
  mysql -u root -e "CREATE DATABASE IF NOT EXISTS todo_app;"
  mysql -u root -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON todo_app.* TO '$DB_USER'@'localhost';"
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
  mysql -u root -e "FLUSH PRIVILEGES;"
  print_success "MySQL root password set."
else
  # try with provided password
  if mysql -u root -p$DB_PASSWORD -e "SELECT 1" &>/dev/null; then
    print_success "Connected to MySQL successfully."
    print_info "Creating database and user..."
    mysql -u root -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS todo_app;"
    mysql -u root -p$DB_PASSWORD -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
    mysql -u root -p$DB_PASSWORD -e "GRANT ALL PRIVILEGES ON todo_app.* TO '$DB_USER'@'localhost';"
    mysql -u root -p$DB_PASSWORD -e "FLUSH PRIVILEGES;"
  else
    # ask for existing root password
    print_prompt "Please enter your existing MySQL root password (leave blank if none):"
    read -s EXISTING_PASSWORD
    echo

    print_info "Setting up database..."
    if [[ -z "$EXISTING_PASSWORD" ]]; then
      mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
      mysql -u root -e "CREATE DATABASE IF NOT EXISTS todo_app;"
      mysql -u root -e "GRANT ALL PRIVILEGES ON todo_app.* TO '$DB_USER'@'localhost';"
      mysql -u root -e "FLUSH PRIVILEGES;"
    else
      mysql -u root -p$EXISTING_PASSWORD -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
      mysql -u root -p$EXISTING_PASSWORD -e "CREATE DATABASE IF NOT EXISTS todo_app;"
      mysql -u root -p$EXISTING_PASSWORD -e "GRANT ALL PRIVILEGES ON todo_app.* TO '$DB_USER'@'localhost';"
      mysql -u root -p$EXISTING_PASSWORD -e "FLUSH PRIVILEGES;"
    fi

    if [ $? -eq 0 ]; then
      print_success "Created $DB_USER user successfully."
    else
      print_error "Failed to create user. You may need to set up the database manually."
      exit 1
    fi
  fi
fi

print_header "Finalizing Setup"
# create .env file with credentials
echo "DB_USER=$DB_USER" > .env
echo "DB_PASSWORD=$DB_PASSWORD" >> .env
print_success "Password and user saved to .env file."

print_header "Setup Complete!"
echo -e "${GREEN}${BOLD}Todo App is ready to use!${NC}"
echo -e "${BLUE}Start the app with: ${YELLOW}npm start${NC}"
echo