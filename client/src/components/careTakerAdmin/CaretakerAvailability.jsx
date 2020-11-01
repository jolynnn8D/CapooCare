import React, { useState, useEffect } from 'react'
import { useStoreActions, useStoreState } from 'easy-peasy';


const CaretakerAvailability = (props) => {
    const getUserAvailability = useStoreActions(actions => actions.careTakers.getUserAvailability);
    useEffect(() => {
        getUserAvailability({
            ctuname: props.username,
            s_time: new Date(),
            e_time: new Date(new Date().setDate(new Date().getDate() + 365)), //one year from now
        });
        return () => {};
    }, []);
    return (
        <div>
            hi
        </div>
    )
}

export default CaretakerAvailability
