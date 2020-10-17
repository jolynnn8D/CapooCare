import React from 'react'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

import TabPanel from "../components/careTakerAdmin/TabPanel"
import BidPanel from "../components/careTakerAdmin/BidPanel"

const useStyles = makeStyles({
    root: {
        margin: 30
    }
})

const CaretakerAdmin = () => {
    const classes = useStyles();

    return (
        <div>
            <Grid container className={classes.root}>
                <Grid item xs={12}>
                    <TabPanel/>
                </Grid>
            </Grid>
        </div>
    )
}

export default CaretakerAdmin
