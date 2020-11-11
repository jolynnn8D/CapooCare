import { Container, Button, Modal, Table, TableBody, TableCell, TableHead, TableRow, Typography, TextField, IconButton, Icon, Card } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { useStoreActions, useStoreState } from 'easy-peasy';
import React, { useEffect, useState } from 'react';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';

const useStyles = makeStyles((theme) => ({
  root: {
    // maxWidth: 680,
    marginTop: 200
  },
  media: {
    height: 140,
  },
  container: {
    marginTop: theme.spacing(15),
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  modal: {
    minWidth: 1000,
    display: 'flex',
    padding: theme.spacing(1),
    alignItems: 'center',
    justifyContent: 'center',

  },
  paper: {
    width: 400,
    backgroundColor: theme.palette.background.paper,
    border: '2px solid #000',
    boxShadow: theme.shadows[5],
    padding: theme.spacing(2, 4, 3),
  },
  textfield: {
    margin: theme.spacing(3),
    marginLeft: 0
  }
}));

const SetPricepage = () => {
  const classes = useStyles();
  const petCategories = useStoreState(state => state.pets.petCategories);
  const getPetCategories = useStoreActions(actions => actions.pets.getPetCategories);
  const addPetCategory = useStoreActions(actions => actions.pets.addPetCategory);
  const editPetCategory = useStoreActions(actions => actions.pets.editPetCategory);
  const basePricesTableHeaders = ['Pet Type', 'Base Price', 'Edit']
  const [open, setOpen] = useState(false);
  const [isAddPetCategory, setIsAddPetCategory] = useState(false);
  const [newPetCategory, setNewPetCategory] = useState('');
  const [newPetBasePrice, setNewPetBasePrice] = useState(0);

  useEffect(() => {
    getPetCategories();
    return () => { };
  }, [])

  const openAddModal = () => {
    setNewPetCategory("");
    setIsAddPetCategory(true);
    setOpen(true);
  }

  const openEditModal = (pettype) => {
    setNewPetCategory(pettype);
    setIsAddPetCategory(false);
    setOpen(true);
  }

  const closeModal = () => {
    setOpen(false);
  }

  const sendData = (action) => {
    addPetCategory({
      "category": newPetCategory,
      "base_price": newPetBasePrice
    })
      .then((res) => {
        closeModal();
        getPetCategories();
      })
      .catch((error) => {
        console.log(error)
      })
  }

  const updateData = (action) => {
    editPetCategory({
      "category": newPetCategory,
      "base_price": newPetBasePrice
    })
      .then((res) => {
        closeModal();
        getPetCategories();
      })
      .catch((error) => {
        console.log(error)
      })
  }

  return (
    <div>
      <Container component="main" maxWidth="ml" className={classes.container}>
        <Typography variant="h2" id="tableTitle">Set Base Prices</Typography>
        <Button variant="contained" color="primary" onClick={openAddModal}>Add Base Price</Button>
        <Table aria-label="base-prices-table">
          <TableHead>
            <TableRow>
              {basePricesTableHeaders.map((tableHeader) => (
                <TableCell>{tableHeader}</TableCell>
              ))}
            </TableRow>
          </TableHead>
          <TableBody>
            {petCategories.map((type) => (
              <TableRow key={type.pettype}>
                <TableCell>
                  {type.pettype}
                </TableCell>
                <TableCell>
                  {type.base_price}
                </TableCell>
                <TableCell>
                  <IconButton edge="end" aria-label="edit" onClick={() => openEditModal(type.pettype)}>
                    <EditIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

      </Container>
      <Modal
        open={open}
        onClose={closeModal}
        className={classes.modal}>
        <Card className={classes.paper}>
          <Typography id="simple-modal-title" variant="h5">{isAddPetCategory ? "Add Base Price" : "Edit Base Price"}</Typography>
          <TextField
            variant="outlined"
            label="Pet Type"
            required
            fullWidth
            disabled={!isAddPetCategory}
            id="newPetCategory"
            autoComplete="newPetCategory"
            autoFocus
            defaultValue={newPetCategory}
            className={classes.textfield}
            onChange={(event) => setNewPetCategory(event.target.value)}
          />
          <TextField
            variant="outlined"
            label="Base Price"
            required
            fullWidth
            id="newPetBasePrice"
            autoComplete="newPetBasePrice"
            autoFocus
            className={classes.textfield}
            onChange={(event) => setNewPetBasePrice(event.target.value)}
          />
          {isAddPetCategory 
            ? <Button variant="contained" color="primary" onClick={sendData}>Add</Button>
            : <Button variant="contained" color="primary" onClick={updateData}>Edit</Button>
          }
        </Card>
      </Modal>
    </div>
  )
}

export default SetPricepage
