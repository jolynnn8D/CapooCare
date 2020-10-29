import React, { useState } from 'react'
import { Card, Typography, Grid, Modal, Button, FormControl, FormControlLabel, FormLabel, Switch } from '@material-ui/core';
import Calendar from 'react-calendar'
import { makeStyles } from '@material-ui/core/styles';
import BidList from "./BidList"
import { isEmpty } from "lodash"
import BidModal from '../userProfile/careTakerProfile/BidModal';

const useStyles = makeStyles({
    root: {
        padding: 30,
        marginTop: 20
    },
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

const bidList = [
    {
        pouname: 'busypetowner123',
        petName: 'Max',
        petType: 'Corgi Dog',
        ctuname: 'johnthebest',
        s_time: new Date('2020-10-10'),
        e_time: new Date('2020-11-02'),
        pay_status: false,
        pay_type: 'Incomplete',
        price: 60.0
    },
    {
        pouname: 'tiredowner',
        petName: 'Jess',
        petType: 'Labrapoodle Dog',
        ctuname: 'johnthebest',
        s_time: new Date('2020-10-26'),
        e_time: new Date('2020-10-30'),
        pay_status: false,
        pay_type: 'Incomplete',
        price: 40.0
    }
]

const BidPanel = () => {
    const classes = useStyles()
    const [date, setDate] = useState(new Date());
    const [selectedBid, setSelectedBid] = useState({});
    const [open, setOpen] = useState(false);

    const openModal = () => {
        setOpen(true);
    }

    const closeModal = () => {
        setOpen(false);
    }

    const submitData = (selectedVals) => {
        console.log(selectedVals);
        setOpen(false);
    }

    const handleSelectedBid = (newSelectedBid) => {
        setSelectedBid(newSelectedBid)
    }

    const updatePayStatus = (newPayStatus) => {
        console.log("Changing pay status on backend!")
    }

    return (
        <div>
            <Grid container>
                <Grid item xs={8}>
                    <Calendar className={classes.calendar}
                        onChange={(res) => {
                            setSelectedBid({})
                            setDate(res)
                        }}
                    />
                </Grid>
                <Grid item xs={4}>
                    <BidList
                        subheader={months}
                        bids={bidList}
                        onClick={handleSelectedBid}
                    />
                </Grid>
            </Grid>
            {bidList
                .filter((bidInfo) => !isEmpty(selectedBid)
                    ? (
                        bidInfo.pouname === selectedBid.pouname &&
                        bidInfo.petName === selectedBid.petName &&
                        bidInfo.petType === selectedBid.petType &&
                        bidInfo.ctuname === selectedBid.ctuname &&
                        bidInfo.s_time === selectedBid.s_time &&
                        bidInfo.e_time === selectedBid.e_time
                    )
                    : (date <= bidInfo.e_time && date >= bidInfo.s_time))
                .map((bidInfo) => (
                    <Card className={classes.root}>
                        <Typography variant="h4">
                            Bid Details
                        </Typography>
                        <Typography variant="h6">
                            User: {bidInfo.pouname}
                        </Typography>
                        <Typography variant="h6">
                            Pet: {bidInfo.petName} ({bidInfo.petType})
                        </Typography>
                        <Typography variant="h6">
                            Caretaker: {bidInfo.ctuname}
                        </Typography>
                        <Typography variant="h6">
                            Duration: {bidInfo.s_time.toDateString()} to {bidInfo.e_time.toDateString()}
                        </Typography>
                        <Typography variant="h6">
                            Price: ${bidInfo.price.toFixed(2)}
                        </Typography>
                        <Typography variant="h6">
                            Payment Made: {bidInfo.pay_type}
                        </Typography>
                        <br />

                        <FormControl>
                            <FormLabel color="primary" focused>Accept bid?</FormLabel>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={bidInfo.pay_status}
                                        onChange={(event) => updatePayStatus(event.target.checked)}
                                        color="primary"
                                    />
                                }
                                label={bidInfo.pay_status ? "Accepted" : "Pending"}
                            />
                        </FormControl>
                    </Card>
                ))}
            <Button variant="contained" onClick={openModal} color="primary">
                Create Bid (temp)
            </Button>
            <Modal
                open={open}
                onClose={closeModal}>
                <BidModal closeModal={closeModal} submitData={submitData} />
            </Modal>
        </div>
    )
}

export default BidPanel
