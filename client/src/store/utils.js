function appendLeadingZeroes(n){
    if(n <= 9){
      return "0" + n;
    }
    return n
  }

export default function convertDate(date) {
    let formatted_date = '' + date.getFullYear() + appendLeadingZeroes((date.getMonth() + 1)) + appendLeadingZeroes(date.getDate())
    return parseInt(formatted_date)
}