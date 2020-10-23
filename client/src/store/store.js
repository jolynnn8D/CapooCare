
import { createStore } from 'easy-peasy';
import careTakersModel from './models/careTakersModel';
import petOwnersModel from './models/petOwnersModel'


const storeModel = {
  careTakers: careTakersModel,
  petOwners: petOwnersModel
};

const store = createStore(storeModel);

export default store;