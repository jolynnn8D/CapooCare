import React, { useEffect } from 'react'
import { Card, List, ListItem, Grid, Typography, Button} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { v4 } from 'uuid';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { sqlToJsDate } from '../../utils';

const useStyles = makeStyles((theme) => ({
    root: {
        padding: theme.spacing(2),
        width: "100%"
    }
}));

const OrderList = (props) => {
    const {username} = props;
    const classes = useStyles();
    const getPetOwnerBids = useStoreActions(actions => actions.bids.getPetOwnerBids);
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

    return (
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
                                        {bid.pay_status ?  
                                            sqlToJsDate(bid.e_time) < new Date() 
                                                ? <Button color='default' variant='contained'>Leave Review </Button> : null 
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
    )
}

export default OrderList
