
import { createStore } from 'easy-peasy';
import careTakersModel from './models/careTakersModel';
import petsModel from './models/petsModel';


const storeModel = {
  careTakers: careTakersModel,
  pets: petsModel
};

const store = createStore(storeModel);

export default store;