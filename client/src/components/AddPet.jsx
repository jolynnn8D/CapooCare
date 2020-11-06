import React, {useState, useEffect} from 'react'
import PropTypes from 'prop-types';
import { Button, FormControl, InputLabel, Select, TextField } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { CREATE, EDIT, DELETE } from "../constants"
import { useStoreActions, useStoreState } from 'easy-peasy';

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
    const [petAge, setPetAge] = useState(0);
    const [petRequirements, setPetRequirements] = useState('');
    const getPetCategories = useStoreActions(actions => actions.pets.getPetCategories);
    const petCategories = useStoreState(state => state.pets.petCategories);

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
        getPetCategories();
        setPetName(props.parentData.petName);
        setPetType(props.parentData.petType);
        setPetAge(props.parentData.petAge);
        setPetRequirements(props.parentData.petRequirements);
        return () => {};
    }, [])

    return (
        <form>
            <TextField
                variant="outlined"
                label="Pet Name"
                required
                fullWidth
                id="petName"
                autoComplete="petName"
                defaultValue={props.parentData.petName}
                multiline
                disabled={modalType!=CREATE}
                autoFocus
                className={classes.textfield}
                onChange={(event) => setPetName(event.target.value)}
            />
            <FormControl required variant="outlined" fullWidth className={classes.formControl} >
                <InputLabel htmlFor='select-caretaker-petType'>Pet Type</InputLabel>
                    <Select
                        native
                        value={petType}
                        label="Pet Type"
                        onChange={(event) => setPetType(event.target.value)}
                        inputProps={{
                            name: 'pettype',
                            id: 'select-caretaker-petType',
                        }}
                    >
                        <option aria-label="None" value="" />
                        {petCategories.map((type) => (
                                <option key={type.pettype} value={type.pettype}>
                                    {type.pettype}
                                </option>
                        ))}
                    </Select>
            </FormControl>
            <TextField
                variant="outlined"
                label="Pet Age"
                required
                fullWidth
                id="petAge"
                autoComplete="petAge"
                type="number"
                defaultValue={props.parentData.petAge}
                autoFocus
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
            

        </form>
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
        petAge: 0,
        petRequirements: ""
    },
    modalType: CREATE
}
export default AddPet
