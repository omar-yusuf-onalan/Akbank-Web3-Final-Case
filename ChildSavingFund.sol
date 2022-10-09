// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract ChildSavingFund {
    address owner;

    event LogChildSavingFundWithdrawn(
        address addr,
        uint256 balance,
        uint256 fundBalance
    );

    constructor() {
        owner = msg.sender;
    }

    struct Child {
        string firstName;
        string lastName;
        address payable walletAddress;
        uint256 balance;
        uint256 withdrawTime;
        bool ableToWithdraw;
    }

    Child[] public children;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner may add children.");
        _;
    }

    function addChild(
        string memory firstName,
        string memory lastName,
        address payable walletAddress,
        uint256 balance,
        uint256 withdrawTime,
        bool ableToWithdraw
    ) public onlyOwner {
        children.push(
            Child(
                firstName,
                lastName,
                walletAddress,
                balance,
                withdrawTime,
                ableToWithdraw
            )
        );
    }

    function addToChildsBalance(address walletAddress) private {
        for (uint256 x = 0; x < children.length; x++) {
            if (children[x].walletAddress == walletAddress) {
                children[x].balance += msg.value;
                emit LogChildSavingFundWithdrawn(
                    walletAddress,
                    msg.value,
                    balanceOf()
                );
            }
        }
    }

    function deposit(address walletAddress) public payable {
        addToChildsBalance(walletAddress);
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function getIndex(address walletAddress) private view returns (uint256) {
        for (uint256 x = 0; x < children.length; x++) {
            if (children[x].walletAddress == walletAddress) {
                return x;
            }
        }
        return 404;
    }

    function CanWithdraw(address walletAddress) public returns (bool) {
        uint256 x = getIndex(walletAddress);
        require(
            block.timestamp > children[x].withdrawTime,
            "You may not withdraw yet."
        );
        if (block.timestamp > children[x].withdrawTime) {
            children[x].ableToWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    function withdraw(address payable walletAddress) public payable {
        uint256 x = getIndex(walletAddress);
        require(
            msg.sender == children[x].walletAddress,
            "You must be the specific child in order to withdraw."
        );
        require(
            children[x].ableToWithdraw == true,
            "You may not withdraw yet."
        );
        children[x].walletAddress.transfer(children[x].balance);
    }
}
