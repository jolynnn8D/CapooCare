import React, {useState, useEffect} from 'react'
import PropTypes from 'prop-types';
import { Button, FormControl, InputLabel, Select, TextField } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { useStoreActions, useStoreState } from 'easy-peasy';

const useStyles = makeStyles((theme) => ({
    textfield: {
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(3),
    },
    button: {
        margin: theme.spacing(3),
    }
}));

const UserModal = (props) => {
  const {closeModal, ...other} = props;
  const classes = useStyles();
  const getSingleUser = useStoreActions(actions => actions.user.getSingleUser);
  const editUser = useStoreActions(actions => actions.user.editUser);
  const singleUser = useStoreState(state => state.user.singleUser);
  const [userName, setUserName] = useState('');
  const [userFirstName, setUserFirstName] = useState(singleUser.firstname);
  const [userAge, setUserAge] = useState(singleUser.age);

  const handleButtonClick = () => {
    closeModal();

    editUser({
        username: singleUser.username,
        firstname: userFirstName,
        age: userAge,
        usertype: 'petowner'
    })
  }

  return (
    <form>
        <TextField
            variant="outlined"
            label="Username (You can't change your username)"
            required
            fullWidth
            disabled
            id="username"
            autoComplete="userName"
            defaultValue={singleUser.username}
            multiline
            autoFocus
            className={classes.textfield}
            onChange={(event) => setUserName(event.target.value)}
        />
        <TextField
            variant="outlined"
            label="User First Name"
            required
            fullWidth
            id="userfirstname"
            autoComplete="userFirstName"
            defaultValue={singleUser.firstname}
            autoFocus
            className={classes.textfield}
            onChange={(event) => setUserFirstName(event.target.value)}
        />
        
        <TextField
            variant="outlined"
            label="User Age"
            required
            fullWidth
            id="userage"
            autoComplete="userAge"
            type="number"
            defaultValue={singleUser.age}
            autoFocus
            className={classes.textfield}
            onChange={(event) => setUserAge(event.target.value)}
        />
        <Button className={classes.button}
            variant="contained"
            color="inherit"
            onClick={() => handleButtonClick()}
        >
            Save User Information
        </Button>
    </form>
  )
}

export default UserModal
