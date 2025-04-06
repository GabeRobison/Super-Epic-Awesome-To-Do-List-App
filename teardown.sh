#!/bin/bash
# Todo App Teardown Script (Clean Version)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo -e "\n${BOLD}${BLUE}== $1 ==${NC}\n"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_info() {
  echo -e "${BLUE}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

# Startup message
echo -e "\n${BOLD}${BLUE}TODO APP TEARDOWN ASSISTANT${NC}\n"

# Stop MySQL
stop_mysql() {
  print_header "Stopping MySQL Service"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    print_info "Stopping MySQL via Homebrew..."
    if brew services stop mysql; then
      print_success "MySQL service stopped."
    else
      print_error "Failed to stop MySQL. You may need to stop it manually."
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_info "Stopping MySQL via systemctl..."
    if sudo systemctl stop mysql; then
      print_success "MySQL service stopped."
    else
      print_error "Failed to stop MySQL. Try 'sudo systemctl stop mysql'."
    fi
  else
    print_info "Unrecognized OS. Please stop MySQL manually."
  fi
}

# Yes/no prompt
ask_yes_no() {
  local prompt="$1"
  local response

  while true; do
    echo -n "$prompt (y/n): "
    read -r response
    case "$response" in
      [Yy]* ) return 0 ;;
      [Nn]* ) return 1 ;;
      * ) echo "Please answer y or n." ;;
    esac
  done
}

# Drop database
drop_database() {
  if ! command -v mysql &> /dev/null; then
    print_error "MySQL not found. Cannot drop database."
    return 1
  fi

  if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)

    if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
      print_error "DB_USER or DB_PASSWORD missing in .env."
      return 1
    fi

    print_info "Dropping database 'todo_app'..."
    if mysql --protocol=tcp -u "$DB_USER" --password="$DB_PASSWORD" -e "DROP DATABASE IF EXISTS todo_app;"; then
      print_success "Database dropped."
    else
      print_error "Could not drop database. Check your credentials or if MySQL is running."
    fi
  else
    print_error ".env file not found. Skipping database drop."
  fi
}

# Remove .env file
clean_env_files() {
  if [ -f .env ]; then
    rm .env
    print_success ".env file removed."
  else
    print_info ".env file not found. Skipping."
  fi
}

# Teardown steps
print_header "Teardown Options"

if ask_yes_no "Do you want to perform a full reset (drop database and remove .env file)?"; then
  print_info "Running full reset..."
  drop_database
  clean_env_files
  print_success "Reset complete."
else
  print_info "Skipping full reset. Database and config left unchanged."
fi

stop_mysql

print_header "Teardown Complete"
print_success "Todo App resources have been cleaned up."
echo -e "${BLUE}To restart the app later, run:${NC} ${BOLD}npm run setup${NC}"
