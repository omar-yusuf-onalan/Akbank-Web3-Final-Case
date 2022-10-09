// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract ChildSavingFund {
    // Defined the family elder who will allocate funds.
    address owner;

    event LogChildSavingFundWithdrawn(address addr, uint balance, uint fundBalance);


	// The constructor is run only once when the smart contract is first deployed. 
	// Here, we declare the owner who will be allocating funds into smart contract which will be distributed to the children.
	// When the smart contract is deployed, the family elder will be the owner of the contract.
    constructor() {
        owner = msg.sender;
    }

    // Defined the children who will be receivig the saving funds when they reach a certain age. 
    // Structs are like objects in Javascript.
    struct Child {
        string firstName;
        string lastName;
        address payable walletAddress;
        uint balance;
        uint withdrawTime;
        bool ableToWithdraw;
    }

    // This is the array of children that will be receiving the saving funds. 
    // A number is not present in the square brackets as the number of children may change with time.
    Child[] public children;

    // Require is utilizied so that only the family elder, who is also the owner, can add children into the saving fund plan. 
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner may add children.");
        _;
    }

    // This function adds a child to the contract. Corresponding to the characteristics of struct Child, information about
    // the child must be entered.
    function addChild(string memory firstName, string memory lastName, address payable walletAddress, uint balance, uint withdrawTime, bool ableToWithdraw) public onlyOwner {
        children.push(Child(
            firstName,
            lastName,
            walletAddress,
            balance,
            withdrawTime,
            ableToWithdraw
        ));
    }

    // This function will be utilized to deposit funds.
    function addToChildsBalance(address walletAddress) private {
        for(uint x = 0; x < children.length; x++) {
            if(children[x].walletAddress == walletAddress) {
                children[x].balance += msg.value;
                emit LogChildSavingFundWithdrawn(walletAddress, msg.value, balanceOf());
            }
        }
    }

    // This function deposits funds into the smart contract.
    // The funds deposit into a specific child's address.
    function deposit(address walletAddress) payable public {
        addToChildsBalance(walletAddress);
    }

    // Children added to the saving fund can learn their balance by entering their address into this function.
    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    
    // This function returns the index of a child by using their added wallet address.
    function getIndex(address walletAddress) view private returns(uint) {
        for(uint x = 0; x < children.length; x++) {
            if (children [x].walletAddress == walletAddress) {
                return x;
            }
        }
        return 404;
    }

    // Children added to the saving fund can learn if they are able to withdraw the funds from the contract with this function.  
    function CanWithdraw(address walletAddress) public returns(bool) {
        uint x = getIndex(walletAddress);
        require(block.timestamp > children[x].withdrawTime, "You may not withdraw yet.");
        if (block.timestamp > children[x].withdrawTime) {
            children[x].ableToWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // After confirming that they can withdraw money from the contract, the children may utilize the withdraw function below to withdraw the money in their saving fund.
    // If the person withdrawing the funds is not a child that is added to the saving fund or if they are but, their time to withdraw has not come yet, then the smart
    // contract will throw an error.
    function withdraw(address payable walletAddress) payable public {
        uint x = getIndex(walletAddress);
        require(msg.sender == children[x].walletAddress, "You must be the specific child in order to withdraw.");
        require(children[x].ableToWithdraw == true, "You may not withdraw yet.");
        children[x].walletAddress.transfer(children[x].balance);
    }

}