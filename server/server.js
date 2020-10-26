require('dotenv').config();

const express = require("express");
const cors = require("cors");
const db = require("./database/queries");
const morgan = require('morgan');
const { Pool } = require('pg');
const keys = require("./keys");
const port = keys.port || 5000;

const app = express();

app.use(cors())
app.use(express.json());

// If True, then the database will be wiped and re-initialized. By default, use False.
const forceInitializeDatabase = keys.forceInitializeDatabase || false

if (forceInitializeDatabase) {
    console.log("Re-initializing database...");
    db.initDatabase();
}

//MIDDLEWARE
// match all request - middleware has to be before as express reads from top to bottom
// app.use(morgan('dev'));

// app.use((req, res, next) => {
//     res.status
//     next();
// });


// ROUTES 
//route handles = (req, res) aka request object and response object


/* API calls for Users */

// Get all Users. The same username can represent both a Pet Owner and Care Taker. A User is represented via the truth
// value of the is_carer attribute.
// Used for debugging.
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
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Get an existing User.
/*
    Expected inputs:
        Path parameter: username, which represents the unique username of the User. If the User is both a Pet Owner and
                            a Care Taker, the differences will be seen via the is_carer attribute.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.get("/api/v1/users/:username", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Users WHERE username = $1", [req.params.username]);
        res.status(200).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});



/* API calls for Accounts */

// Get all Account holders. This follows the rules of the Users API above, but includes the PCSAdmins.
// Used for debugging.
app.get("/api/v1/accounts", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Accounts");
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                accounts: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Get an existing Account holder.
/*
    Expected inputs:
        Path parameter: username, which represents the unique username of the Account holder. If the Account holder is
                            a PCSAdmin, this will be shown via the is_admin attribute. Else, if the Account holder is a
                            User who is both a Pet Owner and a Care Taker, the differences will be seen via the is_carer
                            attribute.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.get("/api/v1/accounts/:username", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Accounts WHERE username = $1", [req.params.username]);
        res.status(200).json({
            status: "success",
            data: {
                account: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});



/* API calls for Care Takers */


// Get all Care Takers.
// Used for debugging.
app.get("/api/v1/caretaker", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM CareTaker");
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                users: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Get an existing Care Taker.
/*
    Expected inputs:
        Path parameter: username, which represents the unique username of the Care Taker.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.get("/api/v1/caretaker/:username", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM CareTaker WHERE username = $1", [req.params.username]);
        res.status(200).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Create a new Care Taker.
/*
    Expected inputs:
        JSON object of the form:
        {
            "username": String,
            "name": String,
            "age": Integer (optional; put null otherwise),
            "petTypes": String array
        }

    Expected status code: 201 Created, or 400 Bad Request
 */
app.post("/api/v1/caretaker", async (req, res) => {
    try {
        const results = await db.query("INSERT INTO CareTaker(username, carerName, age, petTypes) " +
            "VALUES ($1, $2, $3, $4) RETURNING *",
            [req.body.username, req.body.carername, req.body.age, req.body.pettypes]);
        res.status(201).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Update an existing Care Taker's name, age, and pet types. Stores all fields in the input object to the database.
/*
    Expected inputs:
        JSON object of the form:
        {
            "name": String,
            "age": Integer (optional; put null otherwise),
            "petTypes": String array
        }

        Path parameter: username, which represents the unique username of the Care Taker.

    Expected status code: 204 No Content, or 400 Bad Request
 */
app.put("/api/v1/caretaker/:username", async (req, res) => {
    try {
        const results = await db.query("UPDATE CareTaker SET carerName = $1, age = $2, petTypes = $3" +
            " WHERE username = $4 RETURNING *",
            [req.body.carername, req.body.age, req.body.pettypes, req.params.username]);
        res.status(204).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Delete an existing Care Taker.
/*
    Expected inputs:
        Path parameter: username, which represents the unique username of the Care Taker.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.delete("/api/v1/caretaker/:username", async (req, res) => {
    try {
        const results = await db.query("DELETE FROM CareTaker WHERE username = $1", [req.params.username]);
        res.status(200).json({
            status: "success"
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});



/* API calls for Pet Owners */


// Get all Pet Owners.
// Used for debugging.
app.get("/api/v1/petowner", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM PetOwner");
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                users: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Get an existing Pet Owner.
/*
    Expected inputs:
        Path parameter: username, which represents the unique username of the Pet Owner.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.get("/api/v1/petowner/:username", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM PetOwner WHERE username = $1", [req.params.username]);
        res.status(200).json({
            status: "success",
            data: {
                user: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Create a new Pet Owner.
/*
    Expected inputs:
        JSON object of the form:
        {
            "username": String,
            "name": String,
            "age": Integer (optional; put null otherwise)
        }

    Expected status code: 201 Created, or 400 Bad Request
 */
app.post("/api/v1/petowner", async (req, res) => {
    try {
        const results = await db.query("CALL add_petOwner($1, $2, $3, $4, $5, $6, $7)",
            [req.body.username, req.body.ownername, req.body.age, req.body.pettype, req.body.petname, req.body.petage, req.body.requirements]);
        res.status(201).json({
            status: "success",
            data: {
                user: results.rows[0]

            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Update an existing Pet Owner's name and age. Stores the name and age in the query data as the new name and age.
/*
    Expected inputs:
        JSON object of the form:
        {
            "name": String,
            "age": Integer (optional; put null otherwise)
        }

        Path parameter: username, which represents the unique username of the Pet Owner.

    Expected status code: 204 No Content, or 400 Bad Request
 */
app.put("/api/v1/petowner/:username", async (req, res) => {
    try {
        const results = await db.query("UPDATE PetOwner SET ownerName = $1, age = $2 WHERE username = $3 RETURNING *",
            [req.body.ownername, req.body.age, req.params.username]);
        res.status(204).json({
            status: "success",
            data: {
                user: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Delete an existing Pet Owner.
/*
    Expected inputs:
        Path parameter: username, which represents the unique username of the Pet Owner.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.delete("/api/v1/petowner/:username", async (req, res) => {
    try {
        const results = await db.query("DELETE FROM PetOwner WHERE username = $1", [req.params.username]);
        res.status(200).json({
            status: "success"
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});



/* API calls for Pets */


// Get all Pets.
// Used for debugging.
app.get("/api/v1/pet", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Owned_Pet");
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                pets: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});

// Get all existing pets belonging to a username
/*
    Expected inputs:
        Path parameters:
            username, which represents the unique username of the Pet's Owner.
    
    Expected status code 200 OK, or 400 Bad Request
*/

app.get("/api/v1/pet/:username", async(req, res) => {
    try {
        const results = await db.query("SELECT * FROM Owned_Pet WHERE username = $1",
            [req.params.username]);
        res.status(200).json({
            status: "success",
            data: {
                pets: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Get an existing Pet.
/*
    Expected inputs:
        Path parameters:
            username, which represents the unique username of the Pet's Owner.
            petName, which represents the name of the Pet. For a Pet Owner, all Pet names are expected to be unique.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.get("/api/v1/pet/:username/:petName", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Owned_Pet WHERE username = $1 AND petName = $2",
            [req.params.username, req.params.petname]);
        res.status(200).json({
            status: "success",
            data: {
                pet: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Create a new Pet.
/*
    Expected inputs:
        JSON object of the form:
        {
            "username": String,
            "petName": String,
            "petType": String,
            "petAge": String,
            "requirements": String (optional; put null otherwise)
        }

    Expected status code: 201 Created, or 400 Bad Request
 */
app.post("/api/v1/pet", async (req, res) => {
    try {
        const results = await db.query(
            "INSERT INTO Owned_Pet(username, petName, petType, petAge, requirements) VALUES " +
            "($1, $2, $3, $4, $5) RETURNING *",
            [req.body.username, req.body.petname, req.body.pettype, req.body.petage, req.body.requirements]);
        res.status(201).json({
            status: "success",
            data: {
                pet: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Update an existing Pet's data. Overwrites all existing attributes with all attributes in the body of this request.
/*
    Expected inputs:
        JSON object of the form:
        {
            "petType": String,
            "petAge": String,
            "requirements": String (optional; put null otherwise)
        }

        Path parameter:
            username, which represents the unique username of the Pet's Owner.
            petName, which represents the name of the Pet. For a Pet Owner, all Pet names are expected to be unique.

    Expected status code: 204 No Content, or 400 Bad Request
 */
app.put("/api/v1/pet/:username/:petname", async (req, res) => {
    try {
        const results = await db.query("UPDATE Owned_Pet SET petType = $1, petAge = $2, requirements = $3" +
            " WHERE username = $4 AND petName = $5 RETURNING *",
            [req.body.pettype, req.body.petage, req.body.requirements, req.params.username, req.params.petname]);
        res.status(200).json({
            status: "success",
            data: {
                pet: results.rows[0]
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});


// Delete an existing Pet.
/*
    Expected inputs:
        Path parameter:
            username, which represents the unique username of the Pet's Owner.
            petName, which represents the name of the Pet. For a Pet Owner, all Pet names are expected to be unique.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.delete("/api/v1/pet/:username/:petName", async (req, res) => {
    try {
        const results = await db.query("DELETE FROM Owned_Pet WHERE username = $1 AND petName = $2",
            [req.params.username, req.params.petname]);
        res.status(200).json({
            status: "success"
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                "error": err
            }
        });
    }
});



app.listen(port, () => {
    console.log(`server has started on port ${port}`);
});
