// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/evm/contracts/ITablelandTables.sol";

contract MCNFT is ERC721, AccessControl {
    using Counters for Counters.Counter;
    string private _baseURIString = "https://testnet.tableland.network/query?";

    Counters.Counter private _tokenIdCounter;

    ITablelandTables private _tableland;
    uint256 private _metadataTableId;
    uint256 private _attributesTableId;
    string public mainTable;
    string public attributesTable;
    string private _tablePrefix = "Mojo_Creators";

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

    event addressUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _address,
        uint256 tokenId
    );

    event sloganUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _slogan,
        uint256 tokenId
    );

    event profileImgUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _profile_img,
        uint256 tokenId
    );

    event bannerImgUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _banner_img,
        uint256 tokenId
    );

    event websiteUpdated(
        address indexed from,
        uint256 timestamp,
        uint256 _metadataTableId,
        string _website,
        uint256 tokenId
    );

    event newAttributeAdded(
        address indexed from,
        uint256 timestamp,
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

    constructor(address registry) ERC721("Mojo Creator", "mcNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _tableland = ITablelandTables(registry);
        _metadataTableId = _tableland.createTable(
            address(this),
            string.concat(
                "CREATE TABLE ",
                _tablePrefix,
                "_",
                Strings.toString(block.chainid),
                " (tokenid int, name text, description text, image text, address text, slogan text, profile_img text, banner_img text, website text);"
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
                " (maintable_tokenid int, trait_id int, icon text, display_type text, trait_type text, value text);"
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
        string memory _address,
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
                " (tokenid, name, description, image, address) VALUES ('",
                Strings.toString(tokenId),
                "', '",
                _name,
                "', '",
                _description,
                "', '",
                _image_url,
                "', '",
                _address,
                "')"
            )
        );
        _tableland.runSQL(
            address(this),
            _attributesTableId,
            string.concat(
                "INSERT INTO ",
                attributesTable,
                " (maintable_tokenid, trait_id, icon, display_type, trait_type, value) VALUES ('",
                Strings.toString(tokenId),
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
        emit NewNftMinted(msg.sender, block.timestamp, tokenId);
        return tokenId;
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

    function update_address(uint256 tokenId, string memory _address) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET address = '",
                _address,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit addressUpdated(msg.sender, block.timestamp, _metadataTableId, _address, tokenId);
    }

    function update_slogan(uint256 tokenId, string memory _slogan) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET slogan = '",
                _slogan,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit sloganUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _slogan,
            tokenId
        );
    }

    function update_profile_img(uint256 tokenId, string memory _profile_img) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET profile_img = '",
                _profile_img,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit profileImgUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _profile_img,
            tokenId
        );
    }

    function update_banner_img(uint256 tokenId, string memory _banner_img) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET banner_img = '",
                _banner_img,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit bannerImgUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _banner_img,
            tokenId
        );
    }

    function update_website(uint256 tokenId, string memory _website) public {
        require(this.ownerOf(tokenId) == msg.sender, "Invalid owner");
        _tableland.runSQL(
            address(this),
            _metadataTableId,
            string.concat(
                "UPDATE ",
                mainTable,
                " SET website = '",
                _website,
                "' WHERE tokenid = ",
                Strings.toString(tokenId),
                ";"
            )
        );
        emit websiteUpdated(
            msg.sender,
            block.timestamp,
            _metadataTableId,
            _website,
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
                " (maintable_tokenid, trait_id, icon, display_type, trait_type, value) VALUES ('",
                Strings.toString(_tokenId),
                "', '",
                Strings.toString(counter_trait + 1),
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
                "SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27address%27%2Caddress%2C%27slogan%27%2Cslogan%2C%27profile_img%27%2Cprofile_img%2C%27banner_img%27%2Cbanner_img%2C%27website%27%2Cwebsite%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20",
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
