import axios from 'axios';
import { PET_LIST_FAIL, PET_LIST_REQUEST, PET_LIST_SUCCESS, USER_LIST_FAIL, USER_LIST_REQUEST, USER_LIST_SUCCESS } from '../constants/userConstants';


const listUsers = () => async (dispatch) => {
  try {
    dispatch({type: USER_LIST_REQUEST});
    const {data} = await axios.get("http://localhost:5000/api/v1/users");
    dispatch({type: USER_LIST_SUCCESS, payload: data});
  } catch (error) {
    dispatch({type: USER_LIST_FAIL, payload: error.message}); 
  }
}

const listPets = () => async (dispatch) => {
  try {
    dispatch({type: PET_LIST_REQUEST});
    const {data} = await axios.get("http://localhost:5000/api/v1/pets");
    dispatch({type: PET_LIST_SUCCESS, payload: data});
  } catch (error) {
    dispatch({type: PET_LIST_FAIL, payload: error.message}); 
  }
}

export {listUsers, listPets};