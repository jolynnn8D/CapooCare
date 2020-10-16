import {applyMiddleware, createStore, combineReducers, compose} from 'redux';
import thunk from 'redux-thunk';
import { userListReducer } from '../reducers/userReducers';

const initialState = {};
const reducer = combineReducers({
  userList: userListReducer,
})
const composeEnhancer = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
const store = createStore(reducer, initialState, composeEnhancer(applyMiddleware(thunk)));

export default store;