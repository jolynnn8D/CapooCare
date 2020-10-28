import React from 'react'
import Card from '@material-ui/core/Card'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import UserCard from "../components/userProfile/UserCard"
import PetCareList from "../components/careTakerAdmin/PetCareList"
import {
  useParams
} from "react-router-dom";

import ReviewPanel from "../components/userProfile/careTakerProfile/ReviewPanel"

const useStyles = makeStyles({
    verticalSections: {
        margin: "100px 10px 30px"
    }
})

const CaretakerProfile = (props) => {
    const classes = useStyles();
    const params = useParams();
    return (
        <div>
            <Grid container>
                <Grid item className={classes.verticalSections} xs={12}>
                    <Grid item xs={12}>
                        <UserCard display={'caretaker'}/>
                    </Grid>
                    <Grid item>
                        <Card>
                            <PetCareList owner={false}/>
                        </Card>
                    </Grid>
                </Grid>
                <Grid item className = {classes.verticalSections} xs={12}>
                    <ReviewPanel/>
                </Grid>
            </Grid>
        </div>
    )
}

export default CaretakerProfile
