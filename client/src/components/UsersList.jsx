import React, { useEffect, useContext } from 'react';
import UserFinder from "../apis/UserFinder";
import { UsersContext } from '../context/UsersContext';
import { useHistory } from "react-router-dom";

const UsersList = (props) => {
    const { users, setUsers } = useContext(UsersContext);
    let history = useHistory();
    useEffect(() => {

        const fetchData = async () => {
            try {
                const response = await UserFinder.get("/")   //takes whatever is in UserFinder URL and adding a / at the end, returns a promise
                setUsers(response.data.data.users);
            } catch (err) {

            }
        };
        fetchData();
    }, [])
    //empty dependencies array -> run the hook only when the component is loaded

    const handleDelete = async (id) => {
        try {
            const response = await UserFinder.delete(`/${id}`);
            //update ui
            setUsers(users.filter(user => {
                return user.id != id;
            }));
        } catch (err) {

        }
    };

    const handleUpdate = (id) => {
        history.push(`/users/${id}/update`);
    };

    return (
        <div className="list-group">
            <table className="table table-hover table-dark ">
                <thead>
                    <tr className="bg-primary">
                        <th scope="col">User</th>
                        <th scope="col">id</th>
                        <th scope="col">Price Range</th>
                        <th scope="col">Rating</th>
                        <th scope="col">Edit</th>
                        <th scope="col">Delete</th>
                    </tr>
                </thead>
                <tbody>
                    {/* if users exist, run this code */}
                    {users && users.map((user) => {
                        return (
                            <tr key={user.id}>
                                <td>{user.username}</td>
                                <td>{user.id}</td>
                                <td>{"$".repeat(2)}</td>
                                <td>3/5</td>
                                <td>
                                    {/* pass reference to function, not function as u want it to run when its clicked */}
                                    <button onClick={() => handleUpdate(user.id)} className="btn btn-warning">Update</button>
                                </td>
                                <td>
                                    <button onClick={() => handleDelete(user.id)} className="btn btn-danger">Delete</button>
                                </td>
                            </tr>
                        );
                    })}
                </tbody>
            </table>
        </div>
    )
}

export default UsersList
