import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import Homepage from "./routes/Homepage"
import Updatepage from "./routes/Updatepage"
import Userdetailpage from "./routes/Userdetailpage"
import { UsersContextProvider } from "./context/UsersContext";

const App = () => {
    return (
        <UsersContextProvider>
            <div className="container">
                <Router>
                    <Switch>
                        <Route exact path="/" component={Homepage} />
                        <Route exact path="/users/:id/update" component={Updatepage} />
                        <Route exact path="/users/:id" component={Userdetailpage} />
                    </Switch>
                </Router>
            </div>
        </UsersContextProvider>
    )
};

export default App;