// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogisticsContract {
    enum PackageStatus { Pending, InTransit, Delivered, Failed }

    // Define the PACKAGE structure with proper spelling
    struct Package {
        address sender;
        address carrier;
        address recipient;
        uint256 packageId;
        PackageStatus status;
    }

    // Change "ARE MAPPED" to "are mapped" and add access specifier to packageCount
    mapping(uint256 => Package) public packages;
    uint256 public packageCount;

    // Event for package sent
    event PackageSent(uint256 packageId, address sender, address recipient);

    // Event for package status change
    event PackageStatusChanged(uint256 packageId, PackageStatus status);

    // External function to send a package to a specified recipient
    function sendPackage(address _recipient) external {
        // Increment packageCount first to ensure unique IDs
        uint256 newPackageId = packageCount++;
        Package storage newPackage = packages[newPackageId];

        newPackage.sender = msg.sender;
        newPackage.recipient = _recipient;
        newPackage.status = PackageStatus.Pending;

        emit PackageSent(newPackageId, msg.sender, _recipient);
    }

    // External function to update the status of a package
    function updatePackageStatus(uint256 _packageId, PackageStatus _status) external {
        // Move the status validation check to the beginning
        require(_status >= PackageStatus.Pending && _status <= PackageStatus.Failed, "Invalid status");

        Package storage package = packages[_packageId];
        require(package.sender == msg.sender || package.recipient == msg.sender || package.carrier == msg.sender, "Unauthorized");

        package.status = _status;

        emit PackageStatusChanged(_packageId, _status);
    }

    // External function to assign a carrier for a package
    function assignCarrier(uint256 _packageId, address _carrier) external {
        Package storage package = packages[_packageId];
        require(package.sender == msg.sender, "Only sender can assign a carrier");

        package.carrier = _carrier;
    }
}
