/* Import Tableland sdk */
import { connect } from "@tableland/sdk";

/* Get our Mojo Contract Address */
// const mojoContractAddress = "0x13B9DF4c7C97563fAD045251FCA95a9E61c9Dc85";
// const mojoCreatorsContractAddress = "0x22Dbbb789aE924dCA4C2366Fc4d34f269e2fC3B3";
// const tablelandRigsContractAddress = "0x8eaa9ae1ac89b1c8c8a8104d08c045f78aadb42d";

export default class tablelandCRUD {
  constructor() {
    this.mainMojoCreatorsTable = "Mojo_Creators_80001_3524";
    this.attributesMojoCreatorsTable = "Mojo_Creators_80001_3525";
    this.mainMojoMusicTable = "Mojo_Creators_80001_3522";
    this.attributesMojoMusicTable = "Mojo_Music_80001_3523";
    this.categoriesTable = "Mojo_Music_80001_3473";
  }

  /**
   * @param {String} accountAddress
   * @returns {Promise<String|Error>}
   */
  async getMojoCreatorNFTsByAddress(accountAddress) {
    // Connect to the Tableland testnet (defaults to Polygon Mumbai testnet chain)
    // @return {Connection} Interface to access the Tableland network and, optionally, a target `chain`
    const tableland = await connect({ network: "testnet", chain: "polygon-mumbai" });
    // Run a SQL SELECT query
    // @return {ReadQueryResult} Tableland gateway response with row & column values
    const { rows } = await tableland.read(
      `SELECT tokenid, name, description, image, address, slogan, profile_img, banner_img, website FROM ${this.mainMojoCreatorsTable} WHERE address = '${accountAddress}';`
    );
    return rows;
  }

  /**
   * @param {String} tokenId
   * @returns {Promise<String|Error>}
   */
  async getMojoCreatorNFTsById(tokenId) {
    // Connect to the Tableland testnet (defaults to Polygon Mumbai testnet chain)
    // @return {Connection} Interface to access the Tableland network and, optionally, a target `chain`
    const tableland = await connect({ network: "testnet", chain: "polygon-mumbai" });
    // Run a SQL SELECT query
    // @return {ReadQueryResult} Tableland gateway response with row & column values
    const { rows } = await tableland.read(
      `SELECT tokenid, name, description, image, address, slogan, profile_img, banner_img, website FROM ${this.mainMojoCreatorsTable} WHERE tokenid = ${tokenId};`
    );
    return rows;
  }

  /**
   * @param {String} tokenId
   * @returns {Promise<String|Error>}
   */
  async getMojoCreatorNFTAttributes(tokenId) {
    // Connect to the Tableland testnet (defaults to Polygon Mumbai testnet chain)
    // @return {Connection} Interface to access the Tableland network and, optionally, a target `chain`
    const tableland = await connect({ network: "testnet", chain: "polygon-mumbai" });
    // Run a SQL SELECT query
    // @return {ReadQueryResult} Tableland gateway response with row & column values
    const { rows } = await tableland.read(
      `SELECT maintable_tokenid, trait_id, icon, display_type, trait_type, value FROM ${this.attributesMojoCreatorsTable} WHERE maintable_tokenid = ${tokenId};`
    );
    return rows;
  }

  /**
   * Update a Mojo Music NFT
   */
  async updateNFT(
    tokenId,
    cid,
    name,
    description,
    externalUrl,
    imageUrl,
    size,
    createdAt,
    audioVideoType,
    maxInvocations,
    royaltyPercentage,
    price,
    title,
    category,
    license,
    website,
    preview,
    audioVideoURL,
    animationURL,
    youtubeURL,
    backgroundColor,
    resolution
  ) {
    console.log("tokenId :", tokenId);
    console.log("cid :", cid);
    console.log("name :", name);
    console.log("description :", description);
    console.log("category :", category);
    console.log("externalUrl :", externalUrl);
    console.log("imageUrl :", imageUrl);
    console.log("backgroundColor :", backgroundColor);
    console.log("size :", size);
    console.log("createdAt :", createdAt);

    console.log("audioVideoType :", audioVideoType);
    console.log("maxInvocations :", maxInvocations);
    console.log("royaltyPercentage :", royaltyPercentage);
    console.log("price :", price);
    console.log("title :", title);
    console.log("license :", license);
    console.log("website :", website);
    console.log("preview :", preview);
    console.log("audioVideoURL :", audioVideoURL);
    console.log("animationURL :", animationURL);
    console.log("youtubeURL :", youtubeURL);
    console.log("resolution :", resolution);

    // Run a SQL SELECT query
    // @return {ReadQueryResult} Tableland gateway response with row & column values
    const { rows } = await tableland.read(
      `SELECT maintable_tokenid, trait_id, icon, display_type, trait_type, value FROM Mojo_Creators_80001_3523 WHERE maintable_tokenid = ${tokenId};`
    );
    // console.log("columns", columns);
    // [ { name: 'name' }, { name: 'id' } ]
    console.log("rows", rows);
    let traitId = 1;
    let traitType = "";
    let last = rows[rows.length - 1];

    console.log("last", last);
    if (last) {
      traitId = last.trait_id;
    }

    // Connect to the Tableland testnet (defaults to Polygon Mumbai testnet chain)
    // @return {Connection} Interface to access the Tableland network and, optionally, a target `chain`
    const tableland = await connect({ network: "testnet", chain: "polygon-mumbai" });

    // Runs a mutating query statement at the specified table
    // @return {WriteQueryResult} On-chain transaction hash of the write query
    const updateResult = await tableland.write(
      `UPDATE Mojo_Music_80001_3522 (name, description, image, category, external_url, background_color, animation_url, youtube_url) VALUES (${name}, ${description}, ${imageUrl}, ${category}, ${externalUrl}, ${backgroundColor}, ${animationURL}, ${youtubeURL}) WHERE = ${tokenId};`
    );
    console.log("updateResult", updateResult);

    if (audioVideoType) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${audioVideoType});`
      );
      console.log("insertResult", insertResult);
    }

    if (maxInvocations) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${maxInvocations});`
      );
      console.log("insertResult", insertResult);
    }

    if (royaltyPercentage) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${royaltyPercentage});`
      );
      console.log("insertResult", insertResult);
    }

    if (price) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${price});`
      );
      console.log("insertResult", insertResult);
    }

    if (title) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${title});`
      );
      console.log("insertResult", insertResult);
    }

    if (license) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${license});`
      );
      console.log("insertResult", insertResult);
    }

    if (website) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${website});`
      );
      console.log("insertResult", insertResult);
    }

    if (preview) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${preview});`
      );
      console.log("insertResult", insertResult);
    }

    if (audioVideoURL) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${audioVideoURL});`
      );
      console.log("insertResult", insertResult);
    }

    if (animationURL) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${animationURL});`
      );
      console.log("insertResult", insertResult);
    }

    if (youtubeURL) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${youtubeURL});`
      );
      console.log("insertResult", insertResult);
    }

    if (resolution) {
      const insertResult = await tableland.write(
        `INSERT INTO Mojo_Music_80001_3523 (maintable_tokenid, trait_id, locked, icon, display_type, trait_type, value) VALUES (${tokenId}, ${traitId}, 0, "", "", ${traitType}, ${resolution});`
      );
      console.log("insertResult", insertResult);
    }

    return;
  }
}
