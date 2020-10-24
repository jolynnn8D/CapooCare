import { action, thunk } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';

const petOwnersModel = {
    users: [],
    singleUser: [],
    getPetOwner: thunk(async (actions, payload) => {
        const username = payload;
        const url = serverUrl + "/api/v1/petowner/" + username;
        const {data} = await axios.get(url);
        actions.setUser(data.data.user); 
      }), 
      setUser: action((state, payload) => { // action
        state.singleUser = payload;
      }),

    addPetOwner: thunk(async (actions, payload) => {
        console.log(payload);
        const {username, ownername, age, pettype, petname, petage, requirements} = {...payload};
        const {data} = await axios.post("http://localhost:5000/api/v1/petowner", {
            username: username,
            ownername: ownername,
            age: age,
            pettype: pettype,
            petname: petname,
            petage: petage,
            requirements: requirements
        });
      }),
}

export default petOwnersModel;
