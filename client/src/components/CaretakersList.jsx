import * as React from 'react';
import { DataGrid } from '@material-ui/data-grid';
import { useDispatch, useSelector } from 'react-redux';
import { listUsers } from '../actions/userActions';

// const columns = [
//   { field: 'id', headerName: 'ID', width: 70 },
//   { field: 'firstName', headerName: 'First name', width: 130 },
//   { field: 'lastName', headerName: 'Last name', width: 130 },
//   {
//     field: 'age',
//     headerName: 'Age',
//     type: 'number',
//     width: 90,
//   },
//   {
//     field: 'fullName',
//     headerName: 'Full name',
//     description: 'This column has a value getter and is not sortable.',
//     sortable: false,
//     width: 160,
//     valueGetter: (params) =>
//       `${params.getValue('firstName') || ''} ${
//         params.getValue('lastName') || ''
//       }`,
//   },
// ];

// const rows = [
//   { id: 1, lastName: 'Snow', firstName: 'Jon', age: 35 },
//   { id: 2, lastName: 'Lannister', firstName: 'Cersei', age: 42 },
//   { id: 3, lastName: 'Lannister', firstName: 'Jaime', age: 45 },
//   { id: 4, lastName: 'Stark', firstName: 'Arya', age: 16 },
//   { id: 5, lastName: 'Targaryen', firstName: 'Daenerys', age: null },
//   { id: 6, lastName: 'Melisandre', firstName: null, age: 150 },
//   { id: 7, lastName: 'Clifford', firstName: 'Ferrara', age: 44 },
//   { id: 8, lastName: 'Frances', firstName: 'Rossini', age: 36 },
//   { id: 9, lastName: 'Roxie', firstName: 'Harvey', age: 65 },
// ];
const columns = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'name', headerName: 'First name', width: 130 },
];

const CaretakersList = () => {

  React.useEffect(() => {
    dispatch(listUsers());

    return () => {
      // no clean up
    }
  }, []);

  const userList = useSelector(state => state.userList);
  const {users, loading, error} = userList;
  const dispatch = useDispatch();

  const tests = [{"user_id": 1, "name": "hung"}, {"user_id": 2, "name": "something"}];

  // const rows = users.map(user => ({
  //   "id" : user.user_id,
  //   "name" : user.name
  // }));

  console.log(users);
  // console.log(rows);

  return (
      loading ? <div>Loading...</div>
      : error ? <div>{error}</div>
      : 
      <DataGrid rows={users.map(user => ({
        "id": user.user_id,
        "name": user.name    
      }))} columns={columns} pageSize={5} checkboxSelection />
  );
}

export default CaretakersList