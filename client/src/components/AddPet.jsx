import React, {useState} from 'react'
import PropTypes from 'prop-types';
import { Button, TextField } from '@material-ui/core'
 
import { makeStyles } from '@material-ui/core/styles';
const useStyles = makeStyles((theme) => ({
    textfield: {
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(3),
    },
}));


const AddPet = (props) => {
    const {parentCallback, parentData, ...other} = props;
    const classes = useStyles();
    const [petName, setPetName] = useState('');
    const [petType, setPetType] = useState('');
    const [petAge, setPetAge] = useState('');
    const [petRequirements, setPetRequirements] = useState('');

    const sendData = () => {
        props.parentCallback({
            "petName": petName,
            "petType": petType,
            "petAge": petAge,
            "petRequirements": petRequirements
        });
    }

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
            <Button
                fullWidth
                variant="contained"
                color="white"
                onClick={sendData}
            >
                Save Pet Information
            </Button>

        </div>
    )
}

AddPet.propTypes = {
    parentCallback: PropTypes.func,
    parentData: PropTypes.object
};
AddPet.defaultProps = {
    parentCallback: function() {
        console.log("There is no parent callback function defined");
    },
    parentData: {
        petName: "",
        petType: "",
        petAge: "",
        petRequirements: ""
    }
}
export default AddPet
