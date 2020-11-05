import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { Button, Card, FormControl, Grid, InputLabel, List, Select, Typography } from '@material-ui/core';
import { getStartEndOfMonth } from "../../utils";

const useStyles = makeStyles((theme) => ({
    summaryCard: {
        marginTop: 30,
        padding: 20
    },
    formControl: {
      margin: theme.spacing(3),
      marginLeft: 0,
      marginBottom: theme.spacing(1) 
    },
}));

export const Summary = (props) => {
  const classes = useStyles();
  const getSingleCaretakerPettypeSummary = useStoreActions(actions => actions.careTakers.getSingleCaretakerPettypeSummary);
  const getSingleCaretakerPetownerSummary = useStoreActions(actions => actions.careTakers.getSingleCaretakerPetownerSummary);
  const singleCaretakerPettypeSummary = useStoreState(state => state.careTakers.singleCaretakerPettypeSummary);
  const singleCaretakerPetownerSummary = useStoreState(state => state.careTakers.singleCaretakerPetownerSummary);
  const [month, setMonth] = useState(new Date().getMonth());
  const monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];

  useEffect(() => {
    getSingleCaretakerPettypeSummary({
      ctuname: props.username,
      s_time: getStartEndOfMonth(month).s_time,
      e_time: getStartEndOfMonth(month).e_time
    });

    getSingleCaretakerPetownerSummary({
      ctuname: props.username,
      s_time: getStartEndOfMonth(month).s_time,
      e_time: getStartEndOfMonth(month).e_time
    });

    return () => {};
  }, []);

  const handleChangeMonth = async (event) => {
    setMonth(event.target.value);
  }

  const getPetdaysSummary = async () => {
    await getSingleCaretakerPettypeSummary({
      ctuname: props.username,
      s_time: getStartEndOfMonth(month).s_time,
      e_time: getStartEndOfMonth(month).e_time
    });

    await getSingleCaretakerPetownerSummary({
      ctuname: props.username,
      s_time: getStartEndOfMonth(month).s_time,
      e_time: getStartEndOfMonth(month).e_time
    });
  }

  return (
    <div>
      <FormControl required variant="outlined" fullWidth className={classes.formControl} >
        <InputLabel htmlFor='select-month'>Select Month</InputLabel>
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
    <Button variant="outlined" onClick={getPetdaysSummary}>
        Change Month
    </Button>
      <Card className={classes.summaryCard}>
          <Typography variant='h6'> Pet-days by Pet Type: {getStartEndOfMonth(month).s_time.toLocaleDateString()} to {getStartEndOfMonth(month).e_time.toLocaleDateString()}: {singleCaretakerPettypeSummary.map(petday => {
            console.log(petday);
            return (<h6>Type of pet: {petday.pet_type} - Number of pet days: {petday.count}</h6>)
          })}</Typography>
      </Card>
      <Card className={classes.summaryCard}>
          <Typography variant='h6'> Pet-days by Pet Owner: {getStartEndOfMonth(month).s_time.toLocaleDateString()} to {getStartEndOfMonth(month).e_time.toLocaleDateString()}: {singleCaretakerPetownerSummary.map(petday => {
            return (<h6>Pet owner: {petday.username} - Number of pet days: {petday.count}</h6>)
          })}</Typography>
      </Card>
    </div>
  )
}

export default Summary