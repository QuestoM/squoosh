import { jest } from '@jest/globals';
import WorkerBridge from '../index';
import { wrap } from 'comlink';

jest.mock('../../util', () => ({
  abortable: jest.fn().mockImplementation((signal, promise) => promise),
}));

jest.mock('../../../features-worker', () => 'worker-url', { virtual: true });

jest.mock('comlink', () => ({
  wrap: jest.fn(),
}));

describe('WorkerBridge', () => {
  let bridge: WorkerBridge;
  let mockWorkerApi: any;
  let mockAbortController: AbortController;
  let mockImageData: ImageData;
  let mockWorker: Worker;

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Create mock ImageData for tests
    mockImageData = new ImageData(1, 1);

    // Setup mock worker API
    mockWorkerApi = {
      avifEncode: jest.fn(),
      mozjpegEncode: jest.fn(),
      resize: jest.fn(),
      webpEncode: jest.fn(),
      quantize: jest.fn(),
      rotate: jest.fn(),
    };

    mockWorker = {
      terminate: jest.fn(),
    } as unknown as Worker;

    // Mock Worker constructor
    (global.Worker as any) = jest.fn().mockImplementation(() => mockWorker);
    (wrap as jest.Mock).mockReturnValue(mockWorkerApi);

    // Create new bridge instance
    bridge = new WorkerBridge();

    // Setup abort controller
    mockAbortController = new AbortController();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should initialize worker when first method is called', async () => {
    const signal = mockAbortController.signal;
    await bridge.avifEncode(signal, mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });

    expect(wrap).toHaveBeenCalled();
    expect(mockWorkerApi.avifEncode).toHaveBeenCalledWith(mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });
  });

  it('should terminate worker after timeout', async () => {
    jest.useFakeTimers();
    const signal = mockAbortController.signal;

    await bridge.avifEncode(signal, mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });
    jest.advanceTimersByTime(10000);

    // Try to use the worker again - it should create a new one
    await bridge.mozjpegEncode(signal, mockImageData, {
      quality: 75,
      baseline: false,
      arithmetic: false,
      progressive: true,
      optimize_coding: true,
      smoothing: 0,
      color_space: 3,
      quant_table: 3,
      trellis_multipass: false,
      trellis_opt_zero: false,
      trellis_opt_table: false,
      trellis_loops: 1,
      auto_subsample: true,
      chroma_subsample: 2,
      separate_chroma_quality: false,
      chroma_quality: 75,
    });
    expect(wrap).toHaveBeenCalledTimes(2);
  });

  it('should handle abort signal', async () => {
    const signal = mockAbortController.signal;
    const encodePromise = bridge.avifEncode(signal, mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });

    mockAbortController.abort();
    await expect(encodePromise).rejects.toThrow('AbortError');
  });

  it('should queue multiple operations', async () => {
    const signal = mockAbortController.signal;

    const promise1 = bridge.avifEncode(signal, mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });
    const promise2 = bridge.mozjpegEncode(signal, mockImageData, {
      quality: 75,
      baseline: false,
      arithmetic: false,
      progressive: true,
      optimize_coding: true,
      smoothing: 0,
      color_space: 3,
      quant_table: 3,
      trellis_multipass: false,
      trellis_opt_zero: false,
      trellis_opt_table: false,
      trellis_loops: 1,
      auto_subsample: true,
      chroma_subsample: 2,
      separate_chroma_quality: false,
      chroma_quality: 75,
    });

    await Promise.all([promise1, promise2]);

    expect(mockWorkerApi.avifEncode).toHaveBeenCalled();
    expect(mockWorkerApi.mozjpegEncode).toHaveBeenCalled();
    expect(mockWorkerApi.avifEncode.mock.invocationCallOrder[0]).toBeLessThan(
      mockWorkerApi.mozjpegEncode.mock.invocationCallOrder[0],
    );
  });

  it('should continue queue after error', async () => {
    const signal = mockAbortController.signal;
    mockWorkerApi.avifEncode.mockRejectedValueOnce(new Error('Test error'));

    await expect(
      bridge.avifEncode(signal, mockImageData, {
        quality: 50,
        qualityAlpha: -1,
        denoiseLevel: 0,
        tileColsLog2: 0,
        tileRowsLog2: 0,
        speed: 6,
        subsample: 1,
        chromaDeltaQ: false,
        sharpness: 0,
        tune: 0,
        enableSharpYUV: false,
      }),
    ).rejects.toThrow('Test error');
    await expect(
      bridge.mozjpegEncode(signal, mockImageData, {
        quality: 75,
        baseline: false,
        arithmetic: false,
        progressive: true,
        optimize_coding: true,
        smoothing: 0,
        color_space: 3,
        quant_table: 3,
        trellis_multipass: false,
        trellis_opt_zero: false,
        trellis_opt_table: false,
        trellis_loops: 1,
        auto_subsample: true,
        chroma_subsample: 2,
        separate_chroma_quality: false,
        chroma_quality: 75,
      }),
    ).resolves.not.toThrow();
  });

  it('should terminate worker when signal is aborted', async () => {
    const signal = mockAbortController.signal;
    const promise = bridge.avifEncode(signal, mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });

    mockAbortController.abort();
    await expect(promise).rejects.toThrow('AbortError');
    expect(mockWorker.terminate).toHaveBeenCalled();
  });

  it('should handle multiple operations with different methods', async () => {
    const signal = mockAbortController.signal;

    const promise1 = bridge.webpEncode(signal, mockImageData, {
      quality: 75,
      target_size: 0,
      target_PSNR: 0,
      method: 4,
      sns_strength: 50,
      filter_strength: 60,
      filter_sharpness: 0,
      filter_type: 1,
      partitions: 0,
      segments: 4,
      pass: 1,
      show_compressed: 0,
      preprocessing: 0,
      autofilter: 0,
      partition_limit: 0,
      alpha_compression: 1,
      alpha_filtering: 1,
      alpha_quality: 100,
      lossless: 0,
      exact: 0,
      image_hint: 0,
      emulate_jpeg_size: 0,
      thread_level: 0,
      low_memory: 0,
      near_lossless: 100,
      use_delta_palette: 0,
      use_sharp_yuv: 0,
    });
    const promise2 = bridge.quantize(signal, mockImageData, {
      zx: 0,
      maxNumColors: 256,
      dither: 1.0,
    });
    const promise3 = bridge.rotate(signal, mockImageData, {
      rotate: 90,
    });

    await Promise.all([promise1, promise2, promise3]);

    expect(mockWorkerApi.webpEncode).toHaveBeenCalled();
    expect(mockWorkerApi.quantize).toHaveBeenCalled();
    expect(mockWorkerApi.rotate).toHaveBeenCalled();
  });

  it('should not create new worker if one already exists', async () => {
    const signal = mockAbortController.signal;

    await bridge.avifEncode(signal, mockImageData, {
      quality: 50,
      qualityAlpha: -1,
      denoiseLevel: 0,
      tileColsLog2: 0,
      tileRowsLog2: 0,
      speed: 6,
      subsample: 1,
      chromaDeltaQ: false,
      sharpness: 0,
      tune: 0,
      enableSharpYUV: false,
    });
    await bridge.mozjpegEncode(signal, mockImageData, {
      quality: 75,
      baseline: false,
      arithmetic: false,
      progressive: true,
      optimize_coding: true,
      smoothing: 0,
      color_space: 3,
      quant_table: 3,
      trellis_multipass: false,
      trellis_opt_zero: false,
      trellis_opt_table: false,
      trellis_loops: 1,
      auto_subsample: true,
      chroma_subsample: 2,
      separate_chroma_quality: false,
      chroma_quality: 75,
    });

    expect(global.Worker).toHaveBeenCalledTimes(1);
  });

  it('should do nothing when terminating non-existent worker', () => {
    bridge['_terminateWorker']();
    expect(mockWorker.terminate).not.toHaveBeenCalled();
  });
});
