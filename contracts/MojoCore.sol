// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/evm/contracts/ITablelandTables.sol";

contract MojoCore is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ITablelandTables private _tableland;

    string private _baseURIString = "https://testnet.tableland.network/query?s=";
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _tablePrefix = "mojo";
    string private _externalURL = "not.implemented.com";

    /* Event */
    event NewNftMinted(address indexed from, uint256 timestamp, uint256 tokenId);

    constructor(address registry) ERC721("MojoNFT", "mNFT") {
        _tableland = ITablelandTables(registry);

        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                _tablePrefix,
                "_",
                Strings.toString(block.chainid),
                " (id int, external_link text);"
            )
        );

        _metadataTable = string.concat(
            _tablePrefix,
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_metadataTableId)
        );
    }

    /*
     * safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically inserted into the metadata table.
     */
    function safeMint(address to, string memory newTokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "INSERT INTO ",
                _metadataTable,
                " (id, external_link) VALUES (",
                Strings.toString(newItemId),
                ", '",
                _externalURL,
                "')"
            )
        );

        _safeMint(to, newItemId, "");
        _setTokenURI(newItemId, newTokenURI);
        emit NewNftMinted(msg.sender, block.timestamp, newItemId);
        return newItemId;
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
        string[2] memory cols = ["id", "external_link"];
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
    }
}
