// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import "@tableland/evm/contracts/utils/URITemplate.sol";
import '@tableland/evm/contracts/ITablelandTables.sol';

// Import this file to use console.log
import 'hardhat/console.sol';

contract MojoCore is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ITablelandTables private _tableland;

    // The testnet gateway URI plus query parameter
    string private _baseURIString = "https://testnet.tableland.network/query?mode=list&s=";
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _tablePrefix = 'mojo';

    /* Event */
    event NewNftMinted(address indexed from, uint256 timestamp, uint256 tokenId);
    event NftUpdated(address indexed from, uint256 timestamp, NFT nft);

    struct NFT {
        uint256 tokenId;
        string name;
        string description;
        string imageUrl;
        string externalUrl;
    }

    constructor(address registry) ERC721('MojoNFT', 'mNFT') {
        /*
         * registry if the address of the Tableland registry. You can always find those
         * here https://github.com/tablelandnetwork/evm-tableland#currently-supported-chains
         */
        _tableland = ITablelandTables(registry);

        /*
         * Stores the unique ID for the newly created table.
         */
        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                'CREATE TABLE ',
                _tablePrefix,
                '_',
                Strings.toString(block.chainid),
                ' (id int, name text, description text, image text, external_url text, PRIMARY KEY (id));'
            )
        );
        console.log('_metadataTableId', _metadataTableId);

        /**
         * Stores the full tablename for the new media table.
         * {prefix}_{chainid}_{tableid}
         */
        _metadataTable = string.concat(
            _tablePrefix,
            '_',
            Strings.toString(block.chainid),
            '_',
            Strings.toString(_metadataTableId)
        );
        console.log('_metadataTable', _metadataTable);
    }
    /*
     * safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically inserted into the Tableland metadata table.
     */
    function safeMint(address to, NFT memory nft) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        /* Tableland Insert */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                'INSERT INTO ',
                _metadataTable,
                ' (id, name, description, image, external_url, background_color, attributes) VALUES (',
                Strings.toString(newItemId),
                ', ',
                nft.name,
                ', ',
                nft.description,
                ', ',
                nft.imageUrl,
                ', ',
                nft.externalUrl,
                ')'
            )
        );
        _safeMint(to, newItemId, '');
        _setTokenURI(newItemId, tokenURI(newItemId));

        console.log('nft.name', nft.name);
        console.log('nft.description', nft.description);
        console.log('nft.imageUrl', nft.imageUrl);
        console.log('nft.externalUrl', nft.externalUrl);

        /* Increment tokenId for our next minting */
        _tokenIds.increment();
        /* Emit our newly created NFT to our front-end */
        emit NewNftMinted(msg.sender, block.timestamp, newItemId);
        /* Return tokenId */
        return newItemId;
    }

    /*
     * updateNFT allows NFT owners to update a tokens core NFT Tableland metadata
     */
    function updateNFT(NFT memory nft) public {
        // Check token ownership
        require(this.ownerOf(nft.tokenId) == msg.sender, 'Invalid owner');
        // Update the row in tableland
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                'UPDATE ',
                _metadataTable,
                ' SET name = ',
                nft.name,
                'AND description = ',
                nft.description,
                'AND image = ',
                nft.imageUrl,
                'AND external_url = ',
                nft.externalUrl,
                ' WHERE id = ',
                Strings.toString(nft.tokenId),
                ';'
            )
        );
        /* Emit our updated NFT to our front-end */
        emit NftUpdated(msg.sender, block.timestamp, nft);
    }

    // The base URI used by tokenURI
    function _baseURI() internal view override returns (string memory) {
      return _baseURIString;
    }

    // Ensures the contract owner can easily update the project's baseURI
    function setBaseURI(string memory baseURI) public onlyOwner {
      _baseURIString = baseURI;
    }

    /*
     * tokenURI is an example of how to turn a row in your table back into
     * erc721 compliant metadata JSON. here, we do a simple SELECT statement
     * with function that converts the result into json.
     */
    function tokenURI(uint256 tokenId)
      public
      view
      virtual
      override
      returns (string memory)
    {
        require(_exists(tokenId), 'ERC721URIStorage: URI query for nonexistent token');

        string memory base = _baseURI();
        string memory json_group = '';
        string[5] memory cols = [
            'id',
            'name',
            'description',
            'image',
            'external_url'
        ];
        for (uint256 i; i < cols.length; i++) {
            if (i > 0) {
                json_group = string.concat(json_group, ',');
            }
            json_group = string.concat(json_group, "'", cols[i], "',", cols[i]);
        }

        return
            string.concat(
                base,
                'SELECT%20',
                json_group,
                '%20FROM%20',
                _metadataTable,
                '%20WHERE%20id%3D',
                Strings.toString(tokenId),
                '&mode=list'
            );
    }

    /**
     * View the Contract’s Metadata Table
     */
    function metadataURI() public view returns (string memory) {
        string memory base = _baseURI();
        return string.concat(
          base,
          'SELECT%20*%20FROM%20',
          _metadataTable
        );
    }
}
