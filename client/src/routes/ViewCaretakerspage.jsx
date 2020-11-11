import React from 'react'
import CaretakersVerticalTabs from '../components/admin/CaretakersVerticalTabs'
import CaretakersList from '../components/CaretakersList'
import Summary from "../components/admin/Summary"
import { makeStyles } from '@material-ui/core/styles';


const useStyles = makeStyles({
    verticalSections: {
        margin: "100px 10px 30px"
    }
})

const ViewCaretakerspage = () => {
  const classes = useStyles();

  return (
    <div className={classes.verticalSections}>
      <CaretakersVerticalTabs/>
      {/* <CaretakersList/> */}
    </div>
  );
}

export default ViewCaretakerspage
