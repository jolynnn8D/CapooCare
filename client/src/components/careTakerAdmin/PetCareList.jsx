import React, { useEffect, useState } from 'react'
import { makeStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemAvatar from '@material-ui/core/ListItemAvatar';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Modal from '@material-ui/core/Modal';
import Card from '@material-ui/core/Card';
import Button from '@material-ui/core/Button';

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
                <ListItemText
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
