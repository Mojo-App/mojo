// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/evm/contracts/ITablelandTables.sol";

contract MOJO is ERC721, AccessControl {
    using Counters for Counters.Counter;
    string private _baseURIString = "https://testnet.tableland.network/query?";

    Counters.Counter private _tokenIdCounter;

    ITablelandTables private _tableland;
    uint256 private _metadataTableId;
    uint256 private _attributesTableId;
    string public mainTable;
    string public attributesTable;
    string private _tablePrefix = "Mojo_Music";

    mapping(uint256 => uint256) private nb_of_attributes;

    event NewNftMinted(
      address indexed from,
      uint256 timestamp,
      uint256 tokenId
    );

    event imageUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _image,
        uint256 tokenId
    );

    event nameUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _name,
        uint256 tokenId
    );

    event descriptionUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _description,
        uint256 tokenId
    );

    event categoryUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _category,
        uint256 tokenId
    );

    event externalUrlUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _external_url,
        uint256 tokenId
    );

    event backgroundColorUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _background_color,
        uint256 tokenId
    );

    event animationUrlUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _animation_url,
        uint256 tokenId
    );

    event youtubeUrlUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _youtube_url,
        uint256 tokenId
    );

    event newAttributeAdded(
        address indexed from,
        uint256 timestamp,
        uint256 tokenId,
        uint256 _trait_id
    );

    event traitLockedUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _locked,
        uint256 tokenId,
        uint256 _trait_id
    );

    event traitIconUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _icon,
        uint256 tokenId,
        uint256 _trait_id
    );

    event traitDisplayTypeUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _display_type,
        uint256 tokenId,
        uint256 _trait_id
    );

    event traitTypeUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _trait_type,
        uint256 tokenId,
        uint256 _trait_id
    );

    event valueUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _attributesTableId,
        string _value,
        uint256 tokenId,
        uint256 _trait_id
    );

    constructor(address registry) ERC721("Mojo Music", "mNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _tableland = ITablelandTables(registry);
        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                _tablePrefix,
                "_",
                Strings.toString(block.chainid),
                " (tokenid int, name text, description text, image text, category text, external_url text, background_color text, animation_url text, youtube_url text);"
            )
        );
        mainTable = string.concat(
            _tablePrefix,
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_metadataTableId)
        );
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
                "false",
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
        emit NewNftMinted(msg.sender, block.timestamp, tokenId);
        return tokenId;
    }

    function update_image(uint256 tokenId, string memory _image) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET image = '",
                _image,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit imageUpdated(msg.sender, block.timestamp, _metadataTableId, _image, tokenId);
    }

    function update_name(uint256 tokenId, string memory _name) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET name = '",
                _name,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit nameUpdated(msg.sender, block.timestamp, _metadataTableId, _name, tokenId);
    }

    function update_description(uint256 tokenId, string memory _description) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET description = '",
                _description,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit descriptionUpdated(msg.sender, block.timestamp, _metadataTableId, _description, tokenId);
    }

    function update_category(uint256 tokenId, string memory _category) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
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
        emit categoryUpdated(msg.sender, block.timestamp, _metadataTableId, _category, tokenId);
    }

    function update_external_url(uint256 tokenId, string memory _external_url) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
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
        emit externalUrlUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _external_url,
            tokenId
        );
    }

    function update_background_color(uint256 tokenId, string memory _background_color) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
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
        emit backgroundColorUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _background_color,
            tokenId
        );
    }

    function update_animation_url(uint256 tokenId, string memory _animation_url) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
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
        emit animationUrlUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _animation_url,
            tokenId
        );
    }

    function update_youtube_url(uint256 tokenId, string memory _youtube_url) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
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
        emit youtubeUrlUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _youtube_url,
            tokenId
        );
    }

    function add_new_attribute(
        uint256 _tokenId,
        string memory _icon,
        string memory _display_type,
        string memory _trait_type,
        string memory _value
    ) public returns (uint256) {
        require(this.ownerOf(_tokenId) == msg.sender, "Invalid owner");
        uint256 counter_trait = nb_of_attributes[_tokenId];
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
        nb_of_attributes[_tokenId] = counter_trait + 1;
        emit newAttributeAdded(msg.sender, block.timestamp, _tokenId, counter_trait + 1);
        return counter_trait + 1;
    }

    function update_locked(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _locked
    ) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");
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
        emit traitLockedUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _locked,
            tokenId,
            _trait_id
        );
    }

    function update_icon(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _icon
    ) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");
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
        emit traitIconUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _icon,
            tokenId,
            _trait_id
        );
    }

    function update_display_type(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _display_type
    ) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");
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
        emit traitDisplayTypeUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _display_type,
            tokenId,
            _trait_id
        );
    }

    function update_trait_type(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _trait_type
    ) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");
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
        emit traitTypeUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _trait_type,
            tokenId,
            _trait_id
        );
    }

    function update_value(
        uint256 tokenId,
        uint256 _trait_id,
        string memory _value
    ) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        require(nb_of_attributes[tokenId] >= _trait_id && _trait_id > 0, "trait_id not found ");
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
        emit valueUpdated(
            msg.sender,
            block.timestamp,
            _attributesTableId,
            _value,
            tokenId,
            _trait_id
        );
    }

    function main_metadataURI() public view returns (string memory) {
        string memory base = _baseURI();
        return
            string.concat(base, "unwrap=true&extract=false&s=", "SELECT%20*%20FROM%20", mainTable);
    }

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

    function setBaseURI(string memory baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseURIString = baseURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();

        if (bytes(baseURI).length == 0) {
            return "";
        }

        string memory query = string(
            abi.encodePacked(
                "SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27category%27%2Ccategory%2C%27external_url%27%2Cexternal_url%2C%27background_color%27%2Cbackground_color%2C%27animation_url%27%2Canimation_url%2C%27youtube_url%27%2Cyoutube_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27locked%27%2Clocked%2C%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20",
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

    function _baseURI() internal view override returns (string memory) {
        return _baseURIString;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
