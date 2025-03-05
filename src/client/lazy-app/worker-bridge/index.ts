import { wrap } from 'comlink';
import { BridgeMethods, methodNames } from './meta';
import workerURL from 'omt:../../../features-worker';
import type { ProcessorWorkerApi } from '../../../features-worker';
import { abortable } from '../util';
import {
  EncoderState,
  ProcessorState,
  PreprocessorState,
} from '../feature-meta';

// Import worker function types
import type avifDecode from '../../../features/decoders/avif/worker/avifDecode';
import type jxlDecode from '../../../features/decoders/jxl/worker/jxlDecode';
import type qoiDecode from '../../../features/decoders/qoi/worker/qoiDecode';
import type webpDecode from '../../../features/decoders/webp/worker/webpDecode';
import type wp2Decode from '../../../features/decoders/wp2/worker/wp2Decode';
import type avifEncode from '../../../features/encoders/avif/worker/avifEncode';
import type jxlEncode from '../../../features/encoders/jxl/worker/jxlEncode';
import type mozjpegEncode from '../../../features/encoders/mozJPEG/worker/mozjpegEncode';
import type oxipngEncode from '../../../features/encoders/oxiPNG/worker/oxipngEncode';
import type qoiEncode from '../../../features/encoders/qoi/worker/qoiEncode';
import type webpEncode from '../../../features/encoders/webP/worker/webpEncode';
import type wp2Encode from '../../../features/encoders/wp2/worker/wp2Encode';
import type rotate from '../../../features/preprocessors/rotate/worker/rotate';
import type quantize from '../../../features/processors/quantize/worker/quantize';
import type resize from '../../../features/processors/resize/worker/resize';

/** How long the worker should be idle before terminating. */
const workerTimeout = 10_000;

// Extend the base methods but override the return types to avoid Promise<Promise<T>> issues
interface WorkerBridge {
  // Original BridgeMethods
  avifDecode(
    signal: AbortSignal,
    ...args: Parameters<typeof avifDecode>
  ): Promise<ReturnType<typeof avifDecode>>;
  jxlDecode(
    signal: AbortSignal,
    ...args: Parameters<typeof jxlDecode>
  ): Promise<ReturnType<typeof jxlDecode>>;
  qoiDecode(
    signal: AbortSignal,
    ...args: Parameters<typeof qoiDecode>
  ): Promise<ReturnType<typeof qoiDecode>>;
  webpDecode(
    signal: AbortSignal,
    ...args: Parameters<typeof webpDecode>
  ): Promise<ReturnType<typeof webpDecode>>;
  wp2Decode(
    signal: AbortSignal,
    ...args: Parameters<typeof wp2Decode>
  ): Promise<ReturnType<typeof wp2Decode>>;
  avifEncode(
    signal: AbortSignal,
    ...args: Parameters<typeof avifEncode>
  ): Promise<ReturnType<typeof avifEncode>>;
  jxlEncode(
    signal: AbortSignal,
    ...args: Parameters<typeof jxlEncode>
  ): Promise<ReturnType<typeof jxlEncode>>;
  mozjpegEncode(
    signal: AbortSignal,
    ...args: Parameters<typeof mozjpegEncode>
  ): Promise<ReturnType<typeof mozjpegEncode>>;
  oxipngEncode(
    signal: AbortSignal,
    ...args: Parameters<typeof oxipngEncode>
  ): Promise<ReturnType<typeof oxipngEncode>>;
  qoiEncode(
    signal: AbortSignal,
    ...args: Parameters<typeof qoiEncode>
  ): Promise<ReturnType<typeof qoiEncode>>;
  webpEncode(
    signal: AbortSignal,
    ...args: Parameters<typeof webpEncode>
  ): Promise<ReturnType<typeof webpEncode>>;
  wp2Encode(
    signal: AbortSignal,
    ...args: Parameters<typeof wp2Encode>
  ): Promise<ReturnType<typeof wp2Encode>>;
  rotate(
    signal: AbortSignal,
    ...args: Parameters<typeof rotate>
  ): Promise<ReturnType<typeof rotate>>;
  quantize(
    signal: AbortSignal,
    ...args: Parameters<typeof quantize>
  ): Promise<ReturnType<typeof quantize>>;
  resize(
    signal: AbortSignal,
    ...args: Parameters<typeof resize>
  ): Promise<ReturnType<typeof resize>>;

  // Additional methods
  decodeImage(file: File, signal: AbortSignal): Promise<ImageData>;
  preprocessImage(
    image: ImageData,
    preprocessorState: PreprocessorState,
    signal: AbortSignal,
  ): Promise<ImageData>;
  processImage(
    image: ImageData,
    processorState: ProcessorState,
    signal: AbortSignal,
  ): Promise<ImageData>;
  encodeImage(
    image: ImageData,
    encoderState: EncoderState,
    signal: AbortSignal,
  ): Promise<Blob>;
  browserDecode(file: File, signal: AbortSignal): Promise<ImageData>;
}

class WorkerBridge {
  protected _queue = Promise.resolve() as Promise<unknown>;
  /** Worker instance associated with this processor. */
  protected _worker?: Worker;
  /** Comlinked worker API. */
  protected _workerApi?: ProcessorWorkerApi;
  /** ID from setTimeout */
  protected _workerTimeout?: number;

  protected _terminateWorker() {
    if (!this._worker) return;
    this._worker.terminate();
    this._worker = undefined;
    this._workerApi = undefined;
  }

  protected _startWorker() {
    this._worker = new Worker(workerURL);
    this._workerApi = wrap<ProcessorWorkerApi>(this._worker);
  }
}

for (const methodName of methodNames) {
  WorkerBridge.prototype[methodName] = function (
    this: WorkerBridge,
    signal: AbortSignal,
    ...args: any
  ) {
    this._queue = this._queue
      // Ignore any errors in the queue
      .catch(() => {})
      .then(async () => {
        if (signal.aborted) throw new DOMException('AbortError', 'AbortError');

        if (this._workerTimeout !== undefined)
          clearTimeout(this._workerTimeout);
        if (!this._worker) this._startWorker();

        const onAbort = () => this._terminateWorker();
        signal.addEventListener('abort', onAbort);

        return abortable(
          signal,
          // @ts-ignore - TypeScript can't figure this out
          this._workerApi![methodName](...args),
        ).finally(() => {
          // No longer care about aborting - this task is complete.
          signal.removeEventListener('abort', onAbort);

          // Start a timer to clear up the worker.
          this._workerTimeout = setTimeout(() => {
            this._terminateWorker();
          }, workerTimeout) as number;
        });
      });

    return this._queue;
  } as any;
}

export default WorkerBridge;
