import Adminpage from "./Adminpage";
import CaretakerAdmin from "./CaretakerAdmin";
import CaretakerProfile from "./CaretakerProfile";
import FindCaretakers from "./FindCaretakers";
import Homepage from "./Homepage";
import Login from "./Login";
import Signup from "./Signup";
import UserProfile from "./UserProfile";

var Routes = [ // updated after login
    {
        path: '/',
        sidebarName: 'Login',
        component: Login,
    },
    {
        path: '/signup',
        sidebarName: 'Signup',
        component: Signup,
    },
    {
        path: '/homepage',
        sidebarName: 'Homepage',
        component: Homepage,
    },
    {
        path: '/users/marythemess',
        sidebarName: 'Petowner Profile',
        component: UserProfile,
    },
    {
        path: '/users/marythemess/caretaker',
        sidebarName: 'Caretaker Profile',
        component: CaretakerProfile,
    },
    {
        path: '/users/marythemess/caretaker-admin',
        sidebarName: 'Caretaker Settings',
        component: CaretakerAdmin,
    },
    {
        path: '/admin',
        sidebarName: 'PCS Administrator Settings',
        component: Adminpage,
    },
    {
        path: '/users/caretakers',
        sidebarName: 'Look for Caretakers',
        component: FindCaretakers,
    }
]

export default Routes;