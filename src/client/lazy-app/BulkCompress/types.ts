import { Options as RotateOptions } from '../../../features/preprocessors/rotate/shared/meta';
import { Options as QuantizeOptions } from '../../../features/processors/quantize/shared/meta';
import { Options as ResizeOptions } from '../../../features/processors/resize/shared/meta';

export interface PreprocessorState {
  rotate: RotateOptions;
}

export interface ProcessorState {
  resize: {
    enabled: boolean;
  } & ResizeOptions;
  quantize: {
    enabled: boolean;
  } & QuantizeOptions;
}

export interface EncoderState {
  type: 'mozJPEG' | 'webP' | 'avif' | 'oxiPNG' | 'jxl';
  options: any;
}
