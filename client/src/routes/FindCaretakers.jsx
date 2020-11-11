import React, { useEffect, useState } from 'react';
import { TextField, InputAdornment, Typography, Container, Card, CardActionArea, CardMedia, CardContent, CardActions, Button, Paper, InputBase, Divider, IconButton, Modal, Grid, List } from '@material-ui/core';
import Search from '@material-ui/icons/Search';
import { makeStyles } from '@material-ui/core/styles';
import Rating from '@material-ui/lab/Rating';
import { Link } from 'react-router-dom';
import { thunk, useStoreActions, useStoreState } from 'easy-peasy';
import { v4 } from 'uuid';
import Filter from '../components/Filter';
import { DateRangePicker } from 'react-date-range';
import store from "../store/store"
import { addDays, addYears, eachDayOfInterval, toDate } from 'date-fns';
import { useHistory } from 'react-router-dom';
import { FixedSizeList } from 'react-window';



const useStyles = makeStyles((theme) => ({
    card: {
        marginTop: theme.spacing(2),
        marginBottom: theme.spacing(2),
        width: "100%",
    },
    media: {
        height: 140,
    },
    container: {
        marginTop: theme.spacing(8),
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
    },
    rating: {
        display: 'flex',
        flexDirection: 'column',
        '& > * + *': {
            marginTop: theme.spacing(1),
        },
    },
    root: {
        padding: '2px 4px',
        display: 'flex',
        alignItems: 'center',
        width: 400,
    },
    input: {
        marginLeft: theme.spacing(1),
        flex: 1,
    },
    iconButton: {
        padding: 10,
    },
    divider: {
        height: 28,
        margin: 4,
    },
    searchbar: {
        margin: theme.spacing(1),
    },
    modal: {
        width: "40%",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        position: 'absolute',
        backgroundColor: theme.palette.background.paper,
        border: '2px solid #000',
        boxShadow: theme.shadows[5],
        padding: theme.spacing(2, 4, 3),
    },
    button: {
        margin: theme.spacing(1)
    },
    gridList: {
        width: "100%",
        height: 450
    },
}));

const FindCaretakers = () => {
    const classes = useStyles();
    const history = useHistory();
    const [search, setSearch] = useState("");
    const [availModal, setAvailModal] = useState(false);
    const [filteredCaretakers, setFilteredCaretakers] = useState([]);
    const [sortValue, setSortValue] = useState("highest");
    const [dateRange, setDateRange] = useState([
        {
            startDate: new Date(),
            endDate: new Date(),
            key: "selection"
        }
    ]);
    const minDate = new Date();
    const maxDate = addYears(minDate, 2);


    const getCareTakers = useStoreActions(actions => actions.careTakers.getCareTakers);
    const getPetTypeList = useStoreActions(actions => actions.careTakers.getPetTypeList);
    const getCareTakerRatings = useStoreActions(actions => actions.careTakers.getCareTakerRatings);
    const getAvailableCaretakers = useStoreActions(actions => actions.careTakers.getAvailableCaretakers);
    const getCaretakersForAllPets = useStoreActions(actions => actions.careTakers.getCaretakersForAllPets);
    
    useEffect(() => {
        getCareTakers();
        getPetTypeList();
        getCareTakerRatings();
        return () => {};
    }, []);


    const careTakers = useStoreState(state => state.careTakers.caretakers);
    const petTypes = useStoreState(state => state.careTakers.petTypeList);
    const careTakerRatings = useStoreState(state => state.careTakers.careTakerRatings);
    const singleUser = useStoreState(state => state.user.singleUser);

    careTakers.map(caretaker => caretaker.pettypes = [...petTypes].filter(pettype => pettype.ctuname === caretaker.username));
    careTakers.map(caretaker => caretaker.pettypes = caretaker.pettypes.map(pettype => pettype.pettype).join(", "))
    careTakers.map(caretaker => caretaker.rating = [...careTakerRatings].filter(rating => rating.ctuname === caretaker.username));
    careTakers.map(caretaker => {
        if (caretaker.rating.length === 0) {
            caretaker.rating = null;
        } else {
            caretaker.rating = caretaker.rating[0].avg_rating;
        }
    })

    useEffect(() => {
        setFilteredCaretakers(
            careTakers.filter(caretaker => {
                return caretaker.pettypes.toLowerCase().includes(search.toLowerCase());
            })
        )
    }, [search, careTakers])

    const handleSearchChange = () => {
        setFilteredCaretakers(
            careTakers.filter(caretaker => {
                return caretaker.pettypes.toLowerCase().includes(search.toLowerCase());
            })
        )
        console.log(filteredCaretakers)
    }

    const sortCareTakers = (event) => {
        setSortValue(event.target.value);
        setFilteredCaretakers(
            filteredCaretakers.sort((a,b) => (
                sortValue === 'lowest' ? 
                ((a.rating < b.rating) ? 1: -1) :
                sortValue === 'highest' ?
                ((a.rating > b.rating) ? 1: -1) :
                a.age > b.age ? 1: -1
            ))
        )
        // console.log(event.target.value);
    }

    const openAvailModal = () => {
        setAvailModal(true);
    }
    
    const closeAvailModal = () => {
        setAvailModal(false);
    }

    const handleSubmit = async () => {
        await getAvailableCaretakers({
            s_time: dateRange[0].startDate, 
            e_time: dateRange[0].endDate
        });
        const availCaretakers = store.getState().careTakers.availableCaretakers;
        const availableCTUsernames = availCaretakers.map(caretaker => caretaker.ctuname);
        // console.log(availableCTUsernames);
        console.log(dateRange);
        setFilteredCaretakers(careTakers);
        setFilteredCaretakers(
            careTakers.filter(caretaker => availableCTUsernames.includes(caretaker.username))
        );
        setAvailModal(false);
    }

    const handleGetForAllPets = async () => {
        await getCaretakersForAllPets({
            username: singleUser.username,
            s_time: dateRange[0].startDate,
            e_time: dateRange[0].endDate});
        const availCaretakers = store.getState().careTakers.availableCaretakers;
        const availableCTUsernames = availCaretakers.map(caretaker => caretaker.ctuname);
        // console.log(availableCTUsernames);
        setFilteredCaretakers(careTakers);
        setFilteredCaretakers(
            careTakers.filter(caretaker => availableCTUsernames.includes(caretaker.username))
        );
        setAvailModal(false);

    }

    const viewCaretakerProfile = (username) => {
        history.push(`/users/${username}/caretaker`)
    }
    const renderRow = ({index, style}) => {
        const caretaker = filteredCaretakers[index];
        return (
            <Card key={v4()} className={classes.card} variant="outlined" style={style}>
                {/* <CardActionArea component={Link} to={`/users/${caretaker.username}/caretaker`} style={{ textDecoration: 'none' }}> */}
                <CardActionArea onClick={() => viewCaretakerProfile(caretaker.username)}>
                    <CardContent>
                        <Typography gutterBottom variant="h5" component="h2">
                            {caretaker.username + ` (${caretaker.carername})`}
                        </Typography>
                        <Typography variant="body2" component="p">
                            Caretaker age: {caretaker.age}
                        </Typography>
                        <div className={classes.rating}>
                            <Rating value={caretaker.rating} precision={0.5} readOnly />
                        </div>
                        <Typography variant="body2" component="p">
                            Takes care of: {caretaker.pettypes}
                            {/* Takes care of: {caretaker.pettypes.map(pettype => pettype.pettype).join(", ")} */}
                        </Typography>
                        <Button size="small" color="primary">
                            Learn More
                        </Button>
                    </CardContent>
                </CardActionArea>
            </Card>
        );
      }
    
    return (
        <div>
            <Container component="main" maxWidth="md" className={classes.container}>
                <Typography component="h1" variant="h3" color="textPrimary" align="left">
                    Caretakers
                </Typography>
                <TextField
                    onChange={(event) => setSearch(event.target.value)}
                    className={classes.margin}
                    label="Search pet type"
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <Search />
                            </InputAdornment>
                        ),
                    }}
                    variant="outlined"
                    fullWidth
                />
                <Filter count={filteredCaretakers.length}
                        sortValue={sortValue}
                        sortCareTakers={sortCareTakers} />
                <Button className={classes.button}
                    variant='outlined'
                    onClick={openAvailModal}>
                    Click to filter caretaker by availability
                </Button>
                {/* <GridList className={classes.gridList}> */}
                {filteredCaretakers.map((caretaker) => (
                    <Card key={v4()} className={classes.card} variant="outlined">
                        <CardActionArea component={Link} to={`/users/${caretaker.username}/caretaker`} style={{ textDecoration: 'none' }}>
                            <CardContent>
                                <Typography gutterBottom variant="h5" component="h2">
                                    {caretaker.username + ` (${caretaker.carername})`}
                                </Typography>
                                <Typography variant="body2" component="p">
                                    Caretaker age: {caretaker.age}
                                </Typography>
                                <div className={classes.rating}>
                                    <Rating value={caretaker.rating} precision={0.5} readOnly />
                                </div>
                                <Typography variant="body2" component="p">
                                    Takes care of: {caretaker.pettypes}
                                    {/* Takes care of: {caretaker.pettypes.map(pettype => pettype.pettype).join(", ")} */}
                                </Typography>
                                <Button size="small" color="primary">
                                    Learn More
                                </Button>
                            </CardContent>
                        </CardActionArea>
                    </Card>
                ))}
                {/* </GridList> */}
                <FixedSizeList height={560} width={300} itemSize={180} itemCount={filteredCaretakers.length} style={{overflow: 'auto', width: "100%"}}> 
                    {renderRow}
                </FixedSizeList>
            </Container>
            <Modal
                open={availModal}
                onClose={closeAvailModal}>
                <Card className = {classes.modal}>
                    <Grid item xs={12}>
                    <DateRangePicker
                        id="form-datepicker"
                        onChange={item => {
                            console.log(item);
                            setDateRange([{
                                startDate: item.selection.startDate,
                                endDate: item.selection.endDate,
                                key: item.selection.key
                            }]);
                            // console.log(item.selection);
                            // console.log(dateRange);
                            // console.log(filteredCaretakers);
                        }}
                        showSelectionPreview={true}
                        moveRangeOnFirstSelection={false}
                        ranges={dateRange}
                        direction="horizontal"
                        minDate = {minDate}
                        maxDate={maxDate}
                    />
                    </Grid>
                    <Button className={classes.button}
                        variant="outlined"
                        fullWidth
                        color="primary"
                        onClick={() => handleSubmit()}>
                        Look for Caretakers in this timeframe!
                    </Button>
                    <Button className={classes.button}
                        variant="outlined"
                        fullWidth
                        onClick={handleGetForAllPets}>
                        Going for vacation? Look for caretakers that can care for all your pets in this frame!
                    </Button>
                </Card>
            </Modal>
        </div>
    )
}

export default FindCaretakers;