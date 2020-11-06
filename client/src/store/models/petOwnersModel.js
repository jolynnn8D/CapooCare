import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';
import store from "../store"

const petOwnersModel = {
    singlePetOwner: null,
    getPetOwner: thunk(async (actions, payload) => {
        const username = payload;
        const url = serverUrl + "/api/v1/petowner/" + username;
        const {data} = await axios.get(url);
        actions.setPetOwner(data.data); 
        return data.status;
      }), 
      setPetOwner: action((state, payload) => { // action
        console.log(payload);
        if (payload.user !== null ) {
            state.singlePetOwner = payload.user;
        }
        console.log(debug(state));

      }),

    addPetOwner: thunk(async (actions, payload) => {
        const {username, ownername, age, pettype, petname, petage, requirements} = {...payload};
        const data = await axios.post(serverUrl + "/api/v1/petowner", {
            username: username,
            ownername: ownername,
            age: age,
            pettype: pettype,
            petname: petname,
            petage: petage,
            requirements: requirements
        }).then((res) => {
          store.getActions().pets.addAPet({
            pouname: ownername,
            pettype: pettype,
            petname: petname,
            petage: petage,
            requirements: requirements
          })
        }).catch((err) => {
          console.log(err);
        })
      }),

}

export default petOwnersModel;
