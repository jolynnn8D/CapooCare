import { Container, Button, Modal, Table, TableBody, TableCell, TableHead, TableRow, Typography, TextField, IconButton } from '@material-ui/core';
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
    padding: theme.spacing(3)
  }
}));

const SetPricepage = () => {
  const classes = useStyles();
  const petCategories = useStoreState(state => state.pets.petCategories);
  const getPetCategories = useStoreActions(actions => actions.pets.getPetCategories);
  const addPetCategories = useStoreActions(actions => actions.pets.addPetCategories);
  const basePricesTableHeaders = ['Pet Type', 'Base Price', 'Delete', 'Modify']
  const [open, setOpen] = useState(false);
  const [newPetCategory, setNewPetCategory] = useState('');
  const [newPetBasePrice, setNewPetBasePrice] = useState(0);

  useEffect(() => {
    getPetCategories();
    return () => { };
  }, [])

  const openModal = () => {
    setOpen(true);
  }

  const closeModal = () => {
    setOpen(false);
  }

  const sendData = (action) => {
    addPetCategories({
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
        <Button variant="contained" color="primary" onClick={openModal}>Add Base Price</Button>
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
                  <IconButton edge="end" aria-label="delete">
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
                <TableCell>
                  <EditIcon />
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
        <div className={classes.paper}>
          <Typography id="simple-modal-title" variant="h5">Add Base Price</Typography>
          <TextField
            variant="outlined"
            label="New Pet Type"
            required
            fullWidth
            id="newPetCategory"
            autoComplete="newPetCategory"
            autoFocus
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
          <Button variant="contained" color="primary" onClick={sendData}>Submit</Button>
        </div>
      </Modal>
    </div>
  )
}

export default SetPricepage
