import React, { useEffect } from 'react'
import Card from '@material-ui/core/Card'
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { v4 } from 'uuid';
import { ListItemSecondaryAction, ListItemText } from '@material-ui/core';



const ReviewPanel = (props) => {
    const getUserReviews = useStoreActions(actions => actions.careTakers.getUserReviews);
    const userReviews = useStoreState(state => state.careTakers.userReviews);
    useEffect(() => {
        getUserReviews(props.username);
        return () => {};
    }, [])
    return (
        <Card style={{width: "100%"}}>
            <List style={{maxHeight:300, overflow: 'auto'}}>
                            {userReviews.map((item) => {
                                return (<ListItem key={v4()}>
                                    <ListItemText
                                    primary = {`${item.pouname}: ${item.review}`}/>
                                    <ListItemSecondaryAction>
                                        <ListItemText
                                        primary={`Rating: ${item.rating}/5`}/>
                                    </ListItemSecondaryAction>
                                </ListItem>);
                            })}
            </List>
        </Card>
    )
}

export default ReviewPanel
