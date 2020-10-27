import React from 'react'
// import { Provider } from 'react-redux';
import { StoreProvider, useStoreRehydrated } from 'easy-peasy';
import ReactDOM from 'react-dom'
import {App} from "./App"
import store from './store/store'

function WaitForStateRehydration({ children }) {
  const isRehydrated = useStoreRehydrated();
  return isRehydrated ? children : null;
}

ReactDOM.render(
<StoreProvider store={store}>
  {/* <WaitForStateRehydration> */}
  <App />
  {/* </WaitForStateRehydration> */}
</StoreProvider>, document.getElementById("root"))

