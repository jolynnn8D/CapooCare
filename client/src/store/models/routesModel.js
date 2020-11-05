import { action } from 'easy-peasy';

const routesModel = {
  routes: [ // updated after login
    {
        path: '/',
        sidebarName: 'Login',
    },
    {
        path: '/signup',
        sidebarName: 'Signup',
    }
  ],
  setRoutes: action((state, payload) => {
    state.routes = payload;
  })
}

export default routesModel;