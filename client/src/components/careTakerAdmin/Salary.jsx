/* THIS FILE IS NOT BEING USED */ 

import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { getPrevMonths, getStartEndOfMonth } from '../../utils';
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
    const dateRange = getStartEndOfMonth(props.month);
    
    useEffect(() => {
        getSalary({
            ctuname: props.username,
            s_time: dateRange.s_time,
            e_time: dateRange.e_time, 
        });
        return () => {};
    }, []);
    return (
        <Card className={classes.salaryCard}>
            <Typography variant='h6'> Salary: ${parseFloat(userSalary).toFixed(2)}</Typography>
        </Card>
    )
}

export default Salary
