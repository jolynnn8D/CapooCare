require('dotenv').config();

const express = require("express");
const cors = require("cors");
const db = require("./db");
const morgan = require('morgan');
const { Pool } = require('pg');
const port = process.env.PORT || 5000;

const app = express();

app.use(cors())
app.use(express.json());

//MIDDLEWARE
// match all request - middleware has to be before as express reads from top to bottom
// app.use(morgan('dev'));

// app.use((req, res, next) => {
//     res.status
//     next();
// });


// ROUTES 
//route handles = (req, res) aka request object and response object

// Get all users
app.get("/api/v1/users", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Users");
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                users: results.rows
            }
        });
    } catch (err) {
        console.log(err);
    }
});

// Get a user
app.get("/api/v1/users/:id", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM users WHERE id=$1", [req.params.id]);
        res.status(200).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        console.log(err);
    }
});

// Create a user
app.post("/api/v1/users", async (req, res) => {
    try {
        const results = await db.query("INSERT INTO users (username) VALUES ($1) returning *", [req.body.username]);
        res.status(200).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        console.log(err);
    }
});

// Update a user
app.put("/api/v1/users/:id", async (req, res) => {
    try {
        const results = await db.query("UPDATE users SET name = $1 WHERE id = $2 returning *", [req.body.name, req.params.id]);
        res.status(200).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        console.log(err);
    }
});

// Delete User
app.delete("/api/v1/users/:id", async (req, res) => {
    try {
        const results = await db.query("DELETE FROM users WHERE id = $1", [req.params.id]);
        res.status(204).json({
            status: "success"
        });
    } catch (err) {
        console.log(err);
    }
});

app.listen(port, () => {
    console.log(`server has started on port ${port}`);
});