import { action, thunk, debug } from 'easy-peasy';
import { serverUrl } from "./serverUrl"
import axios from 'axios';
import {convertDate} from "../../utils"

const adminModel = {
    singleCaretakerSalary: [],
    partTimerSalary: [],
    fullTimerSalary: [],
    singleAccount: [],

    getNewAdminAccount: thunk(async (actions, payload) => {
      const username = payload;
      const url = serverUrl + "/api/v1/accounts/" + username;
      // await axios.get(url).then(response => {
      //   // console.log(response.data.data);
      //   if (response.data.data.account != null) {
      //     // alert('Username already exists in the database!');
      //     return response.data.data.account;
      //   } else {
      //     // console.log("here");
      //     return response.data.data.account;
      //   }
      // }).catch((error) => {
      //   alert("Please choose a different username!");
      // })
      const data = await axios.get(url);
      return data;
    }),
    getAccount: thunk(async (actions, payload) => {
    const username = payload;
    const url = serverUrl + "/api/v1/accounts/" + username;
    const data = await axios.get(url).then(response => {
      // console.log(response);
      if (response.data.status === "success") {
        return response.data.data.account;
      } else {
        alert('Username does not exist in the database!');
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
      const data = await axios.post(serverUrl + "/api/v1/pcsadmin", {
          username: username,
          adminname: adminname,
      }).then(response => {
        alert("Admin added!");
      })
    }),

    getSingleCaretakerSalary: thunk(async (actions, payload) => {
        const { ctuname, s_time, e_time } = { ...payload };
        const url = serverUrl + "/api/v1/admin/salary/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time);
        const {data} = await axios.get(url);
        actions.setSingleCaretakerSalary(data.data); 
      }), 
      setSingleCaretakerSalary: action((state, payload) => { // action
        if (payload.salary !== null ) {
            state.singleCaretakerSalary = payload.salary;
        }
      }),
      getPartTimerSalary: thunk(async (actions, payload) => {
        const { s_time, e_time } = { ...payload };
        const url = serverUrl + "/api/v1/admin/salary/parttimers/" + convertDate(s_time) + "/" + convertDate(e_time);
        const {data} = await axios.get(url);
        console.log(url)
        actions.setPartTimerSalary(data.data); 
      }), 
      setPartTimerSalary: action((state, payload) => { // action
        if (payload.salaries !== null ) {
            state.partTimerSalary = payload.salaries;
        }
      }),
      getFullTimerSalary: thunk(async (actions, payload) => {
        const { s_time, e_time } = { ...payload };
        const url = serverUrl + "/api/v1/admin/salary/fulltimers/" + convertDate(s_time) + "/" + convertDate(e_time);
        const {data} = await axios.get(url);
        actions.setFullTimerSalary(data.data); 
      }), 
      setFullTimerSalary: action((state, payload) => { // action
        if (payload.salaries !== null ) {
            state.fullTimerSalary = payload.salaries;
        }
      }),
}

export default adminModel;
