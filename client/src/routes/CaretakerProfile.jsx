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
        margin: "100px 10px 30px"
    }
})

const CaretakerProfile = (props) => {
    const classes = useStyles();
    const params = useParams();

    // console.log(params);
    const username = params.username;
    const getSingleUser = useStoreActions(actions => actions.user.getUser);
    const singleUser = useStoreState(state => state.user.singleUser);
    console.log(singleUser)
    // console.log(caretaker);

    useEffect(() => {
        getSingleUser(username);
        return () => {};
    }, []);
    

    if (singleUser.is_carer == true) {
        return (
            <div>
                <Grid container>
                    <Grid item className={classes.verticalSections} xs={12}>
                        <Grid item xs={12}>
                            <UserCard display={'caretaker'} username={username}/>
                        </Grid>
                        <Grid item>
                            <Card>
                                <PetCareList owner={false} username={username}/>
                            </Card>
                        </Grid>
                    </Grid>
                    <Grid item className = {classes.verticalSections} xs={12}>
                        <ReviewPanel/>
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
