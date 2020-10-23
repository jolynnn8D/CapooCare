import { action, thunk } from 'easy-peasy';
import axios from 'axios';

const petOwnersModel = {
    users: [],
    addPetOwner: thunk(async (actions, payload) => {
        console.log(payload);
        const {username, ownername, age, pettype, petname, petage, requirements} = {...payload};
        const {data} = await axios.post("http://localhost:5000/api/v1/petowner", {
            username: username,
            ownername: ownername,
            age: age,
            pettype: pettype,
            petname: petname,
            petage: petage,
            requirements: requirements
        });
        actions.addUser(data); 
      }),
      addUser: action((state, payload) => {
        state.users.push(payload);
      })
}

export default petOwnersModel;
