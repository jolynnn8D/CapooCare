import React, { useState } from 'react'
import { Card, Grid, Typography, Button, Modal, FormControl, FormLabel, RadioGroup, Radio, FormHelperText, FormControlLabel} from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { useStoreActions, useStoreState } from 'easy-peasy';

import PetTypeInput from "../../PetTypeInput"

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

    const addPartTimeCareTaker = useStoreActions(actions => actions.careTakers.addPartTimeCareTaker);
    const addFullTimeCareTaker = useStoreActions(actions => actions.careTakers.addFullTimeCareTaker);
    const singleUser = useStoreState(state => state.user.singleUser);


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

    const signUpCaretaker = () => {
        console.log({
            username: singleUser.username,
            name: singleUser.firstname,
            age: singleUser.age,
            pettype: petType,
            price: parseInt(petPrice)
        })
        if (caretakerType == 'parttime') {
            addPartTimeCareTaker({
                username: singleUser.username,
                name: singleUser.firstname,
                age: singleUser.age,
                pettype: petType,
                price: parseInt(petPrice)
            })
        }
        else if (caretakerType == 'fulltime') { 
            addFullTimeCareTaker({
                username: singleUser.username,
                name: singleUser.firstname,
                age: singleUser.age,
                pettype: petType,
                price: parseInt(petPrice)
            })
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
                    <PetTypeInput parentType = {onSelectType} parentPrice={onInputPrice} label = "Choose a pet type you can care for"/>
                    <Button color="primary" onClick={signUpCaretaker}> Confirm sign up </Button>
                </Card>
            </Modal>
        </Grid>
    )
}

export default NotCaretakerPage
