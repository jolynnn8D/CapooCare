// connect express to postgres
const { Pool } = require('pg');
const fs = require('fs');
const keys = require('../keys')

const pool = new Pool({
    user: keys.pgUser,
    host: keys.pgHost,
    database: keys.pgDatabase,
    password: keys.pgPassword,
    port: keys.pgPort,
});


// Initialise database
const initDatabase = () => {
    const init = fs.readFileSync("database/init.sql").toString();
    try {
        pool.query(init).then(r => console.log('Database initialised successfully'));
    } catch (err) {
        console.log(err);
        throw err;
    }
}


module.exports = {
    initDatabase: initDatabase,
    query: (text, params) => pool.query(text, params)
};
