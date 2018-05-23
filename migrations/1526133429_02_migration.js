var Mineority = artifacts.require("./MineorityCore.sol");

module.exports = function(deployer) {
  deployer.deploy(Mineority).then(() => {
    Mineority.deployed().then((instance) => {
      instance.setPrice(1,1,815,0,{ from: web3.eth.accounts[0] });
      instance.setPrice(1,2,1030,0,{ from: web3.eth.accounts[0] });
      instance.setPrice(1,3,1240,0,{ from: web3.eth.accounts[0] });
      instance.setPrice(2,2,2500,0,{ from: web3.eth.accounts[0] });
      instance.setPrice(2,3,3050,0,{ from: web3.eth.accounts[0] });
      
      instance.setCFO("0x1677D1d23064a19cB630706A2eF48251D8c2d3F2",{ from: web3.eth.accounts[0] });      
      return instance.setCTO("0x68b2246b8969CA71069f7b3ff97B90F708de6064",{from: web3.eth.accounts[0]});});
  });
};
