import React, {useEffect} from 'react'
import { Card, Grid, Typography, Button} from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import UserCard from "../components/userProfile/UserCard"
import PetCareList from "../components/careTakerAdmin/PetCareList"
import NotCaretakerPage from "../components/userProfile/careTakerProfile/NotCaretakerPage"
import {
  useParams
} from "react-router-dom";

import ReviewPanel from "../components/userProfile/careTakerProfile/ReviewPanel"
import { useStoreActions, useStoreState } from 'easy-peasy';

const useStyles = makeStyles({
    verticalSections: {
        margin: "100px 30px 30px"
    },
    card: {
        marginTop: 30
    }
})

const CaretakerProfile = (props) => {
    const classes = useStyles();
    const params = useParams();

    // console.log(params);
    const username = params.username;
    
    const getDisplayedUser = useStoreActions(actions => actions.user.getDisplayedUser);
    const getSingleUser = useStoreActions(actions => actions.user.getSingleUser);
    const displayedUser = useStoreState(state => state.user.displayedUser);
    const singleUser = useStoreState(state => state.user.singleUser);

    // console.log(caretaker);

    useEffect(() => {
        getDisplayedUser(username);
        return () => {};
    }, []);
    
    if (displayedUser.username != singleUser.username) {
        return (
            <div>
                <Grid container>
                    <Grid item className={classes.verticalSections} xs={12}>
                        <Grid item xs={12}>
                            <UserCard display={'different_caretaker'} username={username}/>
                        </Grid>
                        <Grid item xs={12}>
                            <Card>
                                <PetCareList userType="po" username={username}/>
                            </Card>
                        </Grid>
                        <Grid item xs={12} className={classes.card}>
                            <Typography variant='h4'> Reviews </Typography> 
                            <ReviewPanel username={username}/>
                        </Grid>
                    </Grid>
                </Grid>
            </div>
        )
    }
    else if (displayedUser.is_carer == true ) {
        return (
            <div>
                <Grid container>
                    <Grid item className={classes.verticalSections} xs={12}>
                        <Grid item xs={12}>
                            <UserCard display={'caretaker'} username={username}/>
                        </Grid>
                        <Grid item xs={12}>
                            <Card>
                                <PetCareList userType="po" username={username}/>
                            </Card>
                        </Grid>
                        <Grid item xs={12} className={classes.card}>
                            <Typography variant='h4'> Reviews </Typography> 
                            <ReviewPanel username={username}/>
                        </Grid>
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

export default CaretakerProfile
