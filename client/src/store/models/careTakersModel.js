import { action, thunk } from 'easy-peasy';
import axios from 'axios';

const careTakersModel = {
    caretakers: [],
    getCareTakers: thunk(async (actions, payload) => {
      const {data} = await axios.get("http://localhost:5000/api/v1/caretaker");
      actions.setUsers(data.data.users); 
    }),
    setUsers: action((state, payload) => {
      state.caretakers = [...payload];
    }),

    addCareTaker: thunk(async (actions, payload) => {
        const {username, carername, age, pettypes} = {...payload};
        const {data} = await axios.post("http://localhost:5000/api/v1/caretaker", {
            username: username,
            carername: carername,
            age: age,
            pettypes: pettypes
        });
        actions.addUsers(data); 
      }),
      addUsers: action((state, payload) => {
        state.users.push(payload);
      })
  
  
  }

export default careTakersModel;