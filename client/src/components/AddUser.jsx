import React, { useState, useContext } from 'react'
import UserFinder from "../apis/UserFinder"
import { UsersContext } from '../context/UsersContext';

const AddUser = () => {
    const { addUsers } = useContext(UsersContext);
    const [name, setName] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await UserFinder.post("/", {
                username: name,
            });
            addUsers(response.data.data.user);
        } catch (err) {
            console.log(err);
        }
    };

    return (
        <div className="mb-4">
            <form action="">
                <div className="form-row">
                    <div className="col">
                        <input
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            type="text"
                            className="form-control"
                            placeholder="Name"
                        />
                    </div>
                    <div className="col">
                        <input type="text" className="form-control" placeholder="age" />
                    </div>
                    <div className="col">
                        <select className="custom-select my-1 mr-sm-2">
                            <option disabled>Price Range</option>
                            <option value="1">$</option>
                            <option value="2">$$</option>
                            <option value="3">$$$</option>
                        </select>
                    </div>
                    <button onClick={handleSubmit} type="submit" className="btn btn-primary">Add</button>
                </div>
            </form>
        </div>
    )
}

export default AddUser
