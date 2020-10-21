import React from 'react'
import Avatar from '@material-ui/core/Avatar'
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles({
    profile: {
        width: 130,
        height: 130,
        margin: "0px 30px 0 0",
        background: "white"
    },
    media: {
        height: '100%',
        width: '100%'
    }
});

const ProfilePic = (props) => {
    const classes = useStyles();
    return (
        <div>
            <Avatar className={classes.profile}>
                <a href={props.href}>
                    <img className={classes.media} src={props.img}/>
                </a>
            </Avatar>
        </div>
    )
}

export default ProfilePic
