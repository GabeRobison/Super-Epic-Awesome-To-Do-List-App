const express = require("express");
const path = require("path");
const mysql = require("mysql2");
const app = express();
const PORT = 4131;

const connection = mysql.createConnection({
  host: "cse-mysql-classes-01.cse.umn.edu",
  user: "C4131F24U38",
  password: "1494",
  database: "C4131F24U38",
});

// middlewares
app.set("view engine", "pug");
app.set("views", "views");
app.use(express.static("public"));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// setup for db
connection.query(`
  CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    is_done BOOLEAN DEFAULT FALSE
  )
`);

// https://www.geeksforgeeks.org/mysql-on-delete-cascade-constraint/
connection.query(`
  CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    todo_id INT,
    content TEXT NOT NULL,
    FOREIGN KEY (todo_id) REFERENCES todos(id) ON DELETE CASCADE
  )
`);

app.get("/", (req, res) => {
  const filter = req.query.filter || "all";
  let query = "SELECT * FROM todos";
  if (filter === "done") {
    query += " WHERE is_done = TRUE";
  } else if (filter === "undone") {
    query += " WHERE is_done = FALSE";
  }

  connection.query(query, (error, todos) => {
    if (error) throw error;
    res.render("index", { todos, filter });
  });
});

app.post("/todos", (req, res) => {
  const { title, description } = req.body;
  connection.query(
    "INSERT INTO todos (title, description) VALUES (?, ?)",
    [title, description],
    (error) => {
      if (error) throw error;
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
      if (error) throw error;
      connection.query(
        "SELECT * FROM comments WHERE todo_id = ?",
        [todoId],
        (error, comments) => {
          if (error) throw error;
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
      if (error) throw error;
      res.redirect(`/todos/${todoId}`);
    }
  );
});

app.delete("/todos/:id", (req, res) => {
  const todoId = req.params.id;
  connection.query("DELETE FROM todos WHERE id = ?", [todoId], (error) => {
    if (error) throw error;
    res.json({ success: true });
  });
});

app.post("/todos/:id/toggle", (req, res) => {
  const todoId = req.params.id;
  connection.query(
    "UPDATE todos SET is_done = NOT is_done WHERE id = ?",
    [todoId],
    (error) => {
      if (error) throw error;
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
      if (error) throw error;
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
      if (error) throw error;
      res.json({ success: true });
    }
  );
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
