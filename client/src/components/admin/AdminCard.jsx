import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Card, CardActionArea, CardActions, CardContent, CardMedia, Button, Typography } from '@material-ui/core';
import { useHistory } from 'react-router-dom';

const useStyles = makeStyles({
  root: {
    maxWidth: 345,
  },
  media: {
    height: 140,
  },
});

const AdminCard = (props) => {
    const { route, image, label, description } = props;
    const classes = useStyles();
    const history = useHistory();
    const handleClick = () => {
    history.push(route);
  }

  return (
<Card onClick={handleClick} className={classes.root}>
      <CardActionArea>
        <CardMedia
          className={classes.media}
          image={image}
          title={label}
        />
        <CardContent>
          <Typography gutterBottom variant="h5" component="h2">
            {label}
          </Typography>
          <Typography variant="body2" color="textSecondary" component="p">
            {description}
          </Typography>
        </CardContent>
      </CardActionArea>
    </Card>
  )
}

export default AdminCard
