// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "forge-std/console.sol";
import "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import "@seaport/interfaces/SeaportInterface.sol";



interface IFlashLoans {
    function flashLoan(address recipient, address[] calldata tokens, uint256[] calldata amounts, bytes calldata params) external;
}


contract FlashBuyer {
    address owner;
    address vault;
    address ft;
    SeaportInterface seaport;

    constructor(address _vault, address _seaport, address _ft) {
        owner = msg.sender;
        vault = _vault;
        seaport = SeaportInterface(_seaport);
        ft = _ft;
    }

    function withdrawFT(address tokenAddress) external returns(uint256 balance) {
    }

    function withdrawNFT(address tokenAddress, uint256 tokenId) external {
    }

    function flashLoan(uint256 amount, bytes calldata order) external {
        console.log(IERC20(ft).balanceOf(address(this)));
        address[] memory tokens = new address[](1);
        tokens[0] = ft;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        IFlashLoans(vault).flashLoan(address(this), tokens, amounts, order);
    }

    function receiveFlashLoan(address[] calldata tokens, uint256[] calldata amounts, uint256[] calldata feeAmounts, bytes calldata params) external {
        require(msg.sender == vault, "!SENDER");
        require(amounts.length == 1, "!LEN#1");
        require(tokens.length == 1, "!LEN#2");
        require(tokens[0] == ft, "!FT");
        require(feeAmounts[0] == 0, "!FEE");

        uint256 amount = amounts[0];

        // Fulfill order
        (bool success, ) =
            address(seaport).call(abi.encodePacked(seaport.fulfillBasicOrder.selector, params));
        require(success, "!SEA");

        // Get back loan
        IERC20(ft).transferFrom(owner, address(this), 124375e18);
        IERC20(ft).transferFrom(0xcD31c23B84475a7392E2f86119Be188BC2e7F197, address(this), 625e18);

        // Repay loan
        IERC20(ft).transfer(vault, amount);
    }

    function approveWeth() external {
        IERC20(ft).approve(address(seaport), 99999999999999999999999999999999999);
        IERC20(ft).approve(0x1E0049783F008A0085193E00003D00cd54003c71, 99999999999999999999999999999999999);
    }
}
