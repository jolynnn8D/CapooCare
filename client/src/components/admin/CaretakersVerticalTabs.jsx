import React, {useEffect, useState} from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import {Box, Tab, Tabs, Typography} from '@material-ui/core';
import { useStoreActions, useStoreState } from 'easy-peasy';
import UserCard from "../userProfile/UserCard"
import PetCareList from "../careTakerAdmin/PetCareList"
import Salary from '../careTakerAdmin/Salary';
import Summary from '../careTakerAdmin/Summary';


function TabPanel(props) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`vertical-tabpanel-${index}`}
      aria-labelledby={`vertical-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box p={3}>
          <Typography>{children}</Typography>
        </Box>
      )}
    </div>
  );
}

TabPanel.propTypes = {
  children: PropTypes.node,
  index: PropTypes.any.isRequired,
  value: PropTypes.any.isRequired,
};

function a11yProps(index) {
  return {
    id: `vertical-tab-${index}`,
    'aria-controls': `vertical-tabpanel-${index}`,
  };
}

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    backgroundColor: theme.palette.background.paper,
    display: 'flex',
  },
  tabs: {
    borderRight: `1px solid ${theme.palette.divider}`,
  },
}));

export default function CaretakersVerticalTabs() {
  const classes = useStyles();
  const [value, setValue] = React.useState(0);
  const [month, setMonth] = useState(new Date().getMonth());
  const caretakers = useStoreState(state => state.careTakers.caretakers);
  const getCareTakers = useStoreActions(actions => actions.careTakers.getCareTakers);
  let index = 0;
  let tabIndex = 0;

  const handleChange = (event, newValue) => {
    setValue(newValue);
  }; 

  useEffect(() => {
    getCareTakers();
    return () => {};
  }, [])
  
  return (
    <div className={classes.root}>
      <Tabs
        orientation="vertical"
        variant="scrollable"
        value={value}
        onChange={handleChange}
        aria-label="Vertical tabs example"
        className={classes.tabs}
      >
      {caretakers.map((caretaker) => {
        return (
          <Tab key={caretaker.username} label={caretaker.username} {...a11yProps(index++)}/>
        );
      })}
      </Tabs>
      {caretakers.map((caretaker) => {
        return(
          <TabPanel key={caretaker.username} value={value} index={tabIndex++}>
                <UserCard display={'caretaker'} username={caretaker.username}/>
                <PetCareList userType="admin" username={caretaker.username}/>
                {/* <Salary username={caretaker.username}/> */}
                <Summary username={caretaker.username}/>
                
          </TabPanel>
        )
      })}
    </div>
  );
}