import React, { useEffect } from 'react'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import { useParams } from 'react-router-dom';
import { useStoreActions, useStoreState } from 'easy-peasy';


import TabPanel from "../components/careTakerAdmin/TabPanel"
import NotCaretakerPage from '../components/userProfile/careTakerProfile/NotCaretakerPage';

const useStyles = makeStyles({
    root: {
        margin: "100px 30px 30px"
    }
})

const CaretakerAdmin = () => {
    const classes = useStyles();
    const params = useParams();
    console.log(params)
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
            </div>
        )
    } else {
        return (
            <NotCaretakerPage/>
        )
    }
}

export default CaretakerAdmin
