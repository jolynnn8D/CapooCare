import React, { useState, useEffect } from 'react'
import AdminCard from "../components/admin/AdminCard"
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    marginTop: 150,
    marginLeft: 100
  },
  component: {
    padding: theme.spacing(2),
    textAlign: 'center',
    color: theme.palette.text.secondary,
  },
  paper: {
      marginTop: theme.spacing(8),
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
  },
  avatar: {
      margin: theme.spacing(1),
      backgroundColor: theme.palette.secondary.main,
  },
  header: {
      margin: theme.spacing(3),
      textAlign: 'center'
  },
  summarycard: {
      marginTop: theme.spacing(3),
  }
}));

const Adminpage = () => {
  const classes = useStyles();

  return (
    <div className={classes.root}>
      <Grid container spacing={3}>
        <Grid item xs={6}>
          <AdminCard 
            route='/admin/view-caretakers' 
            image= "https://storage.googleapis.com/petbacker/images/blog/2018/pet-care-dog-sitting-services.jpg"
            label= "View All Caretakers"
            description= "Our Caretakers are amazing with animals"/>
        </Grid>
        <Grid item xs={6}>
          <AdminCard 
              route= "/admin/set-price"
              image= "https://mrpetapp.com/wp-content/uploads/2016/11/pets_big.png"
              label= "Set Pet Prices"
              description= "Set base prices for pet categories here"/>
        </Grid>
        <Grid className={classes.summarycard} item xs={6} marginTop={20}>
          <AdminCard 
                route= '/admin/summary'
                image= "https://api.time.com/wp-content/uploads/2014/03/dog-money.jpg"
                label= "View Salary Details"
                description= "View salary details of caretakers"/>
        </Grid>
        <Grid className={classes.summarycard} item xs={6} marginTop={20}>
          <AdminCard 
                route= '/admin/add-admin'
                image= "https://i2-prod.mirror.co.uk/incoming/article16509270.ece/ALTERNATES/s615/1_Business-dog-at-work.jpg"
                label= "Add New Admin"
                description= "Create a new admin account here"/>
        </Grid>
      </Grid>
    </div>
  );
}

export default Adminpage
