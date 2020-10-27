import React, { useState, useEffect } from 'react'
import { AppBar, Toolbar, Container, TextField, Card, Typography, Button } from '@material-ui/core'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { classnames } from '@material-ui/data-grid';
import { useHistory } from 'react-router-dom';
import store from "../store/store"
import Routes from './allRoutes';

const useStyles = makeStyles((theme) => ({
    paper: {
      marginTop: theme.spacing(8),
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
    },
    avatar: {
      margin: theme.spacing(1),
      backgroundColor: theme.palette.secondary.main,
    },
    form: {
      width: '100%', // Fix IE 11 issue.
      marginTop: theme.spacing(1),
    },
    submit: {
      margin: theme.spacing(3, 0, 2),
    },
    container: {
        marginTop: theme.spacing(15),
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
    },
    textfield: {
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(3),
    },
  }));

const Login = () => {
    const classes = useStyles();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');
    const getPetOwner = useStoreActions(actions => actions.petOwners.getPetOwner);
    const owner = useStoreState(state => state.petOwners.singleUser);
    
    
    const checkAccountExists = () => {
        const curr_owner = store.getState().petOwners.singleUser;
        if (curr_owner == null || curr_owner.length == 0) {
            setErrorMessage("Username does not exist");
            return false;
        } else {
            return true;
        }
    }

    const history = useHistory();


    const handleClick = async (event) => {
        await getPetOwner(username);
        const validateAccount = checkAccountExists();
        if (validateAccount) {
          Routes[3].path = '/users/' + username;
          Routes[4].path = '/users/' + username + '/caretaker';
          Routes[5].path = '/users/' + username + '/caretaker-admin';
          Routes[7].path = '/users/' + username + '/caretakers';
            history.push('/users/' + username);
        } else {
            event.preventDefault();
        }
    }

    return (
        <div>
            <Container component="main" maxWidth="xs" className={classes.container}>
            <Typography component="h1" variant="h3" color="textPrimary" align="center">
                Login
            </Typography>
            <form className={classes.form} noValidate>
                <TextField 
                    variant="outlined"
                    label="Username"
                    required
                    fullWidth
                    id="username"
                    autoComplete="username"
                    autoFocus
                    className={classes.textfield}
                    onChange={(event) => setUsername(event.target.value)}
                />
                <TextField
                    variant="outlined"
                    label="Password"
                    required
                    fullWidth
                    id="password"
                    autoComplete="password"
                    autoFocus
                    className={classes.textfield}
                    onChange={(event)=>setPassword(event.target.value)}
                />
                <Button
                    onClick={(event) => handleClick(event)}
                    // type="submit"
                    fullWidth
                    variant="contained"
                    color="primary"
                    className={classes.submit}
                >
                    Login
                </Button>
                <Typography variant="h5">
                    {errorMessage}
                </Typography>
            </form>
        </Container>
        </div>
    )
}

export default Login