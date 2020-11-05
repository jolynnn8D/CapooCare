function appendLeadingZeroes(n){
    if(n <= 9){
      return "0" + n;
    }
    return n
  }

function convertDate(passedDate) {
    const date = new Date(passedDate)
    let formatted_date = '' + date.getFullYear() + appendLeadingZeroes((date.getMonth() + 1)) + appendLeadingZeroes(date.getDate())
    return formatted_date
}

function sqlToJsDate(date) {
    let dateSplit = date.split('T');
    return new Date(date.replace(' ', 'T'));    ;
}

export {convertDate, sqlToJsDate}