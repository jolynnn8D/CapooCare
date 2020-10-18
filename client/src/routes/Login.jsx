import React from 'react'
import { AppBar, Toolbar, Container, TextField, Card, Typography, Button } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { classnames } from '@material-ui/data-grid';

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
        marginTop: theme.spacing(8),
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

    return (
        <div>
            <AppBar>
                <Toolbar>
                    <Typography variant="h5">
                        Login
                    </Typography>
                </Toolbar>
            </AppBar>
            <Container component="main" maxWidth="xs" className={classes.container}>
            <Typography component="h1" variant="h3" color="textPrimary" align="center">
                Login Page
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
                />
                <Button
                    type="submit"
                    fullWidth
                    variant="contained"
                    color="primary"
                    className={classes.submit}
                >
                    Login
                </Button>
            </form>
        </Container>
        </div>
    )
}

export default Login