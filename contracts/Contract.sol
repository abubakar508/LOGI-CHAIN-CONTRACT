// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogisticsContract {
    enum PackageStatus { Pending, InTransit, Delivered, Failed }

    struct Package {
        address sender;
        address carrier;
        address recipient;
        uint256 packageId;
        PackageStatus status;
    }

    mapping(uint256 => Package) private packages;
    uint256 private packageCount;

    event PackageSent(uint256 packageId, address sender, address recipient);
    event PackageStatusChanged(uint256 packageId, PackageStatus status);
    event CarrierAssigned(uint256 packageId, address carrier);

    function sendPackage(address _recipient) external {
        uint256 newPackageId = packageCount++;
        Package storage newPackage = packages[newPackageId];

        newPackage.sender = msg.sender;
        newPackage.recipient = _recipient;
        newPackage.status = PackageStatus.Pending;

        emit PackageSent(newPackageId, msg.sender, _recipient);
    }

    function updatePackageStatus(uint256 _packageId, PackageStatus _status) external {
        require(_status >= PackageStatus.Pending && _status <= PackageStatus.Failed, "Invalid status");

        Package storage package = packages[_packageId];
        require(package.sender == msg.sender || package.recipient == msg.sender || package.carrier == msg.sender, "Unauthorized");

        package.status = _status;

        emit PackageStatusChanged(_packageId, _status);
    }

    function assignCarrier(uint256 _packageId, address _carrier) external {
        Package storage package = packages[_packageId];
        require(package.sender == msg.sender, "Only sender can assign a carrier");

        package.carrier = _carrier;

        emit CarrierAssigned(_packageId, _carrier);
    }

    // Additional function to retrieve package details
    function getPackageDetails(uint256 _packageId) external view returns (Package memory) {
        return packages[_packageId];
    }
}
