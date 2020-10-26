import { Chip, FormControl, Input, InputLabel, MenuItem, Select } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import React, {useState} from 'react'
import PropTypes from 'prop-types';


const useStyles = makeStyles((theme) => ({
    formControl: {
        margin: theme.spacing(3),
        marginLeft: 0
    },
    chip: {
        margin: 2
    },
    chips: {
        display: 'flex',
        flexWrap: 'wrap'
    }
}));

const defaultPetTypes = ['Dog', 'Cat', 'Bird', 'Fish'];

const PetTypeInput = (props) => {
    const [petType, setPetType] = useState([]);
    const {parentCallback, label, ...other} = props;
    const handleChange = (event) => {
        setPetType(event.target.value);
        parentCallback(event);
    }
    const classes = useStyles();
    return (
        <FormControl fullWidth className={classes.formControl}>
            <InputLabel id="select-caretaker-petType">{props.label}</InputLabel>
                <Select
                    labelId="select-caretaker-petType"
                    id="caretaker-petTypes"
                    multiple
                    onChange={handleChange}
                    value={petType}
                    input={<Input id="select-multiple-chip"/>}
                    renderValue={(selected) => (
                        <div className={classes.chips}>
                        {selected.map((value) => (
                            <Chip key={value} label={value} className={classes.chip} />
                        ))}
                        </div> )}
                    >
                    {defaultPetTypes.map((type) => (
                        <MenuItem key={type} value={type}>
                            {type}
                        </MenuItem>
                    ))}
                </Select>
        </FormControl>
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
