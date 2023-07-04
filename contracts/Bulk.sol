// SPDX-License-Identifier: MIT

//1685300400 time
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    //contract address 0x86aF33eB1c2a06F30A212304dB2e607F4141E8Ce
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Bulk {
    struct MyData {
        uint256 number;
        address addr;
        address sentBy;
        uint256 time;
        bool withdrawn;
        bool paused;
        bool cancelled;
        uint txId;
        address token;
        string name;
    }

    struct Token {
        address token;
        string name;
        string symbol;
        uint256 depositedAmount;
        uint256 id;
    }

    MyData[] public combinedArray;
    mapping(address => mapping(address => uint)) public balances;
    mapping(address => mapping(address => uint)) public withdrawals;
    mapping(address => uint256[]) public traverseTx; // This is a mapping where we keep track of all Tx_id created on a particular address

    mapping(address => Token[]) public employerTokens;
    mapping(address => mapping(address => uint256)) public employeeBalances;
    mapping(address => mapping(address => bool)) public tokenExist;
    mapping(address => mapping(address => uint)) public tokenID;

    mapping(address => string[][]) public addressToTokens;

    event tokenList(
        address indexed employer,
        address indexed token,
        string name,
        string symbol,
        uint256 depositedAmount
    );
    event EmployeePaid(
        address indexed employee,
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 amount
    );
    event EmployeeWithdraw(
        address indexed employee,
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 amount
    );

    uint public count;
    uint public tID;

    // This function combines three arrays of uint256, address, and uint256 types respectively
    // It also takes in an address and a string as additional parameters
    function combineArrays(
        uint256[] memory numbers,
        address[] memory addresses,
        uint256[] memory time,
        address token,
        string memory _name
    ) public {
        // Ensure that the length of all three arrays is the same
        require(numbers.length == addresses.length, "Array lengths must match");
        // Initialize an index variable to the length of the combinedArray
        uint index = combinedArray.length;
        // Loop through the numbers array
        for (uint256 i = 0; i < numbers.length; i++) {
            // Push a new MyData object to the combinedArray with the corresponding values from the arrays
            combinedArray.push(
                MyData(
                    numbers[i],
                    addresses[i],
                    msg.sender,
                    time[i],
                    false,
                    false,
                    false,
                    count,
                    token,
                    _name
                )
            );
            // Push the count variable to the traverseTx mapping with the corresponding address as the key
            traverseTx[addresses[i]].push(count);
            // Increment the count variable
            count++;
        }
        // Call the sendBulkPayments function with the index variable as the parameter
        sendBulkPayments(index);
    }

    // This function sends bulk payments to multiple addresses
    function sendBulkPayments(uint index) public {
        // Check if the combinedArray is not empty
        require(combinedArray.length > 0, "Empty Array");
        // Declare a string variable to store the token address
        string memory tokenadd;
        // Loop through the combinedArray starting from the given index
        for (uint256 i = index; i < combinedArray.length; i++) {
            // Add the payment amount to the balance of the recipient's token balance
            balances[combinedArray[i].addr][
                combinedArray[i].token
            ] += combinedArray[i].number;
            // Get the token ID of the token sent by the employer
            uint x = tokenID[combinedArray[i].sentBy][combinedArray[i].token];
            // Subtract the payment amount from the deposited amount of the employer's token
            employerTokens[combinedArray[i].sentBy][x]
                .depositedAmount -= combinedArray[i].number;
            // Convert the token address to a string
            tokenadd = stringConvertor(combinedArray[i].token);
            // Push the payment details to an array
            pushValues(combinedArray[i].addr, combinedArray[i].name, tokenadd);
            // Emit an event to indicate that the payment has been made
            emit EmployeePaid(
                combinedArray[i].addr,
                combinedArray[i].token,
                employerTokens[combinedArray[i].sentBy][x].name,
                employerTokens[combinedArray[i].sentBy][x].symbol,
                employerTokens[combinedArray[i].sentBy][x].depositedAmount
            );
        }
    }

    // This function takes in an employee address and two string values and pushes them to a dynamic array associated with the employee address
    function pushValues(
        address _employee,
        string memory _value1,
        string memory _value2
    ) public {
        // Get the length of the dynamic array associated with the employee address
        uint len = addressToTokens[_employee].length;
        // Create a storage variable for the dynamic array
        string[][] storage dynamicArray = addressToTokens[_employee];
        // If the dynamic array is not empty
        if (len > 0) {
            // Loop through the dynamic array
            for (uint i = 0; i < len; i++) {
                // Check if the first value of the current element in the dynamic array matches the first value passed in
                if (
                    dynamicArray.length > 0 &&
                    keccak256(abi.encodePacked(dynamicArray[i][0])) ==
                    keccak256(abi.encodePacked(_value1))
                ) {
                    // If there is a match, log a message and continue to the next element
                    console.log("Duplicate Tokens detected");
                    continue;
                } else {
                    // If there is no match, push the two values to the dynamic array
                    dynamicArray.push([_value1, _value2]);
                }
            }
        } else {
            // If the dynamic array is empty, push the two values to the dynamic array
            dynamicArray.push([_value1, _value2]);
            // Log the employee address
            // 0xB85a70B76904f5F111b29d80581463aA74dde705
        }
    }

    // This function takes an Ethereum address as input and converts it into a hexadecimal string
    // The input parameter is an Ethereum address of type 'address'
    // The function is declared as 'public' and 'pure', which means it can be called from outside the contract and does not modify the state of the contract
    // The function returns a string of type 'string memory'
    function stringConvertor(
        address _address
    ) public pure returns (string memory) {
        // The 'Strings' library is used to convert the address to a hexadecimal string
        // The 'toHexString' function takes two parameters: the first is the address converted to a uint256, and the second is the number of bytes to convert (in this case, 20 bytes for an Ethereum address)
        string memory x = Strings.toHexString(uint256(uint160(_address)), 20);
        // The hexadecimal string is returned as output
        return x;
    }

    // This function takes an address as input and returns a dynamic array of string arrays
    function getDynamicArray(
        address _address
    ) public view returns (string[][] memory) {
        // Retrieve the dynamic array of string arrays associated with the input address from the mapping
        return addressToTokens[_address];
    }

    function getlength() public view returns (uint) {
        return addressToTokens[msg.sender].length;
    }

    // This function allows a user to deposit a token into the contract
    // It takes in the token address, name, symbol, and deposited amount as parameters
    // It requires that the name and symbol are not empty, the deposited amount is greater than 0, and the token has not already been deposited by the user
    // It creates a new instance of the IERC20 interface using the token address
    // It checks that the user has enough balance to deposit the specified amount of tokens
    // It creates a new Token struct with the token information and adds it to the employerTokens mapping for the user
    // It assigns a unique token ID to the token and adds it to the tokenID mapping for the user
    // It transfers the deposited amount of tokens from the user to the contract
    // It emits a tokenList event with the token information and deposited amount
    function depositToken(
        address _token,
        string memory name,
        string memory symbol,
        uint256 depositedAmount
    ) external {
        require(bytes(name).length != 0, "Name cannot be empty");
        require(bytes(symbol).length != 0, "Symbol cannot be empty");
        require(depositedAmount > 0, "Deposited amount must be greater than 0");
        require(!tokenExist[msg.sender][_token], "Token Already Deposited");

        IERC20 token = IERC20(_token);
        require(
            token.balanceOf(msg.sender) >= depositedAmount,
            "Insufficient balance"
        );

        Token memory newToken = Token(
            _token,
            name,
            symbol,
            depositedAmount,
            tID
        );
        employerTokens[msg.sender].push(newToken);
        tokenID[msg.sender][_token] = tID;
        token.transferFrom(
            msg.sender,
            address(this),
            depositedAmount * (10 ** 18)
        );
        tID++;
        emit tokenList(msg.sender, _token, name, symbol, depositedAmount);
    }

    // This function allows an employer to top up their token balance
    // It takes in the token address and the additional amount to be added
    function tokenTopUp(
        address tokenAddress,
        uint256 additionalAmount
    ) external {
        // Ensure that the employer address is valid
        require(msg.sender != address(0), "Invalid employer address");
        // Get the token ID for the employer and token address
        uint _tokenId = tokenID[msg.sender][tokenAddress];
        // Ensure that the additional amount is greater than 0
        require(
            additionalAmount > 0,
            "Additional amount must be greater than 0"
        );
        // Get the token contract instance
        IERC20 token = IERC20(tokenAddress);
        // Transfer the additional amount from the employer to this contract
        token.transferFrom(
            msg.sender,
            address(this),
            additionalAmount * (10 ** 18)
        );
        // Update the deposited amount for the employer's token balance
        employerTokens[msg.sender][_tokenId]
            .depositedAmount += additionalAmount;
    }

    function getEmployerTokens(
        address employer
    ) external view returns (Token[] memory) {
        require(employer != address(0), "Invalid employer address");
        return employerTokens[employer];
    }

    // This function allows a user to withdraw funds from a specific transaction ID
    function withdraw(uint _txId) external {
        // Retrieve the data for the specified transaction ID from the combinedArray
        MyData storage mydata = combinedArray[_txId];
        // Ensure that the funds have not already been withdrawn
        require(!mydata.withdrawn, "Already withdrawn");
        // Ensure that the release time for the funds has been reached
        require(block.timestamp >= mydata.time, "Release time not reached");
        // Ensure that the user has sufficient balance of the specified token
        require(
            mydata.number <= balances[msg.sender][mydata.token],
            "Insufficient Balance Available"
        );
        // Retrieve the amount to be withdrawn
        uint amount = mydata.number;
        // Deduct the amount from the user's balance
        balances[msg.sender][mydata.token] -= amount;
        // Add the amount to the user's withdrawal history
        withdrawals[msg.sender][mydata.token] += amount;
        // Retrieve the ERC20 token contract for the specified token
        IERC20 tokenx = IERC20(mydata.token);
        // Transfer the amount of tokens to the user's address
        tokenx.transfer(msg.sender, amount * (10 ** 18));
        // Mark the funds as withdrawn
        mydata.withdrawn = true;
    }

    // This function pauses a stream with the given transaction ID
    function pauseStream(uint _txId) external {
        // Retrieve the MyData struct from the combinedArray using the given transaction ID
        MyData storage mydata = combinedArray[_txId];
        // Ensure that the stream has not already been withdrawn
        require(!mydata.withdrawn, "Already withdrawn");
        // Ensure that the stream has not already been paused
        require(!mydata.paused, "Already Paused");
        // Set the paused flag to true for the specified stream
        mydata.paused = true;
    }

    // This function resumes a stream with the given transaction ID
    function resumeStream(uint _txId) external {
        // Retrieve the MyData struct from the combinedArray using the transaction ID
        MyData storage mydata = combinedArray[_txId];
        // Ensure that the stream has not already been withdrawn
        require(!mydata.withdrawn, "Already withdrawn");
        // Ensure that the stream has been paused
        require(mydata.paused, "Already Resumed");
        // Set the paused flag to false to resume the stream
        mydata.paused = false;
    }

    // This function cancels a stream by taking in the transaction ID as input
    function cancelStream(uint _txId) external {
        // Accessing the MyData struct from the combinedArray using the transaction ID
        MyData storage mydata = combinedArray[_txId];
        // Checking if the stream has already been withdrawn
        require(!mydata.withdrawn, "Already withdrawn");
        // Checking if the stream has already been cancelled
        require(!mydata.cancelled, "Already Cancelled");
        // Storing the amount of tokens being cancelled
        uint amount = mydata.number;
        // Subtracting the cancelled amount from the balance of the user
        balances[mydata.addr][mydata.token] -= amount;
        // Marking the stream as cancelled
        mydata.cancelled = true;
    }

    function getAvailableAmount(address _token) public returns (uint, address) {
        uint totalamount;
        for (uint i = 0; i < traverseTx[msg.sender].length; i++) {
            MyData storage mydata = combinedArray[traverseTx[msg.sender][i]];
            if (
                !mydata.withdrawn &&
                mydata.time <= block.timestamp &&
                mydata.token == _token
            ) {
                totalamount += mydata.number;
                mydata.withdrawn = true;
            }
        }
        return (totalamount, _token);
    }

    // This function takes an address of a token as input and returns the total available amount of that token for the caller
    function viewAvailableAmount(address _token) public view returns (uint) {
        uint totalamount; // Initialize a variable to hold the total amount of the token available
        for (uint i = 0; i < traverseTx[msg.sender].length; i++) {
            // Loop through all the transactions of the caller
            MyData storage mydata = combinedArray[traverseTx[msg.sender][i]]; // Get the transaction data from the combined array
            if (
                !mydata.withdrawn &&
                mydata.time <= block.timestamp &&
                mydata.token == _token
            ) {
                // Check if the transaction has not been withdrawn, the time is less than or equal to the current block timestamp, and the token matches the input token
                totalamount += mydata.number; // Add the amount of the token in the transaction to the total amount
            }
        }
        return totalamount; // Return the total amount of the token available for the caller
    }

    function withdrawAll(address _token) external {
        (uint amount, address _tokenx) = getAvailableAmount(_token);

        require(amount > 0, "Zero Amount available At the Moment");

        balances[msg.sender][_tokenx] -= amount;

        withdrawals[msg.sender][_tokenx] += amount;

        IERC20 tokenx = IERC20(_tokenx);

        tokenx.transfer(msg.sender, amount * (10 ** 18));
    }

    function clearArray() public {
        delete combinedArray;
    }

    function getData() public view returns (MyData[] memory) {
        return combinedArray;
    }

    // This function takes an address of a token as input and returns the balance of that token held by the contract
    function getBalance(address _tokenAddress) external view returns (uint256) {
        // Create an instance of the IERC20 interface with the given token address
        IERC20 tokenx = IERC20(_tokenAddress);
        // Return the balance of the token held by the contract
        return tokenx.balanceOf(address(this));
    }
}
