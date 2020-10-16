import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActionArea from '@material-ui/core/CardActionArea';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import { useHistory } from "react-router-dom";

const useStyles = makeStyles({
  root: {
    maxWidth: 345,
  },
  media: {
    height: 140,
  },
});

const PriceList = () => {
  const classes = useStyles();

  let history = useHistory();
  const handleClick = (e) => {
    history.push("/admin/set-price");
  }
  return (
    <Card onClick={handleClick} className={classes.root}>
      <CardActionArea>
        <CardMedia
          className={classes.media}
          image="https://mrpetapp.com/wp-content/uploads/2016/11/pets_big.png"
          title="Contemplative Reptile"
        />
        <CardContent>
          <Typography gutterBottom variant="h5" component="h2">
            Set Pet Prices
          </Typography>
          <Typography variant="body2" color="textSecondary" component="p">
            Set Each Pet Price Here
          </Typography>
        </CardContent>
      </CardActionArea>
      <CardActions>
        <Button size="small" color="primary">
          Share
        </Button>
        <Button size="small" color="primary">
          Learn More
        </Button>
      </CardActions>
    </Card>
  );
}

export default PriceList
