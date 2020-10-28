import React from 'react'
import { useParams } from 'react-router-dom'

const UpdateUser = (props) => {
    const { id } = useParams();

    return (
        <div className="text-center">
            Update Userssss UWU
        </div>
    )
}

export default UpdateUser
