import React from 'react'
import Card from '@material-ui/core/Card';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';

const OrderList = (props) => {
    return (
        <Card style={{width: "100%"}}>
            <List style={{maxHeight:500, overflow: 'auto'}}>
                            {Array.from(Array(15).keys()).map((item) => {
                                return (<ListItem>
                                    Past {props.type} #{item}
                                </ListItem>);
                            })}
                        </List>
        </Card>
    )
}

export default OrderList
