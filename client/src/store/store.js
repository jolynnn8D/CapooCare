
import { createStore } from 'easy-peasy';
import careTakersModel from './models/careTakersModel';


const storeModel = {
  careTakers: careTakersModel
};

const store = createStore(storeModel);

export default store;