import React from 'react'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

import UserCard from "../components/userProfile/UserCard"
import PetList from "../components/userProfile/PetList"
import ProfileTabs from "../components/userProfile/ProfileTabs"

const useStyles = makeStyles({
    verticalSections: {
        margin: "100px 10px 30px"
    }
})

const UserProfile = () => {
    const classes = useStyles();
    return (
        <div>
            <Grid container>
                <Grid item className={classes.verticalSections} xs={7}>
                    <Grid item xs={12}>
                        <UserCard/>
                    </Grid>
                    <Grid item>
                        <PetList/>
                    </Grid>
                </Grid>
                <Grid item className={classes.verticalSections} xs={4}>
                    <ProfileTabs/>
                </Grid>
            </Grid>
        </div>
    )
}

export default UserProfile
