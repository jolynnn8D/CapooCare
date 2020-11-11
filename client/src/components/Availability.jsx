import { Chip, FormControl, Input, InputLabel, NativeSelect, Select, FormHelperText, TextField, Typography } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import React, {useState, useEffect} from 'react'
import PropTypes from 'prop-types';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { convertDate } from '../utils';

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
    const {setP1StartDate, setP1EndDate, setP2StartDate, setP2EndDate} = props;

    const classes = useStyles();
    return (
        <div>
            <Typography align="center" >Please enter two periods of 150 days each within a one year time frame.</Typography> 
            <TextField
                variant="outlined"
                label="Enter your period 1 start date in YYYYMMDD"
                required
                fullWidth
                id="startDate"
                autoComplete="startdate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setP1StartDate(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Enter your period 1 end date YYYYMMDD"
                required
                fullWidth
                id="endDate"
                autoComplete="enddate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setP1EndDate(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Enter your period 2 start date in YYYYMMDD"
                required
                fullWidth
                id="startDate"
                autoComplete="startdate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setP2StartDate(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Enter your period 2 end date YYYYMMDD"
                required
                fullWidth
                id="endDate"
                autoComplete="enddate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setP2EndDate(event.target.value)}
            />
                    
        </div>
    )
}

export default Availability
