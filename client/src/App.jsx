import React from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { UsersContextProvider } from "./context/UsersContext";
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
import NavBar from './components/NavBar';

const Routes = [
    {
        path: '/login',
        sidebarName: 'Login',
        component: Login,
    },
    {
        path: '/signup',
        sidebarName: 'Signup',
        component: Signup,
    },
    {
        path: '/',
        sidebarName: 'Homepage',
        component: Homepage,
    },
    {
        path: '/users/1',
        sidebarName: 'Profile',
        component: UserProfile,
    },
    {
        path: '/users/1/caretaker',
        sidebarName: 'Caretaker Profile',
        component: CaretakerProfile,
    },
    {
        path: '/users/1/caretaker-admin',
        sidebarName: 'Caretaker Settings',
        component: CaretakerAdmin,
    },
    {
        path: '/admin',
        sidebarName: 'PCS Administrator Settings',
        component: Adminpage
    }
]

const App = () => {
    return (
        <UsersContextProvider>
            <div className="container">
                <Router>
                    <NavBar />
                    <Switch>
                        <Route exact path="/" component={Homepage} />
                        <Route exact path="/admin" component={Adminpage}/>
                        <Route exact path="/admin/set-price" component={SetPricepage}/>
                        <Route exact path="/admin/view-caretakers" component={ViewCaretakerspage}/>
                        <Route exact path="/users/:id/update" component={Updatepage} />
                        <Route exact path="/users/:id" component={UserProfile} />
                        <Route exact path ="/users/:id/caretaker-admin" component={CaretakerAdmin}/>
                        <Route exact path ="/users/:id/caretaker" component={CaretakerProfile}/>
                        <Route exact path="/login" component={Login} />
                        <Route exact path="/signup" component={Signup} />
                    </Switch>
                </Router>
            </div>
        </UsersContextProvider>
    )
};

export {
    App,
    Routes
};