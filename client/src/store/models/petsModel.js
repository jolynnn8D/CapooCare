import { action, thunk } from 'easy-peasy';
import axios from 'axios';
import {serverUrl} from "./serverUrl"

const petsModel = {
  allPets: [],
  ownerSpecificPets: [],
  petCategories: [],
  biddablePets: [],

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

  getOwnerPetsOfType: thunk(async (actions, payload) => {
    const { username, pettype } = payload;
    const url = serverUrl + "/api/v1/pet/" + username + "/" + pettype;
    console.log(url);
    const {data} = await axios.get(url); 
    actions.setBiddablePets(data.data.pets); 
  }),
  setBiddablePets: action((state, payload) => {
    state.biddablePets = [...payload];
  }),

  addPet: thunk(async (actions, payload) => {
      const {username, petname, pettype, petage, requirements} = {...payload};
      const data = await axios.post(serverUrl + "/api/v1/pet", {
        username: username,
        petname: petname,
        pettype: pettype,
        petage: petage,
        requirements: requirements
      }).then((res) => {
        actions.addAPet(res.data.data.pet); 
      }).catch((err) => {
        console.log(err);
      })
    }),
    addAPet: action((state, payload) => {
      state.ownerSpecificPets.push(payload);
    }),

  editPet: thunk(async (actions, payload) => {
    const{username, petname, pettype, petage, requirements} = {...payload};
    const url = serverUrl + "/api/v1/pet/" + username + "/" + petname;
    const data = await axios.put(url, {
      pettype: pettype,
      petage: petage,
      requirements: requirements
    }).then((res) => {
      actions.editAPet(res.data.data.pet);
    }).catch((err) => {
      console.log(err);
    })
  }),
  editAPet: action((state, payload) => {
    state.ownerSpecificPets.map((pet) => {
      if (pet.petname == payload.petname) {
        pet.pettype = payload.pettype;
        pet.petage = payload.petage;
        pet.requirements = payload.requirements;
      }
    }
  )}),

  deletePet: thunk(async (actions,payload) => {
    const { username, petname } = {...payload};
    const url = serverUrl + "/api/v1/pet/" + username + "/" + petname;
    console.log(url)
    const data = await axios.delete(url)
      .then((res) => {
        actions.deleteAPet(petname)
      }).catch((err) => {
        console.log(err);
      })
  }),
  deleteAPet: action((state, payload) => {
    state.ownerSpecificPets.forEach(function(pet, index) {
      if(pet.petname == payload) {
        state.ownerSpecificPets.splice(index, 1);
      }
    })
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