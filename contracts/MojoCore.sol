// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/evm/contracts/ITablelandTables.sol";
import {Base64} from "./libraries/Base64.sol";
import "hardhat/console.sol";

contract MojoCore is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ITablelandTables private _tableland;

    string private _baseURIString = "https://testnet.tableland.network/query?s=";
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _tablePrefix = "mojo";

    string public _name = "not.implemented.com";
    string public _description = "not.implemented.com";
    string public _image = "not.implemented.com";
    string public _externalURL = "not.implemented.com";
    string public _attributes = "not.implemented.com";

    mapping(string => address) public creators;
    mapping(string => string) public records;

    /* Event */
    event NewNftMinted(address indexed from, uint256 timestamp, uint256 tokenId);

    constructor(
      address registry
    ) payable ERC721("MojoNFT", "mNFT") {
      /*
      * registry if the address of the Tableland registry. You can always find those
      * here https://github.com/tablelandnetwork/evm-tableland#currently-supported-chains
      */
      _tableland = ITablelandTables(registry);
      _metadataTableId = _tableland.createTable(
        address(this),
        string(abi.encodePacked(
          "CREATE TABLE ",
          _tablePrefix,
          "_",
          Strings.toString(block.chainid),
          " (id int, name text, description text, image text, external_url text, attributes text);"
        ))
      );
      _metadataTable = string(abi.encodePacked(
        _tablePrefix,
        "_",
        Strings.toString(block.chainid),
        "_",
        Strings.toString(_metadataTableId)
      ));
    }

    /*
    * safeMint allows anyone to mint a token in this project.
    * Any time a token is minted, a new row of metadata will be
    * dynamically insterted into the metadata table.
    */
    function safeMint(
      string calldata name,
      string calldata description,
      string calldata image,
      string calldata externalURL,
      string calldata attributes
    ) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        '", "description": "',
                        description,
                        '", "image": "',
                        image,
                        '", "external_url": "',
                        externalURL,
                        '", "attributes": "',
                        attributes,
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n------NFT Preview--------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");
        _safeMint(msg.sender, newItemId);
        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);
        emit NewNftMinted(msg.sender, block.timestamp, newItemId);
        _tokenIds.increment();
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
    // function tokenURI(uint256 tokenId)
    //   public
    //   view
    //   virtual
    //   override
    //   returns (string memory)
    // {
    //     require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

    //     string memory base = _baseURI();

    //     string memory json_group = "";
    //     string[6] memory cols = ["id", "name", "description", "image", "external_url", "attributes"];
    //     for (uint i; i < cols.length; i++) {
    //       if (i > 0) {
    //         json_group = string.concat(json_group,",");
    //       }
    //       json_group = string.concat(
    //         json_group,
    //         "'",
    //         cols[i],
    //         "',",
    //         cols[i]
    //       );
    //     }

    //     return string.concat(
    //       base,
    //       "SELECT%20",
    //       json_group,
    //       "%20FROM%20",
    //       _metadataTable,
    //       "%20WHERE%20id%3D",
    //       Strings.toString(tokenId),
    //       "&mode=list"
    //     );
    // }

    /*
    * setAttributes updates our Metadata Attributes in Tableland
    */
    function setAttributes(string calldata attributes) external onlyOwner() {
      _attributes = attributes;
      _tableland.runSQL(
        address(this),
        _metadataTableId,
        string.concat(
          "UPDATE ",
          _metadataTable,
          " set attributes = ",
          attributes,
          ";"
        )
      );
    }

    /*
    * setExternalURL provides an example of how to update a field for every
    * row in an table.
    */
    function setExternalURL(string calldata externalURL) external onlyOwner() {
      _externalURL = externalURL;
      _tableland.runSQL(
        address(this),
        _metadataTableId,
        string.concat(
          "update ",
          _metadataTable,
          " set external_url = ",
          externalURL,
          "||'?tokenId='||id", // Turns every row's URL into a URL including get param for tokenId
          ";"
        )
      );
    }

    function _addressToString(address x) internal pure returns (string memory) {
      bytes memory s = new bytes(40);
      for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);
      }
      return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

}
