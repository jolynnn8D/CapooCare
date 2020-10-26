import React from 'react'
// import { Provider } from 'react-redux';
import { StoreProvider } from 'easy-peasy';
import ReactDOM from 'react-dom'
import {App} from "./App"
import store from './store/store'

ReactDOM.render(
<StoreProvider store={store}>
  <App />
</StoreProvider>, document.getElementById("root"))

