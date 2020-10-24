import React, {useEffect} from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';

import { useStoreActions, useStoreState } from 'easy-peasy';
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
const UserCard = (props) => {
    const classes = useStyles();
    // console.log(props);
    const username = props.userName;
    const getPetOwner = useStoreActions(actions => actions.petOwners.getPetOwner);
    useEffect(() => {
        getPetOwner(username);
        return () => {};
    }, [])
    const owner = useStoreState(state => state.petOwners.singleUser);
 
    return (
        <Card className={classes.root}>
            <Grid container>
                <Grid item xs={3}>
                    <ProfilePic img={profileImg} href="/users/:id/update"/>
                </Grid>
                <Grid item className={classes.profileTextArea}>
                    <h2 className={classes.profileText}> {username} ({owner.ownername})</h2>
                    <h4> Age: {owner.age}</h4>
                    <h4> Rating: 4.5 / 5 </h4>
                </Grid>
            </Grid>
        </Card>
    )
}

export default UserCard
