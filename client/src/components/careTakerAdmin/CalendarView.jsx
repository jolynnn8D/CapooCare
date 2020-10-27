import React from 'react'
import Grid from '@material-ui/core/Grid'
import Calendar from 'react-calendar'
import { makeStyles } from '@material-ui/core/styles'
import 'react-calendar/dist/Calendar.css'
import BidList from "./BidList"

const useStyles = makeStyles({
    calendar: {
        width: "100%",
        height: "100%",
        padding: "30px 20px 50px"
    },
    list: {
        height: 600
    }
})
const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const CalendarView = () => {
    const classes = useStyles();

    return (
        <Grid container>
            <Grid item xs={8}>
                <Calendar className={classes.calendar}>
                </Calendar>
            </Grid>
            <Grid item xs={4}>
                <BidList subheader={months}/>
            </Grid>

        </Grid>
    )
}

export default CalendarView;