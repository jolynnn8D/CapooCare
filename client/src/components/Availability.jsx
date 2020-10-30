import { Chip, FormControl, Input, InputLabel, NativeSelect, Select, FormHelperText, TextField} from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import React, {useState, useEffect} from 'react'
import PropTypes from 'prop-types';
import { useStoreActions, useStoreState } from 'easy-peasy';

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


const Availability = (props) => {
    const [startDate, setStartDate] = useState(0);
    const [endDate, setEndDate] = useState(0);

    const classes = useStyles();
    return (
        <div>
            <TextField
                variant="outlined"
                label="Enter your start date in YYYYMMDD"
                required
                fullWidth
                id="startDate"
                autoComplete="startdate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setStartDate(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Enter your end date YYYYMMDD"
                required
                fullWidth
                id="endDate"
                autoComplete="enddate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setEndDate(event.target.value)}
            />
                    
        </div>
    )
}

export default Availability
