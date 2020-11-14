import React, { Component } from 'react'

export default class Filter extends Component {
  render() {
    return (
      <div className="filter">
        <div className="filter-result">{this.props.count} caretakers displayed!</div>
        <div className="filter-sort">
          <select value={this.props.sortValue} onChange={this.props.sortCareTakers}>
            {/* <option value="latest"></option> */}
            <option value="highest">Highest Rating</option>
            <option value="lowest">Lowest Rating</option>
          </select></div>
      </div>
    )
  }
}

