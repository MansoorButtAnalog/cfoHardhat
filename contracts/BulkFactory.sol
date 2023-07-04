// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Bulk.sol";

contract BulkFactory{

    Bulk[] public bulks;

    function createBulkContract() public {
        Bulk bulk = new Bulk();
        bulks.push(bulk);
    }

    function getbulk() public view returns(Bulk[] memory){
        return bulks;
    }

}