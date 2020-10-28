import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import Adminpage from "./routes/Adminpage";
import CaretakerAdmin from "./routes/CaretakerAdmin"
import Homepage from "./routes/Homepage"
import Updatepage from "./routes/Updatepage"
import SetPricepage from "./routes/SetPricepage";
import ViewAllCaretakers from "./components/admin/ViewAllCaretakers";
import ViewCaretakerspage from "./routes/ViewCaretakerspage";
import UserProfile from "./routes/UserProfile";
import CaretakerProfile from "./routes/CaretakerProfile"
import Login from "./routes/Login";
import Signup from "./routes/Signup";
import FindCaretakers from "./routes/FindCaretakers";
import NavBar from './components/NavBar';

const App = () => {
    return (
        <div className="container">
            <Router>
                <NavBar />
                <Switch>
                    <Route exact path="/" component={Login} />
                    <Route exact path="/admin" component={Adminpage}/>
                    <Route exact path="/admin/set-price" component={SetPricepage}/>
                    <Route exact path="/admin/view-caretakers" component={ViewCaretakerspage}/>
                    <Route exact path="/users/caretakers" component={FindCaretakers} />
                    <Route exact path="/users/:username/update" component={Updatepage} />
                    <Route exact path="/users/:username" component={UserProfile} />
                    <Route exact path ="/users/:username/caretaker-admin" component={CaretakerAdmin}/>
                    <Route exact path ="/users/:username/caretaker" component={CaretakerProfile}/>
                    <Route exact path="/homepage" component={Homepage} />
                    <Route exact path="/signup" component={Signup} />
                </Switch>
            </Router>
        </div>
    )
};

export {
    App
};