import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { v4 } from 'uuid';
import { Avatar, Button, Grid, IconButton, List, ListItem, ListItemAvatar, ListItemSecondaryAction, ListItemText, TextField, Typography } from '@material-ui/core';
import { sqlToJsDate, differenceInTwoDates, stringToJsDate, isValidStringDate } from '../../utils';
import DateRangeIcon from '@material-ui/icons/DateRange';
import DeleteIcon from '@material-ui/icons/Delete';
import Availability from '../Availability';

const useStyles = makeStyles((theme) => ({
    textfield: {
        marginRight: theme.spacing(3),
        marginBottom: theme.spacing(3),
        marginTop: theme.spacing(3),
        width: "40%"
    },
}));

const CaretakerAvailability = (props) => {
    const classes = useStyles();
    const [startDate, setStartDate] = useState("");
    const [endDate, setEndDate] = useState("");
    const [p2startDate, setP2StartDate] = useState("");
    const [p2endDate, setP2EndDate] = useState("");
    const singleUser = useStoreState(state => state.user.singleUser);
    const addFulltimerAvailability = useStoreActions(actions => actions.careTakers.addFullTimeCareTaker);
    const userAvailability = useStoreState(state => state.careTakers.availability);
    const getUserAvailability = useStoreActions(actions => actions.careTakers.getUserAvailability);
    const addUserAvailability = useStoreActions(actions => actions.careTakers.addUserAvailability);
    const deleteUserAvailability = useStoreActions(actions => actions.careTakers.deleteUserAvailability);

    useEffect(() => {
        getUserAvailability({
            ctuname: props.username,
            s_time: new Date(),
            e_time: new Date(new Date().setDate(new Date().getDate() + 730)), //two years from now
        });
        return () => {};
    }, []);

    const validateDates = () => {
        if (startDate.length != 8 || endDate.length != 8) {
            alert("Please enter date in the format YYYYMMDD")
            return false;
        }
        if (stringToJsDate(startDate) > stringToJsDate(endDate)) {
            alert("Please enter a start date that is before the end date")
            return false;
        }
        if (!(isValidStringDate(startDate) && isValidStringDate(endDate))) {
            alert("Invalid date entered. Please enter in the format YYYYMMDD")
            return false;
        }
        if (stringToJsDate(startDate) < new Date()) {
            alert("Please enter a start date in the future.")
            return false;
        }
        if (singleUser.is_fulltimer) {
            if (p2startDate.length != 8 || p2endDate.length != 8) {
                alert("Please enter date in the format YYYYMMDD")
                return false;
            }
            if (stringToJsDate(p2startDate) > stringToJsDate(p2endDate)) {
                alert("Please enter a start date that is before the end date")
                return false;
            }
            if (!(isValidStringDate(p2startDate) && isValidStringDate(p2endDate))) {
                alert("Invalid date entered. Please enter in the format YYYYMMDD")
                return false;
            }
            if (stringToJsDate(p2startDate) < new Date()) {
                alert("Please enter a start date in the future.")
                return false;
            }
            const dayDifference = differenceInTwoDates(startDate, endDate)
            const p2dayDifference = differenceInTwoDates(p2startDate, p2endDate);
            if (dayDifference < 150 || p2dayDifference < 150) {
                alert("You need to add an availability period of at least 150 days")
                return false;
            }
            if (differenceInTwoDates(startDate, p2endDate) > 365) {
                alert("The two availabilities need to occur within a one year time frame.")
                return false;
            }
        }
        return true;
    }  
    const handleAddAvailability = () => {
        const result = validateDates();
        if (!result) {
            return;
        }
        if (props.isFT) {
            //use the add fulltimer instead
            addFulltimerAvailability({
                username: props.username,
                name: null,
                age: null,
                pettype: null,
                price: null,
                period1_s: startDate,
                period1_e: endDate,
                period2_s: p2startDate,
                period2_e: p2endDate
            })
        } else {
            addUserAvailability({
                ctuname: props.username,
                s_time: startDate,
                e_time: endDate
            })
        }

        setStartDate("");
        setEndDate("");
        setP2StartDate("");
        setP2EndDate("");
    }
    const handleDeleteAvailability = (avail) => {
        console.log(avail)
        deleteUserAvailability({
            ctuname: props.username,
            s_time: avail.s_time,
            e_time: avail.e_time
        })
    }
    return (
        <div>
            <Typography> Your availability in the next two years: </Typography>
            <List>
            {userAvailability.map((avail) => {
                return (
                    <ListItem key={v4()}>
                        <ListItemAvatar>
                            <Avatar>
                                <DateRangeIcon/>
                            </Avatar>
                        </ListItemAvatar>
                        <ListItemText primary= {`${sqlToJsDate(avail.s_time).toDateString()} to ${sqlToJsDate(avail.e_time).toDateString()}`}/>
                        <ListItemSecondaryAction>
                        {!props.isFT ?
                            <IconButton edge="end" aria-label="delete" onClick={()=>handleDeleteAvailability(avail)}>
                                <DeleteIcon />
                            </IconButton> : null }
                        </ListItemSecondaryAction>
                    </ListItem>
                )
            })}
            </List>
            <Typography> Add new availability here: </Typography>
            {props.isFT ? <Availability setP1StartDate={setStartDate} setP1EndDate={setEndDate} 
                                        setP2StartDate={setP2StartDate} setP2EndDate={setP2EndDate}/> 
            : <>
            <TextField
                variant="outlined"
                label="Enter start date in YYYYMMDD"
                required
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
                id="endDate"
                autoComplete="enddate"
                autoFocus
                type="number"
                className={classes.textfield}
                onChange={(event) => setEndDate(event.target.value)}
            /></>}
            <Button variant='outlined' color='primary' onClick={handleAddAvailability}>
                Submit availability
            </Button>
        </div>
    )
}

export default CaretakerAvailability
