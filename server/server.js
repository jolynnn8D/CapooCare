require('dotenv').config();

const express = require("express");
const cors = require("cors");
const db = require("./database/init");
const keys = require("./keys");
const port = keys.port || 5000;

const app = express();

app.use(cors())
app.use(express.json());

// If True, then the database will be wiped and re-initialized. By default, use False.
const forceInitializeDatabase = keys.forceInitializeDatabase || false

if (forceInitializeDatabase === "true" || forceInitializeDatabase === "True") {
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
                error: err
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
                error: err
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
                error: err
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
                account: results.rows[0] // double-check this
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                error: err
            }
        });
    }
});

app.post("/api/v1/pcsadmin", async (req, res) => {
    try {
        const results = await db.query("INSERT INTO pcsadmin(username, adminname, age) VALUES ($1, $2, NULL) RETURNING *", [req.body.username, req.body.adminname]);
        res.status(200).json({
            status: "success",
            data: {
                admin: results.rows[0] // double-check this
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                error: err
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
                error: err
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
                error: err
            }
        });
    }
});

app.get("/api/v1/pettype", async (req, res) => {
    try {
        const results = await db.query("SELECT * FROM cares");
        res.status(200).json({
            status: "success",
            results: results.rows.length,
            data: {
                pettypes: results.rows
            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                error: err
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
                error: err
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
                error: err
            }
        });
    }
});


// Update an existing Care Taker's name, age. Stores all fields in the input object to the database.
/*
    Expected inputs:
        JSON object of the form:
        {
            "name": String,
            "age": Integer
        }

        Path parameter: username, which represents the unique username of the Care Taker.

    Expected status code: 204 No Content, or 400 Bad Request
 */
app.put("/api/v1/caretaker/:username", async (req, res) => {
    try {
        const results = await db.query("UPDATE CareTaker SET carerName = $1, age = $2" +
            " WHERE username = $3 RETURNING *",
            [req.body.carername, req.body.age, req.params.username]);
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
                error: err
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
                error: err
            }
        });
    }
});


/*
    Gets all pet categories that the Caretaker can not currently take care of, ordered by how lucrative they are for the
    specified timeframe. A 'lucrative' category is a category with a large overall amount of money involved between all
    Petowners and all Caretakers for all winning Bids for the specified category. This could be used by the Caretaker to
    analyze which categories of Pet they should train themselves to care for next.

    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker
            s_time, which is the starting day of the timeframe (to be specified in YYYYMMDD format as a String)
            e_time, which is the ending day of the timeframe (to be specified in YYYYMMDD format as a String)
        IMPORTANT: Both days specified by s_time and e_time are included in the calculation. This also means that
                        if s_time = e_time, then the lucrative score for that 1 day will be calculated.

        Expected status code:
            200 OK, if successful
            400 Bad Request, if general failure
 */
app.get("/api/v1/caretaker/summary/:ctuname/:s_time/:e_time/lucrative", async (req, res) => {
    db.query("SELECT pettype, SUM(cost) AS lucrative_score" +
        "        FROM Bid" +
        "        WHERE pettype IN (" +
        "            SELECT pettype" +
        "                FROM Category" +
        "                WHERE pettype NOT IN (" +
        "                    SELECT pettype" +
        "                        FROM Cares" +
        "                        WHERE ctuname = $1" +
        "                )" +
        "        ) AND is_win = true" +
        "               AND s_time >= to_date($2, 'YYYYMMDD') AND e_time <= to_date($3, 'YYYYMMDD')" +
        "        GROUP BY pettype" +
        "    UNION" +
        "    SELECT pettype, 0 AS lucrative_score" +
        "        FROM Category" +
        "        WHERE pettype NOT IN (" +
        "            SELECT pettype" +
        "                FROM Bid" +
        "                WHERE is_win = true" +
        "        ) AND pettype NOT IN (" +
        "            SELECT pettype" +
        "                FROM Cares" +
        "                WHERE ctuname = $1" +
        "        )" +
        "    ORDER BY lucrative_score DESC, pettype;",
        [req.params.ctuname, req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    categories: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});


/*
    Gets the number of pet-days for a Caretaker during a specific timeframe. Group this by the type of pet cared for.

    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker
            s_time, which is the starting day of the timeframe (to be specified in YYYYMMDD format as a String)
            e_time, which is the ending day of the timeframe (to be specified in YYYYMMDD format as a String)
        IMPORTANT: Both days specified by s_time and e_time are included in the calculation. This also means that
                        if s_time = e_time, then the pets cared for during that 1 day will be calculated.

        Expected status code:
            200 OK, if successful
            400 Bad Request, if general failure
 */

app.get("/api/v1/caretaker/summary/:ctuname/:s_time/:e_time/pettype", async (req, res) => {
    db.query(
        "SELECT petType AS pet_type, COUNT(day) AS count" +
        "    FROM (" +
        "        SELECT" +
        "            generate_series(" +
        "                GREATEST(to_date($2, 'YYYYMMDD')::timestamp, s_time::timestamp)," +
        "                LEAST(to_date($3, 'YYYYMMDD')::timestamp, e_time::timestamp)," +
        "                '1 day'::interval" +
        "            ) AS day, petType, pouname, petName" +
        "            FROM Bid NATURAL JOIN Cares" +
        "            WHERE ctuname = $1 AND is_win = true" +
        "                AND (s_time, e_time) OVERLAPS (to_date($2, 'YYYYMMDD'), to_date($3, 'YYYYMMDD'))" +
        "            GROUP BY day, petType, pouname, petName" +
        "    ) AS pet_days" +
        "    GROUP BY petType" +
        "    ORDER BY count DESC",
        [req.params.ctuname, req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    petdays: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});


/*
    Gets the number of pet-days for a Caretaker during a specific timeframe. Group this by the petowner who owned the
        pet.

    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker
            s_time, which is the starting day of the timeframe (to be specified in YYYYMMDD format as a String)
            e_time, which is the ending day of the timeframe (to be specified in YYYYMMDD format as a String)
        IMPORTANT: Both days specified by s_time and e_time are included in the calculation. This also means that
                        if s_time = e_time, then the pets cared for during that 1 day will be calculated.

        Expected status code:
            200 OK, if successful
            400 Bad Request, if general failure
 */

app.get("/api/v1/caretaker/summary/:ctuname/:s_time/:e_time/petowner", async (req, res) => {
    db.query(
        "SELECT pouname AS username, COUNT(day) AS count" +
        "    FROM (" +
        "        SELECT" +
        "            generate_series(" +
        "                GREATEST(to_date($2, 'YYYYMMDD')::timestamp, s_time::timestamp)," +
        "                LEAST(to_date($3, 'YYYYMMDD')::timestamp, e_time::timestamp)," +
        "                '1 day'::interval" +
        "            ) AS day, petType, pouname, petName" +
        "            FROM Bid NATURAL JOIN Cares" +
        "            WHERE ctuname = $1 AND is_win = true" +
        "                AND (s_time, e_time) OVERLAPS (to_date($2, 'YYYYMMDD'), to_date($3, 'YYYYMMDD'))" +
        "            GROUP BY day, petType, pouname, petName" +
        "    ) AS pet_days" +
        "    GROUP BY pouname" +
        "    ORDER BY count DESC",
        [req.params.ctuname, req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    petdays: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
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
                error: err
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
                error: err
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
                error: err
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
                error: err
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
                error: err
            }
        });
    }
});

/* Get all caretakers that can take care of all the petowners' pet at a certain period of time. 
    Results are arranged according to decreasing rating then by increasing total cost */

app.get("/api/v1/petowner/:username/all_ct/:s_time/:e_time",  async (req, res) => {
    try {
        const results = await db.query(
            "SELECT DISTINCT A.ctuname,   " +
            "COALESCE((SELECT AVG(rating)  FROM Bid Where ctuname = A.ctuname GROUP BY ctuname),3) AS rating, " +
            "(SELECT SUM(price) * (to_date($3,'YYYYMMDD') - to_date($2,'YYYYMMDD') + 1) AS DAYS  " +
            "    FROM Cares  " +
            "    WHERE ctuname = A.ctuname AND pettype IN ( " +
            "                SELECT DISTINCT pettype FROM Owned_Pet_Belongs WHERE pouname = $1 )) AS price " +
            " " +
            "FROM  Has_Availability A  " +
            "WHERE NOT EXISTS ( " +
            "        SELECT 1 " +
            "        FROM (SELECT DISTINCT pettype FROM Owned_Pet_Belongs WHERE pouname = $1) AS PT " +
            "        WHERE NOT EXISTS ( " +
            "                    SELECT price " +
            "                    FROM (SELECT DISTINCT pettype, price  " +
            "                            FROM Cares  " +
            "                            WHERE ctuname = A.ctuname) AS C2 " +
            "                    WHERE C2.pettype = PT.pettype " +
            "                        ) " +
            "        ) " +
            "    AND s_time <= to_date($2,'YYYYMMDD') " +
            "    AND e_time >= to_date($3,'YYYYMMDD') " +
            "    AND ( " +
            "            (  " +
            "                A.ctuname IN (SELECT username FROM Fulltimer)  " +
            "                AND " +
            "                (SELECT COUNT(*) " +
            "                FROM Bid " +
            "                WHERE A.ctuname = Bid.ctuname AND Bid.is_win = True  AND (to_date($2,'YYYYMMDD'), to_date($3,'YYYYMMDD'))  " +
            "                    OVERLAPS (Bid.s_time, Bid.e_time)) < 5 " +
            "            ) " +
            "        OR " +
            "            ( " +
            "                A.ctuname IN (SELECT username FROM Parttimer)  " +
            "                AND " +
            "                CASE WHEN (SELECT AVG(rating) " +
            "                            FROM Bid AS B " +
            "                            WHERE  A.ctuname = B.ctuname) IS NULL  " +
            "                            OR " +
            "                            (SELECT AVG(rating) " +
            "                            FROM Bid AS B " +
            "                            WHERE  A.ctuname = B.ctuname) < 4  " +
            "                        THEN  " +
            "                        (SELECT COUNT(*) " +
            "                        FROM Bid " +
            "                        WHERE A.ctuname = Bid.ctuname AND Bid.is_win = True AND (to_date($2,'YYYYMMDD'), to_date($3,'YYYYMMDD'))  " +
            "                            OVERLAPS (Bid.s_time, Bid.e_time)) < 2 " +
            "                    ELSE (SELECT COUNT(*) " +
            "                            FROM Bid " +
            "                            WHERE 'johnthebest' = Bid.ctuname AND Bid.is_win = True AND (to_date($2,'YYYYMMDD'), to_date($3,'YYYYMMDD'))  " +
            "                                OVERLAPS (Bid.s_time, Bid.e_time)) < 5 " +
            "                END " +
            "            ) " +
            "        ) " +
            "ORDER BY rating DESC, " +
            "         price ASC; " 
            , [req.params.username, req.params.s_time, req.params.e_time]);
        res.status(200).json({
            status: "success",
            data: {
                caretakers: results.rows

            }
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                error: err
            }
        });
    }
})

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
                error: err
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
        const results = await db.query("SELECT * FROM Owned_Pet_Belongs WHERE pouname = $1",
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
                error: err
            }
        });
    }
});

// Get all existing pets belonging to a username of a certain pet type
/*
    Expected inputs:
        Path parameters:
            username, which represents the unique username of the Pet's Owner.
            pettype, which represents the pet type that to retrieve.
    
    Expected status code 200 OK, or 400 Bad Request
*/
app.get("/api/v1/pet/:username/:pettype", async(req, res) => {
    try {
        const results = await db.query("SELECT * FROM Owned_Pet_Belongs WHERE pouname = $1 AND pettype = $2",
            [req.params.username, req.params.pettype]);
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
                error: err
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
        const results = await db.query("SELECT * FROM Owned_Pet_Belongs WHERE pouname = $1 AND petName = $2",
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
                error: err
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
            "INSERT INTO Owned_Pet_Belongs(pouname, petName, petType, petAge, requirements) VALUES " +
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
                error: err
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
            " WHERE pouname = $4 AND petname = $5 RETURNING *",
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
                error: err
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
        const results = await db.query("DELETE FROM Owned_Pet_Belongs WHERE pouname = $1 AND petname = $2",
            [req.params.username, req.params.petname]);
        res.status(200).json({
            status: "success"
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                error: err
            }
        });
    }
});

/* API calls for Category */

// Get all the pet categories and their base prices
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
                error: err
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
                error: err
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
                error: err
            }
        });
    }
});

app.delete("/api/v1/categories/:username/:pettype", async (req, res) => {
    try {
        const results = await db.query("DELETE FROM Cares WHERE ctuname = $1 AND pettype = $2",
            [req.params.username, req.params.pettype]);
        res.status(200).json({
            status: "success"
        });
    } catch (err) {
        res.status(400).json({
            status: "failed",
            data: {
                error: err
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
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            pay_type: String (which is either NULL, 'credit card', or 'cash'),
            pet_pickup: String (which is either NULL, 'poDeliver', 'ctPickup', or 'transfer')
        }

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.post("/api/v1/bid/", async (req, res) => {
    db.query("CALL add_bid($1, $2, $3, $4, to_date($5,'YYYYMMDD'), to_date($6,'YYYYMMDD'), $7, $8)",
        [req.body.pouname, req.body.petname, req.body.pettype, req.body.ctuname, req.body.s_time, req.body.e_time, req.body.pay_type, req.body.pet_pickup]
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
                    error: error
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
app.get("/api/v1/bid/:ctuname/ct", async (req, res) => {
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
                    error: error
                }
            })
        }
    )
});


// Gets all Bids for a Petowner.
/*
    Expected inputs:
        Path parameters:
            pouname, which is the username of the Petowner.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/bid/:pouname/po", async (req, res) => {
    db.query("SELECT * FROM Bid WHERE pouname = $1 ORDER BY s_time DESC",
        [req.params.pouname]
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
                    error: error
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
                    error: error
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
                    error: error
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
                    error: error
                }
            })
        }
    )
});


// Updates a specific Bid. This can only be done if the Bid has been won already. Otherwise, the details cannot be
// updated. If the key characteristics are to be changed (i.e. CT, Pet, and time details), then the Bid should be
// deleted and re-added.
// IMPORTANT: If no rows are returned, then the updating has failed (most likely because it was not marked beforehand).
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
                res.status(400).json({
                    status: "unsuccessful update",
                    message: "Check that: 1) is_win is not NULL or false, 2) s_time and e_time are entered in YYYYMMDD, " +
                        "3) you have correctly identified the start and end dates, 4) pouname and ctuname are in the right order."
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
                    error: error
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
                    error: error
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
                res.status(400).json({
                    status: "unsuccessful update",
                    message: "Check that: 2) s_time and e_time are entered in YYYYMMDD, 2) you have correctly identified" +
                        " the start and end dates, 3) pouname and ctuname are in the right order, 4) the CT is not overloaded."
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
                    error: error
                }
            })
        }
    )
});

// Completes a payment status between a Caretaker's Availability and a specific Pet. This will only change the 
// payment status of a Bid that is referred to exactly via its s_time and e_time. The GET APIs should be used to
// verify the exact s_time and e_time.
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
app.put("/api/v1/bid/:ctuname/:pouname/pay", async (req, res) => {
    db.query("UPDATE Bid SET pay_status = True WHERE ctuname = $1 AND pouname = $2 AND petname = $3 AND pettype = $4 AND s_time = to_date($5,'YYYYMMDD') AND e_time = to_date($6,'YYYYMMDD') RETURNING *",
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
                    error: error
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
    console.log(req)
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
                    error: error
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
                    error: error
                }
            })
        }
    )
});


// Gets all Availabilities from a Caretaker within a timeframe. All availabilities indicated by the caretaker will be
// returned in this query, within the s_time and e_time indicated in this API call.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get('/api/v1/availability/:ctuname/:s_time/:e_time', async (req, res) => {
    db.query("SELECT * FROM Has_Availability WHERE ctuname = $1 AND (s_time, e_time) OVERLAPS (to_date($2, 'YYYYMMDD'), to_date($3, 'YYYYMMDD'))",
        [req.params.ctuname, req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    availabilities: result.rows,
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

// Gets all Availabilities from All Caretakers within a timeframe. All availabilities indicated by the caretaker will be
// returned in this query, within the s_time and e_time indicated in this API call.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get('/api/v1/availability/:s_time/:e_time', async (req, res) => {
    console.log(req.params);
    db.query("SELECT * FROM has_availability WHERE s_time <= to_date($1,'YYYYMMDD') AND e_time >= to_date($2,'YYYYMMDD')",
        [req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    availabilities: result.rows,
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});


// Gets all Availabilities from a Caretaker. All availabilities indicated by the caretaker will be
// returned in this query.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
// app.get("/api/v1/availability/:ctuname", async (req, res) => {
//     db.query("SELECT * FROM Has_Availability WHERE ctuname = $1",
//         [req.params.ctuname]
//     ).then(
//         (result) => {
//             res.status(200).json({
//                 status: "success",
//                 data: {
//                     availabilities: result.rows
//                 }
//             })
//         }
//     ).catch(
//         (error) => {
//             res.status(400).json({
//                 status: "failed",
//                 data: {
//                     error: error
//                 }
//             })
//         }
//     )
// });


// Deletes all Availabilities from a Caretaker within a timeframe. All availabilities indicated by the caretaker that
// entirely intersect the s_time and e_time indicated will be deleted. This does not include partial overlaps.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.
            s_time: String (in the format YYYYMMDD, which will be converted by API to Date),
            e_time: String (in the format YYYYMMDD, which will be converted by API to Date)

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.delete("/api/v1/availability/:ctuname/:s_time/:e_time", async (req, res) => {
    console.log(req)
    db.query("DELETE FROM Has_Availability WHERE ctuname = $1 AND s_time >= to_date($2,'YYYYMMDD') AND e_time <= to_date($3,'YYYYMMDD') RETURNING *",
        [req.params.ctuname, req.params.s_time, req.params.e_time]
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
                    error: error
                }
            })
        }
    )
});


/* API calls for Ratings and Reviews */

// Get the average rating of a Caretaker. The rating is the average of all given ratings, or NULL if no ratings have
// been given.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/rating/:ctuname", async (req, res) => {
    db.query("SELECT AVG(rating) FROM Bid WHERE ctuname = $1",
        [req.params.ctuname]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    rating: result.rows[0]
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});



// Get the average rating of all Caretakers. The rating is the average of all given ratings, or NULL if no ratings have
// been given.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/rating", async (req, res) => {
    db.query("SELECT ctuname, AVG(rating) AS avg_rating FROM Bid GROUP BY ctuname").then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    rating: result.rows
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


// Get all reviews about a Caretaker.
/*
    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker.

    Expected status code:
        200 OK, if successful
        400 Bad Request, if general failure
 */
app.get("/api/v1/review/:ctuname", async (req, res) => {
    db.query("SELECT pouname, rating, review FROM Bid WHERE ctuname = $1 AND review IS NOT NULL",
        [req.params.ctuname]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    reviews: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});



/* API calls for PCSAdmin */



/*
    Gets the expected salary of all fulltime Caretakers, for a specified timeframe.

    The specific details on the computation are:
        Within alias pet_day_prices:
            generate_series() is used to generate all pet-days for a specific username.
            The OVERLAPS operator is used to identify all won Bids which overlap with the specified timeframe. It is
                assumed that a won Bid will have been paid for.
            The GREATEST and LEAST operators collectively limit the days examined to exactly within the confines of the
                specified dates and the Bid timeframe itself.
            The important columns returned are ctuname and price; day is used to differentiate them.
            The other columns (petName and pouname) are used to maintain uniqueness of rows through the GROUP BY clause.

        Within alias bonuses:
            rank() and PARTITION BY are used to order the output days by username. This needs to be done rather than
                ORDER BY because 60 pet-days must be taken off of each Fulltimer.
            WHERE RANK > 60 selects for this, within each partition.
            No rows will be returned for Fulltimers who fail to reach the 60 pet-day barrier. They must be artificially
                added back in to ensure that they will appear in the final list.
            The RIGHT JOIN operator adds these Fulltimers back in.
            The COALESCE operator assigns them a 'price' of 0, i.e. they get no bonuses.
            All other Fulltimers will have some rows, each representing one pet-day, each with its own price.
            These collectively represent the bonuses of the Fulltimers.

        Within alias salaries:
            The bonuses for the salary are modified based on the rating of the Fulltimer.
            The CASE block gives a 10% bonus to the salary if the rating is between 4 and 5 inclusive, and 5% bonus if 
                the rating is between 3 and 4 inclusive (4 is not included only by elimination, since the first case is 
                examined first).

        This is collectively returned, along with the ctuname of the Caretaker.

    Expected inputs:
        Path parameters:
            s_time, which is the starting day of the timeframe (to be specified in YYYYMMDD format as a String)
            e_time, which is the ending day of the timeframe (to be specified in YYYYMMDD format as a String)
        IMPORTANT: Both days specified by s_time and e_time are included in the calculation. This also means that
                        if s_time = e_time, then the salary for 1 day will be calculated.

        Expected status code:
            200 OK, if successful
            400 Bad Request, if general failure
 */
app.get("/api/v1/admin/salary/fulltimers/:s_time/:e_time", async (req, res) => {
    db.query(
        "SELECT ctuname," +
        "    (3000 + SUM(cost) * 0.80) * (" +
        "        SELECT" +
        "            CASE" +
        "                WHEN AVG(rating) BETWEEN 4 AND 5" +
        "                    THEN 1.1" +
        "                WHEN AVG(rating) BETWEEN 3 AND 4" +
        "                    THEN 1.05" +
        "                ELSE 1" +
        "            END" +
        "            FROM Bid RIGHT JOIN Fulltimer ON (Bid.ctuname = Fulltimer.username)" +
        "            WHERE salaries.ctuname = username" +
        "    ) AS salary" +
        "    FROM (" +
        "        SELECT username AS ctuname, day, COALESCE(price, 0) AS cost, pouname, petName" +
        "            FROM (" +
        "                SELECT ctuname, day, price, pouname, petName" +
        "                    FROM (" +
        "                       SELECT ctuname, day, price, pouname, petName," +
        "                           rank() OVER (" +
        "                               PARTITION BY ctuname" +
        "                               ORDER BY day, price" +
        "                           )" +
        "                           FROM (" +
        "                               SELECT" +
        "                                   generate_series(" +
        "                                       GREATEST(to_date($1, 'YYYYMMDD')::timestamp, s_time::timestamp)," +
        "                                       LEAST(to_date($2, 'YYYYMMDD')::timestamp, e_time::timestamp)," +
        "                                       '1 day'::interval" +
        "                                   ) AS day, price, ctuname, pouname, petName" +
        "                                   FROM Bid NATURAL JOIN Cares RIGHT JOIN Fulltimer ON (Bid.ctuname = Fulltimer.username)" +
        "                                   WHERE ctuname = username AND is_win = true" +
        "                                       AND (s_time, e_time) OVERLAPS (to_date($1, 'YYYYMMDD'), to_date($2, 'YYYYMMDD'))" +
        "                                   ORDER BY ctuname, day, price, pouname, petName" +
        "                           ) AS pet_day_prices" +
        "                           GROUP BY ctuname, day, price, pouname, petName" +
        "                    ) AS filter" +
        "                    WHERE rank > 60" +
        "            ) AS bonuses RIGHT JOIN Fulltimer ON (bonuses.ctuname = Fulltimer.username)" +
        "            GROUP BY username, day, price, pouname, petName" +
        "    ) AS salaries" +
        "    GROUP BY ctuname",
        [req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    salaries: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});


/*
    Gets the expected salary of all parttime Caretakers, for a specified timeframe.

    The details of this computation are similar to the single-Caretaker API written below.

    Expected inputs:
        Path parameters:
            s_time, which is the starting day of the timeframe (to be specified in YYYYMMDD format as a String)
            e_time, which is the ending day of the timeframe (to be specified in YYYYMMDD format as a String)
        IMPORTANT: Both days specified by s_time and e_time are included in the calculation. This also means that
                        if s_time = e_time, then the salary for 1 day will be calculated.

        Expected status code:
            200 OK, if successful
            400 Bad Request, if general failure
 */
app.get("/api/v1/admin/salary/parttimers/:s_time/:e_time", async (req, res) => {
    db.query(
        "SELECT ctuname," +
        "    SUM(cost) * 0.75 * (" +
        "        SELECT" +
        "            CASE" +
        "                WHEN AVG(rating) BETWEEN 4 AND 5" +
        "                    THEN 1.1" +
        "                WHEN AVG(rating) BETWEEN 3 AND 4" +
        "                    THEN 1.05" +
        "                ELSE 1" +
        "            END" +
        "            FROM Bid RIGHT JOIN Parttimer ON (Bid.ctuname = Parttimer.username)" +
        "            WHERE salaries.ctuname = username" +
        "    ) AS salary" +
        "    FROM (" +
        "        SELECT username AS ctuname, day, COALESCE(price, 0) AS cost, pouname, petName" +
        "            FROM (" +
        "                SELECT" +
        "                    generate_series(" +
        "                        GREATEST(to_date($1, 'YYYYMMDD')::timestamp, s_time::timestamp)," +
        "                        LEAST(to_date($2, 'YYYYMMDD')::timestamp, e_time::timestamp)," +
        "                        '1 day'::interval" +
        "                    ) AS day, price, ctuname, pouname, petName" +
        "                    FROM Bid NATURAL JOIN Cares RIGHT JOIN Parttimer ON (Bid.ctuname = Parttimer.username)" +
        "                    WHERE ctuname = username AND is_win = true" +
        "                        AND (s_time, e_time) OVERLAPS (to_date($1, 'YYYYMMDD'), to_date($2, 'YYYYMMDD'))" +
        "                    ORDER BY ctuname, day, price, pouname, petName" +
        "            ) AS totalprice RIGHT JOIN Parttimer ON (totalprice.ctuname = Parttimer.username)" +
        "            GROUP BY username, day, price, pouname, petName" +
        "    ) AS salaries" +
        "    GROUP BY ctuname",
        [req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    salaries: result.rows
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});




/*
    Gets the expected salary of a Caretaker, for a specified timeframe.

    The calculation values (e.g. $3000 as base salary for Fulltimers) are hardcoded, and they assume that a span of 1
    month will be used (e.g. (20210101 to 20210131). Both endpoints will be used in the calculation. This calculation
    considers only the bids that have been won, and assumes that won bids automatically result in payment.

    For Fulltimers, the 60-petday limit is chosen based on date, followed by ascending order of price. This means that
    if 59 petdays have been counted, and the next day has two pets, costing $50 and $70, then the cost of $50 will go
    towards the base 60-petday value, and the Caretaker will reap bonuses for the $70.

    There is a rating bonus of 10% if the rating of the Caretaker is between 4 and 5 inclusive, and 5% if between 3 and
    4 inclusive. Since the cases start from the 10%, therefore functionally the 5% bonus is awarded only for
    3 <= rating < 4.

    Expected inputs:
        Path parameters:
            ctuname, which is the username of the Caretaker
            s_time, which is the starting day of the timeframe (to be specified in YYYYMMDD format as a String)
            e_time, which is the ending day of the timeframe (to be specified in YYYYMMDD format as a String)
        IMPORTANT: Both days specified by s_time and e_time are included in the calculation. This also means that
                        if s_time = e_time, then the salary for 1 day will be calculated.

        Expected status code:
            200 OK, if successful
            400 Bad Request, if general failure
 */

app.get("/api/v1/admin/salary/:ctuname/:s_time/:e_time", async (req, res) => {
    db.query(
        "SELECT" +
        "    CASE" +
        "        WHEN $1 = ANY(SELECT username FROM Parttimer)" +
        "            THEN SUM(price) * 0.75" +
        "        WHEN $1 = ANY(SELECT username FROM Fulltimer)" +
        "            THEN 3000 + COALESCE(SUM(price), 0) * 0.80" +
        "        ELSE 0" +
        "    END * (" +
        "        SELECT" +
        "            CASE" +
        "                WHEN AVG(rating) BETWEEN 4 AND 5" +
        "                    THEN 1.1" +
        "                WHEN AVG(rating) BETWEEN 3 and 4" +
        "                    THEN 1.05" +
        "                ELSE 1" +
        "            END" +
        "            FROM Bid" +
        "            WHERE ctuname = $1" +
        "    ) AS salary" +
        "    FROM (" +
        "        SELECT" +
        "            generate_series(" +
        "                GREATEST(to_date($2, 'YYYYMMDD')::timestamp, s_time::timestamp)," +
        "                LEAST(to_date($3, 'YYYYMMDD')::timestamp, e_time::timestamp)," +
        "                '1 day'::interval" +
        "            ) AS day, price, pouname, petName" +
        "            FROM Bid NATURAL JOIN Cares" +
        "            WHERE ctuname = $1 AND is_win = true" +
        "                AND (s_time, e_time) OVERLAPS (to_date($2, 'YYYYMMDD'), to_date($3, 'YYYYMMDD'))" +
        "            ORDER BY day, price, pouname, petName" +
        "            OFFSET" +
        "                CASE" +
        "                    WHEN $1 = ANY(SELECT username FROM Fulltimer)" +
        "                        THEN 60" +
        "                    ELSE 0" +
        "                END" +
        "    ) AS pet_day_prices",
        [req.params.ctuname, req.params.s_time, req.params.e_time]
    ).then(
        (result) => {
            let value = 0;
            if (result.rows[0].salary !== null) {
                value = result.rows[0].salary;
            }
            res.status(200).json({
                status: "success",
                data: {
                    salary: value
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});

/* Add a new pet category and their base price */

app.post("/api/v1/admin/category", async (req, res) => {
    db.query(
        "INSERT INTO Category(pettype, base_price) VALUES ($1 , $2) RETURNING *",
        [req.body.category, req.body.base_price]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    category: result.rows[0]
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});

/* Edit previous pet category's base price */

app.put("/api/v1/admin/category/:pettype", async (req, res) => {
    db.query(
        "UPDATE Category SET base_price = $2 WHERE pettype = $1 RETURNING *",
        [req.body.category, req.body.base_price]
    ).then(
        (result) => {
            res.status(200).json({
                status: "success",
                data: {
                    category: result.rows[0]
                }
            })
        }
    ).catch(
        (error) => {
            res.status(400).json({
                status: "failed",
                data: {
                    error: error
                }
            })
        }
    )
});

app.listen(port, () => {
    console.log(`server has started on port ${port}`);
});
