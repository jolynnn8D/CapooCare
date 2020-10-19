import React from 'react';
import { Typography, Container, Card, CardActionArea, CardMedia, CardContent, CardActions, Button } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
    root: {
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
}));

const FindCaretakers = () => {
    const classes = useStyles();

    return (
        <div>
            <Container component="main" maxWidth="sm" className={classes.container}>
                <Typography component="h1" variant="h3" color="textPrimary" align="left">
                    Caretakers
                </Typography>
                <Card className={classes.root} variant="outlined" width={1}>
                    <CardActionArea>
                        <CardContent>
                            <Typography gutterBottom variant="h5" component="h2">
                                Caretaker Name
                            </Typography>
                            <Typography variant="body2" ccomponent="p">
                                Caretaken description about the pets that they take care of, how much they charge and all.
                            </Typography>
                        </CardContent>
                    </CardActionArea>
                    <CardActions>
                        <Button size="small" color="primary">
                            Learn More
                        </Button>
                    </CardActions>
                </Card>
            </Container>
        </div>
    )
}

export default FindCaretakers;