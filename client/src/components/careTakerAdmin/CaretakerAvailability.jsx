import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { v4 } from 'uuid';
import { Avatar, Button, Grid, IconButton, List, ListItem, ListItemAvatar, ListItemSecondaryAction, ListItemText, TextField, Typography } from '@material-ui/core';
import { sqlToJsDate } from '../../utils';
import DateRangeIcon from '@material-ui/icons/DateRange';
import DeleteIcon from '@material-ui/icons/Delete';

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
    const userAvailability = useStoreState(state => state.careTakers.availability);
    const getUserAvailability = useStoreActions(actions => actions.careTakers.getUserAvailability);
    const addUserAvailability = useStoreActions(actions => actions.careTakers.addUserAvailability);
    const deleteUserAvailability = useStoreActions(actions => actions.careTakers.deleteUserAvailability);

    useEffect(() => {
        getUserAvailability({
            ctuname: props.username,
            s_time: new Date(),
            e_time: new Date(new Date().setDate(new Date().getDate() + 365)), //one year from now
        });
        return () => {};
    }, []);

    const handleAddAvailability = () => {
        addUserAvailability({
            ctuname: props.username,
            s_time: startDate,
            e_time: endDate
        })
        setStartDate("");
        setEndDate("");
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
            <Typography> Your availability in the next year: </Typography>
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
                            <IconButton edge="end" aria-label="delete" onClick={()=>handleDeleteAvailability(avail)}>
                                <DeleteIcon />
                            </IconButton>
                        </ListItemSecondaryAction>
                    </ListItem>
                )
            })}
            </List>
            <Typography> Add new availability here (if you're a full-timer, you can only add periods of 150 days): </Typography>
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
            />
            <Button variant='outlined' color='primary' onClick={handleAddAvailability}>
                Submit availability
            </Button>
        </div>
    )
}

export default CaretakerAvailability
