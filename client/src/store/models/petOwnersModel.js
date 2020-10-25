import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';

const petOwnersModel = {
    users: [],
    singleUser: [],
    getPetOwner: thunk(async (actions, payload) => {
        const username = payload;
        const url = serverUrl + "/api/v1/petowner/" + username;
        const {data} = await axios.get(url);
        actions.setUser(data.data); 
      }), 
      setUser: action((state, payload) => { // action
        console.log(payload);
        if (payload.user !== null ) {
            state.singleUser = payload.user;
        }
        console.log(debug(state));

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
