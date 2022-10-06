// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/evm/contracts/ITablelandTables.sol";

contract MOJO is ERC721, AccessControl {
    using Counters for Counters.Counter;
    /* The testnet gateway URI plus query parameter */
    string private _baseURIString = "https://testnet.tableland.network/query?";

    Counters.Counter private _tokenIdCounter;

    /* Tableland */
    ITablelandTables private _tableland;
    //string private _metadataTable;
    uint256 private _metadataTableId;
    uint256 private _attributesTableId;
    string public mainTable;
    string public attributesTable;
    string private _tablePrefix = "Mojo_Music";

    /* Map of tokenid to the numbers of trait_id  */
    mapping(uint256 => uint256) private nb_of_attributes;

    /* Events */
    event NewNftMinted(
      address indexed from,
      uint256 timestamp,
      uint256 tokenId
    );

    /* The NFT Category is updated */
    event categoryUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _category,
        uint256 tokenId
    );

    /* The NFT Image Data is updated */
    event imageDataUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _image_data,
        uint256 tokenId
    );

    /* The NFT External Url is updated */
    event externalUrlUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _external_url,
        uint256 tokenId
    );

    /* The NFT Background Color is updated */
    event backgroundColorUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _background_color,
        uint256 tokenId
    );

    /* The NFT Animation Url is updated */
    event animationUrlUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _animation_url,
        uint256 tokenId
    );

    /* The NFT Youtube Url is updated */
    event youtubeUrlUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _youtube_url,
        uint256 tokenId
    );

    /* A new NFT attribute is added */
    event newAttributeAdded(
        address indexed from,
        uint256 timestamp,
        uint256 tokenId,
        uint256 _trait_id
    );

    /* The NFTs locked attribute is updated */
    event traitLockedUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _locked,
        uint256 tokenId,
        uint256 _trait_id
    );

    /* The NFTs trait icon attribute is updated */
    event traitIconUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _icon,
        uint256 tokenId,
        uint256 _trait_id
    );

    /* The NFTs trait display_type is updated */
    event traitDisplayTypeUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _display_type,
        uint256 tokenId,
        uint256 _trait_id
    );

    /* The NFTs trait trait_type is updated */
    event traitTypeUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _trait_type,
        uint256 tokenId,
        uint256 _trait_id
    );

    /* The NFTs trait value is updated */
    event valueUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _value,
        uint256 tokenId,
        uint256 _trait_id
    );

    constructor(address registry) ERC721("Mojo Music", "mNFT") {
        /*
         * Assign role to Tableland table
         */
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        /*
         * The Tableland address on your current chain
         */
        _tableland = ITablelandTables(registry);

        /*
         * Stores the unique ID for the newly created table.
         */
        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                _tablePrefix,
                "_",
                Strings.toString(block.chainid),
                " (tokenid int, name text, description text, image text, image_data text, category text, external_url text, background_color text, animation_url text, youtube_url text);"
            )
        );

        /*
         * Stores the full tablename for the new table.
         * {prefix}_{chainid}_{tableid}
         */
        mainTable = string.concat(
            _tablePrefix,
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_metadataTableId)
        );

        /*
         * create a new attribute table.
         */
        _attributesTableId = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                _tablePrefix,
                "_",
                Strings.toString(block.chainid),
                " (maintable_tokenid int, trait_id int, locked int, icon text, display_type text, trait_type text, value text);"
            )
        );
        attributesTable = string.concat(
            _tablePrefix,
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_attributesTableId)
        );
    }

    /* ========== PUBLIC METHODS ========== */
    /* Mint NFT
     * We only mint the basics due to contract overloading, so only the image, name and description are used for a very basic NFT template
     * The category is a custom attribute that will be used in Mojo Music to filter and search by category, this will be a separate table in Tableland
     * We'll use the category label as the saved value for readability, but the category table will be indexed accordingly
     * The first trait added at index 0 is the minting date, this enable further traits to be added in a numerical fashion starting at #1
     */
    function safeMint(
        address to,
        string memory _name,
        string memory _description,
        string memory _image_url,
        string memory _category,
        string memory _icon,
        string memory _display_type,
        string memory _trait_type,
        string memory _value
    ) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        //insert into maintable
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "INSERT INTO ",
                mainTable,
                " (tokenid, name, description, image, category) VALUES ('",
                Strings.toString(tokenId),
                "', '",
                _name,
                "', '",
                _description,
                "', '",
                _image_url,
                "', '",
                _category,
                "')"
            )
        );
        /* Insert into attributesTable */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "INSERT INTO ",
                attributesTable,
                " (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES ('",
                Strings.toString(tokenId),
                "', '",
                "0",
                "', '",
                "0",
                "', '",
                _icon,
                "', '",
                _display_type,
                "', '",
                _trait_type,
                "', '",
                _value,
                "')"
            )
        );
        _safeMint(to, tokenId);
        nb_of_attributes[tokenId] = 1;
        _tokenIdCounter.increment();
        /* Emit Event */
        emit NewNftMinted(msg.sender, block.timestamp, tokenId);
        return tokenId;
    }

    /*
     * Update a category
     */
    function update_category(uint256 tokenId, string memory _category) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET category = '",
                _category,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        /* Emit Event */
        emit categoryUpdated(msg.sender, block.timestamp, _metadataTableId, _category, tokenId);
    }

    /*
     * Update NFT Image Data
     */
    function update_image_data(uint256 tokenId, string memory _image_data) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET image_data = '",
                _image_data,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        /* Emit Event */
        emit imageDataUpdated(msg.sender, block.timestamp, _metadataTableId, _image_data, tokenId);
    }

    /*
     * Update NFT External Url
     */
    function update_external_url(uint256 tokenId, string memory _external_url) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET external_url = '",
                _external_url,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        /* Emit Event */
        emit externalUrlUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _external_url,
            tokenId
        );
    }

    /*
     * Update NFT Background Color
     */
    function update_background_color(uint256 tokenId, string memory _background_color) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET background_color = '",
                _background_color,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        /* Emit Event */
        emit backgroundColorUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _background_color,
            tokenId
        );
    }

    /*
     * Update NFT Animation Url
     */
    function update_animation_url(uint256 tokenId, string memory _animation_url) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET animation_url = '",
                _animation_url,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        /* Emit Event */
        emit animationUrlUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _animation_url,
            tokenId
        );
    }

    /*
     * Update NFT Youtube Url
     */
    function update_youtube_url(uint256 tokenId, string memory _youtube_url) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET youtube_url = '",
                _youtube_url,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        /* Emit Event */
        emit youtubeUrlUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _youtube_url,
            tokenId
        );
    }

    /*
     * Add a new Metadata Attribute to the Tableland NFT
     */
    function add_new_attribute(
        uint256 _tokenId,
        string memory _icon,
        string memory _display_type,
        string memory _trait_type,
        string memory _value
    ) public returns (uint256) {
        /* Check Ownership */
        require(this.ownerOf(_tokenId) == msg.sender, "Invalid owner");

        /* This counter begins from 1 not 0 */
        uint256 counter_trait = nb_of_attributes[_tokenId];

        /* Insert into attributesTable */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "INSERT INTO ",
                attributesTable,
                " (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES ('",
                Strings.toString(_tokenId),
                "', '",
                Strings.toString(counter_trait + 1),
                "', '",
                "0",
                "', '",
                _icon,
                "', '",
                _display_type,
                "', '",
                _trait_type,
                "', '",
                _value,
                "')"
            )
        );
        //NOTE: SafeMath is no longer needed starting with Solidity 0.8.
        //The compiler now has built in overflow checking.
        nb_of_attributes[_tokenId] = counter_trait + 1;
        emit newAttributeAdded(msg.sender, block.timestamp, _tokenId, counter_trait + 1);
        return counter_trait + 1;
    }

    /*
     * Update Metadata locked attribute
     */
    function update_locked(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _locked
    ) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "UPDATE ",
                attributesTable,
                " SET locked = '",
                _locked,
                "' WHERE maintable_tokenid = ",
                Strings.toString(tokenId),
                " AND trait_id = ",
                Strings.toString(_trait_id),
                ";"
            )
        );
        /* Emit Event */
        emit traitLockedUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _locked,
            tokenId,
            _trait_id
        );
    }

    /*
     * Update Metadata attribute icon
     */
    function update_icon(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _icon
    ) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "UPDATE ",
                attributesTable,
                " SET icon = '",
                _icon,
                "' WHERE maintable_tokenid = ",
                Strings.toString(tokenId),
                " AND trait_id = ",
                Strings.toString(_trait_id),
                ";"
            )
        );
        /* Emit Event */
        emit traitIconUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _icon,
            tokenId,
            _trait_id
        );
    }

    /*
     * Update Metadata attribute display_type
     * For numeric traits, OpenSea currently supports three different options,
     * number (lower right in the image below),
     * boost_percentage (lower left in the image above),
     * boost_number (similar to boost_percentage but doesn't show a percent sign).
     * If you pass in a value that's a number and you don't set a display_type, the trait will appear in the Rankings section (top right in the image above).
     * Adding an optional max_value sets a ceiling for a numerical trait's possible values.
     * It defaults to the maximum that OpenSea has seen so far on the assets on your contract.
     * If you set a max_value, make sure not to pass in a higher value
     * https://docs.opensea.io/docs/metadata-standards
     */
    function update_display_type(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _display_type
    ) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "UPDATE ",
                attributesTable,
                " SET display_type = '",
                _display_type,
                "' WHERE maintable_tokenid = ",
                Strings.toString(tokenId),
                " AND trait_id = ",
                Strings.toString(_trait_id),
                ";"
            )
        );

        /* Emit Event */
        emit traitDisplayTypeUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _display_type,
            tokenId,
            _trait_id
        );
    }

    /*
     * Update Metadata attribute trait_type
     */
    function update_trait_type(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _trait_type
    ) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "UPDATE ",
                attributesTable,
                " SET trait_type = '",
                _trait_type,
                "' WHERE maintable_tokenid = ",
                Strings.toString(tokenId),
                " AND trait_id = ",
                Strings.toString(_trait_id),
                ";"
            )
        );

        /* Emit Event */
        emit traitTypeUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _trait_type,
            tokenId,
            _trait_id
        );
    }

    /*
     * update Metadata attribute value
     * We use a string to accomodate most types, we can then cast to an Integer on front-end
     */
    function update_value(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _value
    ) public {
        /* Check Ownership */
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");

        /* Update the row in tableland */
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "UPDATE ",
                attributesTable,
                " SET value = '",
                _value,
                "' WHERE maintable_tokenid = ",
                Strings.toString(tokenId),
                " AND trait_id = ",
                Strings.toString(_trait_id),
                ";"
            )
        );

        /* Emit Event */
        emit valueUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _value,
            tokenId,
            _trait_id
        );
    }

    /**
     * @dev View the contract’s Main Metadata table
     */
    function main_metadataURI() public view returns (string memory) {
        string memory base = _baseURI();
        return
            string.concat(base, "unwrap=true&extract=false&s=", "SELECT%20*%20FROM%20", mainTable);
    }

    /**
     * @dev View the contract’s Attributes Metadata table
     */
    function attributes_metadataURI() public view returns (string memory) {
        string memory base = _baseURI();
        return
            string.concat(
                base,
                "unwrap=true&extract=false&s=",
                "SELECT%20*%20FROM%20",
                attributesTable
            );
    }

    /* Ensures the contract owner can easily update the project's baseURI */
    function setBaseURI(string memory baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseURIString = baseURI;
    }

    /**
     * @dev tokenURI that points to the NFT’s metadata. This response must conform to the ERC721 format
     */
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();

        if (bytes(baseURI).length == 0) {
            return "";
        }

        /*
         * A SQL query to JOIN two tables to compose the metadata accross a `main` and `attributes` table
         */
        string memory query = string(
            abi.encodePacked(
                "SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27image_data%27%2Cimage_data%2C%27category%27%2Ccategory%2C%27external_url%27%2Cexternal_url%2C%27background_color%27%2Cbackground_color%2C%27animation_url%27%2Canimation_url%2C%27youtube_url%27%2Cyoutube_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27locked%27%2Clocked%2C%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20",
                mainTable,
                "%20JOIN%20",
                attributesTable,
                "%20ON%20",
                mainTable,
                "%2Etokenid%20%3D%20",
                attributesTable,
                "%2Emaintable_tokenid%20WHERE%20tokenid%3D"
            )
        );
        /* Return the baseURI with a query string, which looks up the token id in a row. */
        /* `unwrap=true&extract=true` formats into the proper JSON object expected by metadata standards. */
        return
            string(
                abi.encodePacked(
                    baseURI,
                    "unwrap=true&extract=true&s=",
                    query,
                    Strings.toString(_tokenId),
                    "%20group%20by%20tokenid"
                )
            );
    }

    /* ========== INTERNAL METHODS ========== */
    function _baseURI() internal view override returns (string memory) {
        return _baseURIString;
    }

    /* The following functions are overrides required by Solidity. */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
