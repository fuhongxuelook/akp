//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AKP is Ownable, ERC20 {

    using SafeMath for uint256;

    uint _supply = 1_000_000_000_000_000_000;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public burnFee = 1;

    uint256 totalFee = burnFee;

    mapping(address => bool) public isExcludedFromFees;


    constructor() ERC20("AKP", "AKP") {
        _mint(msg.sender, _supply);
        isExcludedFromFees[msg.sender] = true;
    }

    function changeExcludeFeeStatus(address addr, bool _st) public {
        isExcludedFromFees[addr] = _st;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint feeAmount = amount.mul(totalFee).div(100);
            super._transfer(from, deadWallet, feeAmount);
            amount = amount.sub(feeAmount);
        }

        super._transfer(from, to, amount);
       
    }
   
}
