import React, { useEffect, useState } from 'react'
import { Card, List, ListItem, Grid, Typography, Button, Modal, TextField} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { v4, validate } from 'uuid';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { sqlToJsDate } from '../../utils';

const useStyles = makeStyles((theme) => ({
    root: {
        padding: theme.spacing(2),
        width: "100%"
    }, 
    modal: {
        width: "40%",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        position: 'absolute',
        backgroundColor: theme.palette.background.paper,
        border: '2px solid #000',
        boxShadow: theme.shadows[5],
        padding: theme.spacing(2, 4, 3),
    },
    textfield: {
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(3),
    },
}));

const OrderList = (props) => {
    const {username} = props;
    const classes = useStyles();
    const [reviewModal, setReviewModal] = useState(false);
    const [modalBid, setModalBid] = useState({});
    const [rating, setRating] = useState(5);
    const [review, setReview] = useState("");
    const getPetOwnerBids = useStoreActions(actions => actions.bids.getPetOwnerBids);
    const addReviewToBid = useStoreActions(actions => actions.bids.addReviewToBid);
    const makePayment = useStoreActions(actions => actions.bids.makePayment);
    const petOwnerBids = useStoreState(state => state.bids.petOwnerBids);
    

    useEffect(() => {
        getPetOwnerBids(username);
        return () => {};
    }, []);

    const handleMakePayment = (bidInfo) => {
        makePayment({
            pouname: bidInfo.pouname,
            petname: bidInfo.petname,
            pettype: bidInfo.pettype,
            ctuname: bidInfo.ctuname,
            s_time: bidInfo.s_time,
            e_time: bidInfo.e_time
        })
    }

    const openReviewModal = (bid) => {
        setReviewModal(true);
        setModalBid(bid);
    }
    const closeReviewModal = () => {
        setReviewModal(false);
    }

    const submitReview = () => {
        console.log(rating == parseInt(rating, 10));
        if (rating > 5 || rating < 0 || rating != parseInt(rating, 10)) {
            alert("Rating must be an integer value from 0 to 5")
            // closeReviewModal()
            return;
        }
        addReviewToBid({
            bid: modalBid,
            rating: rating,
            review: review
        })
        closeReviewModal()
    }

    return (
        <div>
            <Card style={{width: "100%"}} className={classes.root}>
                <List style={{maxHeight:500, overflow: 'auto'}}>
                        {petOwnerBids.map((bid) => {
                            return (<Grid key={v4()}>
                                <Typography>
                                    Pet: {bid.petname}
                                </Typography>
                                <Typography>
                                    Caretaker: {bid.ctuname}
                                </Typography>
                                <Typography>
                                    Duration: {sqlToJsDate(bid.s_time).toLocaleDateString()} to {sqlToJsDate(bid.e_time).toLocaleDateString()}
                                </Typography>
                                <Typography>
                                    Bid: {bid.is_win == null ? "Pending" : bid.is_win ? "Accepted" : "Rejected"}
                                </Typography>
                                {bid.is_win ? 
                                    <>
                                    <Typography>
                                        Job status: {sqlToJsDate(bid.e_time) < new Date() ? "Completed" : "In process"}
                                    </Typography>
                                    <Typography>
                                        Payment made: {bid.pay_status ? "Payment completed" : "Pending payment"}
                                    </Typography>
                                    {bid.pay_status 
                                        ?  sqlToJsDate(bid.e_time) < new Date() 
                                            ? bid.review == null 
                                                ? <Button color='default' variant='contained' onClick={()=> openReviewModal(bid)}>Leave Review </Button> 
                                                : "Review Completed"
                                            : null
                                        : <Button color='default' variant='contained' onClick={() => handleMakePayment(bid)}> Make Payment </Button>}
                                    </>
                                    : null
                                }
                                <Typography>
                                    ----------------------------------------------------------------------
                                </Typography>
                            </Grid>);
                        })}
                </List>
            </Card>
            <Modal
                open={reviewModal}
                onClose={closeReviewModal}>
                <Card className={classes.modal}>
                    <TextField
                            variant="outlined"
                            label="Rating (0 to 5)"
                            required
                            fullWidth
                            id="rating"
                            autoFocus
                            type="number"
                            InputProps={{
                                inputProps: { 
                                    max: 5, min: 0
                            }
                            }}
                            className={classes.textfield}
                            onChange={(event) => setRating(event.target.value)}
                        />
                    <TextField
                        id="review"
                        label="Leave review here"
                        multiline
                        rows={3}
                        fullWidth
                        variant="outlined"
                        className={classes.textfield}
                        onChange={(event) => setReview(event.target.value)}
                    />
                    <Button variant="outlined" onClick={() => submitReview()}>
                        Submit Review
                    </Button>
                </Card>
            </Modal>
        </div>

    )
}

export default OrderList
