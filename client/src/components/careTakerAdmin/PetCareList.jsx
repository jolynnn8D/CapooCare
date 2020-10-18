import React from 'react'
import { makeStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemAvatar from '@material-ui/core/ListItemAvatar';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Avatar from '@material-ui/core/Avatar';
import IconButton from '@material-ui/core/IconButton';
import AddIcon from '@material-ui/icons/Add';
import PetsIcon from '@material-ui/icons/Pets';
import DeleteIcon from '@material-ui/icons/Delete';

const PetCareList = (props) => {
    return (
        <div>
            <List>
                <ListItem>
                <ListItemAvatar>
                    <Avatar>
                      <PetsIcon />
                    </Avatar>
                </ListItemAvatar>
                <ListItemText
                    primary="Corgi"
                />
                <ListItemText
                    primary="$50/day"
                />
                {props.owner ? 
                <ListItemSecondaryAction>
                    <IconButton edge="end" aria-label="delete">
                      <DeleteIcon />
                    </IconButton>
                </ListItemSecondaryAction> : null } 
                </ListItem>
                {props.owner ?
                <ListItem button>
                    <ListItemAvatar>
                        <Avatar>
                            <AddIcon/>
                        </Avatar>
                    </ListItemAvatar>
                    <ListItemText
                        primary="Click to add new pet"
                    />
                </ListItem> : null }
                {!props.owner ? 
                <ListItemSecondaryAction>
                    <IconButton>
                        <ListItemText  
                            primary="Bid"/>
                    </IconButton>
                </ListItemSecondaryAction> : null } 
            </List>
        </div>
    )
}

export default PetCareList
