// connect express to postgres
const { Pool } = require('pg');

const pool = new Pool();

module.exports = {
    query: (text, params) => pool.query(text, params),
};

// Create User Table
const queryText =
    `CREATE TABLE IF NOT EXISTS 
        users(
            user_id serial PRIMARY KEY, 
            name VARCHAR(50) NOT NULL
        )`;
pool.query(queryText, (err, res) => {
    console.log(err, res)
});
