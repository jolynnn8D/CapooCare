import React from 'react'
import { Card, Grid, ListItem, ListItemAvatar, ListItemText, Avatar, Modal, TextField, GridList, GridListTile } from '@material-ui/core';
import AddIcon from '@material-ui/icons/Add';

import ProfilePic from "./ProfilePic"
import { makeStyles } from '@material-ui/core/styles';
import petImg from "../../assets/userProfile/pet.png"
import AddPet from "../AddPet";
import { useEffect } from 'react';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { v4 } from 'uuid';
import { CREATE, EDIT, DELETE } from "../../constants"


const useStyles = makeStyles((theme) => ({
    root: {
        padding: 30,
        maxHeight: 500,
        flexWrap: 'wrap',
        justifyContent: 'space-around',
        overflow: 'hidden',
        backgroundColor: theme.palette.background.paper,
    },
    petAvatar: {
        margin: 10
    },
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
    petName: {
        textAlign: "center"
    },
    gridList: {
        width: "100%",
        height: 450,
      },
}));

const PetList = (props) => {
    const [open, setOpen] = React.useState(false);
    const [petDetails, setPetDetails] = React.useState({});
    const [modalType, setModalType] = React.useState(CREATE);
    const {username, ...other} = props;
    const addPetOwner = useStoreActions(actions => actions.petOwners.addPetOwner);
    const singleUser = useStoreState(state => state.user.singleUser);
    const getUser = useStoreActions(actions => actions.user.getUser);
    const getDisplayedUser = useStoreActions(actions => actions.user.getDisplayedUser);

    const openModal = () => {
        setOpen(true);
    }

    const closeModal = async () => {
        setOpen(false);
        await getUserPets(props.username);
        setPetDetails({});
        
    }

    const openCreateModal = () => {
        openModal();
        setModalType(CREATE);
    }

    const clickOnPet = (name, type, age, petReq) => {
        openModal();
        setModalType(EDIT);
        setPetDetails({
            petName: name,
            petType: type,
            petAge: age,
            petRequirements: petReq
        });
    }

    const handleCreateOrEditPet = (petData, action) => {
        if (action == CREATE) {
            if (!singleUser.is_petowner) {
                addPetOwner({
                    username: singleUser.username,
                    ownername: singleUser.firstname,
                    age: singleUser.age,
                    pettype: petData.petType,
                    petname: petData.petName,
                    petage: petData.petAge,
                    requirements: petData.petRequirements
                })

                getUser(singleUser.username);
                getDisplayedUser(singleUser.username);
            }

            createPet({
                username: props.username,
                petname: petData.petName,
                pettype: petData.petType,
                petage: petData.petAge,
                requirements: petData.petRequirements
            })
        }
        if (action == EDIT) {
            editPet({
                username: props.username,
                petname: petData.petName,
                pettype: petData.petType,
                petage: petData.petAge,
                requirements: petData.petRequirements
            })
        }
        if (action == DELETE) {
            deletePet({
                username: props.username,
                petname: petData.petName
            })
        }
    }

    const getUserPets = useStoreActions(actions => actions.pets.getOwnerPets);
    const createPet = useStoreActions(actions => actions.pets.addPet);
    const editPet = useStoreActions(actions => actions.pets.editPet);
    const deletePet = useStoreActions(actions => actions.pets.deletePet);

    useEffect(() => {
        getUserPets(props.username);
        return () => {};
    }, [])

    const pets = useStoreState(state => state.pets.ownerSpecificPets);
    console.log(pets);

    const classes = useStyles();
    var id = 0;
    return (
        <div>
        <Card className={classes.root}>
            <h2> Pets Owned </h2>
            <GridList cols={4} cellHeight={160} className={classes.gridList}>
                {pets.map((pet) => {
                    return(
                        <GridListTile key={v4()} className={classes.petAvatar} cols={1} onClick={() => clickOnPet(pet.petname, pet.pettype, pet.petage, pet.requirements)}>
                            <ProfilePic img={petImg} href="#"/>
                            <h6 className={classes.petName}> {pet.petname} </h6>
                        </GridListTile>)
                })}
            </GridList>
            <Modal
                open={open}
                onClose={closeModal}>
                <Card className={classes.modal}>
                    <AddPet parentData={petDetails} parentCallback={handleCreateOrEditPet} closeModal={closeModal} modalType={modalType}/>
                </Card>
            </Modal>
        </Card>
        <ListItem button onClick={openCreateModal}>
                    <ListItemAvatar>
                        <Avatar>
                            <AddIcon/>
                        </Avatar>
                    </ListItemAvatar>
            {!singleUser.is_petowner ? 
            <>
                <ListItemText
                    primary="Click to add new pet to become a pet owner!"
                />
            </> : <>
                <ListItemText
                    primary="Click to add new pet"
                />
            </> }
        </ListItem>
        </div>
    )
}

export default PetList
