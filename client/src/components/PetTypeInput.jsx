import { Chip, FormControl, Input, InputLabel, NativeSelect, Select, FormHelperText, TextField} from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import React, {useState} from 'react'
import PropTypes from 'prop-types';


const useStyles = makeStyles((theme) => ({
    formControl: {
        margin: theme.spacing(3),
        marginLeft: 0
    },
    textfield: {
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(3),
    },
}));

const defaultPetTypes = ['Dog', 'Cat', 'Bird', 'Fish'];

const PetTypeInput = (props) => {
    const [petType, setPetType] = useState();
    const [price, setPrice] = useState();
    const {parentType, parentPrice, label, ...other} = props;
    const handleChange = (event) => {
        setPetType(event.target.value);
        parentType(event);
    }

    const handlePriceChange = (event) => {
        setPrice(event.target.value);
        parentPrice(event);
    }
    const classes = useStyles();
    return (
        <div>
            <FormControl required variant="outlined" fullWidth className={classes.formControl} >
                <InputLabel htmlFor='select-caretaker-petType'>{props.label}</InputLabel>
                    <Select
                        native
                        value={petType}
                        label={props.label}
                        onChange={handleChange}
                        inputProps={{
                            name: 'pettype',
                            id: 'select-caretaker-petType',
                        }}
                    >
                        {defaultPetTypes.map((type) => (
                                <option key={type} value={type}>
                                    {type}
                                </option>
                        ))}
                    </Select>
            </FormControl>
            <TextField
                variant="outlined"
                label="Enter the price per day for the pet type above"
                required
                fullWidth
                id="price"
                autoComplete="price"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={handlePriceChange}
            />
                    
        </div>
    )
}
PetTypeInput.propTypes = {
    parentCallback: PropTypes.func,
    label: PropTypes.string
};
PetTypeInput.defaultProps = {
    parentCallback: function() {
        console.log("There is no parent callback function defined");
    },
    label: "Pet Types"
}

export default PetTypeInput
