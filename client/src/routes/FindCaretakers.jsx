import React, { useEffect, useState } from 'react';
import { TextField, InputAdornment, Typography, Container, Card, CardActionArea, CardMedia, CardContent, CardActions, Button, Paper, InputBase, Divider, IconButton } from '@material-ui/core';
import Search from '@material-ui/icons/Search';
import { makeStyles } from '@material-ui/core/styles';
import Rating from '@material-ui/lab/Rating';
import { Link } from 'react-router-dom';
import { useStoreActions, useStoreState } from 'easy-peasy';
import { v4 } from 'uuid';
import Filter from '../components/Filter';
import { DateRangePicker } from 'react-date-range';
import { addDays, addYears, eachDayOfInterval, toDate } from 'date-fns';


const useStyles = makeStyles((theme) => ({
    card: {
        marginTop: theme.spacing(2),
        marginBottom: theme.spacing(2)
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
}));

// const caretakersList = [
//     {
//         name: 'Caretaker 1',
//         id: '1',
//         available: true,
//         takesCareOf: [
//             'Dogs',
//             'Cats',
//             'Birds'
//         ],
//         rating: 4.5
//     },
//     {
//         name: 'Caretaker 2',
//         id: '2',
//         available: true,
//         takesCareOf: [
//             'Dogs',
//             'Cats',
//             'Birds'
//         ],
//         rating: 3.6
//     },
// ]

const FindCaretakers = () => {
    const classes = useStyles();
    const [search, setSearch] = useState("");
    const [filteredCaretakers, setFilteredCaretakers] = useState([]);
    const [sortValue, setSortValue] = useState("highest");
    const [dateRange, setDateRange] = useState([
        {
            startDate: new Date(),
            endDate: new Date(),
            key: 'selection'
        }
    ]);
    const minDate = new Date();
    const maxDate = addYears(minDate, 2);


    const getCareTakers = useStoreActions(actions => actions.careTakers.getCareTakers);
    const getPetTypeList = useStoreActions(actions => actions.careTakers.getPetTypeList);
    const getCareTakerRatings = useStoreActions(actions => actions.careTakers.getCareTakerRatings);
    const getAvailableCaretakers = useStoreActions(actions => actions.careTakers.getAvailableCaretakers);

    useEffect(() => {
        getCareTakers();
        getPetTypeList();
        getCareTakerRatings();
        return () => {};
    }, [])


    const careTakers = useStoreState(state => state.careTakers.caretakers);
    const petTypes = useStoreState(state => state.careTakers.petTypeList);
    const careTakerRatings = useStoreState(state => state.careTakers.careTakerRatings);
    const availableCaretakers = useStoreState(state => state.careTakers.availableCaretakers);

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

    // console.log([...petTypes].filter(pettype => pettype.ctuname === "yellowchicken"));
    // console.log(careTakers);

    useEffect(() => {
        setFilteredCaretakers(
            careTakers.filter(caretaker => {
                return caretaker.pettypes.toLowerCase().includes(search.toLowerCase());
            })
        )
    }, [search, careTakers])

    

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
                <DateRangePicker
                    id="form-datepicker"
                    onChange={item => {
                        setDateRange([{
                            startDate: item.selection.startDate,
                            endDate: item.selection.endDate,
                            key: 'selection'
                        }]);
                        console.log(dateRange);
                        console.log(item.selection);
                        // console.log(dateRange);
                        getAvailableCaretakers({
                            s_time: item.selection.startDate, 
                            e_time: item.selection.endDate
                        });
                        const isAvailableCaretaker = (ct) => {
                            let isFound = false;
                            availableCaretakers.forEach(function(caretaker) {
                                if (caretaker.ctuname == ct.username) {
                                    isFound = true;
                                }
                            })
                            return isFound
                        }
                        setFilteredCaretakers(
                            filteredCaretakers.filter((ct) => isAvailableCaretaker(ct))
                        )
                        console.log(filteredCaretakers);
                    }}
                    showSelectionPreview={true}
                    moveRangeOnFirstSelection={false}
                    ranges={dateRange}
                    direction="horizontal"
                    minDate = {minDate}
                    maxDate={maxDate}
                />
                {filteredCaretakers.map((caretaker) => (
                    <Card key={v4()} className={classes.card} variant="outlined" width={1}>
                        <CardActionArea component={Link} to={`/users/${caretaker.username}/caretaker`} style={{ textDecoration: 'none' }}>
                            <CardContent>
                                <Typography gutterBottom variant="h5" component="h2">
                                    {caretaker.carername}
                                </Typography>
                                <Typography variant="body2" component="p">
                                    Caretaken description such as age: {caretaker.age} and salary: {caretaker.salary} about the pets that they take care of, how much they charge and all.
                                </Typography>
                                <div className={classes.rating}>
                                    <Rating value={caretaker.rating} precision={0.5} readOnly />
                                </div>
                                {caretaker.available ? (
                                    <Button variant="outlined" color="primary">
                                        Available
                                    </Button>
                                ) : (
                                        <Button variant="outlined" disabled>
                                            Unavailable
                                        </Button>
                                    )}
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
            </Container>
        </div>
    )
}

export default FindCaretakers;