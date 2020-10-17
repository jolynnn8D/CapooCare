import React from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';

import ProfilePic from "./ProfilePic"
import { makeStyles } from '@material-ui/core/styles';
import petImg from "../../assets/userProfile/pet.png"

const useStyles = makeStyles({
    root: {
        padding: 30,
        height: 280
    }
})
const PetList = () => {
    const classes = useStyles();
    return (
        <Card className={classes.root}>
            <h2> Pets Owned </h2>
            <Grid container>
                <Grid item>
                    <ProfilePic img={petImg} href="#"/>
                </Grid>
            </Grid>
        </Card>
    )
}

export default PetList
