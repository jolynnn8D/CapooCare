# [Team 57] CapooCare

### [**Video Demo**](https://www.youtube.com/watch?v=GrYxDcfxgS0)

### [**Application Link**](https://capoocare.herokuapp.com)

![Image of Pet Owner's Profile](/resources/petowner_profile.png)  

![Image of the Find Caretakers page](/resources/findcaretakers.png)   

![Image of Caretaker's Profile](/resources/caretaker_profile.png)  

![Image of PCS Admin's Page](/resources/admin_page.png)

# Deployment

Our application, CapooCare, is a web application for pet caretaking services. With its functionalities, CapooCare can take care of the entire use cases of 3 different stakeholders: Pet Owners, Caretakers and PCS Admin. The application has been deployed at the following link: [CapooCare](https://capoocare.herokuapp.com).

# Functionalities

Watch our video demo of the app [here](https://www.youtube.com/watch?v=GrYxDcfxgS0)!  
  
Our application fully supports Pet Owners from managing their profile information, pet list and browsing of potential Caretakers to bidding for Caretakers' services, making payments and leaving ratings as well as reviews.

For Caretakers, they also can manage their profile, pet services, pricing, bids and available periods. There are also summary information for them to review and update their services.

For PCS Admin, they can view information about all Caretakers, set pet prices, view monthly salary details over all Caretakers as well as helping new admins sign up.

# Technology stack

Our web application was built on the PERN stack with PostgreSQL as the database system, Express.js as the back-end framework, React as the front-end framework and Node.js as the runtime environment. Additionally, we made use of Easy-Peasy, an abstraction of Redux, to maintain frontend states. Through this project, we have learnt a lot about building a working web-based application capable of handling non-trivial database and user interface features.

## Frontend

1. Navigate into the client folder.
2. `npm install`
3. `npm start`
4. The application will open on localhost:3000

## Backend

### Running as standalone

1. Open up the PostgreSQL host. Ensure that it is running. Do this by pressing 'Enter' 4 times, then type in password and press 'Enter' again.
2. Ensure that a .env file exists in the `server` directory, with all the required environment variables as defined in
   `server/keys.js`. This file should never be committed.
3. Navigate to `server` and install all dependencies using `npm install`.
4. Run `npm start`. This should run the backend program as a standalone.

### Troubleshooting

Q. How do I initialize database? <br >
A. Ensure that you have the `FORCEINITIALIZEDATABASE` variable in your .env file set to `True`.

Q. Why do I receive an authentication error when trying to access database? <br >
A. Check that your .env file has the correct `PGDATABASE`, `PGUSER` and `PGPASSWORD` fields. These should have been set up on your local PostgreSQL already.
