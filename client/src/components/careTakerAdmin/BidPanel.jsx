import React from 'react'
import Card from '@material-ui/core/Card';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles({
    root: {
        padding : 30,
        marginTop: 20
    }
})

const BidPanel = () => {
    const classes = useStyles()
    return (
        <Card className={classes.root}>
            <h4> Bid Details</h4>
            <h6> User: busypetowner123 </h6>
            <h6> Date: 18 October 2020 to 31 December 2020</h6>
            <h6> Pet: Corgi </h6>
        </Card> 
    )
}

export default BidPanel
