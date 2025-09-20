# DPay – Decentralized Payment & Request System  

**DPay** is a Solidity smart contract that enables peer-to-peer payments with support for wallet names, payment requests, and transaction history.  

---

## 🚀 Features
- Add a **username** to your wallet address.  
- Create **payment requests** with amount and message.  
- **Pay requests** directly with ETH (with amount validation).  
- Maintain **send/receive history** for every user.  
- Contract **owner control** with secure ownership transfer.  

---

## 🛠️ Tech Stack
- **Solidity** `^0.8.28`  
- Works on **Ethereum & EVM-compatible chains**  
- Compatible with **Hardhat / Foundry**  

---

## 📜 Contract Overview
- `addName(string _name)` → Add a username for your wallet.  
- `createRequest(address _user, uint256 _amount, string _msg)` → Request payment from another user.  
- `payRequest(uint256 _request)` → Pay a pending request (in ETH).  
- `getMyRequests(address _user)` → View all requests for a user.  
- `getHistory(address _user)` → View full transaction history.  
- `getMyName(address _user)` → Retrieve username for a wallet.  

---

## 📦 Deployment
```bash
# Install dependencies
npm install

# Clone the repository
https://github.com/Sidharth77777/DecentralisedPay-contract.git
cd contract

# Compile contract
npx hardhat compile

# Deploy contract (update scripts/deploy.js)
npx hardhat run scripts/deploy.js --network <network>
