//
//  ABIs.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 08.11.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

/// Specifies Plasma Contract address and ABI
public struct PlasmaContract {
    
    /// Plasma contract address
    public static var plasmaAddress = "0x1effBc5DBE9f0daAB73C08e3A00cf105B29C547B"
    
    /// Plasma contract ABI
    public static var plasmaABI = """
    [
      {
        "constant": true,
        "inputs": [],
        "name": "buyoutProcessorContract",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "WithdrawCollateral",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "OutputChallangesDelay",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "plasmaErrorFound",
        "outputs": [
          {
            "name": "",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "lastValidBlock",
        "outputs": [
          {
            "name": "",
            "type": "uint32"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "DepositWithdrawDelay",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "ExitDelay",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "blockStorage",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "operatorsBond",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "bytes22"
          }
        ],
        "name": "succesfulExits",
        "outputs": [
          {
            "name": "",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "limboExitContract",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "depositRecords",
        "outputs": [
          {
            "name": "from",
            "type": "address"
          },
          {
            "name": "status",
            "type": "uint8"
          },
          {
            "name": "hasCollateral",
            "type": "bool"
          },
          {
            "name": "amount",
            "type": "uint256"
          },
          {
            "name": "withdrawStartedAt",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "DepositWithdrawCollateral",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "bytes22"
          }
        ],
        "name": "exitBuyoutOffers",
        "outputs": [
          {
            "name": "amount",
            "type": "uint256"
          },
          {
            "name": "from",
            "type": "address"
          },
          {
            "name": "accepted",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "owner",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "challengesContract",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "bytes22"
          }
        ],
        "name": "exitRecords",
        "outputs": [
          {
            "name": "transactionRef",
            "type": "bytes32"
          },
          {
            "name": "amount",
            "type": "uint256"
          },
          {
            "name": "owner",
            "type": "address"
          },
          {
            "name": "timePublished",
            "type": "uint64"
          },
          {
            "name": "blockNumber",
            "type": "uint32"
          },
          {
            "name": "transactionNumber",
            "type": "uint32"
          },
          {
            "name": "outputNumber",
            "type": "uint8"
          },
          {
            "name": "isValid",
            "type": "bool"
          },
          {
            "name": "isLimbo",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "address"
          },
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "allDepositRecordsForUser",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "InputChallangesDelay",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "depositCounter",
        "outputs": [
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "",
            "type": "address"
          },
          {
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "allExitsForUser",
        "outputs": [
          {
            "name": "",
            "type": "bytes22"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "exitQueue",
        "outputs": [
          {
            "name": "",
            "type": "address"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "name": "_priorityQueue",
            "type": "address"
          },
          {
            "name": "_blockStorage",
            "type": "address"
          }
        ],
        "payable": true,
        "stateMutability": "payable",
        "type": "constructor"
      },
      {
        "payable": true,
        "stateMutability": "payable",
        "type": "fallback"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_lastValidBlockNumber",
            "type": "uint256"
          }
        ],
        "name": "ErrorFoundEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_from",
            "type": "address"
          },
          {
            "indexed": true,
            "name": "_amount",
            "type": "uint256"
          },
          {
            "indexed": true,
            "name": "_depositIndex",
            "type": "uint256"
          }
        ],
        "name": "DepositEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_depositIndex",
            "type": "uint256"
          }
        ],
        "name": "DepositWithdrawStartedEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_depositIndex",
            "type": "uint256"
          }
        ],
        "name": "DepositWithdrawChallengedEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_depositIndex",
            "type": "uint256"
          }
        ],
        "name": "DepositWithdrawCompletedEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_hash",
            "type": "bytes32"
          },
          {
            "indexed": false,
            "name": "_data",
            "type": "bytes"
          }
        ],
        "name": "TransactionPublished",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_hash",
            "type": "bytes22"
          }
        ],
        "name": "ExitRecordCreated",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_hash",
            "type": "bytes22"
          }
        ],
        "name": "ExitChallenged",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_index",
            "type": "uint64"
          }
        ],
        "name": "TransactionIsPublished",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_from",
            "type": "address"
          },
          {
            "indexed": false,
            "name": "_priority",
            "type": "uint72"
          },
          {
            "indexed": true,
            "name": "_index",
            "type": "uint72"
          },
          {
            "indexed": true,
            "name": "_hash",
            "type": "bytes22"
          }
        ],
        "name": "ExitStartedEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_from",
            "type": "address"
          },
          {
            "indexed": true,
            "name": "_priority",
            "type": "uint72"
          },
          {
            "indexed": true,
            "name": "_partialHash",
            "type": "bytes22"
          }
        ],
        "name": "LimboExitStartedEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_partialHash",
            "type": "bytes22"
          },
          {
            "indexed": true,
            "name": "_from",
            "type": "address"
          },
          {
            "indexed": true,
            "name": "_buyoutAmount",
            "type": "uint256"
          }
        ],
        "name": "ExitBuyoutOffered",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "name": "_partialHash",
            "type": "bytes22"
          },
          {
            "indexed": true,
            "name": "_from",
            "type": "address"
          }
        ],
        "name": "ExitBuyoutAccepted",
        "type": "event"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_op",
            "type": "address"
          },
          {
            "name": "_status",
            "type": "uint256"
          }
        ],
        "name": "setOperator",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_buyouts",
            "type": "address"
          }
        ],
        "name": "allowDeposits",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_challenger",
            "type": "address"
          }
        ],
        "name": "allowChallenges",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_limboExiter",
            "type": "address"
          }
        ],
        "name": "allowLimboExits",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_headers",
            "type": "bytes"
          }
        ],
        "name": "submitBlockHeaders",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "lastBlockNumber",
        "outputs": [
          {
            "name": "blockNumber",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [],
        "name": "hashOfLastSubmittedBlock",
        "outputs": [
          {
            "name": "",
            "type": "bytes32"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [],
        "name": "incrementWeekOldCounter",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_outputNumber",
            "type": "uint8"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          }
        ],
        "name": "startExit",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_exitRecordHash",
            "type": "bytes22"
          },
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          },
          {
            "name": "_inputNumber",
            "type": "uint8"
          }
        ],
        "name": "challengeNormalExitByShowingExitBeingSpent",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_originalTransaction",
            "type": "bytes"
          },
          {
            "name": "_originalInputNumber",
            "type": "uint8"
          },
          {
            "name": "_exitRecordHash",
            "type": "bytes22"
          },
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          },
          {
            "name": "_inputNumber",
            "type": "uint8"
          }
        ],
        "name": "challengeNormalExitByShowingAnInputDoubleSpend",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_originalTransaction",
            "type": "bytes"
          },
          {
            "name": "_originalInputNumber",
            "type": "uint8"
          },
          {
            "name": "_exitRecordHash",
            "type": "bytes22"
          },
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          },
          {
            "name": "_outputNumber",
            "type": "uint8"
          }
        ],
        "name": "challengeNormalExitByShowingMismatchedInput",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_numOfExits",
            "type": "uint256"
          }
        ],
        "name": "finalizeExits",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          }
        ],
        "name": "isWellFormedTransaction",
        "outputs": [
          {
            "name": "isWellFormed",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [],
        "name": "deposit",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_for",
            "type": "address"
          }
        ],
        "name": "depositFor",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_index",
            "type": "bytes22"
          },
          {
            "name": "_beneficiary",
            "type": "address"
          }
        ],
        "name": "offerOutputBuyout",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_index",
            "type": "bytes22"
          }
        ],
        "name": "acceptBuyoutOffer",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_index",
            "type": "bytes22"
          }
        ],
        "name": "returnExpiredBuyoutOffer",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "depositIndex",
            "type": "uint256"
          }
        ],
        "name": "startDepositWithdraw",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "depositIndex",
            "type": "uint256"
          }
        ],
        "name": "finalizeDepositWithdraw",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "depositIndex",
            "type": "uint256"
          },
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          }
        ],
        "name": "challengeDepositWithdraw",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber1",
            "type": "uint32"
          },
          {
            "name": "_inputNumber1",
            "type": "uint8"
          },
          {
            "name": "_plasmaTransaction1",
            "type": "bytes"
          },
          {
            "name": "_merkleProof1",
            "type": "bytes"
          },
          {
            "name": "_plasmaBlockNumber2",
            "type": "uint32"
          },
          {
            "name": "_inputNumber2",
            "type": "uint8"
          },
          {
            "name": "_plasmaTransaction2",
            "type": "bytes"
          },
          {
            "name": "_merkleProof2",
            "type": "bytes"
          }
        ],
        "name": "proveDoubleSpend",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          },
          {
            "name": "_originatingPlasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_originatingMerkleProof",
            "type": "bytes"
          },
          {
            "name": "_inputNumber",
            "type": "uint8"
          }
        ],
        "name": "proveSpendAndWithdraw",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          }
        ],
        "name": "proveInvalidDeposit",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber1",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction1",
            "type": "bytes"
          },
          {
            "name": "_merkleProof1",
            "type": "bytes"
          },
          {
            "name": "_plasmaBlockNumber2",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction2",
            "type": "bytes"
          },
          {
            "name": "_merkleProof2",
            "type": "bytes"
          }
        ],
        "name": "proveDoubleFunding",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaInputNumberInTx",
            "type": "uint8"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          }
        ],
        "name": "proveReferencingInvalidBlock",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {
            "name": "_plasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_plasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_merkleProof",
            "type": "bytes"
          },
          {
            "name": "_originatingPlasmaBlockNumber",
            "type": "uint32"
          },
          {
            "name": "_originatingPlasmaTransaction",
            "type": "bytes"
          },
          {
            "name": "_originatingMerkleProof",
            "type": "bytes"
          },
          {
            "name": "_inputOfInterest",
            "type": "uint256"
          }
        ],
        "name": "proveBalanceOrOwnershipBreakingBetweenInputAndOutput",
        "outputs": [
          {
            "name": "success",
            "type": "bool"
          }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]
    """
}
