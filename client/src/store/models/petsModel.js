import { action, thunk } from 'easy-peasy';
import axios from 'axios';
import {serverUrl} from "./serverUrl"

const petsModel = {
  allPets: [],
  ownerSpecificPets: [],
  petCategories: [],
  getAllPets: thunk(async (actions, payload) => {
      const {data} = await axios.get(serverUrl + "/api/v1/pet"); // get all pets
      actions.setAllPets(data.data.pets); 
    }),
  setAllPets: action((state, payload) => { // action
    state.allPets = [...payload];
  }),

  getOwnerPets: thunk(async (actions, payload) => {
      const username = payload;
      const url = serverUrl + "/api/v1/pet/" + username;
      const {data} = await axios.get(url); 
      actions.setOwnerPets(data.data.pets); 
    }),
  setOwnerPets: action((state, payload) => {
    state.ownerSpecificPets = [...payload];
  }),

  addPet: thunk(async (actions, payload) => {
      const {username, petname, pettype, petage, requirements} = {...payload};
      const {data} = await axios.post(serverUrl + "/api/v1/pet", {
        username: username,
        petname: petname,
        pettype: pettype,
        petage: petage,
        requirements: requirements
      });
      actions.addAPet(data.data.pet);
    }),
    addAPet: action((state, payload) => {
      state.ownerSpecificPets.push(payload);
    }),

  editPet: thunk(async (actions, payload) => {
    const{username, petname, pettype, petage, requirements} = {...payload};
    const url = serverUrl + "/api/v1/pet/" + username + "/" + petname;
    const {data} = await axios.put(url, {
      pettype: pettype,
      petage: petage,
      requirements: requirements
    });
  }),
  // EDIT ACTION TO UPDATE UI HERE REQUIRED

  deletePet: thunk(async (actions,payload) => {
    const { username, petname } = {...payload};
    const url = serverUrl + "/api/v1/pet/" + username + "/" + petname;
    console.log(url)
    const {data} = await axios.delete(url);
  }),

  getPetCategories: thunk(async (actions,payload) => {
    const url = serverUrl + "/api/v1/categories";
    const {data} = await axios.get(url);
    actions.getAllCategories(data.data.pets);
  }), 
  getAllCategories: action((state, payload) => {
    state.petCategories = [...payload];
  }),


}

export default petsModel;