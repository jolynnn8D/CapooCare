import React, { useState, useEffect } from 'react'
import PriceList from '../components/admin/PriceList';
import ViewAllCaretakers from '../components/admin/ViewAllCaretakers';
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import { FormControlLabel, Checkbox, FormHelperText, FormControl, FormLabel, FormGroup, Container, Radio, RadioGroup, TextField, Card, Typography, Button } from '@material-ui/core';
import { useHistory } from 'react-router-dom';
import { useStoreActions, useStoreState } from 'easy-peasy';

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
  form: {
      width: '100%', // Fix IE 11 issue.
      marginTop: theme.spacing(1),
  },
  submit: {
      margin: theme.spacing(3, 0, 2),
  },
  container: {
      marginTop: theme.spacing(15),
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
  },
  textfield: {
      marginTop: theme.spacing(3),
      marginBottom: theme.spacing(3),
  },
  formControl: {
      margin: theme.spacing(3),
  },
  header: {
      margin: theme.spacing(3),
      textAlign: 'center'
  }
}));

const Adminpage = () => {
  const classes = useStyles();
  const [username, setUsername] = useState('');
  const [adminname, setAdminName] = useState('');
  const addAdmin = useStoreActions(actions => actions.admin.addAdmin);
  
  const submit = async () => {
      await addAdmin({
        username: username,
        adminname: adminname
      });
      setUsername('');
      setAdminName('');
  }

  return (
    <div className={classes.root}>
      <Grid container spacing={3}>
        <Grid item xs={6}>
          <ViewAllCaretakers className={classes.component}/>
        </Grid>
        <Grid item xs={6}>
          <PriceList className={classes.component}/>
        </Grid>
        <div className={classes.container}>
          <Typography component="h1" variant="h3" color="textPrimary" align="center">
              Sign another admin up!
          </Typography>
          <form className={classes.form} noValidate>
            <TextField
                variant="outlined"
                label="Admin Username"
                required
                fullWidth
                id="adminUsername"
                autoComplete="adminUsername"
                autoFocus
                className={classes.textfield}
                onChange={(event) => setUsername(event.target.value)}
            />
            <TextField
                variant="outlined"
                label="Admin Name"
                required
                fullWidth
                id="adminName"
                autoComplete="adminName"
                autoFocus
                className={classes.textfield}
                onChange={(event) => setAdminName(event.target.value)}
            />
            <Button
                // type="submit"
                fullWidth
                variant="contained"
                color="primary"
                className={classes.submit}
                onClick = {() => submit()}
            >
                Signup
            </Button>
          </form>
        </div>
      </Grid>
    </div>
  );
}

export default Adminpage
