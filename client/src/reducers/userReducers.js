import { USER_LIST_FAIL, USER_LIST_REQUEST, USER_LIST_SUCCESS } from "../constants/userConstants";


function userListReducer(state = {users: []}, action) { // action send data from application to the store. They are the only source of information for the store. Sending by `store.dispatch()`
  switch (action.type) {
    case USER_LIST_REQUEST:
      return {loading: true};
    case USER_LIST_SUCCESS:
      return {loading: false, users: action.payload}
    case USER_LIST_FAIL:
      return {loading: false, error: action.payload}
    default:
      return state;
  }
}

export {userListReducer}