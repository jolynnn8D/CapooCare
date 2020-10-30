import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';

const bidModel = {
    userBids: [],

    addBid: thunk(async (actions, payload) => {
      const {pouname, petname, pettype, ctuname, s_time, e_time, pay_type, pet_pickup} = {...payload};
      const url = serverUrl + "/api/v1/bid";
      console.log({
        pouname: pouname,
        petname: petname,
        pettype: pettype,
        ctuname: ctuname,
        s_time: s_time,
        e_time: e_time
      })
      const {data} = await axios.post(url, {
        pouname: pouname,
        petname: petname,
        pettype: pettype,
        ctuname: ctuname,
        s_time: s_time,
        e_time: e_time
      });
    }),
    getUserBids: thunk(async(actions, payload) => {
        const ctuname = payload;
        const url = serverUrl + "/api/v1/bid/" + ctuname;
        console.log(url)
        const {data} = await axios.get(url);
        actions.setUserBids(data.data.bids);
    }),
    setUserBids: action((state, payload) => { // action
        console.log(payload)
        state.userBids = [...payload];
        console.log(state.userBids);
    }),
}

export default bidModel;
