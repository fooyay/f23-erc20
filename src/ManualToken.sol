// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint256) private s_balances;

    // function name() public pure returns (string memory) {
    //     return "Manual Token";
    // }
    string public name = "Manual Token";

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 previousBalance = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        assert(balanceOf(msg.sender) + balanceOf(_to) == previousBalance);
    }

    // and we can see that continue to implement this manually is waste of
    // time, since there's a library from this, called OpenZeppelin
}
