// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@tableland/evm/contracts/ITablelandTables.sol';

// Import this file to use console.log
import 'hardhat/console.sol';

contract MojoCore is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    ITablelandTables private _tableland;

    string private _baseURIString = 'https://testnet.tableland.network/query?s=';
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _metadataAttrTable;
    uint256 private _metadataAttrTableId;
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
        string backgroundColor;
        string attributes;
    }

    NFT[] public nfts;

    constructor(address registry) ERC721('MojoNFT', 'mNFT') {
        /*
         * registry if the address of the Tableland registry. You can always find those
         * here https://github.com/tablelandnetwork/evm-tableland#currently-supported-chains
         */
        _tableland = ITablelandTables(registry);

        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                'CREATE TABLE ',
                _tablePrefix,
                '_',
                Strings.toString(block.chainid),
                ' (id int, name text, description text, image text, external_url text, background_color text, attributes text);'
            )
        );
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

        /**
         * Stores the unique ID for the newly created NFT metadata attributes table.
         */
        _metadataAttrTableId = _tableland.createTable(
            address(this),
            string.concat(
                'CREATE TABLE mojo_media_meta',
                Strings.toString(block.chainid),
                ' (id int, max_invocations int, royalty int, sales_total, int title text, category text, license text, website text, long_description text, preview_url text, audio_video_type text, audio_video_url text, resolution text, duration text, size text, created_at text);'
            )
        );
        /**
         * Stores the full tablename for the new metadata attributes table.
         * {prefix}_{chainid}_{tableid}
         */
        _metadataAttrTable = string.concat(
            'mojo_media_meta',
            Strings.toString(block.chainid),
            '_',
            Strings.toString(_metadataAttrTableId)
        );
    }

    /*
     * safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically insterted into the metadata table.
     */
    function safeMint(address to, NFT memory nft) public {
        uint256 tokenId = _tokenIds.current();
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                'INSERT INTO ',
                _metadataTable,
                ' (id, name, description, image, external_url, background_color, attributes) VALUES (',
                Strings.toString(tokenId),
                ', ',
                nft.name,
                ', ',
                nft.description,
                ', ',
                nft.imageUrl,
                ', ',
                nft.externalUrl,
                ', ',
                nft.backgroundColor,
                ', ',
                _metadataAttrTable,
                ', )'
            )
        );
        _safeMint(to, tokenId, '');
        _tokenIds.increment();

        /* Emit our newly created NFT to our front-end */
        emit NewNftMinted(msg.sender, block.timestamp, tokenId);
    }

    /*
     * makeMove is an example of how to encode gameplay into both the
     * smart contract and the metadata. Whenever a token owner calls
     * make move, they can supply a new x,y coordinate and update
     * their token's metadata.
     */
    function updateNFT(NFT memory nft) public {
        // Check token ownership
        require(this.ownerOf(nft.tokenId) == msg.sender, 'Invalid owner');
        // simple on-chain gameplay enforcement
        // require(nft.name.length < 3, 'Name required');
        // require(nft.description.length < 10, 'Description required');
        // require(nft.imageUrl.length = 0, 'Image Url required');

        // Update the row in tableland
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                'UPDATE ',
                _metadataTable,
                ' SET name = ',
                nft.name,
                ', description = ',
                nft.description,
                ', image = ',
                nft.imageUrl,
                ', external_url = ',
                nft.externalUrl,
                ', background_color = ',
                nft.backgroundColor,
                ' WHERE id = ',
                Strings.toString(nft.tokenId),
                ';'
            )
        );
        /* Emit our updated NFT to our front-end */
        emit NftUpdated(msg.sender, block.timestamp, nft);
    }

    /**
     * Get all NFTs
     */
    function getAllNfts() public view returns (NFT[] memory) {
        return nfts;
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
        require(_exists(tokenId), 'ERC721URIStorage: URI query for nonexistent token');

        string memory base = _baseURI();
        string memory json_group = '';
        string[7] memory cols = [
            'id',
            'name',
            'description',
            'image',
            'external_link',
            'background_color',
            'attributes'
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

    /*
     * setAttributes provides an example of how to update a field for every
     * row in an table.
     */
    function setAttributes(string calldata attributes) external onlyOwner {
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat('update ', _metadataTable, ' set attributes = ', attributes, ';')
        );
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
}
