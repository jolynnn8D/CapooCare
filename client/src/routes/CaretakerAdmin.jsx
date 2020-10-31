import React, { useEffect } from 'react'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import { useParams } from 'react-router-dom';
import { useStoreActions, useStoreState } from 'easy-peasy';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

import TabPanel from "../components/careTakerAdmin/TabPanel"
import NotCaretakerPage from '../components/userProfile/careTakerProfile/NotCaretakerPage';

const useStyles = makeStyles({
    root: {
        margin: "100px 30px 30px"
    },
    bullet: {
        display: 'inline-block',
        margin: '0 2px',
        transform: 'scale(0.8)',
    },
    title: {
        fontSize: 14,
    },
    pos: {
        marginBottom: 12,
    },
})

const CaretakerAdmin = () => {
    const classes = useStyles();
    const params = useParams();
    // console.log(params)
    const username = params.username;
    const getSingleUser = useStoreActions(actions => actions.user.getUser);
    const singleUser = useStoreState(state => state.user.singleUser);

    useEffect(() => {
        getSingleUser(username);
        return () => {};
    }, []);
    
    if (singleUser.is_carer) {
        return (
            <div>
                <Grid container className={classes.root}>
                    <Grid item xs={12}>
                        <TabPanel username = {username}/>
                    </Grid>
                </Grid>
                <Card>
                    <CardContent>
                        <Typography variant="h5" component="h2">
                            Caretaker type: {singleUser.is_fulltimer ? "Full-time Caretaker" : "Part-time Caretaker"}
                        </Typography>
                    </CardContent>
                </Card>
            </div>
        )
    } else {
        return (
            <NotCaretakerPage/>
        )
    }
}

export default CaretakerAdmin
