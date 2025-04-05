# Super Epic Awesome To-Do List!

Todo list built with Express.js, MySQL, Pug.

## Features Implemented

- Core Features:
  - Create, view, and delete todo items
  - Mark todos as done/undone
  - Filter todos by done/undone
- Advanced Feature - Comments and Description:
  - Each todo has a page
  - Can edit descriptions
  - Create and delete comments under to-do's

## Quick Setup

The easiest way to get started is to use the npm setup script:

```bash
# Clone the repository
git clone https://github.com/GabeRobison/Super-Epic-Awesome-To-Do-List-App.git

# Run the setup script
npm run setup

# Start the application
npm start
```

The setup script will:

1. Install project dependencies
2. Check if MySQL is installed (and help install it if needed)
3. Create a database and user for the application
4. Create a .env file for your database password

### Stopping the Application

To properly stop the application and clean up resources:

1. Stop the Node.js server with Ctrl+C
2. Run the teardown script to stop MySQL and clean up resources:
   ```bash
   npm run teardown
   ```

The teardown script will:

1. Stop the MySQL service
2. Optionally drop the application database
3. Optionally remove environment files with credentials

This helps ensure a clean shutdown and prevents MySQL from consuming system resources when not in use.

## Manual Setup

### Prerequisites

- Node.js and npm
- MySQL

### Step 1: Install Dependencies

```bash
npm install
```

### Step 2: Set Up MySQL

1. Install MySQL if you haven't already:

   - macOS: `brew install mysql && brew services start mysql`
   - Linux: `sudo apt install mysql-server && sudo systemctl start mysql`
   - Windows: Download and install from [MySQL website](https://dev.mysql.com/downloads/installer/)

2. Create database and user:

```sql
CREATE DATABASE todo_app;
CREATE USER 'todouser'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON todo_app.* TO 'todouser'@'localhost';
FLUSH PRIVILEGES;
```

### Step 3: Configure Environment

Create a `.env` file in the project root:

```
DB_PASSWORD=your_password
```

### Step 4: Start the Application

```bash
npm start
```

## Project Structure

- `server.js` - Main application file with routes and server setup
- `views/` - Pug templates
  - `index.pug` - Home page with todo list
  - `nav.pug` - Nav bar template
  - `todo.pug` - Individual todo page with comments
- `public/` - Static files
  - `css.css` - Application styling
  - `script.js` - Client-side JavaScript
- `setup.sh` - Automated setup script

## Troubleshooting (Windows probably)

### MySQL Connection Issues

- Make sure MySQL is running:
  - macOS: `brew services list` or `brew services start mysql`
  - Linux: `sudo systemctl status mysql` or `sudo systemctl start mysql`
- Verify your .env file contains the correct password
- Try connecting manually: `mysql -u todouser -p`

### Database Table Creation Issues

If the tables aren't created automatically, you can create them manually:

```sql
USE todo_app;

CREATE TABLE todos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  is_done BOOLEAN DEFAULT FALSE
);

CREATE TABLE comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  todo_id INT,
  content TEXT NOT NULL,
  FOREIGN KEY (todo_id) REFERENCES todos(id) ON DELETE CASCADE
);
```

## Development Notes

This application was originally developed with a school MySQL server. It has been modified to work with a local MySQL database.
