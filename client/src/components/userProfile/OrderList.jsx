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
    const petOwnerBids = useStoreState(state => state.bids.petOwnerBids);

    useEffect(() => {
        getPetOwnerBids(username);
        return () => {};
    }, []);

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
                                                : <Button color='default' variant='contained'> Make Payment </Button>}
                                        </>
                                        : null
                                    }
                                    <Typography>
                                        -------------------------------------------------------------------------
                                    </Typography>
                                </Grid>);
                            })}
                        </List>
        </Card>
    )
}

export default OrderList
