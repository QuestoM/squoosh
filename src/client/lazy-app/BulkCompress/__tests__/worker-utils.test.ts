import { jest } from '@jest/globals';
import WorkerBridge from '../../worker-bridge';
import { ProcessorState, PreprocessorState, EncoderState } from '../types';

// Import the extended WorkerBridge with BulkCompress methods
import '../worker-utils';

jest.mock('../../worker-bridge');

describe('WorkerBridge BulkCompress Methods', () => {
  let bridge: WorkerBridge;
  let mockImageData: ImageData;
  let mockFile: File;
  let mockAbortController: AbortController;

  beforeEach(() => {
    jest.clearAllMocks();

    // Create mock instances
    mockImageData = new ImageData(1, 1);
    mockFile = new File([''], 'test.jpg', { type: 'image/jpeg' });
    mockAbortController = new AbortController();

    // Initialize bridge
    bridge = new WorkerBridge();

    // Mock URL methods
    global.URL.createObjectURL = jest.fn().mockReturnValue('blob:test');
    global.URL.revokeObjectURL = jest.fn();

    // Mock document methods
    document.createElement = jest.fn().mockImplementation((tag) => {
      if (tag === 'img') {
        return {
          onload: null,
          onerror: null,
          naturalWidth: 100,
          naturalHeight: 100,
          src: '',
        };
      } else if (tag === 'canvas') {
        return {
          width: 0,
          height: 0,
          getContext: jest.fn().mockReturnValue({
            drawImage: jest.fn(),
            getImageData: jest.fn().mockReturnValue(mockImageData),
          }),
        };
      }
      return {};
    });
  });

  describe('decodeImage', () => {
    it('should decode JPEG images using browser decoder', async () => {
      const signal = mockAbortController.signal;
      const result = await bridge.decodeImage(mockFile, signal);

      expect(result).toBeInstanceOf(ImageData);
      expect(URL.createObjectURL).toHaveBeenCalledWith(mockFile);
      expect(URL.revokeObjectURL).toHaveBeenCalled();
    });

    it('should decode PNG images using browser decoder', async () => {
      mockFile = new File([''], 'test.png', { type: 'image/png' });
      const signal = mockAbortController.signal;

      const result = await bridge.decodeImage(mockFile, signal);
      expect(result).toBeInstanceOf(ImageData);
    });

    it('should decode WebP images using WebP decoder', async () => {
      mockFile = new File([''], 'test.webp', { type: 'image/webp' });
      const signal = mockAbortController.signal;

      (bridge as any).webpDecode = jest.fn().mockResolvedValue(mockImageData);
      const result = await bridge.decodeImage(mockFile, signal);

      expect(result).toBe(mockImageData);
      expect((bridge as any).webpDecode).toHaveBeenCalled();
    });

    it('should decode AVIF images using AVIF decoder', async () => {
      mockFile = new File([''], 'test.avif', { type: 'image/avif' });
      const signal = mockAbortController.signal;

      (bridge as any).avifDecode = jest.fn().mockResolvedValue(mockImageData);
      const result = await bridge.decodeImage(mockFile, signal);

      expect(result).toBe(mockImageData);
      expect((bridge as any).avifDecode).toHaveBeenCalled();
    });
  });

  describe('preprocessImage', () => {
    it('should apply rotation when specified', async () => {
      const signal = mockAbortController.signal;
      const preprocessorState: PreprocessorState = {
        rotate: { rotate: 90 },
      };

      (bridge as any).rotate = jest.fn().mockResolvedValue(mockImageData);
      const result = await bridge.preprocessImage(
        mockImageData,
        preprocessorState,
        signal,
      );

      expect(result).toBe(mockImageData);
      expect((bridge as any).rotate).toHaveBeenCalledWith(
        signal,
        mockImageData,
        preprocessorState.rotate,
      );
    });

    it('should return original image when no rotation needed', async () => {
      const signal = mockAbortController.signal;
      const preprocessorState: PreprocessorState = {
        rotate: { rotate: 0 },
      };

      const result = await bridge.preprocessImage(
        mockImageData,
        preprocessorState,
        signal,
      );
      expect(result).toBe(mockImageData);
    });
  });

  describe('processImage', () => {
    it('should apply resize and quantize when both enabled', async () => {
      const signal = mockAbortController.signal;
      const processorState: ProcessorState = {
        resize: { enabled: true, width: 100, height: 100 },
        quantize: { enabled: true, numColors: 256 },
      };

      (bridge as any).resize = jest.fn().mockResolvedValue(mockImageData);
      (bridge as any).quantize = jest.fn().mockResolvedValue(mockImageData);

      const result = await bridge.processImage(
        mockImageData,
        processorState,
        signal,
      );

      expect(result).toBe(mockImageData);
      expect((bridge as any).resize).toHaveBeenCalled();
      expect((bridge as any).quantize).toHaveBeenCalled();
    });

    it('should only apply resize when quantize is disabled', async () => {
      const signal = mockAbortController.signal;
      const processorState: ProcessorState = {
        resize: { enabled: true, width: 100, height: 100 },
        quantize: { enabled: false },
      };

      (bridge as any).resize = jest.fn().mockResolvedValue(mockImageData);

      const result = await bridge.processImage(
        mockImageData,
        processorState,
        signal,
      );

      expect(result).toBe(mockImageData);
      expect((bridge as any).resize).toHaveBeenCalled();
      expect((bridge as any).quantize).not.toHaveBeenCalled();
    });
  });

  describe('encodeImage', () => {
    it('should encode to JPEG using mozJPEG', async () => {
      const signal = mockAbortController.signal;
      const encoderState: EncoderState = {
        type: 'mozJPEG',
        options: { quality: 75 },
      };

      (bridge as any).mozjpegEncode = jest
        .fn()
        .mockResolvedValue(new Uint8Array());
      const result = await bridge.encodeImage(
        mockImageData,
        encoderState,
        signal,
      );

      expect(result).toBeInstanceOf(Blob);
      expect((bridge as any).mozjpegEncode).toHaveBeenCalled();
    });

    it('should encode to WebP', async () => {
      const signal = mockAbortController.signal;
      const encoderState: EncoderState = {
        type: 'webP',
        options: { quality: 75 },
      };

      (bridge as any).webpEncode = jest
        .fn()
        .mockResolvedValue(new Uint8Array());
      const result = await bridge.encodeImage(
        mockImageData,
        encoderState,
        signal,
      );

      expect(result).toBeInstanceOf(Blob);
      expect((bridge as any).webpEncode).toHaveBeenCalled();
    });

    it('should encode to AVIF', async () => {
      const signal = mockAbortController.signal;
      const encoderState: EncoderState = {
        type: 'avif',
        options: { quality: 75 },
      };

      (bridge as any).avifEncode = jest
        .fn()
        .mockResolvedValue(new Uint8Array());
      const result = await bridge.encodeImage(
        mockImageData,
        encoderState,
        signal,
      );

      expect(result).toBeInstanceOf(Blob);
      expect((bridge as any).avifEncode).toHaveBeenCalled();
    });

    it('should encode to PNG using oxiPNG', async () => {
      const signal = mockAbortController.signal;
      const encoderState: EncoderState = {
        type: 'oxiPNG',
        options: { level: 2 },
      };

      (bridge as any).oxipngEncode = jest
        .fn()
        .mockResolvedValue(new Uint8Array());
      const result = await bridge.encodeImage(
        mockImageData,
        encoderState,
        signal,
      );

      expect(result).toBeInstanceOf(Blob);
      expect((bridge as any).oxipngEncode).toHaveBeenCalled();
    });

    it('should encode to JXL', async () => {
      const signal = mockAbortController.signal;
      const encoderState: EncoderState = {
        type: 'jxl',
        options: { quality: 75 },
      };

      (bridge as any).jxlEncode = jest.fn().mockResolvedValue(new Uint8Array());
      const result = await bridge.encodeImage(
        mockImageData,
        encoderState,
        signal,
      );

      expect(result).toBeInstanceOf(Blob);
      expect((bridge as any).jxlEncode).toHaveBeenCalled();
    });

    it('should throw error for unsupported encoder type', async () => {
      const signal = mockAbortController.signal;
      const encoderState: EncoderState = {
        type: 'unknown' as any,
        options: {},
      };

      await expect(
        bridge.encodeImage(mockImageData, encoderState, signal),
      ).rejects.toThrow('Unsupported encoder type: unknown');
    });
  });
});
