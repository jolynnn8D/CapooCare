import React from 'react'
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';
import 'react-date-range/dist/styles.css'; // main style file
import 'react-date-range/dist/theme/default.css'; // theme css file
import { DateRangePicker } from 'react-date-range';

const handleSelect = (ranges) => {
    console.log(ranges);
}
const useStyles = makeStyles((theme) => ({
    paper: {
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        position: 'absolute',
        width: 650,
        backgroundColor: theme.palette.background.paper,
        border: '2px solid #000',
        boxShadow: theme.shadows[5],
        padding: theme.spacing(2, 4, 3),
    },
    buttonRow: {
        left: "50%",
        transform: "translateX(60%)",
    },
    button: {
        marginLeft: 10
    }
}));

const BidModal = (props) => {
    const classes = useStyles();
    const selectionRange = {
        startDate: new Date(),
        endDate: new Date(),
        key: 'selection',
    }
    return (
        <div className={classes.paper}>
            <h2 id="simple-modal-title">Select desired dates</h2>
            <DateRangePicker ranges={[selectionRange]} onChange={handleSelect} minDate={new Date()}/>
            <div className={classes.buttonRow}>
                <Button className={classes.button} 
                        variant="outlined" 
                        color="primary"
                        onClick={props.modalHandler}>
                    Confirm
                </Button>
                <Button className={classes.button} 
                        variant="outlined" 
                        color="secondary"
                        onClick={props.modalHandler}>
                    Cancel
                </Button>
            </div>
        </div>
    )
}

export default BidModal
