# Clone of Defi kingdom using avalanche

This is a clone of Defi kingdom using avalanche . It uses solidity and its compiler . It also uses avalanche which is need to be install on the process .

## Description

This is a simple clone of defi kingdom using avalanche which need to be installed using the command (export PATH=~/bin:$PATH >> .bashrc)
after that deploy the two solidityy file in the remix ethereum IDE and perform the tasks like mint, create player , transfer , approve etc.

## Getting Started

### Installing

* Install avalanche using (export PATH=~/bin:$PATH >> .bashrc) this command.
* Install metamask and creation of account to perform task

### Executing program

-> To run this code there is need of terminal and solidity compiler.
-> First install avalanche using terminal
-> Create subnet EVM using this command (avalanche subnet create mysubnet2).
-> Deploy the subnet Created (avalanche subnet deploy mysubnet2).
-> confirm the subnet EVM creation .
-> and use default for a test environment.
-> Use lpcal network
-> And now subnet is ready with balance in account .
-> create new account in metamask and paste the private key .
-> paste the wallet connect information int he metamask network section and by pasting new RPC URL , NETWORK NAME , CHAIN ID, TOKEN NAME AND SYMBOL.
-> after that deploy the game token.sol contract .
-> copy the deployed account of gametoken in the securevault.sol contract and deploy that too.
-> perform task like mint,transfer, create player, approve etc.
-> it all will ask for confirmation from the metamask wallet confirm it.
-> and this is how the project will be completed.

```
* Gametoken.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Amrita";
    string public symbol = "Tuhi";
    uint8 public decimals = 18;

		event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}



* Securevault.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Vault {
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    function deposit(uint _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }
}



```

## Help

```
-> the compiler type and solidity version in code should be same.
-> if subnet with same name is already created then make a new one.
-> chain id can be any number

```

## Authors

Amrita Kumari

https://www.linkedin.com/in/amrita-kumari-753319232/


## License

This project is licensed under the MIT License - see the LICENSE.md file for details
