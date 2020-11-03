import React, { useState } from 'react'
import { Card, Grid, Typography, Button, Modal, FormControl, FormLabel, RadioGroup, Radio, FormHelperText, FormControlLabel} from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { useStoreActions, useStoreState } from 'easy-peasy';

import PetTypeInput from "../../PetTypeInput"
import Availability from '../../Availability';

const useStyles = makeStyles((theme) => ({
    verticalSections: {
        margin: "100px 10px 30px"
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
}))


const NotCaretakerPage = () => {
    const classes = useStyles();
    const [signUpModal, setSignUpModal] = useState(false);
    const [caretakerType, setCaretakerType] = useState("parttime");
    const [petType, setPetType] = useState('');
    const [petPrice, setPetPrice] = useState(0);
    const [p1startDate, setP1StartDate] = useState(0);
    const [p1endDate, setP1EndDate] = useState(0);
    const [p2startDate, setP2StartDate] = useState(0);
    const [p2endDate, setP2EndDate] = useState(0);

    const addPartTimeCareTaker = useStoreActions(actions => actions.careTakers.addPartTimeCareTaker);
    const addFullTimeCareTaker = useStoreActions(actions => actions.careTakers.addFullTimeCareTaker);
    const singleUser = useStoreState(state => state.user.singleUser);
    const getUser = useStoreActions(actions => actions.user.getUser);
    const getDisplayedUser = useStoreActions(actions => actions.user.getDisplayedUser);

    const onChangeCaretakerType = (event) => {
        setCaretakerType(event.target.value);
    }

    const onSelectType = (event) => {
        setPetType(event.target.value);
    }
    
    const onInputPrice = (event) => {
        setPetPrice(event.target.value);
    }

    const toggleSignUpModal = () => {
        setSignUpModal(!signUpModal);
    }

    const signUpCaretaker = async () => {
        console.log({
            username: singleUser.username,
            name: singleUser.firstname,
            age: singleUser.age,
            pettype: petType,
            price: parseInt(petPrice)
        })
        if (caretakerType == 'parttime') {
            await addPartTimeCareTaker({
                username: singleUser.username,
                name: singleUser.firstname,
                age: singleUser.age,
                pettype: petType,
                price: parseInt(petPrice)
            })
            getUser(singleUser.username);
            getDisplayedUser(singleUser.username);
        }
        else if (caretakerType == 'fulltime') { 
            await addFullTimeCareTaker({
                    username: singleUser.username,
                    name: singleUser.firstname,
                    age: singleUser.age,
                    pettype: petType,
                    price: parseInt(petPrice), 
                    period1_s: p1startDate,
                    period1_e: p1endDate,
                    period2_s: p2startDate,
                    period2_e: p2endDate
                })
            getUser(singleUser.username);
            getDisplayedUser(singleUser.username);
        }
        toggleSignUpModal()
    }

    return (
        
        <Grid container>
            <Grid item className={classes.verticalSections} xs = {12}>
                <Typography>
                    You are not a caretaker.
                </Typography>
                <Button color = 'primary' variant ='contained' onClick = {toggleSignUpModal}>
                    Sign up here
                </Button>
                <Typography>
                    If you have signed up, please click on the page again.
                </Typography>
            </Grid>
            <Modal
                open={signUpModal}
                onClose={toggleSignUpModal}>
                <Card className={classes.modal}>
                    <FormControl component="fieldset" >
                        <FormLabel component="legend">Type of caretaker</FormLabel>
                        <RadioGroup value={caretakerType} onChange={onChangeCaretakerType}>
                            <FormControlLabel value="parttime" control={<Radio />} label="Part-time" />
                            <FormControlLabel value="fulltime" control={<Radio />} label="Full-time" />
                        </RadioGroup>
                        <FormHelperText>Choose at least one role!</FormHelperText>
                    </FormControl>
                    { caretakerType === 'fulltime' ?
                    <>
                    <PetTypeInput parentType = {onSelectType} parentPrice={onInputPrice} label = "Choose a pet type you can care for"/>
                    <Availability setP1StartDate={setP1StartDate} setP1EndDate={setP1EndDate} setP2StartDate={setP2StartDate} setP2EndDate={setP2EndDate}/>
                    </> :
                    <>
                    <PetTypeInput parentType = {onSelectType} parentPrice={onInputPrice} label = "Choose a pet type you can care for"/>
                    </>}
                    <Button color="primary" onClick={signUpCaretaker}> Confirm sign up </Button>
                </Card>
            </Modal>
        </Grid>
    )
}

export default NotCaretakerPage
