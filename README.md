# CS2102_2021_S1_Team57

## Frontend

1. Navigate into the client folder.  
2. `npm install`  
3. `npm start`  
4. The application will open on localhost:3000  

## Backend

### Running as standalone

1. Open up the PostgreSQL host. Ensure that it is running. Do this by pressing 'Enter' 4 times, then type in password and press 'Enter' again.
2. Ensure that a .env file exists in the `server` directory, with all the required environment variables as defined in
 `server/keys.js`. Specifically, ensure that a variable exists called `FORCEINITIALIZEDATABASE`. This file should never be committed.
3. Navigate to `server` and install all dependencies using `npm install package.json`.
4. Run `npm start`. This should run the backend program as a standalone.

### Troubleshooting

Q. How do I initialize database? <br >
A. Ensure that you have the `FORCEINITIALIZEDATABASE` variable in your .env file set to `True`.

Q. Why do I receive an authentication error when trying to access database? <br >
A. Check that your .env file has the correct `PGDATABASE`, `PGUSER` and `PGPASSWORD` fields. These should have been set up on your local PostgreSQL already.

