import React from 'react'
import { Card, CardActionArea, CardContent, CardMedia, Typography, Button, Grid } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { Link } from 'react-router-dom';

const useStyles = makeStyles((theme) => ({
    card: {
        marginTop: theme.spacing(2),
        marginBottom: theme.spacing(2)
    },
    media: {
        height: 140,
    },
    container: {
        marginTop: theme.spacing(8),
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
    },
    root: {
        padding: '2px 4px',
        display: 'flex',
        alignItems: 'center',
        width: 400,
    },
    input: {
        marginLeft: theme.spacing(1),
        flex: 1,
    },
    iconButton: {
        padding: 10,
    },
    divider: {
        height: 28,
        margin: 4,
    },
    searchbar: {
        margin: theme.spacing(1),
    },
}));

const welcomeCardsInfo = [
    {
        name: 'Caretaking Services',
        available: true,
        link: '/users/1/caretakers',
        description: 'Find a caretaker for your pet today!',
        imageLink: 'https://storage.googleapis.com/petbacker/images/blog/2017/dog-lover-in-autumn.jpg'
    },
    {
        name: 'Caretaker Settings',
        available: true,
        link: '/users/1/caretaker-admin',
        description: 'Edit your caretaker profile',
        imageLink: 'https://storage.googleapis.com/petbacker/images/blog/2018/pet-care-dog-sitting-services.jpg',
    },
]

const WelcomeCards = () => {
    const classes = useStyles();
    return (
        <Grid container spacing={3}>
            {welcomeCardsInfo.map((welcomeCardInfo) => (
                <Grid item xs={6}>
                    <Card className={classes.card} variant="outlined" width={1}>
                        <CardActionArea component={Link} to={welcomeCardInfo.link} style={{ textDecoration: 'none' }}>
                            <CardMedia
                                className={classes.media}
                                image={welcomeCardInfo.imageLink}
                            />
                            <CardContent>
                                <Typography gutterBottom variant="h5" component="h2">
                                    {welcomeCardInfo.name}
                                </Typography>
                                <Typography variant="body2" component="p">
                                    {welcomeCardInfo.description}
                                </Typography>
                                <Button size="small" color="primary">
                                    Learn More
                                </Button>
                            </CardContent>
                        </CardActionArea>
                    </Card>
                </Grid>
            ))}
        </Grid>
    )
}

export default WelcomeCards;