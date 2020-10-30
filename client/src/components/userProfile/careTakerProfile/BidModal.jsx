import React, { useEffect, useState } from 'react'
import { Button, Typography, InputLabel, Select, MenuItem, FormControl, FormControlLabel, Switch } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import 'react-date-range/dist/styles.css'; // main style file
import 'react-date-range/dist/theme/default.css'; // theme css file
import { DateRangePicker } from 'react-date-range';
import { addDays } from 'date-fns';
import { useStoreState, useStoreActions } from 'easy-peasy';

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
    },
    formControl: {
        margin: theme.spacing(1),
        minWidth: 120,
    },
}));

const petChoices = [
    'Max',
    'Jess',
    'Roger'
]

const paymentTypes = {
    'Credit Card': 'credit card',
    'Cash': 'cash',
}

const pickupTypes = {
    'Delivery by Owner': 'poDeliver',
    'Caretaker Pickup': 'ctPickup',
    'Transfer Pet': 'transfer'
}

const BidModal = (props) => {
    const classes = useStyles();
    const { closeModal, submitData, ...other } = props
    const username = "yellowchicken"
    const [dateRange, setDateRange] = useState([
        {
            startDate: new Date(),
            endDate: addDays(new Date(), 7),
            key: 'selection'
        }
    ]);
    const [petChoice, setPetChoice] = useState("")
    const [paymentType, setPaymentType] = useState("")
    const [pickupType, setPickupType] = useState("")
    const getAvailabilityList = useStoreActions(actions => actions.careTakers.getAvailabilityList);
    const availabilityList = useStoreState(state => state.careTakers.availabilityList);


    useEffect(() => {
        getAvailabilityList({
            username: username,
            s_time: 20190101,
            e_time: 20210101
        })
    }, [])

    return (
        <div className={classes.paper}>
            <Typography id="simple-modal-title" variant="h5">Select desired dates</Typography>
            <DateRangePicker
                id="form-datepicker"
                onChange={item => setDateRange([item.selection])}
                showSelectionPreview={true}
                moveRangeOnFirstSelection={false}
                ranges={dateRange}
                direction="horizontal"
                minDate = {new Date()}
            />

            <FormControl className={classes.formControl}>
                <InputLabel id="form-pet-choice-label">Pet for Care</InputLabel>
                <Select
                    labelId="form-pet-choice-label"
                    id="form-pet-choice-select"
                    value={petChoice}
                    onChange={(event) => setPetChoice(event.target.value)}
                    autoWidth
                >
                    {petChoices.map((choiceOfPet) => {
                        return <MenuItem value={choiceOfPet}>{choiceOfPet}</MenuItem>
                    })}
                </Select>
                <Typography>{petChoice}</Typography>
            </FormControl>

            <FormControl className={classes.formControl}>
                <InputLabel id="form-payment-type-choice-label">Payment Type</InputLabel>
                <Select
                    labelId="form-payment-type-choice-label"
                    id="form-payment-type-choice-select"
                    value={paymentType}
                    onChange={(event) => setPaymentType(event.target.value)}
                    autoWidth
                >
                    {Object.entries(paymentTypes)
                        .map(([choiceOfPaymentKey, choiceOfPaymentValue]) => {
                            return <MenuItem value={choiceOfPaymentValue}>{choiceOfPaymentKey}</MenuItem>
                        })}
                </Select>
            </FormControl>

            <FormControl className={classes.formControl}>
                <InputLabel id="form-pickup-type-choice-label">Pickup Type</InputLabel>
                <Select
                    labelId="form-pickup-type-choice-label"
                    id="form-pickup-type-choice-select"
                    value={pickupType}
                    onChange={(event) => setPickupType(event.target.value)}
                    autoWidth
                >
                    {Object.entries(pickupTypes)
                        .map(([choiceOfPickupKey, choiceOfPickupValue]) => {
                            return <MenuItem value={choiceOfPickupValue}>{choiceOfPickupKey}</MenuItem>
                        })}
                </Select>
            </FormControl>

            <div className={classes.buttonRow}>
                <Button className={classes.button}
                    variant="outlined"
                    color="primary"
                    onClick={() => props.submitData(
                        {
                            s_time: dateRange[0].startDate,
                            e_time: dateRange[0].endDate,
                            petName: petChoice,
                            pay_type: paymentType,
                            pet_pickup: pickupType
                        })}>
                    Confirm
                </Button>
                <Button className={classes.button}
                    variant="outlined"
                    color="secondary"
                    onClick={props.closeModal}>
                    Cancel
                </Button>
            </div>
        </div>
    )
}

export default BidModal
