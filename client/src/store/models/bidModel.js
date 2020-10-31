import { action, thunk, debug } from 'easy-peasy';
import {serverUrl} from "./serverUrl"
import axios from 'axios';
import { convertDate, sqlToJsDate } from '../../utils';


const bidModel = {
    userBids: [],
    petOwnerBids: [],

    addBid: thunk(async (actions, payload) => {
      const {pouname, petname, pettype, ctuname, s_time, e_time, pay_type, pet_pickup} = {...payload};
      const url = serverUrl + "/api/v1/bid";
      const {data} = await axios.post(url, {
        pouname: pouname,
        petname: petname,
        pettype: pettype,
        ctuname: ctuname,
        s_time: s_time,
        e_time: e_time
      });
    }),

    // Get bids for a caretaker
    getUserBids: thunk(async(actions, payload) => {
        const ctuname = payload;
        const url = serverUrl + "/api/v1/bid/" + ctuname + "/ct";
        console.log(url)
        const {data} = await axios.get(url);
        actions.setUserBids(data.data.bids);
    }),
    setUserBids: action((state, payload) => { // action
        state.userBids = [...payload];
    }),

    getPetOwnerBids: thunk(async(actions, payload) => {
      const pouname = payload;
      const url = serverUrl + "/api/v1/bid/" + pouname + "/po";
      console.log(url)
      const {data} = await axios.get(url);
      actions.setPetOwnerBids(data.data.bids);
  }),
  setPetOwnerBids: action((state, payload) => { // action
      state.petOwnerBids = [...payload];
  }),

    
    acceptBid: thunk(async(actions, payload) => {
      const {pouname, petname, pettype, ctuname, s_time, e_time, pay_type, pet_pickup} = {...payload};
      const url = serverUrl + "/api/v1/bid/" + ctuname + "/" + pouname + "/mark";
      console.log(url);
      console.log({
        petname: petname,
        pettype: pettype,
        s_time: convertDate(sqlToJsDate(s_time)),
        e_time: convertDate(sqlToJsDate(e_time))
    });
      const { data } = await axios.put(url, {
          petname: petname,
          pettype: pettype,
          s_time: convertDate(sqlToJsDate(s_time)),
          e_time: convertDate(sqlToJsDate(e_time))
      });
      actions.modifyBidStatus(payload);
    }),
    modifyBidStatus: action((state, payload) => {
      console.log(payload);
      state.userBids.map((bid) => {
        if (bid.pouname == payload.pouname &&
            bid.petname == payload.petname &&
            bid.pettype == payload.pettype &&
            bid.ctuname == payload.ctuname &&
            bid.s_time == payload.s_time &&
            bid.e_time == payload.e_time) {
              bid.is_win = true;
            }
      })
    })
}

export default bidModel;
