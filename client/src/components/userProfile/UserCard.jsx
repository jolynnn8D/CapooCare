import React, {useEffect} from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';

import ProfilePic from "./ProfilePic"
import profileImg from "../../assets/userProfile/userProfile.png"
import { useParams } from 'react-router-dom';

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
const UserCard = (props) => { // currently, when you click on caretaker from FindCaretakers.js, this UserCard is used but it's fetching petowner instead.
    const classes = useStyles();
    
    const username = props.username;

    console.log(username);

    const getDisplayedUser = useStoreActions(actions => actions.user.getDisplayedUser);
    const displayedUser = useStoreState(state => state.user.displayedUser);
    const singleUser = useStoreState(state => state.user.singleUser);


    useEffect(() => {
        getDisplayedUser(username);
        return () => {};
    }, [])

    if (props.display === 'petowner') {
        return (
            <Card className={classes.root}>
                <Grid container>
                    <Grid item xs={3}>
                        <ProfilePic img={profileImg} href="/users/:username/update"/>
                    </Grid>
                    <Grid item className={classes.profileTextArea}>
                        <h2 className={classes.profileText}> {displayedUser.username} ({displayedUser.firstname})</h2>
                        <h4> Age: {displayedUser.age}</h4>
                        {/* <h4> Rating: 4.5 / 5 </h4> */}
                    </Grid>
                </Grid>
            </Card>
        )
    } else {
        return (
            <Card className={classes.root}>
                <Grid container>
                    <Grid item xs={3}>
                        <ProfilePic img={profileImg} href="/users/:username/update"/>
                    </Grid>
                    <Grid item className={classes.profileTextArea}>
                        <h2 className={classes.profileText}> {displayedUser.username} ({displayedUser.firstname})</h2>
                        <h4> Age: {displayedUser.age}</h4>
                        <h4> Rating: {displayedUser.rating} </h4>
                    </Grid>
                </Grid>
            </Card>
        )
    }

}

export default UserCard
