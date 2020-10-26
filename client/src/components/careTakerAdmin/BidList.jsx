import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListSubheader from '@material-ui/core/ListSubheader';

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    maxWidth: 360,
    backgroundColor: theme.palette.background.paper,
    position: 'relative',
    overflow: 'auto',
    maxHeight: 400
  },
  listSection: {
    backgroundColor: 'inherit',
  },
  ul: {
    backgroundColor: 'inherit',
    padding: 0,
  },
}));

export default function BidList(props) {
    const { subheader, bids, ...other } = props;
    const classes = useStyles();

    return (
    <List className={classes.root} subheader={<li />}>
        {props.subheader.map((sectionId) => (
        <li key={`section-${sectionId}`} className={classes.listSection}>
            <ul className={classes.ul}>
            <ListSubheader>{`${sectionId}`}</ListSubheader>
            {[0, 1, 2].map((item) => (
                <ListItem button key={`item-${sectionId}-${item}`}>
                <ListItemText primary={`Bid ${item}`} />
                </ListItem>
            ))}
            </ul>
        </li>
        ))}
    </List>
  );
}