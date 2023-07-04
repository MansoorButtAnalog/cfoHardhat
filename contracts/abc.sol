// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract abcToken is ERC20 {
    address payable public owner;

    constructor() ERC20("abc", "ABC"){
        owner = payable(msg.sender);
        mint(owner, 700000 * (10 ** decimals()));
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
