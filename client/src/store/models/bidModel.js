import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';

const bidModel = {
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
}

export default bidModel;
