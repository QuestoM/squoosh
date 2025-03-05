import { h, Component } from 'preact';
import * as style from './style.css';
import 'add-css:./style.css';
import {
  ProcessorState,
  EncoderState,
  encoderMap,
  defaultPreprocessorState,
} from '../../feature-meta';

interface Props {
  processorState: ProcessorState;
  preprocessorState: typeof defaultPreprocessorState;
  encoderState?: EncoderState;
  processingActive?: boolean;
  onStartProcessing?: () => void;

  onChange: (updates: {
    processorState?: ProcessorState;
    encoderState?: EncoderState;
    preprocessorState?: typeof defaultPreprocessorState;
  }) => void;
}

export default class BatchSettings extends Component<Props> {
  private onEncoderTypeChange = (event: Event) => {
    const select = event.target as HTMLSelectElement;
    const newType = select.value as EncoderState['type'];

    // Get default options for the selected encoder
    const options = encoderMap[newType].meta.defaultOptions;

    this.props.onChange({
      encoderState: {
        type: newType,
        options,
      },
    });
  };

  private onQualityChange = (event: Event) => {
    const input = event.target as HTMLInputElement;
    const quality = Number(input.value);
    const { encoderState } = this.props;

    if (!encoderState) return;

    // Update quality based on encoder type
    switch (encoderState.type) {
      case 'mozJPEG':
        this.props.onChange({
          encoderState: {
            ...encoderState,
            options: {
              ...encoderState.options,
              quality,
            },
          },
        });
        break;
      case 'webP':
        this.props.onChange({
          encoderState: {
            ...encoderState,
            options: {
              ...encoderState.options,
              quality,
            },
          },
        });
        break;
      case 'avif':
        this.props.onChange({
          encoderState: {
            ...encoderState,
            options: {
              ...encoderState.options,
              quality,
            },
          },
        });
        break;
      // Add cases for other encoder types as needed
    }
  };

  render({
    processorState,
    encoderState,
    processingActive,
    onStartProcessing,
  }: Props) {
    return (
      <div
        class={style.batchSettings}
        role="region"
        aria-label="Compression Settings"
      >
        <h2 id="settings-title">Compression Settings</h2>

        <div class={style.settingGroup}>
          <label class={style.settingLabel} htmlFor="format-select">
            Output Format
          </label>
          <select
            id="format-select"
            class={style.formatSelect}
            value={encoderState?.type || 'mozJPEG'}
            onChange={this.onEncoderTypeChange}
            disabled={processingActive}
            aria-describedby="format-description"
          >
            <option value="mozJPEG">JPEG (Best for photos)</option>
            <option value="webP">WebP (Modern format, good compression)</option>
            <option value="avif">AVIF (Best compression, slower)</option>
            <option value="oxiPNG">PNG (Best for graphics)</option>
          </select>
          <div id="format-description" class={style.formatDescription}>
            Select the output format for your compressed images
          </div>
        </div>

        {encoderState && (
          <div class={style.settingGroup}>
            <label class={style.settingLabel}>
              Quality
              {encoderState.type === 'mozJPEG' &&
                ` (${(encoderState.options as any).quality})`}
              {encoderState.type === 'webP' &&
                ` (${(encoderState.options as any).quality})`}
              {encoderState.type === 'avif' &&
                ` (${(encoderState.options as any).quality})`}
            </label>
            <input
              type="range"
              min="0"
              max="100"
              value={(encoderState.options as any).quality || 75}
              onChange={this.onQualityChange}
              disabled={processingActive}
              class={style.qualitySlider}
            />
          </div>
        )}

        <button
          class={style.processButton}
          onClick={onStartProcessing}
          disabled={processingActive}
        >
          {processingActive ? 'Processing...' : 'Process All Images'}
        </button>
      </div>
    );
  }
}
