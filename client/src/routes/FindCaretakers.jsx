import React from 'react';
import { TextField, InputAdornment, Typography, Container, Card, CardActionArea, CardMedia, CardContent, CardActions, Button, Paper, InputBase, Divider, IconButton } from '@material-ui/core';
import Search from '@material-ui/icons/Search';
import { makeStyles } from '@material-ui/core/styles';
import Rating from '@material-ui/lab/Rating';
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
    rating: {
        display: 'flex',
        flexDirection: 'column',
        '& > * + *': {
            marginTop: theme.spacing(1),
        },
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

const caretakersList = [
    {
        name: 'Caretaker 1',
        id: '1',
        available: true,
        takesCareOf: [
            'Dogs',
            'Cats',
            'Birds'
        ],
        rating: 4.5
    },
    {
        name: 'Caretaker 2',
        id: '2',
        available: true,
        takesCareOf: [
            'Dogs',
            'Cats',
            'Birds'
        ],
        rating: 3.6
    },
]

const FindCaretakers = () => {
    const classes = useStyles();

    return (
        <div>
            <Container component="main" maxWidth="ml" className={classes.container}>
                <Typography component="h1" variant="h3" color="textPrimary" align="left">
                    Caretakers
                </Typography>
                <TextField
                    className={classes.margin}
                    label="Search"
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <Search />
                            </InputAdornment>
                        ),
                    }}
                    variant="outlined"
                    fullWidth
                />
                {caretakersList.map((caretakerInfo) => (
                    <Card className={classes.card} variant="outlined" width={1}>
                        <CardActionArea component={Link} to={`/users/${caretakerInfo.id}/caretaker`} style={{ textDecoration: 'none' }}>
                            <CardContent>
                                <Typography gutterBottom variant="h5" component="h2">
                                    {caretakerInfo.name}
                                </Typography>
                                <Typography variant="body2" component="p">
                                    Caretaken description about the pets that they take care of, how much they charge and all.
                                </Typography>
                                <div className={classes.rating}>
                                    <Rating value={caretakerInfo.rating} precision={0.5} readOnly />
                                </div>
                                {caretakerInfo.available ? (
                                    <Button variant="outlined" color="primary">
                                        Available
                                    </Button>
                                ) : (
                                        <Button variant="outlined" disabled>
                                            Unavailable
                                        </Button>
                                    )}
                                <Typography variant="body2" component="p">
                                    Takes care of: {caretakerInfo.takesCareOf.join(", ")}
                                </Typography>
                                <Button size="small" color="primary">
                                    Learn More
                                </Button>
                            </CardContent>
                        </CardActionArea>
                    </Card>
                ))}
            </Container>
        </div>
    )
}

export default FindCaretakers;