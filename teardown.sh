#!/bin/bash
# Todo App Teardown Script
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

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

echo -e "\n${BOLD}${BLUE}┌────────────────────────────────────┐${NC}"
echo -e "${BOLD}${BLUE}│     TODO APP TEARDOWN ASSISTANT     │${NC}"
echo -e "${BOLD}${BLUE}└────────────────────────────────────┘${NC}\n"

# stop MySQL based on OS
stop_mysql() {
  print_header "Stopping MySQL Service"
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    print_info "Stopping MySQL via Homebrew..."
    if brew services stop mysql &>/dev/null; then
      print_success "MySQL service stopped successfully."
    else
      print_error "Failed to stop MySQL service. You may need to stop it manually."
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    print_info "Stopping MySQL via systemctl..."
    if sudo systemctl stop mysql &>/dev/null; then
      print_success "MySQL service stopped successfully."
    else
      print_error "Failed to stop MySQL service. You may need to stop it manually with 'sudo systemctl stop mysql'."
    fi
  else
    print_info "Please stop MySQL manually for your operating system."
  fi
}

# prompt for yes/no
ask_yes_no() {
  local prompt="$1"
  local response
  
  while true; do
    print_prompt "$prompt (y/n): "
    read -r response
    case "$response" in
      [Yy]* ) return 0 ;;
      [Nn]* ) return 1 ;;
      * ) echo "Please answer y (yes) or n (no)." ;;
    esac
  done
}

# drop the database
drop_database() {
  if ! command -v mysql &> /dev/null; then
    print_error "MySQL command not found. Cannot drop database."
    return 1
  fi
  
  # source .env file to get credentials
  if [ -f .env ]; then
    # parse .env file
    DB_USER=$(grep DB_USER .env | cut -d '=' -f2)
    DB_PASSWORD=$(grep DB_PASSWORD .env | cut -d '=' -f2)
    
    print_info "Attempting to drop todo_app database..."
    if mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE todo_app;" &>/dev/null; then
      print_success "Database dropped successfully."
    else
      print_error "Failed to drop database. You may need to drop it manually."
      print_info "You can use: mysql -u root -p -e 'DROP DATABASE todo_app;'"
    fi
  else
    print_error "No .env file found. Cannot determine database credentials."
    print_info "You may need to drop the database manually with:"
    print_info "mysql -u root -p -e 'DROP DATABASE todo_app;'"
  fi
}

# clean env file
clean_env_files() {
  if [ -f .env ]; then
    rm .env
    print_success "Removed .env file."
  else
    print_info "No .env file found."
  fi
}

print_header "MySQL Shutdown"
stop_mysql

# ask ab complete reset
print_header "Complete Reset Option"

if ask_yes_no "Would you like to perform a complete reset (drop database and remove .env file)?"; then
  print_info "Performing complete reset..."
  drop_database
  clean_env_files
  print_success "Reset complete. Next setup will start fresh."
else
  print_info "Skipping reset. Your database and configuration remain intact."
fi

print_header "Teardown Complete!"
echo -e "${GREEN}${BOLD}App resources have been cleaned up.${NC}"
echo -e "${BLUE}To restart the app later, run: ${YELLOW}npm run setup${NC}"