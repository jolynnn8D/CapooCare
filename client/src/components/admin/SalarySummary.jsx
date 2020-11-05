import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { getStartEndOfMonth } from "../../utils";
import { Button, Card, FormControl, Grid, InputLabel, List, Select, Typography } from '@material-ui/core';
import store from "../../store/store"


const useStyles = makeStyles((theme) => ({
    salaryCard: {
        padding: theme.spacing(3),
    },
    formControl: {
        margin: theme.spacing(3),
        marginLeft: 0,
        marginBottom: theme.spacing(1) 
    },
    caretakerRow: {
        padding: theme.spacing(1),
    }
}));

const SalarySummary = () => {
    const classes = useStyles();
    const [ctType, setCtType] = useState('All Caretakers');
    const [month, setMonth] = useState(new Date().getMonth());
    let partTimerSalary = useStoreState(state => state.admin.partTimerSalary);
    let fullTimerSalary = useStoreState(state => state.admin.fullTimerSalary);
    const getPartTimerSalary = useStoreActions(actions => actions.admin.getPartTimerSalary);
    const getFullTimerSalary = useStoreActions(actions => actions.admin.getFullTimerSalary);
    const caretakerTypes = {
        all: "All Caretakers",
        parttime: "Part-time Caretakers",
        fulltime: "Full-time Caretakers"
    };
    const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"];
      

    useEffect(() => {
        getPartTimerSalary(getStartEndOfMonth(month));
        getFullTimerSalary(getStartEndOfMonth(month));
        return () => {};
    }, []);

    const handleChangeType = (event) => {
        setCtType(event.target.value);
    }

    const handleChangeMonth = async (event) => {
        setMonth(event.target.value);
    }

    const updateSalaries = async () => {
        await getPartTimerSalary(getStartEndOfMonth(month));
        await getFullTimerSalary(getStartEndOfMonth(month));
    }
    return (
        <div>
            <Grid container>
                <Grid item xs={12}>
                    <Card className={classes.salaryCard}>
                        <Typography variant='h6'>
                            Salary Summary
                        </Typography>
                        <FormControl required variant="outlined" fullWidth className={classes.formControl} >
                            <InputLabel htmlFor='select-month'>Select Caretaker Type</InputLabel>
                                <Select
                                    native
                                    value={month}
                                    label="Select Month to View"
                                    onChange={handleChangeMonth}
                                    inputProps={{
                                        name: 'month',
                                        id: 'select-month',
                                    }}
                                >
                                    {monthNames.map((month, index) => {
                                        return(
                                            <option key={month} value={parseInt(index)}>
                                                {month}
                                            </option>
                                        );
                                    })}
                                </Select>
                        </FormControl>
                        <Button variant="outlined" onClick={updateSalaries}>
                            Change Month
                        </Button>
                        <FormControl required variant="outlined" fullWidth className={classes.formControl} >
                            <InputLabel htmlFor='select-caretaker-type'>Select Caretaker Type</InputLabel>
                                <Select
                                    native
                                    value={ctType}
                                    label="Select Caretaker Type"
                                    onChange={handleChangeType}
                                    inputProps={{
                                        name: 'cttype',
                                        id: 'select-caretaker-type',
                                    }}
                                >
                                    {Object.keys(caretakerTypes).map(function(keyName, keyIndex) {
                                        return(
                                            <option key={keyName} value={caretakerTypes[keyName]}>
                                                {caretakerTypes[keyName]}
                                            </option>
                                        );
                                    })}
                                </Select>
                        </FormControl>
                        <List style={{maxHeight:300, overflow: 'auto'}}>
                            {ctType == caretakerTypes.parttime || ctType == caretakerTypes.all
                             ? 
                             partTimerSalary.map((ct) => {
                                return(
                                    <Card key={ct.ctuname} className={classes.caretakerRow}>
                                        {ct.ctuname}: ${parseFloat(ct.salary).toFixed(2)}
                                    </Card>
                                )
                            }) : null }
                            {ctType == caretakerTypes.fulltime || ctType == caretakerTypes.all
                             ? fullTimerSalary.map((ct) => {
                                return(
                                    <Card key={ct.ctuname} className={classes.caretakerRow}>
                                        {ct.ctuname}: ${parseFloat(ct.salary).toFixed(2)}
                                    </Card>
                                )
                            }) : null }
                        </List>
                    </Card>
                </Grid>
            </Grid>
        </div>
    )
}

export default SalarySummary
