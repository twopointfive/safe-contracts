
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface IProxy {
    function masterCopy() external view returns (address);
}

interface IBlast{
    // base configuration options
    function configureClaimableYield() external;
    function configureClaimableGas() external;
    function configureGovernor(address _gov) external;
}

interface IBlastPoints {
    function configurePointsOperator(address operator) external;
}

contract BakeryProxy {
    address internal singleton;
    address internal proxyOwner;

    constructor(address _singleton, address _proxyOwner, address blastPoint, address _op, address _gov) {
        singleton = _singleton;
        proxyOwner = _proxyOwner;
        IBlastPoints(blastPoint).configurePointsOperator(_op);
        IBlast(blastPoint).configureClaimableYield() ;
        IBlast(blastPoint).configureClaimableGas();
        IBlast(blastPoint).configureGovernor(_gov);
    }

    function upgrade(address _singleton) external {
        require(msg.sender == proxyOwner, "BP02");
        singleton = _singleton;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
    fallback() external payable {
        // solhint-disable-next-line no-inline-assembly
        require(singleton != address(0), "BP01");
        assembly {
            let _singleton := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            // 0xa619486e == keccak("masterCopy()"). The value is right padded to 32-bytes with 0s
            if eq(calldataload(0), 0xa619486e00000000000000000000000000000000000000000000000000000000) {
                mstore(0, _singleton)
                return(0, 0x20)
            }
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), _singleton, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }
}
