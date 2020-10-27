import React, { useState } from 'react'
import { FormControlLabel, Checkbox, FormHelperText, FormControl, FormLabel, FormGroup, Container, Radio, RadioGroup, TextField, Card, Typography, Button } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { useStoreActions } from 'easy-peasy';
import AddPet from "../components/AddPet";
import PetTypeInput from "../components/PetTypeInput"

const useStyles = makeStyles((theme) => ({
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
}));

const defaultPetTypes = ['Dog', 'Cat', 'Bird', 'Fish'];

const Signup = () => {
    const classes = useStyles();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [firstName, setFirstName] = useState('');
    const [petType, setPetType] = useState('');
    const [petPrice, setPetPrice] = useState('');
    const [age, setAge] = useState('');
    const [isPetOwner, setPetOwner] = useState(false);
    const [isPetCaretaker, setPetCaretaker] = useState(false);
    const [caretakerType, setCaretakerType] = useState("parttime");
    const [petInformation, setPetInformation] = useState({});

    const onPetOwnerSwitchChange = () => {
        setPetOwner(isPetOwner => !isPetOwner);
    }

    const onPetCaretakerSwitchChange = () => {
        setPetCaretaker(isPetCaretaker => !isPetCaretaker);
    }

    const onChangeCaretakerType = (event) => {
        setCaretakerType(event.target.value);
    }

    const onSelectType = (event) => {
        setPetType(event.target.value);
    }
    
    const onInputPrice = (event) => {
        setPetPrice(event.target.value);
    }

    const addCareTaker = useStoreActions(actions => actions.careTakers.addCareTaker);
    const addPartTimeCareTaker = useStoreActions(actions => actions.careTakers.addPartTimeCareTaker);
    const addPetOwner = useStoreActions(actions => actions.petOwners.addPetOwner);
    const addUser = () => {
        if (isPetOwner) {
            addPetOwner({
                username: username,
                ownername: firstName,
                age: age,
                pettype: petInformation.petType,
                petname: petInformation.petName,
                petage: petInformation.petAge,
                requirements: petInformation.petRequirements
            });
        }
        if (isPetCaretaker) {
            if (caretakerType=='parttime') {
                console.log({username: username,
                    name: firstName,
                    age: age,
                    pettype: petType,
                    price: petPrice});
                addPartTimeCareTaker({
                    username: username,
                    name: firstName,
                    age: age,
                    pettype: petType,
                    price: petPrice
                })
            }
        }
    }

    const callbackAddPet = (childData) => {
        setPetInformation(childData);
    }
    
    return (
        <div>
            <Container component="main" maxWidth="xs" className={classes.container}>
                <Typography component="h1" variant="h3" color="textPrimary" align="center">
                    Signup
            </Typography>
                <form className={classes.form} noValidate>
                    <TextField
                        variant="outlined"
                        label="Username"
                        required
                        fullWidth
                        id="username"
                        autoComplete="username"
                        autoFocus
                        className={classes.textfield}
                        onChange={(event) => setUsername(event.target.value)}
                    />
                    <TextField
                        variant="outlined"
                        label="Password"
                        required
                        fullWidth
                        id="password"
                        autoComplete="password"
                        autoFocus
                        className={classes.textfield}
                        onChange={(event) => setPassword(event.target.value)}
                    />
                    <TextField
                        variant="outlined"
                        label="First Name"
                        required
                        fullWidth
                        id="firstName"
                        autoComplete="firstName"
                        autoFocus
                        className={classes.textfield}
                        onChange={(event) => setFirstName(event.target.value)}
                    />
                    <TextField
                        variant="outlined"
                        label="Age"
                        required
                        fullWidth
                        id="age"
                        autoComplete="age"
                        autoFocus
                        type="number"
                        className={classes.textfield}
                        onChange={(event) => setAge(event.target.value)}
                    />
                    
                    <FormControl component="fieldset" className={classes.formControl}>
                        <FormLabel component="legend">Account Roles</FormLabel>
                        <FormGroup>
                            <FormControlLabel
                                control={<Checkbox checked={isPetOwner} onChange={onPetOwnerSwitchChange} 
                                name="petOwner" />}
                                label="Pet Owner"
                                id="isPetOwner"
                            />
                            <FormControlLabel
                                control={<Checkbox checked={isPetCaretaker} onChange={onPetCaretakerSwitchChange} name="petCaretaker" />}
                                label="Pet Caretaker"
                                id="isPetCaretaker"
                            />
                        </FormGroup>
                        <FormHelperText>Choose at least one role!</FormHelperText>
                    </FormControl>
                    { isPetCaretaker ? 
                    <>
                    <FormControl component="fieldset" className={classes.formControl}>
                        <FormLabel component="legend">Type of caretaker</FormLabel>
                        <RadioGroup value={caretakerType} onChange={onChangeCaretakerType}>
                            <FormControlLabel value="parttime" control={<Radio />} label="Part-time" />
                            <FormControlLabel value="fulltime" control={<Radio />} label="Full-time" />
                        </RadioGroup>
                        <FormHelperText>Choose at least one role!</FormHelperText>
                    </FormControl>
                    <PetTypeInput parentType = {onSelectType} parentPrice={onInputPrice} label = "Choose a pet type you can care for"/> </> : null } 
                    {  isPetOwner ? <AddPet parentCallback = {callbackAddPet} /> : null }
                    <Button
                        // type="submit"
                        fullWidth
                        variant="contained"
                        color="primary"
                        className={classes.submit}
                        onClick = {() => addUser()}
                    >
                        Signup
                    </Button>
                </form>
            </Container>
        </div>
    )
}

export default Signup;