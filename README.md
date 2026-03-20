# Electronic Voting System with Blockchain

This is an electronic voting system built using Ethereum and Solidity for the backend, IPFS for storage, Flutter for mobile app development, and a React-based website for the frontend. The project leverages blockchain technology to ensure secure, transparent, and tamper-proof elections.

## Features

- **Decentralized Voting**: Securely cast votes on the Ethereum blockchain.
- **IPFS Storage**: Store and manage large datasets using IPFS.
- **Flutter Mobile App**: Intuitive user interface for voting.
- **React-Based Website**: Public interface to view results, announce outcomes, and provide information about the election.

## Technologies Used

- **Blockchain**: Ethereum
- **Smart Contracts**: Solidity
- **Storage**: IPFS
- **Mobile App**: Flutter (Dart)
- **Frontend**: React Vite
- **Development Environment**: Truffle, Ganache
- **Deployment**: [Specify deployment tools or environments]

## Getting Started

### Prerequisites

1. **Node.js and npm/yarn**
   - Install Node.js from [nodejs.org](https://nodejs.org/)
2. **Ethereum Development Tools**
   - Install Ganache CLI: `npm install -g ganache-cli`
3. **Flutter SDK**
   - Download and install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/mclovin22117/e-voting_app.git
   cd electronic-voting
   ```

2. **Install Dependencies**

   - **Frontend (React Vite)**

     ```bash
     cd frontend
     npm install
     ```

   - **Backend (Truffle and Ganache)**

     ```bash
     cd backend
     truffle compile
     ganache-cli
     ```

3. **Run the Frontend**

   ```bash
   cd frontend
   npm run dev
   ```

4. **Run the Backend**

   In a new terminal:

   ```bash
   cd backend
   truffle migrate --network development
   ```

### Usage

1. **Start Voting**
   - Open the React-based website in your browser.
   - Register and login to vote using your Ethereum address.
   - Cast votes according to the election rules.

2. **Access Mobile App**
   - Download the Flutter app from the respective app store (e.g., Google Play Store, Apple App Store).
   - Register with your Ethereum address.
   - Cast votes from your mobile device.

3. **View Results**
   - Visit the public website to view the election results and outcomes.
---
