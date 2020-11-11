import React, { useEffect, useState } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';
import { makeStyles } from '@material-ui/core/styles';
import { getStartEndOfMonth } from "../../utils";
import SalarySummary from "./SalarySummary"

const useStyles = makeStyles((theme) => ({
    root: {
        marginTop: theme.spacing(13)
    }
}));

const Summary = () => {
    const classes = useStyles();

    return (
        <div className={classes.root}>
            <SalarySummary/>
        </div>
    )
}

export default Summary
