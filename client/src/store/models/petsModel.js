import { action, thunk } from 'easy-peasy';
import axios from 'axios';

const petsModel = {
  allPets: [],
  ownerSpecificPets: [],
  getAllPets: thunk(async (actions, payload) => {
      const {data} = await axios.get("http://localhost:5000/api/v1/pet"); // get all pets
      actions.setAllPets(data.data.pets); 
    }),
  setAllPets: action((state, payload) => { // action
    state.allPets = [...payload];
  }),

  // getOwnerPets: thunk(async (actions, payload) => {
  //     const {userName} = {payload};
  //     const {data} = await axios.get("http://localhost:5000/api/v1/pet"); // get all pets
  //     actions.setAllPets(data.data.pets); 
  //   }),
  addPet: thunk(async (actions, payload) => {
      const {username, petName, petType, petAge, requirements} = {...payload};
      const {data} = await axios.post("http://localhost:5000/api/v1/pet", {
        username,
        petName, 
        petType,
        petAge,
        requirements
      }); // get all pets
      actions.addAPet(data);
    }),
    addAPet: action((state, payload) => {
      state.allPets.push(payload);
    })
}

export default petsModel;