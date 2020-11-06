import React, { useEffect, useState } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import {Typography, Button, Grid, Card, Modal, List, ListItem, ListItemAvatar, ListItemSecondaryAction, ListItemText} from '@material-ui/core';
import store from "../../store/store";
import { DateRangePicker } from 'react-date-range';

import Avatar from '@material-ui/core/Avatar';
import IconButton from '@material-ui/core/IconButton';
import AddIcon from '@material-ui/icons/Add';
import PetsIcon from '@material-ui/icons/Pets';
import DeleteIcon from '@material-ui/icons/Delete';
import BidModal from '../userProfile/careTakerProfile/BidModal';
import { useStoreActions, useStoreState } from 'easy-peasy';
import PetTypeInput from '../PetTypeInput';
import { v4 } from 'uuid';

const useStyles = makeStyles((theme) => ({
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
    priceText: {
        marginRight: theme.spacing(25),
        textAlign: "right"
    },
    lucrativeCard: {
        marginTop: 30,
        padding: 20
    },
}))

const PetCareList = (props) => {
    const { userType, username, ...other} = props;
    const classes = useStyles();
    const [open, setOpen] = useState(false);
    const [addCareOpen, setCareOpen] = useState(false);
    const [petType, setPetType] = useState("");
    const [petPrice, setPetPrice] = useState("");
    const [bidPetType, setBidPetType] = useState("");
    const singleUser = useStoreState(state => state.user.singleUser);
    const getPetCareList = useStoreActions(actions => actions.careTakers.getPetCareList);
    const addPetCareItem = useStoreActions(actions => actions.careTakers.addPetCareItem);
    const deletePetCareItem = useStoreActions(actions => actions.careTakers.deletePetType);
    const petCareList = useStoreState(state => state.careTakers.petCareList);
    const [openLucativeModal, setOpenLucrativeModal] = useState(false);
    const [dateRange, setDateRange] = useState([
        {
            startDate: new Date(),
            endDate: new Date(),
            key: "selection"
        }
    ]);
    const getMostLucrativeCategories = useStoreActions(actions => actions.careTakers.getMostLucrativeCategories);
    const [mostLucrativeCategories, setMostLucrativeCategories] = useState([]);

    const openLucrativeModal = () => {
        setOpenLucrativeModal(true);
    }
    
    const closeLucrativeModal = () => {
        setOpenLucrativeModal(false);
    }

    const handleSubmit = async () => {
        await getMostLucrativeCategories({
            ctuname: props.username,
            s_time: dateRange[0].startDate, 
            e_time: dateRange[0].endDate
        })

        const mostLucrativeCategories = store.getState().careTakers.mostLucrativeCategories;
        setMostLucrativeCategories(mostLucrativeCategories);
        setOpenLucrativeModal(false);
    }

    const openModal = (bidPet) => {
        setBidPetType(bidPet);
        setOpen(true);
    }
    
    const closeModal = () => {
        setOpen(false);
    }

    const openCareModal = () => {
        setCareOpen(true);
    }
    const closeCareModal = () => {
        setCareOpen(false);
    }

    const onPetPriceSet = (event) => {
        setPetPrice(event.target.value);
    }

    const onPetTypeSet = (event) => {
        setPetType(event.target.value);
    }

    const handleAddNewPet = (event) => {
        closeCareModal();
        console.log({
            pettype: petType,
            price: parseInt(petPrice)
        })
        addPetCareItem({
            username: username,
            pettype: petType,
            price: parseInt(petPrice)
        })
    }

    useEffect(() => {
        getPetCareList(username)
        return () => {};
    }, [])


    return (
        <div>
            <Button className={classes.button}
                variant='outlined'
                onClick={openLucrativeModal}>
                Click to find most Lucrative Pet Categories in the past! (Select a timeframe)
            </Button>
            <Card className={classes.lucrativeCard}>
                <Typography variant='h5'> Categories and Lucrative Score: 
                {mostLucrativeCategories.length == 0 
                    ? <Typography>There is no available data! </Typography> 
                    : mostLucrativeCategories.map(category => {
                    return (<h6>Category of pet: {category.pettype} - Lucrative Score: {category.lucrative_score}</h6>)
                })}</Typography>
            </Card>
            <Modal
                open={openLucativeModal}
                onClose={closeLucrativeModal}>
                <Card className = {classes.modal}>
                    <Grid item xs={12}>
                    <DateRangePicker
                        id="form-datepicker"
                        onChange={item => {
                            console.log(item);
                            setDateRange([{
                                startDate: item.selection.startDate,
                                endDate: item.selection.endDate,
                                key: item.selection.key
                            }]);
                            // console.log(item.selection);
                            // console.log(dateRange);
                            // console.log(filteredCaretakers);
                        }}
                        showSelectionPreview={true}
                        moveRangeOnFirstSelection={false}
                        ranges={dateRange}
                        direction="horizontal"
                    />
                    </Grid>
                    <Button className={classes.button}
                        variant="outlined"
                        fullWidth
                        color="primary"
                        onClick={() => handleSubmit()}>
                        Look for most Lucrative Pet Categories in this timeframe!
                    </Button>
                </Card>
            </Modal>
            <List>
                {petCareList.map((careItem) => (
                <>
                <ListItem key={v4()}>
                <ListItemAvatar>
                    <Avatar>
                      <PetsIcon />
                    </Avatar>
                </ListItemAvatar>
                <ListItemText
                    primary={careItem.pettype}
                />
                <ListItemText className={classes.priceText}
                    primary={`$${careItem.price}/day`}
                />
                {userType == 'ct' ? 
                <ListItemSecondaryAction>
                    <IconButton edge="end" aria-label="delete" onClick={() => deletePetCareItem({username: username, pettype: careItem.pettype})}>
                      <DeleteIcon />
                    </IconButton>
                </ListItemSecondaryAction> : null } 
                {userType == 'po' ? 
                <ListItemSecondaryAction>
                    <IconButton onClick={() => openModal(careItem.pettype)}>
                        <ListItemText  
                            primary="Bid"/>
                    </IconButton>
                </ListItemSecondaryAction> : null }
                </ListItem>
                 </>
                ))}
                {userType == 'ct' ?
                <ListItem button onClick={openCareModal}>
                    <ListItemAvatar>
                        <Avatar>
                            <AddIcon/>
                        </Avatar>
                    </ListItemAvatar>
                    <ListItemText
                        primary="Click to add new pet"
                    />
                </ListItem> : null }
            </List>
            <Modal
                open={open}
                onClose={closeModal}>
                <BidModal ctuname={props.username} petType={bidPetType} closeModal={closeModal}/>
            </Modal>
            <Modal
                open={addCareOpen}
                onClose={closeCareModal}>
                <Card className={classes.modal}>
                    <PetTypeInput parentType={onPetTypeSet} parentPrice={onPetPriceSet} isFT={singleUser.is_fulltimer}/>
                    <Button onClick={handleAddNewPet} color="primary"> Add new pet type </Button>
                </Card>
            </Modal>
        </div>
    )
}

export default PetCareList
