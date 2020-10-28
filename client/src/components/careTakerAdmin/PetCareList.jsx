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


const PetCareList = (props) => {
    const { owner, ...other} = props;
    const [open, setOpen] = useState(false);
    const [addCareOpen, setCareOpen] = useState(false);
    const [petType, setPetType] = useState("");
    const [petPrice, setPetPrice] = useState("");
    const getPetCareList = useStoreActions(actions => actions.careTakers.getPetCareList);
    const addPetCareItem = useStoreActions(actions => actions.careTakers.addPetCareItem);
    const petCareList = useStoreState(state => state.careTakers.petCareList);

    const openModal = () => {
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
            username:"yellowbird",
            pettype: petType,
            price: parseInt(petPrice)
        })
    }

    useEffect(() => {
        getPetCareList("yellowbird")
        return () => {};
    }, [])


    return (
        <div>
            <List>
                {petCareList.map((careItem) => (
                <>
                <ListItem>
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
                {props.owner ? 
                <ListItemSecondaryAction>
                    <IconButton edge="end" aria-label="delete">
                      <DeleteIcon />
                    </IconButton>
                </ListItemSecondaryAction> : null } 
                {!props.owner ? 
                <ListItemSecondaryAction>
                    <IconButton onClick={openModal}>
                        <ListItemText  
                            primary="Bid"/>
                    </IconButton>
                </ListItemSecondaryAction> : null }
                </ListItem>
                 </>
                ))}
                {props.owner ?
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
                <BidModal modalHandler={closeModal}/>
            </Modal>
            <Modal
                open={addCareOpen}
                onClose={closeCareModal}>
                <Card>
                    <PetTypeInput parentType={onPetTypeSet} parentPrice={onPetPriceSet}/>
                    <Button onClick={handleAddNewPet} color="primary"> Add new pet type </Button>
                </Card>
            </Modal>
        </div>
    )
}

export default PetCareList
