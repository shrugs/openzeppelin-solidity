require('dotenv').config();

const { createAutoNetwork } = require('buidler/src/core/web3/network');

const HDWalletProvider = require('truffle-hdwallet-provider');

const providerWithMnemonic = (mnemonic, rpcEndpoint) =>
  new HDWalletProvider(mnemonic, rpcEndpoint);

const infuraProvider = network => providerWithMnemonic(
  process.env.MNEMONIC || '',
  `https://${network}.infura.io/${process.env.INFURA_API_KEY}`
);

const ropstenProvider = process.env.SOLIDITY_COVERAGE
  ? undefined
  : infuraProvider('ropsten');

module.exports = {
  networks: {
    test: {
      provider () {
        return createAutoNetwork(this);
      },
      blockGasLimit: 8000000,
      accounts: [
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501202',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501203',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501204',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501205',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501206',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501207',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208',
          balance: '1000000000000000000000000',
        },
        {
          privateKey: '0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501209',
          balance: '1000000000000000000000000',
        },
      ],
    },
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // eslint-disable-line camelcase
    },
    ropsten: {
      provider: ropstenProvider,
      network_id: 3, // eslint-disable-line camelcase
    },
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
    ganache: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // eslint-disable-line camelcase
    },
  },
};
