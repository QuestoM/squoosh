import WorkerBridge from '../worker-bridge';
import {
  EncoderState,
  ProcessorState,
  PreprocessorState,
} from '../feature-meta';

// Implementation of the extension methods
WorkerBridge.prototype.decodeImage = async function (
  file: File,
  signal: AbortSignal,
): Promise<ImageData> {
  // Determine file type and use appropriate decoder
  const fileData = new Uint8Array(await file.arrayBuffer());

  // Use appropriate decoder based on file type
  if (file.type === 'image/jpeg' || file.type === 'image/jpg') {
    // Use browser to decode JPEG
    return this.browserDecode(file, signal);
  } else if (file.type === 'image/png') {
    // Similar approach for PNG
    return this.browserDecode(file, signal);
  } else if (file.type === 'image/webp') {
    return this.webpDecode(signal, new Blob([fileData]));
  } else if (file.type === 'image/avif') {
    return this.avifDecode(signal, new Blob([fileData]));
  } else {
    // Default to browser decoding for other formats
    return this.browserDecode(file, signal);
  }
};

// Helper method for browser-based decoding
WorkerBridge.prototype.browserDecode = async function (
  file: File,
  signal: AbortSignal,
): Promise<ImageData> {
  const img = document.createElement('img');
  const imgLoaded = new Promise<void>((resolve, reject) => {
    img.onload = () => resolve();
    img.onerror = () => reject(new Error('Failed to load image'));
  });

  img.src = URL.createObjectURL(file);
  await imgLoaded;

  const canvas = document.createElement('canvas');
  canvas.width = img.naturalWidth;
  canvas.height = img.naturalHeight;
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('Could not get canvas context');

  ctx.drawImage(img, 0, 0);
  URL.revokeObjectURL(img.src);

  return ctx.getImageData(0, 0, canvas.width, canvas.height);
};

WorkerBridge.prototype.preprocessImage = async function (
  image: ImageData,
  preprocessorState: PreprocessorState,
  signal: AbortSignal,
): Promise<ImageData> {
  // Apply rotation if needed
  if (preprocessorState.rotate.rotate !== 0) {
    return this.rotate(signal, image, preprocessorState.rotate);
  }
  return image;
};

WorkerBridge.prototype.processImage = async function (
  image: ImageData,
  processorState: ProcessorState,
  signal: AbortSignal,
): Promise<ImageData> {
  let processed = image;

  // Apply resize if enabled
  if (processorState.resize.enabled) {
    // Convert browser resize method to worker resize method if needed
    const resizeOptions = {
      width: processorState.resize.width,
      height: processorState.resize.height,
      method: processorState.resize.method.startsWith('browser-')
        ? 'lanczos3'
        : (processorState.resize.method as any),
      premultiply: true,
      linearRGB: true,
    };
    processed = await this.resize(signal, processed, resizeOptions);
  }

  // Apply quantize if enabled
  if (processorState.quantize.enabled) {
    processed = await this.quantize(signal, processed, processorState.quantize);
  }

  return processed;
};

WorkerBridge.prototype.encodeImage = async function (
  image: ImageData,
  encoderState: EncoderState,
  signal: AbortSignal,
): Promise<Blob> {
  // Use appropriate encoder based on type
  switch (encoderState.type) {
    case 'mozJPEG':
      return new Blob(
        [await this.mozjpegEncode(signal, image, encoderState.options)],
        { type: 'image/jpeg' },
      );
    case 'webP':
      return new Blob(
        [await this.webpEncode(signal, image, encoderState.options)],
        { type: 'image/webp' },
      );
    case 'avif':
      return new Blob(
        [await this.avifEncode(signal, image, encoderState.options)],
        { type: 'image/avif' },
      );
    case 'oxiPNG':
      return new Blob(
        [await this.oxipngEncode(signal, image, encoderState.options)],
        { type: 'image/png' },
      );
    case 'jxl':
      return new Blob(
        [await this.jxlEncode(signal, image, encoderState.options)],
        { type: 'image/jxl' },
      );
    default:
      throw new Error(`Unsupported encoder type: ${encoderState.type}`);
  }
};
