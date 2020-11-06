import { action, thunk } from 'easy-peasy';
import axios from 'axios';
import { serverUrl } from './serverUrl';
import { convertDate, sqlToJsDate, dateStringtoSqlDate } from '../../utils';
import store from "../store"

const careTakersModel = {
    caretakers: [],
    petCareList: [],
    petTypeList: [],
    availableCaretakers: [],
    userReviews: [],
    userRating: [],
    careTakerRatings: [],
    availability: [],
    singleCaretakerSalary: [],
    singleCaretakerPettypeSummary: [],
    singleCaretakerPetownerSummary: [],
    mostLucrativeCategories: [],

    getMostLucrativeCategories: thunk(async (actions, payload) => {
      const {ctuname, s_time, e_time} = {...payload};
      const url = serverUrl + "/api/v1/caretaker/summary/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time) + "/lucrative";
      const {data} = await axios.get(url);

      actions.setMostLucrativeCategories(data.data.categories);
    }),
    
    setMostLucrativeCategories: action((state, payload) => {
      state.mostLucrativeCategories = payload;
    }),

    getSingleCaretakerPetownerSummary: thunk(async (actions, payload) => {
      const {ctuname, s_time, e_time} = {...payload};
      // console.log(payload);
      const url = serverUrl + "/api/v1/caretaker/summary/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time) + '/petowner';
      const {data} = await axios.get(url);
      // console.log(data);
      actions.setSingleCaretakerPetownerSummary(data.data.petdays);
    }),

    setSingleCaretakerPetownerSummary: action((state, payload) => {
      state.singleCaretakerPetownerSummary = payload;
    }),

    getSingleCaretakerPettypeSummary: thunk(async (actions, payload) => {
      const {ctuname, s_time, e_time} = {...payload};
      // console.log(payload);
      const url = serverUrl + "/api/v1/caretaker/summary/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time) + '/pettype';
      const {data} = await axios.get(url);
      // console.log(data);
      actions.setSingleCaretakerPettypeSummary(data.data.petdays);
    }),

    setSingleCaretakerPettypeSummary: action((state, payload) => {
      state.singleCaretakerPettypeSummary = payload;
    }),

    getSingleCaretakerSalary: thunk(async (actions, payload) => {
      const { ctuname, s_time, e_time } ={ ...payload };
      // console.log(payload)
      const url = serverUrl + "/api/v1/admin/salary/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time);
      // console.log(url)
      const {data} = await axios.get(url);
      actions.setSingleCaretakerSalary(data.data); 
    }), 

    setSingleCaretakerSalary: action((state, payload) => { // action
      if (payload.salary !== null ) {
          state.singleCaretakerSalary = payload.salary;
      }
    }),
  
    getCareTakers: thunk(async (actions, payload) => {
      const {data} = await axios.get(serverUrl + "/api/v1/caretaker");
      actions.setUsers(data.data.users); 
    }),

    setUsers: action((state, payload) => {
      state.caretakers = [...payload];
    }),
    addPartTimeCareTaker: thunk(async (actions, payload) => {
      const {username, name, age, pettype, price} = {...payload};
      const url = serverUrl + "/api/v1/parttimer";
      const {data} = await axios.post(url, {
          username: username,
          name: name,
          age: age,
          pettype: pettype,
          price: price
      })

      return data.status;
      
    }),
    addFullTimeCareTaker: thunk(async (actions, payload) => {
      const {username, name, age, pettype, price, period1_s, period1_e, period2_s, period2_e} = {...payload};
      const url = serverUrl + "/api/v1/fulltimer";
      console.log({
        username: username,
        name: name, 
        age: age,
        pettype: pettype,
        price: price,
        period1_s: period1_s,
        period1_e: period1_e,
        period2_s: period2_s,
        period2_e: period2_e
      })
      const data = await axios.post(url, {
          username: username,
          name: name, 
          age: age,
          pettype: pettype,
          price: price,
          period1_s: period1_s,
          period1_e: period1_e,
          period2_s: period2_s,
          period2_e: period2_e
      }).then((res) => {
          actions.addAvailability({
            ctuname: username,
            s_time: dateStringtoSqlDate(period1_s),
            e_time: dateStringtoSqlDate(period1_e)
          });
          actions.addAvailability({
            ctuname: username,
            s_time: dateStringtoSqlDate(period2_s),
            e_time: dateStringtoSqlDate(period2_e)
          })
      }).then((err) => {
        console.log(err);
      })
    }),
    getPetCareList: thunk(async(actions, payload) => {
      const username = payload;
      const url = serverUrl + "/api/v1/categories/" + username;
      const {data} = await axios.get(url);
      actions.setPetCareList(data.data.pets);
    }), 
    setPetCareList: action((state, payload) => {
      state.petCareList = [...payload];
    }),
    addPetCareItem: thunk(async(actions, payload) => {
      const {username, pettype, price} = payload;
      const url = serverUrl + "/api/v1/categories/" + username;
      const {data} = await axios.post(url, {
          pettype: pettype,
          price: price
      });
      actions.addPetCareList(data.data.pets);
    }), 
    addPetCareList: action((state, payload) => {
      state.petCareList.push(payload);
    }),

    getPetTypeList: thunk(async(actions, payload) => {
      const url = serverUrl + "/api/v1/pettype";
      const {data} = await axios.get(url);
      console.log(data);
      actions.setPetTypeList(data.data.pettypes);
    }),
    setPetTypeList: action((state, payload) => {
      state.petTypeList = [...payload];
    }),

    deletePetType: thunk(async(actions, payload) => {
      const {username, pettype } = payload;
      const url = serverUrl + "/api/v1/categories/" + username + "/" + pettype;
      const {data} = await axios.delete(url);
      actions.deleteUserPetType(payload.pettype);
    }),
    deleteUserPetType: action((state, payload) => {
        var index = null;
        state.petCareList.forEach(function(value, i) {
          console.log(value.pettype)
            if (value.pettype === payload) {

                index = i;
            }
        })
        state.petCareList.splice(index, 1);
        
    }),

    getUserAvailability: thunk(async(actions, payload) => {
      const { ctuname, s_time, e_time } = payload;
      const url = serverUrl + "/api/v1/availability/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time);
      console.log(url);

      const { data } = await axios.get(url);
      // console.log(data)
      actions.setUserAvailability(data.data.availabilities)
    }),
    setUserAvailability: action((state, payload) => {
      state.availability = [...payload];
    }),

    addUserAvailability: thunk(async(actions, payload) => {
      const { ctuname, s_time, e_time } = payload;
      const url = serverUrl + "/api/v1/availability/" + ctuname;
      console.log(url);

      const { data } = await axios.post(url, {
        s_time: s_time,
        e_time: e_time
      });
      // console.log(data)
      actions.addAvailability(data.data.availability)
    }),
    addAvailability: action((state, payload) => {
      state.availability.push(payload);
    }),
    getAvailableCaretakers: thunk(async(actions, payload) => {
      console.log(payload);
      const {s_time, e_time} = payload;
      const url = serverUrl + "/api/v1/availability/" + convertDate(s_time) + "/" + convertDate(e_time);
      const {data} = await axios.get(url);
      actions.setAvailableCaretakers(data.data.availabilities);
    }),
      setAvailableCaretakers: action((state, payload) => {
        state.availableCaretakers = payload;
      }),
    deleteUserAvailability: thunk(async(actions, payload) => {
      const { ctuname, s_time, e_time } = payload;
      const url = serverUrl + "/api/v1/availability/" + ctuname + "/" + convertDate(sqlToJsDate(s_time)) + "/" + convertDate(sqlToJsDate(e_time))
      console.log(url);
      console.log({
        s_time: convertDate(sqlToJsDate(s_time)),
        e_time: convertDate(sqlToJsDate(e_time))
      });
      const { data } = await axios.delete(url);
      console.log(data)
      actions.deleteAvailability(payload)
    }),
    deleteAvailability: action((state, payload) => {
      let index = null;
      state.availability.forEach(function(avail, i) {
        if (payload.s_time === avail.s_time &&
            payload.e_time === avail.e_time) {
              index = i;
            }
      })
      state.availability.splice(index, 1);
    }),
    getUserReviews: thunk(async(actions, payload) => {
        const ctuname = payload;
        const url = serverUrl + "/api/v1/review/" + ctuname;
        const { data } = await axios.get(url);
        actions.setUserReviews(data.data.reviews);
    }),
    setUserReviews: action((state, payload) => {
      state.userReviews = [...payload];
    }),
    getRating: thunk(async(actions, payload) => {
        const ctuname = payload;
        const url = serverUrl + "/api/v1/rating/" + ctuname;
        const { data } = await axios.get(url);
        actions.setUserRating(data.data.rating);
    }),
    setUserRating: action((state, payload) => {
      state.userRating = payload;
    }),

    getCareTakerRatings: thunk(async(actions, payload) => {
      const url = serverUrl + "/api/v1/rating";
      const {data} = await axios.get(url);
      actions.setCareTakerRatings(data.data.rating);
    }),
    setCareTakerRatings: action((state, payload) => {
      state.careTakerRatings = payload;
    }),
    getCaretakersForAllPets: thunk(async(actions, payload) => {
      const { username, s_time, e_time } = payload;
      const url = serverUrl + "/api/v1/petowner/" + username + "/all_ct/" + convertDate(s_time) + "/" + convertDate(e_time)
      const { data } = await axios.get(url);
      actions.setAvailableCaretakers(data.data.caretakers);
    })



  }

export default careTakersModel;