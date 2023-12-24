// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //version of the solidity being used


// name of the contract 

contract LogisticsContract {
    // enum package status deifne possible states a package can have

    enum PackageStatus { Pending, InTransit, Delivered, Failed }


// defines a custom data structure of our smart contract 'PACKAGE"
    struct Package {
        address sender;
        address carrier;
        address recipient;
        uint256 packageId;
        PackageStatus status;
    }

// creates mappig where package IDS ARE MAPPED to their respective package structs(structures)
    mapping(uint256 => Package) public packages;
    uint256 public packageCount;


// event emitter: like in javascript: logs specific occurences on the blockchain
    event PackageSent(uint256 packageId, address sender, address recipient);
    event PackageStatusChanged(uint256 packageId, PackageStatus status);

// allows an externla caller to send a package to a different address(a recipient): takes recepient as an argument
    function sendPackage(address _recipient) external {
        uint256 newPackageId = packageCount++;
        Package storage newPackage = packages[newPackageId];
        
        newPackage.sender = msg.sender;
        newPackage.recipient = _recipient;
        newPackage.status = PackageStatus.Pending;
        
        emit PackageSent(newPackageId, msg.sender, _recipient);
    }


// allows the sender, recipient, or assigned carrier to update the status of a package.
    function updatePackageStatus(uint256 _packageId, PackageStatus _status) external {
        require(_status >= PackageStatus.Pending && _status <= PackageStatus.Failed, "Invalid status");

        Package storage package = packages[_packageId];
        require(package.sender == msg.sender || package.recipient == msg.sender || package.carrier == msg.sender, "Unauthorized");

        package.status = _status;

        emit PackageStatusChanged(_packageId, _status);
    }

// allows the sender to assign a carrier for a package. 
    function assignCarrier(uint256 _packageId, address _carrier) external {
        Package storage package = packages[_packageId];
        require(package.sender == msg.sender, "Only sender can assign a carrier");

        package.carrier = _carrier;
    }
}
