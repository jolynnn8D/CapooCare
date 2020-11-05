import { action, thunk, debug } from 'easy-peasy';
import { serverUrl } from "./serverUrl"
import axios from 'axios';
import {convertDate} from "../../utils"

const adminModel = {
    singleCaretakerSalary: [],
    partTimerSalary: [],
    fullTimerSalary: [],

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
