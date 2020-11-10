import React, { useState, useEffect } from 'react'
import { FormControlLabel, Checkbox, FormHelperText, FormControl, FormLabel, FormGroup, Container, Radio, RadioGroup, TextField, Card, Typography, Button } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import { useHistory } from 'react-router-dom';
import { useStoreActions, useStoreState } from 'easy-peasy';
import AddPet from "../components/AddPet";
import PetTypeInput from "../components/PetTypeInput"
import Availability from '../components/Availability';
import { sqlToJsDate, differenceInTwoDates, stringToJsDate, isValidStringDate } from "../utils";


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
        backgroundColor: "#1976D2"
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


const Signup = () => {
    const classes = useStyles();
    const history = useHistory();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [firstName, setFirstName] = useState('');
    const [petType, setPetType] = useState('');
    const [petPrice, setPetPrice] = useState(0);
    const [age, setAge] = useState(0);
    const [isPetOwner, setPetOwner] = useState(false);
    const [isPetCaretaker, setPetCaretaker] = useState(false);
    const [caretakerType, setCaretakerType] = useState("parttime");
    const [petInformation, setPetInformation] = useState({});
    const [p1startDate, setP1StartDate] = useState(0);
    const [p1endDate, setP1EndDate] = useState(0);
    const [p2startDate, setP2StartDate] = useState(0);
    const [p2endDate, setP2EndDate] = useState(0);
    const [error, setError] = useState(false);
    const [errorMessage, setErrorMessage] = useState('An error occurred.');


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


    const addPartTimeCareTaker = useStoreActions(actions => actions.careTakers.addPartTimeCareTaker);
    const addFullTimeCareTaker = useStoreActions(actions => actions.careTakers.addFullTimeCareTaker);
    const addPetOwner = useStoreActions(actions => actions.petOwners.addPetOwner);
    const getAllUsers = useStoreActions(actions => actions.user.getAllUsers);
    const allUsers = useStoreState(state => state.user.allUsers);
    
    useEffect(() => {
        getAllUsers();
        return () => {};
    }, []);
    
    const userInDatabase = () => {
        var result = false;
        allUsers.map((user) => {
            if (user.username == username) {
                result = true;
            }
        })
        return result;
    }
    const validateDates = () => {
        if (p1startDate.length != 8 || p1endDate.length != 8 || p2startDate.length != 8 || p2endDate.length != 8) {
            alert("Please enter date in the format YYYYMMDD")
            return false;
        }
        if (stringToJsDate(p1startDate) > stringToJsDate(p1endDate) || stringToJsDate(p2startDate) > stringToJsDate(p2endDate)) {
            alert("Please enter a start date that is before the end date")
            return false;
        }
        if (!(isValidStringDate(p1startDate) && isValidStringDate(p1endDate)) || !(isValidStringDate(p2startDate) && isValidStringDate(p2endDate))) {
            alert("Invalid date entered. Please enter in the format YYYYMMDD")
            return false;
        }
        if (stringToJsDate(p1startDate) < new Date() || stringToJsDate(p2startDate) < new Date()) {
            alert("Please enter a start date in the future.")
            return false;
        }
        const dayDifference = differenceInTwoDates(p1startDate, p1endDate)
        const p2dayDifference = differenceInTwoDates(p2startDate, p2endDate);
        if (dayDifference < 150 || p2dayDifference < 150) {
            alert("You need to add an availability period of at least 150 days")
            return false;
        }
        if (differenceInTwoDates(p1startDate, p2endDate) > 365) {
            alert("The two availabilities need to occur within a one year time frame.")
            return false;
        }
        
        return true;
    }  

    const fieldsAreValid = () => {
        if (userInDatabase()) {
            setErrorMessage('Username is taken')
            setError(true);
            return false;
        } 
        if (!(isPetOwner || isPetCaretaker)) {
            setErrorMessage('Please select either pet owner or caretaker');
            setError(true);
            return false;
        }
        if (firstName == '' || age == 0) {
            setErrorMessage('Please fill up the empty fields');
            setError(true);
            return false;
        }
        if (isPetCaretaker) {
            if (petType == '') {
                setErrorMessage('Please select a valid pet type to care for')
                setError(true);
                return false;
            }
            if (petPrice == 0) {
                setErrorMessage('Price per day cannot be 0 or empty')
                setError(true);
                return false;
            }
            if (caretakerType == "fulltime") {
                if (!validateDates()) {
                    setErrorMessage('Incorrect date input')
                    setError(true);
                    return false;
                }
            }
        }
        if (isPetOwner) {
            if (Object.keys(petInformation).length === 0) {
                setErrorMessage("Please click on the Save Pet Information button");
                setError(true);
                return false;
            }
            if (petInformation.petName == '' || petInformation.petType == '') {
                setErrorMessage("Please fill up the empty pet information")
                setError(true);
                return false;
            }
        }
        return true;
    }
    const submit = async () => {
        if (!fieldsAreValid()) {
            return;
        }
        addUser();
        handlePageChange()
    }
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
                addPartTimeCareTaker({
                    username: username,
                    name: firstName,
                    age: parseInt(age),
                    pettype: petType,
                    price: parseInt(petPrice)
                })
            }
            else if (caretakerType == 'fulltime') { 
                addFullTimeCareTaker({
                    username: username,
                    name: firstName,
                    age: parseInt(age),
                    pettype: petType,
                    price: parseInt(petPrice), 
                    period1_s: p1startDate,
                    period1_e: p1endDate,
                    period2_s: p2startDate,
                    period2_e: p2endDate
                })
            }
        }
    }

    const handlePageChange = () => {
        history.push('/');
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
                    { isPetCaretaker && caretakerType === 'fulltime' ? 
                    <>
                    <FormControl component="fieldset" className={classes.formControl}>
                        <FormLabel component="legend">Type of caretaker</FormLabel>
                        <RadioGroup value={caretakerType} onChange={onChangeCaretakerType}>
                            <FormControlLabel value="parttime" control={<Radio />} label="Part-time" />
                            <FormControlLabel value="fulltime" control={<Radio />} label="Full-time" />
                        </RadioGroup>
                        <FormHelperText>Choose at least one role!</FormHelperText>
                    </FormControl>
                    <PetTypeInput parentType = {onSelectType} parentPrice={onInputPrice} setParentPrice={setPetPrice} isFT={caretakerType == 'fulltime'} label = "Choose a pet type you can care for"/> 
                    <Availability setP1StartDate={setP1StartDate} setP1EndDate={setP1EndDate} setP2StartDate={setP2StartDate} setP2EndDate={setP2EndDate}/> </>
                    : isPetCaretaker ?
                    <> <FormControl component="fieldset" className={classes.formControl}>
                        <FormLabel component="legend">Type of caretaker</FormLabel>
                        <RadioGroup value={caretakerType} onChange={onChangeCaretakerType}>
                            <FormControlLabel value="parttime" control={<Radio />} label="Part-time" />
                            <FormControlLabel value="fulltime" control={<Radio />} label="Full-time" />
                        </RadioGroup>
                        <FormHelperText>Choose at least one role!</FormHelperText>
                    </FormControl>
                    <PetTypeInput parentType = {onSelectType} parentPrice={onInputPrice} setParentPrice={setPetPrice} isFT={caretakerType == 'fulltime'} label = "Choose a pet type you can care for"/> </> : null}
                    {  isPetOwner ? <AddPet parentCallback = {callbackAddPet} /> : null }
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
                    {error ? <Typography> {errorMessage} </Typography> : null}
                </form>
            </Container>
        </div>
    )
}

export default Signup;