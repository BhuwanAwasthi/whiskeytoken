
# Whisky Token Smart Contract

This repository contains the Solidity smart contract for Whisky Tokens, enabling fractional ownership of rare and valuable whisky barrels/casks.

## Functionality

The smart contract allows users to create whisky casks, purchase fractions of casks, exit casks, handle disputes, transfer ownership, and split fractions. It supports the creation and management of whisky tokens representing ownership shares in casks.

## Deployment and Testing

To deploy and test the smart contract, follow these steps:

1. Clone this repository to your local machine

2. Install dependencies (if any are required)
  
3. Deploy the smart contract to a blockchain network using your preferred development environment or tool (e.g., Remix, Truffle).

4. Interact with the contract using a web3-enabled tool, such as Remix, Truffle Console, or a custom web application.

## Dependencies

The smart contract was developed using Solidity version >=0.7.0 <0.9.0.

## Challenges and Solutions

During the development of this smart contract, we encountered the following challenges and addressed them accordingly:

1. **Handling Fractional Ownership**: Implementing a secure and efficient mechanism for fractional ownership required careful consideration of data structures and storage patterns.

   Solution: We utilized mappings and struct data types to represent casks and ownership information. Each cask contains details about its owner, total fractions, fraction price, and more.

2. **Dispute Resolution**: Creating a dispute resolution mechanism that ensures fairness and transparency was important.

   Solution: We implemented a dispute filing and resolution process where claims can be made by participants. The owner of the contract can then decide whether to resolve the dispute or not.

3. **Efficient Profit Calculation**: Calculating profits for cask owners based on fractional ownership and exit prices needed a well-optimized approach.

   Solution: We incorporated a function that calculates profits by considering the total fractions owned and the price difference between fraction price and exit price.

4. **User-Friendly Interaction**: Ensuring that users can easily interact with the contract, purchase fractions, and manage casks was a priority.

   Solution: We documented clear instructions for deployment, testing, and interaction in this README.

## Contact

For questions or inquiries, please contact me at: bhuwanawasthi2021@gmail.com



