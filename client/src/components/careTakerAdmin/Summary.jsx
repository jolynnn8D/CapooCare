import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { getPrevMonths } from '../../utils';
import { Card, Typography } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
    summaryCard: {
        marginTop: 30,
        padding: 20
    }
}));

export const Summary = (props) => {
  const classes = useStyles();
  const startDate = getPrevMonths(1);
  const endDate = new Date(new Date().setDate(0));
  const getSingleCaretakerPettypeSummary = useStoreActions(actions => actions.careTakers.getSingleCaretakerPettypeSummary);
  const getSingleCaretakerPetownerSummary = useStoreActions(actions => actions.careTakers.getSingleCaretakerPetownerSummary);
  const singleCaretakerPettypeSummary = useStoreState(state => state.careTakers.singleCaretakerPetownerSummary);
  const singleCaretakerPetownerSummary = useStoreState(state => state.careTakers.singleCaretakerPetownerSummary);

  useEffect(() => {
    getSingleCaretakerPettypeSummary({
      ctuname: props.username,
      s_time: startDate,
      e_time: endDate
    });

    getSingleCaretakerPetownerSummary({
      ctuname: props.username,
      s_time: startDate,
      e_time: endDate
    });

    return () => {};
  }, []);

  return (
    <div>
      <Card className={classes.salaryCard}>
          <Typography variant='h6'> Summary for: {startDate.toLocaleDateString()} to {endDate.toLocaleDateString()}: ${singleCaretakerPettypeSummary}</Typography>
      </Card>
      <Card className={classes.salaryCard}>
          <Typography variant='h6'> Summary for: {startDate.toLocaleDateString()} to {endDate.toLocaleDateString()}: ${singleCaretakerPetownerSummary}</Typography>
      </Card>
    </div>
  )
}

export default Summary