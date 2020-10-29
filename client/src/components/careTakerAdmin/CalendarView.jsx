import React, { useState } from 'react'
import { Grid, Typography } from '@material-ui/core'
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
    const [date, setDate] = useState(new Date());

    return (
        <Grid container>
            <Grid item xs={8}>
                <Calendar className={classes.calendar} 
                    onChange={(res) => setDate(res)}
                />
            </Grid>
            <Grid item xs={4}>
                <BidList subheader={months}/>
                {/* <Typography variant="h2">{date.toString()}</Typography> */}
            </Grid>

        </Grid>
    )
}

export default CalendarView;