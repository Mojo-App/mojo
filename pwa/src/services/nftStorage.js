import { NFTStorage } from "nft.storage";

const NFT_STORAGE_API_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEFmN2EzNkNmY0M2MzNjMDgwQTQ1NkNiNzVDOWI5Njc1NzM2Njk0ZmIiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY1NzMwNDE5NjI2MywibmFtZSI6Ik1vam8ifQ.te79AsUXEjsR_CJQ2NTYHbLbhY4_kJqpDJ0juZWFBu4";

/**
 * Store NFT Metadata in custom Attribute structure
 * @returns {MetadataURL}
 */
export const nftStorage = async (
  name,
  description,
  imageUrl,
  size,
  createdAt,
  audioVideoType,
  title,
  category,
  license,
  website,
  longDescription,
  preview,
  audioVideoURL,
  animationURL,
  youtubeURL,
  resolution,
  duration
) => {
  /*
   * Create a blob to validate TypeError: property `image` must be a Blob or File
   * object at validateERC1155
   */
  let blob = new Blob([imageUrl], { type: "text/plain" });

  const nft = {
    name,
    decimals: 0,
    description,
    image: blob,
    properties: {
      type: "mNFT",
      authors: [{ name: "Mojo NFT" }],
      content: {
        "text/markdown": longDescription,
      },
    },
    attributes: [
      {
        trait_type: "Title",
        value: title,
      },
      {
        trait_type: "Category",
        value: category,
      },
      {
        trait_type: "License",
        value: license,
      },
      {
        trait_type: "Website Link",
        value: website,
      },
      {
        trait_type: "Preview Link",
        value: preview,
      },
      {
        trait_type: "Audio/Video Link",
        value: audioVideoURL,
      },
      {
        trait_type: "Audio/Video Type",
        value: audioVideoType,
      },
      {
        trait_type: "Animation Link",
        value: animationURL,
      },
      {
        trait_type: "Youtube Link",
        value: youtubeURL,
      },
      {
        trait_type: "Resolution",
        value: resolution,
      },
      {
        trait_type: "Duration",
        value: duration,
      },
      {
        trait_type: "Size",
        value: size,
      },
      {
        display_type: "date",
        trait_type: "duration",
        value: createdAt,
      },
    ],
  };

  const client = new NFTStorage({ token: NFT_STORAGE_API_KEY });
  const metadata = await client.store(nft);

  return metadata.url;
};
