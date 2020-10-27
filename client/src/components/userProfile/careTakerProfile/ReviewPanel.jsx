import React from 'react'
import Card from '@material-ui/core/Card'
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';

const ReviewPanel = () => {
    return (
        <Card style={{width: "100%"}}>
            <List style={{maxHeight:300, overflow: 'auto'}}>
                            {Array.from(Array(15).keys()).map((item) => {
                                return (<ListItem>
                                    Review #{item}
                                </ListItem>);
                            })}
                        </List>
        </Card>
    )
}

export default ReviewPanel
