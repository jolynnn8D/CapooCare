import {createStore} from 'redux';

const initialState = {};
const reducer = combineReducers({
  userList: userListReducer,
})
const store = createStore(reducer, initialState);

