import React from 'react'
import Header from '../components/Header'
import AddUser from '../components/AddUser'
import UsersList from '../components/UsersList'

const Homepage = () => {
    return (
        <div>
            <Header />
            <AddUser />
            <UsersList />
        </div>
    )
}

export default Homepage
