
import { createStore } from 'easy-peasy';
import careTakersModel from './models/careTakersModel';
import petOwnersModel from './models/petOwnersModel'
import petsModel from './models/petsModel';


const storeModel = {
  careTakers: careTakersModel,
  petOwners: petOwnersModel,
  pets: petsModel
};

const store = createStore(storeModel);

export default store;