import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { getPrevMonths } from '../../utils';
import { Card, Typography } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
    salaryCard: {
        marginTop: 30,
        padding: 20
    }
}));

const Salary = (props) => {
    const classes = useStyles();
    const getSalary = useStoreActions(actions => actions.careTakers.getSingleCaretakerSalary);
    const userSalary = useStoreState(state => state.careTakers.singleCaretakerSalary);
    const startDate = getPrevMonths(1);
    const endDate = new Date(new Date().setDate(0));
    useEffect(() => {
        getSalary({
            ctuname: props.username,
            s_time: startDate,
            e_time: endDate, 
        });
        return () => {};
    }, []);
    return (
        <Card className={classes.salaryCard}>
            <Typography variant='h6'> Salary for {startDate.toLocaleDateString()} to {endDate.toLocaleDateString()}: ${userSalary}</Typography>
        </Card>
    )
}

export default Salary
