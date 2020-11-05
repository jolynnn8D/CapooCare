import { action, thunk, debug } from 'easy-peasy';
import { serverUrl } from "./serverUrl"
import axios from 'axios';
import {convertDate} from "../../utils"

const adminModel = {
    singleAccount: [],

    getAccount: thunk(async (actions, payload) => {
    const username = payload;
    const url = serverUrl + "/api/v1/accounts/" + username;
    const data = await axios.get(url).then(response => {
      // console.log(response);
      if (response.data.status === "success") {
        return response.data.data.account;
      } else {
        alert(`Username does not exist in the database!`);
      }
    }).catch((error) => {
      alert("Please choose a different username!");
    });

    console.log(data);
    actions.setAccount(data); 
    }), 
    setAccount: action((state, payload) => { // action
      // console.log(payload);
      if (payload !== null ) {
          state.singleAccount = payload;
      }
      // console.log(debug(state));
    }),
    addAdmin: thunk(async (actions, payload) => {
      // console.log(payload);
      const {username, adminname} = {...payload};
      const {data} = await axios.post(serverUrl + "/api/v1/pcsadmin", {
          username: username,
          adminname: adminname,
      })
    }),
}

export default adminModel;
