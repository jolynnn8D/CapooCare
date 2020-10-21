import { USER_LIST_FAIL, USER_LIST_REQUEST, USER_LIST_SUCCESS, PET_LIST_SUCCESS, PET_LIST_FAIL, PET_LIST_REQUEST} from "../constants/userConstants";


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
// Default pets were added for testing
// Actions are set to return state since backend is currently unavailable.
function petListReducer(state = { pets: [] }, action) {
  switch(action.type) {
    case PET_LIST_REQUEST:
      // return {loading: true};
      return state;
    case PET_LIST_SUCCESS:
      return {loading: false, pets: action.payload.data.pets}
    case PET_LIST_FAIL:
      return {loading: false, error: action.payload}
      // return state;
    default:
      return state;
  }
}

export {userListReducer, petListReducer}