import React from 'react'
import PriceList from '../components/admin/PriceList';
import ViewAllCaretakers from '../components/admin/ViewAllCaretakers';
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    marginTop: 150,
    marginLeft: 100
  },
  component: {
    padding: theme.spacing(2),
    textAlign: 'center',
    color: theme.palette.text.secondary,
  },
}));

const Adminpage = () => {
  const classes = useStyles();

  return (
    <div className={classes.root}>
      <Grid container spacing={3}>
        <Grid item xs={6}>
          <ViewAllCaretakers className={classes.component}/>
        </Grid>
        <Grid item xs={6}>
          <PriceList className={classes.component}/>
        </Grid>
      </Grid>
    </div>
  );
}

export default Adminpage
