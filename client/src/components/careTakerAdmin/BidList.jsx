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
    const { subheader, bids, onClick, ...other } = props;
    const classes = useStyles();

    return (
    <List className={classes.root} subheader={<li />}>
        {subheader.map((sectionId, sectionIndex) => (
        <li key={`section-${sectionId}`} className={classes.listSection}>
            <ul className={classes.ul}>
            <ListSubheader>{`${sectionId}`}</ListSubheader>
            {bids
              .filter((bid) => bid.s_time.getMonth() == sectionIndex || bid.e_time.getMonth() == sectionIndex)
              .map((bid) => (
                <ListItem 
                  button
                  key={`item-${sectionId}-${bid}`}
                  onClick={() => onClick(
                    {
                      pouname: bid.pouname,
                      petName: bid.petName,
                      petType: bid.petType,
                      ctuname: bid.ctuname,
                      s_time: bid.s_time,
                      e_time: bid.e_time
                    }
                  )}
                >
                  <ListItemText primary={`${bid.petName} (${bid.petType})`} />
                </ListItem>
            ))}
            </ul>
        </li>
        ))}
    </List>
  );
}