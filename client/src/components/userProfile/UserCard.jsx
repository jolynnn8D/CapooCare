import React from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';


import { makeStyles } from '@material-ui/core/styles';

import ProfilePic from "./ProfilePic"
import profileImg from "../../assets/userProfile/userProfile.png"

const useStyles = makeStyles({
    root: {
        marginBottom: 40,
        padding: 50,
        height: 250
    },

    profileTextArea: {
        margin: "0px 20px 0px",
    },
    profileText: {
        marginBottom: 15
    }
});
const UserCard = () => {
    const classes = useStyles();
    return (
        <Card className={classes.root}>
            <Grid container>
                <Grid item>
                    <ProfilePic img={profileImg} href="/users/123/update"/>
                </Grid>
                <Grid item className={classes.profileTextArea}>
                    <h2 className={classes.profileText}> Pet Owner </h2>
                    <h4> I love cats and dogs :)</h4>
                    <h4> Rating: 4.5 / 5 </h4>
                </Grid>
            </Grid>
        </Card>
    )
}

export default UserCard
