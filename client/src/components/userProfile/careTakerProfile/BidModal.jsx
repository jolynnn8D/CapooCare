import React, { useState, useEffect } from 'react'
import { Button, Typography, InputLabel, Select, MenuItem, FormControl, FormControlLabel, Switch } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import 'react-date-range/dist/styles.css'; // main style file
import 'react-date-range/dist/theme/default.css'; // theme css file
import { DateRangePicker } from 'react-date-range';
import { addDays, addYears, eachDay } from 'date-fns';
import { useStoreActions, useStoreState } from 'easy-peasy';
import {convertDate} from '../../../utils';

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
    const minDate = new Date();
    const maxDate = addYears(minDate, 2);
    const [petChoice, setPetChoice] = useState("")
    const [paymentType, setPaymentType] = useState("")
    const [pickupType, setPickupType] = useState("")
    const [disabledDates, setDisabledDates] = useState([]);
    const singleUser = useStoreState(state => state.user.singleUser);
    const getOwnerPetsOfType = useStoreActions(actions => actions.pets.getOwnerPetsOfType);
    const biddablePets = useStoreState(state => state.pets.biddablePets);
    const getAvailabilityList = useStoreActions(actions => actions.careTakers.getAvailabilityList);
    const availabilityList = useStoreState(state => state.careTakers.availabilityList);
    const addBid = useStoreActions(actions => actions.bids.addBid);
    // console.log(props.petType)
    // console.log(props.ctuname);

    const findDisabledDates = (enabledRanges) => {
        tempDisabledDates = eachDay(minDate, maxDate);
        allEnabledDates = []
        for (enabledRange of enabledRanges) {
            allEnabledDates.concat(eachDay(new Date(enabledRange.s_time), new Date(enabledRanges.e_time)));
        }
        tempDisabledDates = tempDisabledDates.filter(x => !allEnabledDates.includes(x))
        setDisabledDates(tempDisabledDates);
    }

    useEffect(() => {
        getOwnerPetsOfType({
            username: singleUser.username,
            pettype: props.petType
        })
        console.log(username);
        console.log(convertDate(minDate).toString());
        console.log(convertDate(maxDate).toString())
        getAvailabilityList({
            username: username,
            s_time: convertDate(minDate).toString(),
            e_time: convertDate(maxDate).toString()
        })
            .then(findDisabledDates())
        // console.log(availabilityList);
        return () => {};
    }, [])

    const handleSubmit = () => {
        const startDateInt = convertDate(dateRange[0].startDate);
        const endDateInt = convertDate(dateRange[0].endDate)
        addBid({
            pouname: singleUser.username,
            petname: petChoice,
            pettype: props.petType,
            ctuname: props.ctuname,
            s_time: startDateInt,
            e_time: endDateInt,
            pay_type: paymentType,
            pet_pickup: pickupType
        })
        closeModal();
       
    }
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
                minDate = {minDate}
                maxDate={maxDate}
                disabledDates={disabledDates}
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
                    {biddablePets.map((choiceOfPet) => {
                        return <MenuItem value={choiceOfPet.petname}>{choiceOfPet.petname}</MenuItem>
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

            <Typography>
                {availabilityList || "hello" }
            </Typography>

            <div className={classes.buttonRow}>
                <Button className={classes.button}
                    variant="outlined"
                    color="primary"
                    onClick={() => handleSubmit()}>
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
