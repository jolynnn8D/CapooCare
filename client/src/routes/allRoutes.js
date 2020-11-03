const Routes = [ // updated after login
    {
        path: '/',
        sidebarName: 'Login',
    },
    {
        path: '/signup',
        sidebarName: 'Signup',
    },
    {
        path: '/homepage',
        sidebarName: 'Homepage',
    },
    {
        path: '/users/:username',
        sidebarName: 'Petowner Profile',
    },
    {
        path: '/users/:username/caretaker',
        sidebarName: 'Caretaker Profile',
    },
    {
        path: '/users/:username/caretaker-admin',
        sidebarName: 'Caretaker Settings',
    },
    {
        path: '/admin',
        sidebarName: 'PCS Administrator Settings',
    },
    {
        path: '/users/caretakers',
        sidebarName: 'Look for Caretakers',
    }
]

export default Routes;