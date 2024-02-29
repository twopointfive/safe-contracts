// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract OwnableSingleton {
    address internal singleton;
    address internal owner;
}
