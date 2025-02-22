const imagejs = require("image-js");
const fs = require("fs");
const webp = require('webp-converter');
const path = require('path');

// Constants
const RESOURCE_NAME = GetCurrentResourceName();
const SCREENSHOTS_DIR = GetResourcePath(RESOURCE_NAME) + "/screenshots";
const IMAGE_CROP_FACTOR = 4.5;
const WEBP_QUALITY = 100;

/**
 * Processes a single image by cropping and removing green screen
 * @param {Buffer} imageBuffer - Raw image data buffer
 * @param {string} outputPath - Path to save the processed image
 */
async function processImage(imageBuffer, outputPath) {
  const image = await imagejs.Image.load(imageBuffer);

  // Crop image
  const croppedImage = image.crop({
    x: image.width / IMAGE_CROP_FACTOR,
    width: image.height,
  });

  image.data = croppedImage.data;
  image.width = croppedImage.width;
  image.height = croppedImage.height;

  // Remove green screen
  const processedImage = image.rgba8();
  for (let x = 0; x < processedImage.width; x++) {
    for (let y = 0; y < processedImage.height; y++) {
      const [r, g, b] = processedImage.getPixelXY(x, y);
      if (g > r + b) {
        processedImage.setPixelXY(x, y, [255, 255, 255, 0]);
      }
    }
  }

  await processedImage.save(outputPath);
}

/**
 * Converts PNG files to WebP format and deletes original PNGs
 * @param {string} directoryPath - Directory containing the images
 */
async function convertToWebP(directoryPath) {
  const files = await fs.promises.readdir(directoryPath);

  for (const file of files.filter(file => path.extname(file) === '.png')) {
    const outputFileName = file.replace('.png', '.webp');
    const inputPath = path.join(directoryPath, file);
    const outputPath = path.join(directoryPath, outputFileName);

    try {
      await webp.cwebp(inputPath, outputPath, `-q ${WEBP_QUALITY}`);
      await fs.promises.unlink(inputPath);
    } catch (error) {
      console.error(`Error converting ${file} to WebP:`, error);
    }
  }
}

try {
  if (!fs.existsSync(SCREENSHOTS_DIR)) {
    fs.mkdirSync(SCREENSHOTS_DIR);
  }

  onNet("screenshotFurniture", async (filename) => {
    try {
      exports.screencapture.serverCapture(
        source,
        { encoding: "png" },
        async (data) => {
          try {
            const imagePath = path.join(SCREENSHOTS_DIR, `${filename}.png`);
            const buffer = Buffer.from(data, "base64");

            await processImage(buffer, imagePath);
            await convertToWebP(SCREENSHOTS_DIR);
          } catch (error) {
            console.error("Error processing image:", error);
          }
        },
        "base64"
      );
    } catch (error) {
      console.error("Error in screenshotFurniture:", error);
    }
  });
} catch (error) {
  console.error("Error initializing screenshot system:", error);
}