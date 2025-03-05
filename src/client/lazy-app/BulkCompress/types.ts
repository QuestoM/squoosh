export interface PreprocessorState {
  rotate: {
    rotate: number;
  };
}

export interface ProcessorState {
  resize: {
    enabled: boolean;
    width: number;
    height: number;
  };
  quantize: {
    enabled: boolean;
    numColors?: number;
  };
}

export interface EncoderState {
  type: 'mozJPEG' | 'webP' | 'avif' | 'oxiPNG' | 'jxl';
  options: any;
}
