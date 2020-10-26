import React from 'react'
import Card from '@material-ui/core/Card'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import UserCard from "../components/userProfile/UserCard"
import PetCareList from "../components/careTakerAdmin/PetCareList"

import ReviewPanel from "../components/userProfile/careTakerProfile/ReviewPanel"

const useStyles = makeStyles({
    verticalSections: {
        margin: "100px 10px 30px"
    }
})

const CaretakerProfile = () => {
    const classes = useStyles();
    return (
        <div>
            <Grid container>
                <Grid item className={classes.verticalSections} xs={12}>
                    <Grid item xs={12}>
                        <UserCard username="marythemess"/>
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
