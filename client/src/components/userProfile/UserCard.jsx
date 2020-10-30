import React, {useEffect, useState} from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';

import ProfilePic from "./ProfilePic"
import profileImg from "../../assets/userProfile/userProfile.png"
import { Modal } from '@material-ui/core';


const useStyles = makeStyles((theme) => ({
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
    },
    modal: {
        width: "40%",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        position: 'absolute',
        backgroundColor: theme.palette.background.paper,
        border: '2px solid #000',
        boxShadow: theme.shadows[5],
        padding: theme.spacing(2, 4, 3),
    },
}));
const UserCard = (props) => { // currently, when you click on caretaker from FindCaretakers.js, this UserCard is used but it's fetching petowner instead.
    const classes = useStyles();
    
    const username = props.username;

    // console.log(username);

    const getDisplayedUser = useStoreActions(actions => actions.user.getDisplayedUser);
    const displayedUser = useStoreState(state => state.user.displayedUser);
    const singleUser = useStoreState(state => state.user.singleUser);


    useEffect(() => {
        getDisplayedUser(username);
        return () => {};
    }, [])

    const [open, setOpen] = useState(false);
    const [petOwnerDetails, setPetOwnerDetails] = useState({});
    const openModal = () => {
        setOpen(true);
    }    
    const closeModal = () => {
        setOpen(false);
    }
    const clickOnPetOwnerProfile = (username, ownername, age) => {
        openModal();
        setPetOwnerDetails({
            username: username,
            ownername: ownername,
            age: age,
        });
    }


    if (props.display === 'petowner') {
        return (
            <Card onClick={() => clickOnPetOwnerProfile(petOwnerDetails.username, petOwnerDetails.ownername, petOwnerDetails.age)} className={classes.root}>
                <Grid container>
                    <Grid item xs={3}>
                        <ProfilePic img={profileImg}/>
                    </Grid>
                    <Grid item className={classes.profileTextArea}>
                        <h2 className={classes.profileText}> {displayedUser.username}</h2>
                        <h2 className={classes.profileText}> ({displayedUser.firstname})</h2>
                        <h4> Age: {displayedUser.age}</h4>
                        {/* <h4> Rating: 4.5 / 5 </h4> */}
                    </Grid>
                </Grid>
                <Modal
                    open={open}
                    onClose={closeModal}>
                    <Card className={classes.modal}>
                        This is my modal!
                    </Card>
                </Modal>
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
