
import { createStore, persist } from 'easy-peasy';
import Adminpage from '../routes/Adminpage';
import CaretakerAdmin from '../routes/CaretakerAdmin';
import CaretakerProfile from '../routes/CaretakerProfile';
import FindCaretakers from '../routes/FindCaretakers';
import Homepage from '../routes/Homepage';
import Login from '../routes/Login';
import Signup from '../routes/Signup';
import UserProfile from '../routes/UserProfile';
import careTakersModel from './models/careTakersModel';
import petOwnersModel from './models/petOwnersModel'
import petsModel from './models/petsModel';
import routesModel from './models/routesModel';
import userModel from './models/userModel';


const storeModel = {
  careTakers: careTakersModel,
  petOwners: petOwnersModel,
  pets: petsModel,
  user: userModel, 
  routes: routesModel
};

const store = createStore(storeModel);
// const store = createStore(storeModel);

export default store;