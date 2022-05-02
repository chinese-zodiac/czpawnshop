// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
// If you read this, know that I love you even if your mom doesnt <3
const chai = require('chai');
const { solidity } = require("ethereum-waffle");
chai.use(solidity);

const { ethers, config } = require('hardhat');
const { time } = require("@openzeppelin/test-helpers");
const { toNum, toBN } = require("./utils/bignumberConverter");
const { expect } = require('chai');

const { parseEther } = ethers.utils;

const CZ_NFT = "0x6Bf5843b39EB6D5d7ee38c0b789CcdE42FE396b4";
const CZ_DEPLOYER = "0x70e1cB759996a1527eD1801B169621C18a9f38F9";
const CZUSD_TOKEN = "0xE68b79e51bf826534Ff37AA9CeE71a3842ee9c70";

describe("CZPawnStorage", function () {
  let owner, trader, trader1, trader2, trader3;
  let deployer;
  let czPawnStorage,czNft;
  before(async function() {
    [owner, trader, trader1, trader2, trader3] = await ethers.getSigners();
    await hre.network.provider.request({ 
      method: "hardhat_impersonateAccount",
      params: [CZ_DEPLOYER],
    });
    deployer = await ethers.getSigner(CZ_DEPLOYER);

    czNft = await ethers.getContractAt("CZodiacNFT", CZ_NFT);
    const CZPawnStorage = await ethers.getContractFactory("CZPawnStorage");
    czPawnStorage = await CZPawnStorage.deploy();
  });
  it("Should accept NFT", async function () {
    await czNft.connect(deployer).mint("ipfs://uri",3);
    const totalSupply = await czNft.totalSupply();
    await czNft.connect(deployer).transferFrom(deployer.address,czPawnStorage.address,totalSupply.sub(1));
    const storageBalance = await czNft.balanceOf(czPawnStorage.address);
    expect(storageBalance).to.eq(1);
  });
  it("Should revert without custodian role", async function () {
    const totalSupply = await czNft.totalSupply();
    await expect(
      czPawnStorage.withdraw(czNft.address,totalSupply.sub(1),deployer.address)
    ).to.be.revertedWith(
      "AccessControl: account 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 is missing role 0x5021b8b53ddfbcde6b7315ff88047837720a4fb2dca95d71a400cf1e43c5702f"
    );
  });
  it("Should withdraw NFT", async function () {
    const custodianRole = await czPawnStorage.CUSTODIAN();
    await czPawnStorage.grantRole(custodianRole,owner.address);
    const totalSupply = await czNft.totalSupply();
    await czPawnStorage.withdraw(czNft.address,totalSupply.sub(1),owner.address);
    const storageBalance = await czNft.balanceOf(czPawnStorage.address);
    const ownerBalance = await czNft.balanceOf(owner.address);
    expect(storageBalance).to.eq(0);
    expect(ownerBalance).to.eq(1);
  });

  it("Should withdraw multiple NFT", async function () {
    await czNft.connect(deployer).mint("ipfs://uri",3);
    await czNft.connect(deployer).mint("ipfs://uri",3);
    await czNft.connect(deployer).mint("ipfs://uri",3);
    const totalSupply = await czNft.totalSupply();
    await czNft.connect(deployer).transferFrom(deployer.address,czPawnStorage.address,totalSupply.sub(1));
    await czNft.connect(deployer).transferFrom(deployer.address,czPawnStorage.address,totalSupply.sub(2));
    await czNft.connect(deployer).transferFrom(deployer.address,czPawnStorage.address,totalSupply.sub(3));
    const storageBalanceInitial = await czNft.balanceOf(czPawnStorage.address);
    await czPawnStorage.withdrawAll(czNft.address,owner.address);
    const storageBalanceFinal = await czNft.balanceOf(czPawnStorage.address);
    const ownerBalance = await czNft.balanceOf(owner.address);    
    expect(storageBalanceInitial).to.eq(3);
    expect(storageBalanceFinal).to.eq(0);
    expect(ownerBalance).to.eq(4);
  });
});