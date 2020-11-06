import { Container, Button, Card, CardActionArea, CardActions, CardContent, CardMedia, Table, TableBody, TableCell, TableHead, TableRow, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { useStoreActions, useStoreState } from 'easy-peasy';
import React, { useEffect } from 'react';

const useStyles = makeStyles((theme) => ({
  root: {
    maxWidth: 345,
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
}));

const SetPricepage = () => {
  const classes = useStyles();
  const petCategories = useStoreState(state => state.pets.petCategories);
  const getPetCategories = useStoreActions(actions => actions.pets.getPetCategories);
  const addPetCategories = useStoreActions(actions => actions.pets.addPetCategories);
  const basePricesTableHeaders = ['Pet Type', 'Base Price']

  useEffect(() => {
    getPetCategories();
    return () => { };
  }, [])

  return (
    <Container component="main" maxWidth="xs" className={classes.container}>
      {/* <Typography variant="h6" id="tableTitle"></Typography> */}
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
            </TableRow>
          ))}
          <TableRow>

          </TableRow>
        </TableBody>
      </Table>
    </Container>
  )
}

export default SetPricepage
