import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActionArea from '@material-ui/core/CardActionArea';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import { useHistory } from 'react-router-dom';

const useStyles = makeStyles({
  root: {
    maxWidth: 345,
  },
  media: {
    height: 140,
  },
});

const ViewAllCaretakers = () => {
  const classes = useStyles();

  const history = useHistory();
  const handleClick = () => {
    history.push('/admin/view-caretakers');
  }

  return (
<Card onClick={handleClick} className={classes.root}>
      <CardActionArea>
        <CardMedia
          className={classes.media}
          image="https://storage.googleapis.com/petbacker/images/blog/2018/pet-care-dog-sitting-services.jpg"
          title="Contemplative Reptile"
        />
        <CardContent>
          <Typography gutterBottom variant="h5" component="h2">
            View All Caretakers
          </Typography>
          <Typography variant="body2" color="textSecondary" component="p">
            Our Caretakers are amazing with animals
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
  )
}

export default ViewAllCaretakers
