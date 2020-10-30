import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';

const userModel = {
    singleUser: [],
    getUser: thunk(async (actions, payload) => {
        const username = payload;
        const url = serverUrl + "/api/v1/users/" + username;
        const data = await axios.get(url).then(response => {
          // console.log(response);
          if (response.data.status === "success") {
            return response.data.data.user;
          } else {
            alert(`Username does not exist in the database!`);
          }
        }).catch((error) => {
          alert("Please choose a different username!");
        });

        // console.log(data);
        actions.setUser(data); 
      }), 
      setUser: action((state, payload) => { // action
        // console.log(payload);
        if (payload !== null ) {
            state.singleUser = payload;
        }
        // console.log(debug(state));
      }),
    editUser: thunk(async (actions, payload) => {
      const {username, firstname, age, usertype} = {...payload};
      let url = "";
      if (usertype === 'petowner') {
        url = serverUrl + '/api/v1/petowner/' + username;
        const {data} = await axios.put(url, {
          username: username,
          ownername: firstname,
          age: age
        });

        actions.getUser(username);
        actions.getDisplayedUser(username);
        // console.log(editedUser);
        // actions.setUser(editedUser);
        // actions.setDisplayedUser(editedUser);
      }

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
}

export default userModel;
