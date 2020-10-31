import { action, thunk } from 'easy-peasy';
import axios from 'axios';
import { serverUrl } from './serverUrl';
import { convertDate } from '../../utils';

const careTakersModel = {
    caretakers: [],
    petCareList: [],
    petTypeList: [],
    availability: [],

    getCareTakers: thunk(async (actions, payload) => {
      const {data} = await axios.get("http://localhost:5000/api/v1/caretaker");
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
      const {data} = await axios.post(url, {
          username: username,
          name: name,
          age: age,
          pettype: pettype,
          price: price,
          period1_s: period1_s,
          period1_e: period1_e,
          period2_s: period2_s,
          period2_e: period2_e
      });
      
      return data.status;
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
            if (value.pettype == payload) {

                index = i;
            }
        })
        state.petCareList.splice(index, 1);
        
    }),

    getUserAvailability: thunk(async(actions, payload) => {
      const {ctuname, s_time, e_time } = {...payload}
      const url = serverUrl + "/api/v1/availability/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time);
      console.log(url);

      const { data } = await axios.get(url);
      console.log(data)
      actions.setUserAvailability(data.data.availabilities)
    }),
    setUserAvailability: action((state, payload) => {
      state.availability = [...payload];
    })

  
  }

export default careTakersModel;