import React, {useState} from 'react'
import { makeStyles } from '@material-ui/core/styles';
import { FormControlLabel, Checkbox, FormHelperText, FormControl, FormLabel, FormGroup, Container, Radio, RadioGroup, TextField, Card, Typography, Button } from '@material-ui/core';
import { useStoreActions, useStoreState } from 'easy-peasy';



const useStyles = makeStyles((theme) => ({
    form: {
        width: '100%', // Fix IE 11 issue.
        marginTop: theme.spacing(1),
    },
    submit: {
        margin: theme.spacing(3, 0, 2),
    },
    container: {
        marginTop: theme.spacing(20),
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
    },
  }));

const AddAdmin = () => {
    const classes = useStyles();
    const [username, setUsername] = useState('');
    const [adminname, setAdminName] = useState('');
    const addAdmin = useStoreActions(actions => actions.admin.addAdmin);
    const getNewAdminAccount = useStoreActions(actions => actions.admin.getNewAdminAccount);

    const submit = async (e) => {
        // console.log(username);
        e.preventDefault();
        const result = await getNewAdminAccount(username);

        if (result.data.data.account != null) {
            alert("Username already exists in the database!");
        } else {
            addAdmin({
            username: username,
            adminname: adminname
            });

            setUsername('');
            setAdminName('');
        }
    }

    return (
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
              type="submit"
              fullWidth
              variant="contained"
              color="primary"
              className={classes.submit}
              onClick = {(e) => submit(e)}
          >
              Signup
          </Button>
        </form>
      </div>
    )
}

export default AddAdmin
