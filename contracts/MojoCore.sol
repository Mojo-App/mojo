// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@tableland/evm/contracts/ITablelandTables.sol';

// We import some helper functions for Solidity
import { StringUtils } from './libraries/StringUtils.sol';

// Import this file to use console.log
import 'hardhat/console.sol';

/// @custom:security-contact craigmoss36@gmail.com
contract MojoCore is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    ERC721BurnableUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdCounter;

    /* Set Tableland baseURI for our SQL Queries */
    string private _baseURIString = 'https://testnet.tableland.network/query?s=';

    ITablelandTables private _tableland;
    string private _metadataTable;
    uint256 private _metadataTableId;
    string private _metadataAttrTable;
    uint256 private _metadataAttrTableId;
    string private _tablePrefix = 'mojo';

    string private _externalURL = 'not.implemented.com';

    /// @custom:oz-upgrades-unsafe-allow constructor
    /* Called only when the smart contract is created */
    constructor(address registry) {
        _disableInitializers();
        /*
         * registry if the address of the Tableland registry. You can always find those
         * here https://github.com/tablelandnetwork/evm-tableland#currently-supported-chains
         */
        _tableland = ITablelandTables(registry);

        /**
         * Stores the unique ID for the newly created NFT media table.
         */
        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                'CREATE TABLE mojo_media_',
                Strings.toString(block.chainid),
                ' (id int, name text, description text, image text, external_url text, background_color text, attributes_id text);'
            )
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
         * Stores the full tablename for the new media table.
         * {prefix}_{chainid}_{tableid}
         */
        _metadataTable = string.concat(
            'mojo_media_',
            Strings.toString(block.chainid),
            '_',
            Strings.toString(_metadataTableId)
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

    function initialize() public initializer {
        __ERC721_init('MojoNFT', 'mNFT');
        __ERC721URIStorage_init();
        __Pausable_init();
        __Ownable_init();
        __ERC721Burnable_init();
    }

    /**
     * @dev safeMint allows anyone to mint a token in this project.
     * Any time a token is minted, a new row of metadata will be
     * dynamically inserted into the Tableland NFT metadata table.
     */
    function safeMint(
        address to,
        string memory name,
        string memory description,
        string memory imageUrl,
        string memory externalUrl,
        string memory backgroundColor

    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();

        /* Insert into our main NFT metadata table */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                'INSERT INTO ',
                _metadataTable,
                ' (id, name, description, image, external_url, background_color, attributes_id) VALUES (',
                Strings.toString(tokenId),
                ', ',
                name,
                ', ',
                description,
                ', ',
                imageUrl,
                ', ',
                externalUrl,
                ', ',
                backgroundColor,
                ', ',
                _metadataAttrTable,
                ')'
            )
        );

        console.log('\n--------------------------------------------------------');
        console.log('NFT address holder', to);
        console.log('NFT tokenId', tokenId);
        console.log('name', name);
        console.log('description', description);
        console.log('imageUrl', imageUrl);
        console.log('externalUrl', externalUrl);
        console.log('backgroundColor', backgroundColor);
        console.log('_metadataAttrTable', _metadataAttrTable);

        console.log('--------------------------------------------------------\n');

        _safeMint(to, tokenId, '');
        _tokenIdCounter.increment();
        return tokenId;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIString;
    }

    /**
     * @dev tokenURI is an example of how to turn a row in your table back into
     * erc721 compliant metadata JSON. Here, we do a SELECT and JOIN statement
     * with function that converts the result into json.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        require(_exists(tokenId), 'ERC721URIStorage: URI query for nonexistent token');

        string memory base = _baseURI();

        string memory json_group = '';
        string[7] memory cols = [
            'id',
            'name',
            'description',
            'image',
            'external_url',
            'background_color',
            'attributes_id'
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
     * @dev See Tableland repos here https://github.com/tablelandnetwork/example-apps/blob/canvas/canvas-game/contracts/CanvasGame.sol
     * setExternalURL provides an example of how to update a field for every
     * row in an table.
     */
    // function setExternalURL(string calldata externalURL) external onlyOwner {
    //     _externalURL = externalURL;
    //     _tableland.runSQL(
    //         address(this),
    //         _metadataTableId,
    //         string.concat(
    //             'update ',
    //             _metadataTable,
    //             ' set external_url = ',
    //             externalURL,
    //             "||'?tokenId='||id", // Turns every row's URL into a URL including get param for tokenId
    //             ';'
    //         )
    //     );
    // }

    /*
     * @dev See Tableland repos here https://github.com/tablelandnetwork/example-apps/blob/canvas/canvas-game/contracts/CanvasGame.sol
     */
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
    /*
     * @dev See Tableland repos here https://github.com/tablelandnetwork/example-apps/blob/canvas/canvas-game/contracts/CanvasGame.sol
     */
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    /**
     * View the Contract’s Metadata Table
     */
    function metadataURI() public view returns (string memory) {
        string memory base = _baseURI();

        return string.concat(base, 'SELECT%20*%20FROM%20', _metadataTable);
    }

    /**
     * View the Contract’s Metadata Attributes Table
     */
    function metadataAttrURI() public view returns (string memory) {
        string memory base = _baseURI();

        return string.concat(base, 'SELECT%20*%20FROM%20', _metadataAttrTable);
    }

    /**
     * OpenZeplin Core Contract functions
     */
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }
}
