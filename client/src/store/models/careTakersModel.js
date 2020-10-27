import { action, thunk } from 'easy-peasy';
import axios from 'axios';
import { serverUrl } from './serverUrl';

const careTakersModel = {
    users: [],
    getCareTakers: thunk(async (actions, payload) => {
      const {data} = await axios.get("http://localhost:5000/api/v1/caretaker");
      actions.setUsers(data.data.users); 
    }),
    setUsers: action((state, payload) => {
      state.users = [...payload];
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
      });
    }),
    addFullTimeCareTaker: thunk(async (actions, payload) => {
      const {username, name, age, pettype, price} = {...payload};
      const url = serverUrl + "/api/v1/fulltimer";
      const {data} = await axios.post(url, {
          username: username,
          name: name,
          age: age,
          pettype: pettype,
          price: price
      });
    }),

  
  }

export default careTakersModel;