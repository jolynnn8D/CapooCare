import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';

const userModel = {
    singleUser: [],
    getUser: thunk(async (actions, payload) => {
        const username = payload;
        const url = serverUrl + "/api/v1/users/" + username;
        const {data} = await axios.get(url);
        actions.setUser(data.data); 
      }), 
      setUser: action((state, payload) => { // action
        // console.log(payload);
        if (payload.user !== null ) {
            state.singleUser = payload.user;
        }
        // console.log(debug(state));

      }),

    displayedUser: [],
    getDisplayedUser: thunk(async (actions, payload) => {
      const username = payload;
      const url = serverUrl + "/api/v1/users/" + username;
      const {data} = await axios.get(url);
      actions.setDisplayedUser(data.data); 
    }), 
      setDisplayedUser: action((state, payload) => { // action
        if (payload.user !== null ) {
            state.displayedUser = payload.user;
        }
        // console.log(debug(state));

      }),
    allUsers: [],
    getAllUsers: thunk(async (actions, payload) => {
      const url = serverUrl + "/api/v1/users"
      const {data} = await axios.get(url);
      actions.setAllUsers(data.data);
    }),
    setAllUsers: action((state, payload) => {
      if(payload.users !== null) {
        state.allUsers = payload.users;
      }
    })

}

export default userModel;
