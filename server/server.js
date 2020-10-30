require('dotenv').config();

const express = require("express");
const cors = require("cors");
const db = require("./database/init");
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
                account: results.rows // double-check this
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


// Create a new FullTimer.
/*
    Expected inputs:
        JSON object of the form:
        {
            "username": String,
            "name": String,
            "age": Integer,
            "pettype": String,
            "price" : Integer,
            "period1_s" : string (to be converted to date),
            "period1_e" : string (to be converted to date),
            "period2_s" : string (to be converted to date),
            "period2_e" : string (to be converted to date)
        }

    Expected status code: 201 Created, or 400 Bad Request
 */

app.post("/api/v1/fulltimer", async (req, res) => {
    try {
        const results = await db.query("Call add_fulltimer($1, $2, $3, $4, $5, to_date($6, 'YYYYMMDD'), to_date($7, 'YYYYMMDD'), to_date($8, 'YYYYMMDD'), to_date($9, 'YYYYMMDD'))",
            [req.body.username, req.body.name, req.body.age, req.body.pettype, req.body.price, req.body.period1_s, req.body.period1_e, req.body.period2_s, req.body.period2_e]);
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

// Create a new PartTimer.
/*
    Expected inputs:
        JSON object of the form:
        {
            "username": String,
            "name": String,
            "age": Integer (optional; put null otherwise),
            "pettype": String
            "price" : Integer
        }

    Expected status code: 201 Created, or 400 Bad Request
 */
app.post("/api/v1/parttimer", async (req, res) => {
    try {
        console.log(req.body);
        const results = await db.query("Call add_parttimer($1, $2, $3, $4, $5)",
            [req.body.username, req.body.name, req.body.age, req.body.pettype, req.body.price]);
        console.log(res);
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


// Update an existing Care Taker's name, age, and pet type. Stores all fields in the input object to the database.
/*
    Expected inputs:
        JSON object of the form:
        {
            "name": String,
            "age": Integer (optional; put null otherwise),
            "pettype": String
        }

        Path parameter: username, which represents the unique username of the Care Taker.

    Expected status code: 204 No Content, or 400 Bad Request
 */
app.put("/api/v1/caretaker/:username", async (req, res) => {
    try {
        const results = await db.query("UPDATE CareTaker SET carerName = $1, age = $2, pettype = $3" +
            " WHERE username = $4 RETURNING *",
            [req.body.carername, req.body.age, req.body.pettype, req.params.username]);
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
        const results = await db.query("SELECT * FROM Owned_Pet_Belongs");
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
        const results = await db.query("SELECT * FROM Owned_Pet_Belongs WHERE username = $1",
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
            petname, which represents the name of the Pet. For a Pet Owner, all Pet names are expected to be unique.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.get("/api/v1/pet/:username/:petname", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Owned_Pet_Belongs WHERE username = $1 AND petname = $2",
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
            "petname": String,
            "petType": String,
            "petAge": String,
            "requirements": String (optional; put null otherwise)
        }

    Expected status code: 201 Created, or 400 Bad Request
 */
app.post("/api/v1/pet", async (req, res) => {
    try {
        const results = await db.query(
            "INSERT INTO Owned_Pet_Belongs(username, petname, petType, petAge, requirements) VALUES " +
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
            "pettype": String,
            "petage": String,
            "requirements": String (optional; put null otherwise)
        }

        Path parameter:
            username, which represents the unique username of the Pet's Owner.
            petname, which represents the name of the Pet. For a Pet Owner, all Pet names are expected to be unique.

    Expected status code: 204 No Content, or 400 Bad Request
 */
app.put("/api/v1/pet/:username/:petname", async (req, res) => {
    try {
        const results = await db.query("UPDATE Owned_Pet_Belongs SET pettype = $1, petage = $2, requirements = $3" +
            " WHERE username = $4 AND petname = $5 RETURNING *",
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
            petname, which represents the name of the Pet. For a Pet Owner, all Pet names are expected to be unique.

    Expected status code: 200 OK, or 400 Bad Request
 */
app.delete("/api/v1/pet/:username/:petname", async (req, res) => {
    try {
        const results = await db.query("DELETE FROM Owned_Pet_Belongs WHERE username = $1 AND petname = $2",
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

/* API calls for Category */

// Get all the pet categories
app.get("/api/v1/categories", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Category");
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

app.get("/api/v1/categories/:username", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM Cares WHERE ctuname = $1",
            [req.params.username]);
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

app.post("/api/v1/categories/:username", async (req, res) => {
    try {
        const results = await db.query("INSERT INTO Cares(ctuname, pettype, price) VALUES ($1, $2, $3) RETURNING *",
            [req.params.username, req.body.pettype, req.body.price]);
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                pets: results.rows[0]
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



/* API calls for Bid */

// Adds a Bid.
/*
    Expected inputs:
        JSON object of the form:
        {
            ctuname: String,
            pouname: String,
            petname: String,
            pettype: String,
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)
        }

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.post("/api/v1/bid/", async (req, res) => {
    db.query("CALL add_bid($1, $2, $3, $4, to_date($5,'YYYYMMDD'), to_date($6,'YYYYMMDD'))",
        [req.body.pouname, req.body.petname, req.body.pettype, req.body.ctuname, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    bid: result.rows[0]
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Gets all Bids for a Caretaker.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/bid/:ctuname", async (req, res) => {
    db.query("SELECT * FROM Bid WHERE ctuname = $1",
        [req.params.ctuname]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    bids: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Gets all Bids between a Caretaker and a Petowner.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.
            pouname, which is the username of the Petowner.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/bid/:ctuname/:pouname", async (req, res) => {
    db.query("SELECT * FROM Bid WHERE ctuname = $1 AND pouname = $2",
        [req.params.ctuname, req.params.pouname]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    bids: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Gets all Bids between a Caretaker and a Petowner, within a specified timeframe. This will return all Bids that
// entirely intersect the specified s_time and e_time. Partial overlaps will not be returned.
/*
    Expected inputs:
        JSON object of the form:
        {
            "s_time": String (in the format YYYYMMDD, which will be converted into a Date),
            "e_time": String (in the format YYYYMMDD, which will be converted into a Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.
            pouname, which is the username of the Petowner.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/bid/:ctuname/:pouname/time", async (req, res) => {
    db.query("SELECT * FROM Bid WHERE ctuname = $1 AND pouname = $2 AND s_time >= to_date($5,'YYYYMMDD') AND e_time <= to_date($6,'YYYYMMDD')",
        [req.params.ctuname, req.params.pouname, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    bids: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Gets all Bids between a Caretaker and a specific Pet, within a specified timeframe. This will return all Bids that
// entirely intersect the specified s_time and e_time. Partial overlaps will not be returned.
/*
    Expected inputs:
        JSON object of the form:
        {
            "petname": String,
            "pettype": String,
            "s_time": String (in the format YYYYMMDD, which will be converted into a Date),
            "e_time": String (in the format YYYYMMDD, which will be converted into a Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.
            pouname, which is the username of the Petowner.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/bid/:ctuname/:pouname/time/pet", async (req, res) => {
    db.query("SELECT * FROM Bid WHERE ctuname = $1 AND pouname = $2 AND petname = $3 AND pettype = $4 AND s_time >= to_date($5,'YYYYMMDD') AND e_time <= to_date($6,'YYYYMMDD')",
        [req.params.ctuname, req.params.pouname, req.body.petname, req.body.pettype, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    bids: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// IMPORTANT: If no rows are returned, then the updating has failed (most likely because it was not marked beforehand).
// Updates a specific Bid. This can only be done if the Bid has been won already. Otherwise, the details cannot be
// updated. If the key characteristics are to be changed (i.e. CT, Pet, and time details), then the Bid should be
// deleted and re-added.
/*
    Expected inputs:
        JSON object of the form:
        {
            ctuname: String,
            pouname: String,
            petname: String,
            pettype: String,
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            pay_type: String (which is either NULL, 'credit card', or 'cash'),
            pet_pickup: String (which is either NULL, 'poDeliver', 'ctPickup', or 'transfer'),
            rating: Integer (which is either NULL, or between 0 and 5 inclusive),
            review: String (which is either NULL, or a string limited to 200 characters),
            pay_status: Boolean (cannot be NULL; default False)
        }

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.put("/api/v1/bid/", async (req, res) => {
    db.query("UPDATE Bid SET pay_type = $1, pet_pickup = $2, rating = $3, review = $4, pay_status = $5" +
        " WHERE ctuname = $6 AND pouname = $7 AND petname = $8 AND pettype = $9 AND s_time = to_date($10,'YYYYMMDD') AND " +
        " e_time = to_date($11,'YYYYMMDD') AND is_win = True RETURNING *",
        [req.body.pay_type, req.body.pet_pickup, req.body.rating, req.body.review, req.body.pay_status,
            req.body.ctuname, req.body.pouname, req.body.petname, req.body.pettype, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            if (result.rows.length === 0) {
                res.status(200).json({
                    status: "unsuccessful update",
                    message: "This is most likely because is_win = False or NULL. Also consider that the params might wrong."
                });
            } else {
                res.status(200).json({
                    status: "success",
                    data: {
                        bids: result.rows
                    }
                });
            }
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Deletes all Bids between a Caretaker and a specific Pet, within a specified timeframe. This will delete all Bids that
// entirely intersect the specified s_time and e_time. Partial overlaps will not be deleted.
/*
    Expected inputs:
        JSON object of the form:
        {
            "petname": String,
            "pettype": String,
            "s_time": String (in the format YYYYMMDD, which will be converted into a Date),
            "e_time": String (in the format YYYYMMDD, which will be converted into a Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.
            pouname, which is the username of the Petowner.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.delete("/api/v1/bid/:ctuname/:pouname/pet", async (req, res) => {
    db.query("DELETE FROM Bid WHERE ctuname = $1 AND pouname = $2 AND petname = $3 AND pettype = $4 AND s_time >= to_date($5,'YYYYMMDD') AND e_time <= to_date($6,'YYYYMMDD') RETURNING *",
        [req.params.ctuname, req.params.pouname, req.body.petname, req.body.pettype, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    bids: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Marks a Bid between a Caretaker's Availability and a specific Pet. This will only mark a Bid that is referred
// to exactly via its s_time and e_time. The GET APIs should be used to verify the exact s_time and e_time.
/*
    Expected inputs:
        JSON object of the form:
        {
            "petname": String,
            "pettype": String,
            "s_time": String (in the format YYYYMMDD, which will be converted into a Date),
            "e_time": String (in the format YYYYMMDD, which will be converted into a Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.
            pouname, which is the username of the Petowner.

    Expected status code:
        200 OK, if successful
        409 Conflict, if caretaker has exceeded their allowed number of Pets at that time.
 */
app.put("/api/v1/bid/:ctuname/:pouname/mark", async (req, res) => {
    db.query("UPDATE Bid SET is_win = True WHERE ctuname = $1 AND pouname = $2 AND petname = $3 AND pettype = $4 AND s_time = to_date($5,'YYYYMMDD') AND e_time = to_date($6,'YYYYMMDD') RETURNING *",
        [req.params.ctuname, req.params.pouname, req.body.petname, req.body.pettype, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            if (result.rows.length === 0) {
                res.status(200).json({
                    status: "unsuccessful update (check parameters)",
                });
            } else {
                res.status(200).json({
                    status: "success",
                    data: {
                        bids: result.rows
                    }
                });
            }
        }
    ).catch(
        (error) => {
            res.status(409).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});



/* API calls for Availability */

// Adds an Availability.
/*
    Expected inputs:
        JSON object of the form:
        {
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.post("/api/v1/availability/:ctuname", async (req, res) => {
    db.query("INSERT INTO Has_Availability VALUES ($1, to_date($2,'YYYYMMDD'), to_date($3,'YYYYMMDD')) RETURNING *",
        [req.params.ctuname, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    availability: result.rows[0]
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Gets all Availabilities.
// Used for debugging.
app.get("/api/v1/availability/", async (req, res) => {
    db.query(
        "SELECT * FROM Has_Availability"
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    availabilities: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Gets all Availabilities from a Caretaker within a timeframe. All availabilities indicated by the caretaker will be
// returned in this query, within the s_time and e_time indicated in this API call.
/*
    Expected inputs:
        JSON object of the form:
        {
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/availability/:ctuname", async (req, res) => {
    db.query("SELECT * FROM Has_Availability WHERE ctuname = $1 AND s_time >= to_date($2,'YYYYMMDD') AND e_time <= to_date($3,'YYYYMMDD')",
        [req.params.ctuname, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    availabilities: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});


// Deletes all Availabilities from a Caretaker within a timeframe. All availabilities indicated by the caretaker that
// entirely intersect the s_time and e_time indicated will be deleted. This does not include partial overlaps.
/*
    Expected inputs:
        JSON object of the form:
        {
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)
        }

        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.delete("/api/v1/availability/:ctuname", async (req, res) => {
    db.query("DELETE FROM Has_Availability WHERE ctuname = $1 AND s_time >= to_date($2,'YYYYMMDD') AND e_time <= to_date($3,'YYYYMMDD') RETURNING *",
        [req.params.ctuname, req.body.s_time, req.body.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    availabilities: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    "error": error
                }
            })
        }
    )
});



app.listen(port, () => {
    console.log(`server has started on port ${port}`);
});
