import React, { useState, useEffect } from 'react'
import { Card, Typography, Grid, Modal, Button, FormControl, FormControlLabel, FormLabel, Switch } from '@material-ui/core';
import Calendar from 'react-calendar'
import { makeStyles } from '@material-ui/core/styles';
import BidList from "./BidList"
import { isEmpty } from "lodash"
import { useStoreActions, useStoreState } from 'easy-peasy';
import BidModal from '../userProfile/careTakerProfile/BidModal';
import { sqlToJsDate, convertDate } from '../../utils';

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
    }, 
    sectionHeader:{
        marginLeft: 12
    }
})

const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

const BidPanel = (props) => {
    const classes = useStyles()
    const [date, setDate] = useState(new Date());
    const [selectedBid, setSelectedBid] = useState({});
    const [open, setOpen] = useState(false);
    const getUserBids = useStoreActions(actions => actions.bids.getUserBids);
    const bidList = useStoreState(state => state.bids.userBids);
    const acceptBid = useStoreActions(actions => actions.bids.acceptBid);

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

    const updateBidStatus = (bidInfo) => {
        console.log("Changing bid status on backend!")
        acceptBid({
            pouname: bidInfo.pouname,
            petname: bidInfo.petname,
            pettype: bidInfo.pettype,
            ctuname: bidInfo.ctuname,
            s_time: bidInfo.s_time,
            e_time: bidInfo.e_time
        })
        
    }

    const dateHasBid = (date) => {
        let result = false;
        bidList.forEach(function(bid) {
            if(sqlToJsDate(bid.s_time) <= date && sqlToJsDate(bid.e_time) >= date) {
                result = true;
            }
        })
        return result;
    }

    useEffect(() => {
        getUserBids(props.username);
        return () => {};
    }, [])


    return (
        <div>
            <Grid container>
                <Grid item xs={8}>
                    <Calendar className={classes.calendar}
                        tileDisabled={({activeStartDate, date, view }) => !dateHasBid(date)}
                        onChange={(res) => {
                            setSelectedBid({})
                            setDate(res)
                        }}
                    />
                </Grid>
                <Grid item xs={4}>
                    <Typography variant='h6' className={classes.sectionHeader}>Current year bids</Typography>
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
                        bidInfo.petname === selectedBid.petname &&
                        bidInfo.pettype === selectedBid.pettype &&
                        bidInfo.ctuname === selectedBid.ctuname &&
                        bidInfo.s_time === selectedBid.s_time &&
                        bidInfo.e_time === selectedBid.e_time
                    )
                    : (date <= sqlToJsDate(bidInfo.e_time) && date >= sqlToJsDate(bidInfo.s_time)))
                .map((bidInfo) => (
                    <Card className={classes.root}>
                        <Typography variant="h4">
                            Bid Details
                        </Typography>
                        <Typography variant="h6">
                            User: {bidInfo.pouname}
                        </Typography>
                        <Typography variant="h6">
                            Pet: {bidInfo.petname} ({bidInfo.pettype})
                        </Typography>
                        <Typography variant="h6">
                            Caretaker: {bidInfo.ctuname}
                        </Typography>
                        <Typography variant="h6">
                            Duration: {sqlToJsDate(bidInfo.s_time).toDateString()} to {sqlToJsDate(bidInfo.e_time).toDateString()}
                        </Typography>
                        <Typography variant="h6">
                            Price: ${bidInfo.cost == null ? "0.00" : bidInfo.cost.toFixed(2)}
                        </Typography>
                        <Typography variant="h6">
                            Pickup Method: {bidInfo.pet_pickup == 'poDeliver' ? "Pet Owner Deliver" 
                                            : bidInfo.pet_pickup == 'ctPickup' ? "Caretaker Pickup" 
                                            : bidInfo.pet_pickup == 'transfer' ? "Transfer" : null}
                        </Typography>
                        <br />

                        <FormControl>
                            <FormLabel color="primary" focused>Accept bid?</FormLabel>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={bidInfo.is_win == true ? true : false}
                                        onChange={(event) => updateBidStatus(bidInfo)}
                                        color="primary"
                                    />
                                }
                                label={bidInfo.is_win ? "Bid Accepted" : "Pending"}
                            />
                        </FormControl>
                    </Card>
                ))}
            {/* <Button variant="contained" onClick={openModal} color="primary">
                Create Bid (temp)
            </Button>
            <Modal
                open={open}
                onClose={closeModal}>
                <BidModal closeModal={closeModal} submitData={submitData} />
            </Modal> */}
        </div>
    )
}

export default BidPanel
