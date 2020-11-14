import React, {useEffect, useState} from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';

import ProfilePic from "./ProfilePic"
import profileImg from "../../assets/userProfile/userProfile.png"
import { Modal } from '@material-ui/core';
import UserModal from './UserModal';


const useStyles = makeStyles((theme) => ({
    root: {
        marginBottom: 40,
        padding: 50,
        maxHeight: 500,
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
    const getUserRating = useStoreActions(actions => actions.careTakers.getRating);
    const userRating = useStoreState(state => state.careTakers.userRating);


    useEffect(() => {
        getDisplayedUser(username);
        getUserRating(username);
        return () => {};
    }, [])

    const [open, setOpen] = useState(false);

    const toggleModal = () => {
        setOpen(!open);
    }

    // console.log(petOwnerDetails);

    if (props.display === 'petowner') {
        return (
            <div>
                <Card onClick={() => toggleModal()} className={classes.root}>
                    <Grid container>
                        <Grid item xs={3}>
                            <ProfilePic img={profileImg}/>
                        </Grid>
                        <Grid item className={classes.profileTextArea}>
                            <h2 className={classes.profileText}> {displayedUser.username}</h2>
                            <h2 className={classes.profileText}> ({displayedUser.firstname})</h2>
                            <h4> Age: {displayedUser.age}</h4>
                            <h6>Click on your profile to make any updates!</h6>
                            {/* <h4> Rating: 4.5 / 5 </h4> */}
                        </Grid>
                    </Grid>
                </Card>
                <Modal
                        open={open}
                        onClose={toggleModal}>
                        <Card className={classes.modal}>
                            <UserModal closeModal={toggleModal}/>
                        </Card>
                </Modal>
            </div>
        )
    } else {
        if (props.display === 'different_caretaker') {
            return (
                <div>
                    <Card className={classes.root}>
                        <Grid container>
                            <Grid item xs={3}>
                                <ProfilePic img={profileImg}/>
                            </Grid>
                            <Grid item className={classes.profileTextArea}>
                                <h2 className={classes.profileText}> {displayedUser.username} ({displayedUser.firstname})</h2>
                                <h4> Age: {displayedUser.age}</h4>
                                <h4> Caretaker Type: {displayedUser.is_fulltimer ? "full-timer" : "part-timer"}</h4>
                                <h4> Rating: {userRating.avg == null ? "No rating so far" : parseFloat(userRating.avg).toFixed(2)} </h4>
                            </Grid>
                        </Grid>
                    </Card>
                </div>
            )
        } else {
            return (
                <div>
                    <Card onClick={() => toggleModal()} className={classes.root}>
                        <Grid container>
                            <Grid item xs={3}>
                                <ProfilePic img={profileImg}/>
                            </Grid>
                            <Grid item className={classes.profileTextArea}>
                                <h2 className={classes.profileText}> {displayedUser.username} ({displayedUser.firstname})</h2>
                                <h4> Age: {displayedUser.age}</h4>
                                <h4> Caretaker Type: {displayedUser.is_fulltimer ? "full-timer" : "part-timer"}</h4>
                                <h4> Rating: {userRating.avg == null ? "No rating so far" : parseFloat(userRating.avg).toFixed(2)} </h4>
                                <h6>Click on your profile to make any updates!</h6>

                            </Grid>
                        </Grid>
                    </Card>
                    <Modal
                            open={open}
                            onClose={toggleModal}>
                            <Card className={classes.modal}>
                                <UserModal closeModal={toggleModal}/>
                            </Card>
                    </Modal>
                </div>
            )
        }
        
    }

}

export default UserCard
