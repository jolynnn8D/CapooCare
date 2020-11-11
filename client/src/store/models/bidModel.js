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
      const data = await axios.post(url, {
        pouname: pouname,
        petname: petname,
        pettype: pettype,
        ctuname: ctuname,
        s_time: s_time,
        e_time: e_time,
        pay_type: pay_type,
        pet_pickup: pet_pickup
      }).then((res) => {
        console.log(res)
        alert("Bid successful");
      }).catch((err) => {
        alert("Bid unsuccessful");
        console.log(err);
      })
    }),

    addReviewToBid: thunk(async(actions, payload) => {
      const { bid, rating, review } = {... payload};
      const url = serverUrl + "/api/v1/bid";
      const { data } = await axios.put(url, {
        pouname: bid.pouname,
        petname: bid.petname,
        pettype: bid.pettype,
        ctuname: bid.ctuname,
        s_time: convertDate(sqlToJsDate(bid.s_time)),
        e_time: convertDate(sqlToJsDate(bid.e_time)),
        pay_type: bid.pay_type,
        pet_pickup: bid.pet_pickup,
        rating: rating,
        review: review,
        pay_status: bid.pay_status
      });
      actions.modifyBidReview(payload);
    }),
    modifyBidReview: action((state, payload) => {
      state.petOwnerBids.map((bid) => {
        if (bid.pouname == payload.bid.pouname &&
            bid.petname == payload.bid.petname &&
            bid.pettype == payload.bid.pettype &&
            bid.ctuname == payload.bid.ctuname &&
            bid.s_time == payload.bid.s_time &&
            bid.e_time == payload.bid.e_time) {
              bid.rating = payload.rating;
              bid.review = payload.review;
            }
      })
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
    }), 
    makePayment: thunk(async(actions, payload) => {
      const {pouname, petname, pettype, ctuname, s_time, e_time, pay_type, pet_pickup} = {...payload};
      const url = serverUrl + "/api/v1/bid/" + ctuname + "/" + pouname + "/pay";
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
      actions.modifyPayStatus(payload);
    }),
    modifyPayStatus: action((state, payload) => {
      console.log(payload);
      state.petOwnerBids.map((bid) => {
        if (bid.pouname == payload.pouname &&
            bid.petname == payload.petname &&
            bid.pettype == payload.pettype &&
            bid.ctuname == payload.ctuname &&
            bid.s_time == payload.s_time &&
            bid.e_time == payload.e_time) {
              bid.pay_status = true;
            }
      })
    }), 
    
}

export default bidModel;
