import React from 'react'
import Welcome from '../components/Welcome';
import WelcomeCards from '../components/WelcomeCards'
import { Container } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
    card: {
        marginTop: theme.spacing(2),
        marginBottom: theme.spacing(2)
    },
    media: {
        height: 140,
    },
    container: {
        marginTop: theme.spacing(17),
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
    },
}))

const Homepage = () => {
    const classes = useStyles();
    return (
        <Container component="main" maxWidth="xl" className={classes.container}>
            <Welcome />
            <WelcomeCards />
        </Container>
    )
}

export default Homepage
