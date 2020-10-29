
import { createStore, persist } from 'easy-peasy';
import careTakersModel from './models/careTakersModel';
import petOwnersModel from './models/petOwnersModel'
import petsModel from './models/petsModel';
import userModel from './models/userModel';


const storeModel = {
  careTakers: careTakersModel,
  petOwners: petOwnersModel,
  pets: petsModel,
  user: userModel
};

// const store = createStore(persist(storeModel));
const store = createStore(storeModel);

export default store;