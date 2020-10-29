import React from 'react'
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import { useParams } from 'react-router-dom';


import TabPanel from "../components/careTakerAdmin/TabPanel"

const useStyles = makeStyles({
    root: {
        margin: "100px 30px 30px"
    }
})

const CaretakerAdmin = () => {
    const classes = useStyles();
    const params = useParams();
    console.log(params)
    const username = params.username;

    return (
        <div>
            <Grid container className={classes.root}>
                <Grid item xs={12}>
                    <TabPanel username = {username}/>
                </Grid>
            </Grid>
        </div>
    )
}

export default CaretakerAdmin
