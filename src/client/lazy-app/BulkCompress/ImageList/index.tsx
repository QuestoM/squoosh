import { h, Component } from 'preact';
import * as style from './style.css';
import 'add-css:./style.css';

interface BatchImageState {
  file: File;
  status: 'queued' | 'processing' | 'complete' | 'error';
  thumbnail?: string;
  result?: any;
  progress: number;
  error?: string;
}

interface Props {
  images: BatchImageState[];
  onRemove: (index: number) => void;
  onDownload?: (index: number) => void;
}

export default class ImageList extends Component<Props> {
  private getStatusText(status: BatchImageState['status']): string {
    switch (status) {
      case 'complete':
        return 'Processing complete';
      case 'error':
        return 'Error occurred';
      case 'processing':
        return 'Processing in progress';
      default:
        return 'Queued for processing';
    }
  }

  private getStatusClass(status: BatchImageState['status']): string {
    switch (status) {
      case 'complete':
        return style.statusComplete;
      case 'error':
        return style.statusError;
      case 'processing':
        return style.statusProcessing;
      default:
        return style.statusQueued;
    }
  }

  private formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }

  private getCompressionRatio(originalSize: number, compressedSize: number): string {
    const savings = ((originalSize - compressedSize) / originalSize * 100).toFixed(1);
    return savings + '%';
  }

  render({ images, onRemove, onDownload }: Props) {
    return (
      <div class={style.imageList}>
        {images.map((image, index) => (
          <div 
            class={style.imageItem} 
            key={image.file.name}
            role="article"
            aria-label={`Image ${image.file.name}, status: ${this.getStatusText(image.status)}`}
          >
            <div class={style.imageHeader}>
              <span class={style.fileName} title={image.file.name}>{image.file.name}</span>
              <button
                class={style.removeButton}
                onClick={() => onRemove(index)}
                onKeyDown={(e) => e.key === 'Enter' && onRemove(index)}
                aria-label={`Remove ${image.file.name}`}
                tabIndex={0}
              >×</button>
            </div>

            <div class={style.thumbnailContainer}>
              {image.thumbnail ? (
                <img src={image.thumbnail} alt={image.file.name} class={style.thumbnail} />
              ) : (
                <div class={style.thumbnailPlaceholder}>Loading...</div>
              )}

              <div class={`${style.statusBadge} ${this.getStatusClass(image.status)}`}>
                {image.status}
              </div>
            </div>

            <div class={style.imageInfo}>
              <div class={style.infoRow}>
                <span>Original:</span>
                <span>{this.formatFileSize(image.file.size)}</span>
              </div>

              {image.result && (
                <div class={style.infoRow}>
                  <span>Compressed:</span>
                  <span>{this.formatFileSize(image.result.file.size)}</span>
                </div>
              )}

              {image.result && (
                <div class={style.infoRow}>
                  <span>Savings:</span>
                  <span>{this.getCompressionRatio(image.file.size, image.result.file.size)}</span>
                </div>
              )}
            </div>

            {image.status === 'processing' && (
              <div class={style.progressContainer}>
                <div class={style.progressBar} style={{ width: `${image.progress * 100}%` }}></div>
              </div>
            )}
          </div>
        ))}
      </div>
    );
  }
}