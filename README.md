This project is a Web 3 version of the in real life Child saving fund (without a frontend interface) in which parents deposit funds into a bank account that their children are able to withdraw after a certain amount of time.

The parent deploys the contract, becoming the "owner" variable. 

Then, the parent adds children, who are defined as structs, through the addChild function. 

After defining the characteristics of the child, which include wallet address and the specific time the child can withdraw the funds invested in them, the parent can deposit funds into the smart contract through the deposit function.

Children can check the funds invested into them by using the balance function, and finally, they can withdraw the funds to their wallet when the specified time has come with the withdraw function.