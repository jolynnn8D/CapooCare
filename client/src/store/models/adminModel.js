import { action, thunk, debug } from 'easy-peasy';
import { serverUrl } from "./serverUrl"
import axios from 'axios';
import {convertDate} from "../../utils"

const adminModel = {
    singleCaretakerSalary: [],
    getSingleCaretakerSalary: thunk(async (actions, payload) => {
        const { ctuname, s_time, e_time } ={ ...payload };
        console.log(payload)
        const url = serverUrl + "/api/v1/admin/salary/" + ctuname + "/" + convertDate(s_time) + "/" + convertDate(e_time);
        console.log(url)
        const {data} = await axios.get(url);
        actions.setSingleCaretakerSalary(data.data); 
      }), 
      setSingleCaretakerSalary: action((state, payload) => { // action
        if (payload.salary !== null ) {
            state.singleCaretakerSalary = payload.salary;
        }
      }),
}

export default adminModel;
