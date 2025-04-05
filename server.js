require("dotenv").config();

const express = require("express");
const path = require("path");
const mysql = require("mysql2");
const app = express();
const PORT = 4131;

const connection = mysql.createConnection({
  host: "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD,
  database: "todo_app",
});

// Handle connection errors
connection.connect((err) => {
  if (err) {
    console.error("Error connecting to MySQL:", err.message);
    console.error("Check if:");
    console.error("1. MySQL is running on your machine");
    console.error('2. The database "todo_app" exists');
    console.error("3. The user credentials are correct");
    console.error(
      "4. If using environment variables, DB_PASSWORD is set correctly"
    );
    process.exit(1);
  }
  console.log("Connected to MySQL database successfully!");
  setupDatabase();
});

// middlewares
app.set("view engine", "pug");
app.set("views", "views");
app.use(express.static("public"));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// setup for db
function setupDatabase() {
  connection.query(
    `
    CREATE TABLE IF NOT EXISTS todos (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      is_done BOOLEAN DEFAULT FALSE
    )
  `,
    (err) => {
      if (err) {
        console.error("Error creating todos table:", err.message);
      } else {
        console.log("Todos table ready");
      }
    }
  );

  connection.query(
    `
    CREATE TABLE IF NOT EXISTS comments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      todo_id INT,
      content TEXT NOT NULL,
      FOREIGN KEY (todo_id) REFERENCES todos(id) ON DELETE CASCADE
    )
  `,
    (err) => {
      if (err) {
        console.error("Error creating comments table:", err.message);
      } else {
        console.log("Comments table ready");
      }
    }
  );
}

app.get("/", (req, res) => {
  const filter = req.query.filter || "all";
  let query = "SELECT * FROM todos";
  if (filter === "done") {
    query += " WHERE is_done = TRUE";
  } else if (filter === "undone") {
    query += " WHERE is_done = FALSE";
  }

  connection.query(query, (error, todos) => {
    if (error) {
      console.error(error);
      return res.status(500).send("Database error: " + error.message);
    }
    res.render("index", { todos, filter });
  });
});

app.post("/todos", (req, res) => {
  const { title, description } = req.body;
  connection.query(
    "INSERT INTO todos (title, description) VALUES (?, ?)",
    [title, description],
    (error) => {
      if (error) {
        console.error(error);
        return res.status(500).send("Database error: " + error.message);
      }
      res.redirect("/");
    }
  );
});

app.get("/todos/:id", (req, res) => {
  const todoId = req.params.id;
  connection.query(
    "SELECT * FROM todos WHERE id = ?",
    [todoId],
    (error, todos) => {
      if (error) {
        console.error(error);
        return res.status(500).send("Database error: " + error.message);
      }
      connection.query(
        "SELECT * FROM comments WHERE todo_id = ?",
        [todoId],
        (error, comments) => {
          if (error) {
            console.error(error);
            return res.status(500).send("Database error: " + error.message);
          }
          res.render("todo", { todo: todos[0], comments });
        }
      );
    }
  );
});

app.post("/todos/:id/comments", (req, res) => {
  const { content } = req.body;
  const todoId = req.params.id;
  connection.query(
    "INSERT INTO comments (todo_id, content) VALUES (?, ?)",
    [todoId, content],
    (error) => {
      if (error) {
        console.error(error);
        return res.status(500).send("Database error: " + error.message);
      }
      res.redirect(`/todos/${todoId}`);
    }
  );
});

app.delete("/todos/:id", (req, res) => {
  const todoId = req.params.id;
  connection.query("DELETE FROM todos WHERE id = ?", [todoId], (error) => {
    if (error) {
      console.error(error);
      return res.status(500).json({ success: false, error: error.message });
    }
    res.json({ success: true });
  });
});

app.post("/todos/:id/toggle", (req, res) => {
  const todoId = req.params.id;
  connection.query(
    "UPDATE todos SET is_done = NOT is_done WHERE id = ?",
    [todoId],
    (error) => {
      if (error) {
        console.error(error);
        return res.status(500).json({ success: false, error: error.message });
      }
      res.json({ success: true });
    }
  );
});

app.put("/todos/:id", (req, res) => {
  const todoId = req.params.id;
  const { description } = req.body;
  connection.query(
    "UPDATE todos SET description = ? WHERE id = ?",
    [description, todoId],
    (error) => {
      if (error) {
        console.error(error);
        return res.status(500).json({ success: false, error: error.message });
      }
      res.json({ success: true });
    }
  );
});

app.delete("/comments/:id", (req, res) => {
  const commentId = req.params.id;
  connection.query(
    "DELETE FROM comments WHERE id = ?",
    [commentId],
    (error) => {
      if (error) {
        console.error(error);
        return res.status(500).json({ success: false, error: error.message });
      }
      res.json({ success: true });
    }
  );
});

app.listen(PORT, () => {
  console.log(
    `Server running at ${"\x1b[36m"}http://localhost:${PORT}${"\x1b[0m"}`
  );
});
