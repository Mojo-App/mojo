// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/evm/contracts/ITablelandTables.sol";

contract MojoCore is
    ERC721URIStorageUpgradeable,
    ERC721HolderUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ITablelandTables private _tableland;

    string private _baseURIString;
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _tablePrefix;
    string private _externalURL;

    /* Event */
    event NewNftMinted(
      address indexed from,
      uint256 timestamp,
      uint256 tokenId
    );

    event SetNftExternalUrl(
      address indexed from,
      uint256 timestamp,
      uint256 metadataTableId,
      string metadataTable
    );

    event SetNftAID(
      address indexed from,
      uint256 timestamp,
      uint256 aid,
      uint256 tokenId
    );

    event SetNftGID(
      address indexed from,
      uint256 timestamp,
      uint256 gid,
      uint256 tokenId
    );

    function initialize(string memory baseURI, string memory externalURL) public initializer {
        __ERC721URIStorage_init();
        __ERC721Holder_init();
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        _baseURIString = baseURI;
        _tablePrefix = "mojo";
        _externalURL = externalURL;
    }

    function createMetadataTable(address registry) external payable onlyOwner returns (uint256) {
        /*
         * registry if the address of the Tableland registry. You can always find those
         * here https://github.com/tablelandnetwork/evm-tableland#currently-supported-chains
         */
        _tableland = ITablelandTables(registry);

        _metadataTableId = _tableland.createTable(
            address(this),
            /*
             *  CREATE TABLE prefix_chainId (
             *    int id,
             *    string name,
             *    string description,
             *    string external_link,
             *    int x,
             *    int y
             *  );
             */
            string.concat(
                "CREATE TABLE ",
                _tablePrefix,
                "_",
                Strings.toString(block.chainid),
                " (id int, external_link text, aid int, gid int);"
            )
        );

        return _metadataTableId;
    }

    /*
     * safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically insterted into the metadata table.
     */
    function safeMint(address to) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "INSERT INTO ",
                _metadataTable,
                " (id, external_link, aid, gid) VALUES (",
                Strings.toString(newItemId),
                ", '",
                _externalURL,
                "', 0, 0)"
            )
        );
        _safeMint(to, newItemId, "");
        // _setTokenURI(newItemId, newTokenURI);
        _tokenIds.increment();
        emit NewNftMinted(msg.sender, block.timestamp, newItemId);
        return newItemId;
    }

    /*
     * updateAID is an Attributes Table
     */
    function updateAID(
        uint256 tokenId,
        uint256 aid
    ) public {
        // check token ownership
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        // Update the row in tableland
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                _metadataTable,
                " SET aid = ",
                Strings.toString(aid),
                " WHERE id = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit SetNftAID(msg.sender, block.timestamp, _metadataTableId, tokenId);
    }

    /*
     * updateGID is an Attributes Table
     */
    function updateGID(
        uint256 tokenId,
        uint256 gid
    ) public {
        // check token ownership
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        // Update the row in tableland
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                _metadataTable,
                " SET gid = ",
                Strings.toString(gid),
                " WHERE id = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit SetNftGID(msg.sender, block.timestamp, _metadataTableId, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIString;
    }

    /*
     * tokenURI is an example of how to turn a row in your table back into
     * erc721 compliant metadata JSON. here, we do a simple SELECT statement
     * with function that converts the result into json.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory base = _baseURI();

        string memory json_group = "";
        string[4] memory cols = ["id", "external_link", "aid", "gid"];
        for (uint256 i; i < cols.length; i++) {
            if (i > 0) {
                json_group = string.concat(json_group, ",");
            }
            json_group = string.concat(json_group, "'", cols[i], "',", cols[i]);
        }

        return
            string.concat(
                base,
                "SELECT%20",
                json_group,
                "%20FROM%20",
                _metadataTable,
                "%20WHERE%20id%3D",
                Strings.toString(tokenId),
                "&mode=list"
            );
    }

    /*
     * setExternalURL provides an example of how to update a field for every
     * row in an table.
     */
    function setExternalURL(string calldata externalURL) external onlyOwner {
        _externalURL = externalURL;
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "update ",
                _metadataTable,
                " set external_link = ",
                externalURL,
                "||'?tokenId='||id", // Turns every row's URL into a URL including get param for tokenId
                ";"
            )
        );
        emit SetNftExternalUrl(msg.sender, block.timestamp, _metadataTableId, _metadataTable);
    }

    function _addressToString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    /**
     * @dev See {UUPSUpgradeable-_authorizeUpgrade}.
     */
    function _authorizeUpgrade(address) internal view override onlyOwner {} // solhint-disable no-empty-blocks
}
