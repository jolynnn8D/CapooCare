function appendLeadingZeroes(n){
    if(n <= 9){
      return "0" + n;
    }
    return n
  }

function convertDate(date) {
    let formatted_date = '' + date.getFullYear() + appendLeadingZeroes((date.getMonth() + 1)) + appendLeadingZeroes(date.getDate())
    return parseInt(formatted_date)
}

function sqlToJsDate(date) {
    let dateSplit = date.split('T');
    return new Date(dateSplit[0]);
}

export {convertDate, sqlToJsDate}