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
    const getUser = useStoreActions(actions => actions.user.getUser);
    const user = useStoreState(state => state.user.singleUser);
    
    
    const checkAccountExists = () => {
        const curr_user = store.getState().user.singleUser;
        if (curr_user == null || curr_user.length == 0) {
            setErrorMessage("Username does not exist");
            return false;
        } else {
            return true;
        }
    }

    const history = useHistory();


    const handleClick = async (event) => {
        await getUser(username);
        const validateAccount = checkAccountExists();
        if (validateAccount) {
          Routes[3].path = '/users/' + username;
          Routes[4].path = '/users/' + username + '/caretaker';
          Routes[5].path = '/users/' + username + '/caretaker-admin';
          history.push('homepage');
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