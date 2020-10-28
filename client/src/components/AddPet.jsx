import React, {useState, useEffect} from 'react'
import PropTypes from 'prop-types';
import { Button, TextField } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { CREATE, EDIT, DELETE } from "../constants"

const useStyles = makeStyles((theme) => ({
    textfield: {
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(3),
    },
    button: {
        margin: theme.spacing(3),
    }
}));


const AddPet = (props) => {
    const {parentCallback, parentData, closeModal, modalType, ...other} = props;
    const classes = useStyles();
    const [petName, setPetName] = useState('');
    const [petType, setPetType] = useState('');
    const [petAge, setPetAge] = useState('');
    const [petRequirements, setPetRequirements] = useState('');

    const sendData = (action) => {
        props.parentCallback({
            "petName": petName,
            "petType": petType,
            "petAge": petAge,
            "petRequirements": petRequirements
        }, action);
    }

    const handleButtonClick = (action) => {
        sendData(action);
        closeModal();
    }
    

    useEffect(() => {
        setPetName(props.parentData.petName);
        setPetType(props.parentData.petType);
        setPetAge(props.parentData.petAge);
        setPetRequirements(props.parentData.petRequirements);
        return () => {};
    }, [])

    return (
        <div>
            <TextField
                variant="outlined"
                label="Pet Name"
                required
                fullWidth
                id="petName"
                autoComplete="petName"
                defaultValue={props.parentData.petName}
                multiline
                autoFocus
                className={classes.textfield}
                onChange={(event) => setPetName(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Pet Type"
                required
                fullWidth
                id="petType"
                autoComplete="petType"
                defaultValue={props.parentData.petType}
                multiline
                autoFocus
                className={classes.textfield}
                onChange={(event) => setPetType(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Pet Age"
                required
                fullWidth
                id="petAge"
                autoComplete="petAge"
                defaultValue={props.parentData.petAge}
                multiline
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setPetAge(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Special Requirements"
                fullWidth
                id="petRequirements"
                autoComplete="petRequirements"
                defaultValue={props.parentData.petRequirements}
                multiline
                autoFocus
                className={classes.textfield}
                onChange={(event) => setPetRequirements(event.target.value)}
            />
            <Button className={classes.button}
                variant="contained"
                color="inherit"
                onClick={() => handleButtonClick(props.modalType)}
            >
                Save Pet Information
            </Button>
            {props.modalType == EDIT ? 
                <Button className={classes.button}
                    variant="contained"
                    color="secondary"
                    onClick={() => handleButtonClick(DELETE)}
                >
                    Delete Pet
                </Button> : null }
            

        </div>
    )
}

AddPet.propTypes = {
    parentCallback: PropTypes.func,
    parentData: PropTypes.object,
    closeModal: PropTypes.func,
    modalType: PropTypes.string,
};
AddPet.defaultProps = {
    parentCallback: function() {
        console.log("There is no parent callback function defined");
    },
    closeModal: function() {
        console.log("Please pass a close modal function from the parent")
    },
    parentData: {
        petName: "",
        petType: "",
        petAge: "",
        petRequirements: ""
    },
    modalType: CREATE
}
export default AddPet
