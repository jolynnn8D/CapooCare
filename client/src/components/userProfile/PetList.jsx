import React, { useEffect } from 'react'
import Card from '@material-ui/core/Card';
import Grid from '@material-ui/core/Grid';

import ProfilePic from "./ProfilePic"
import { makeStyles } from '@material-ui/core/styles';
import petImg from "../../assets/userProfile/pet.png"
import { useDispatch, useSelector } from 'react-redux';
import { listPets } from "../../actions/userActions"

const useStyles = makeStyles({
    root: {
        padding: 30,
        height: 280
    },
    petAvatar: {
        margin: 10
    }
})
const PetList = () => {
    const petList = useSelector(state => state.petList);
    const {pets, loading ,error} = petList;
    const dispatch = useDispatch();
    useEffect(() => {
        dispatch(listPets());
        console.log(pets);
    })

    const classes = useStyles();
    return loading ? <div> Loading ... </div> : error ? <div>{error}</div> : (
        <Card className={classes.root}>
            <h2> Pets Owned </h2>
            <Grid container>
                {pets.map((pet) => {
                    return(
                        <Grid item className={classes.petAvatar}>
                            <ProfilePic img={petImg} href="#"/>
                            <p> {pet} </p>
                        </Grid>)
                })}
            </Grid>
        </Card>
    )
}

export default PetList
