import { h, Component } from 'preact';
import * as style from './style.css';
import 'add-css:./style.css';

interface Props {
  totalImages: number;
  processedImages: number;
  totalSavings: number;
  originalSize: number;
  compressedSize: number;
  onDownloadAll: () => void;
}

export default class BatchResults extends Component<Props> {
  private formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }

  render({ totalImages, processedImages, totalSavings, originalSize, compressedSize, onDownloadAll }: Props) {
    const savingsPercent = totalSavings.toFixed(1);
    
    return (
      <div class={style.batchResults} role="region" aria-label="Batch Processing Results">
        <h2 id="results-title">Batch Results</h2>
        
        <div class={style.statsContainer} aria-labelledby="results-title">
          <div class={style.statItem} role="status" aria-label="Processing Progress">
            <div class={style.statValue} aria-label={`${processedImages} out of ${totalImages} images processed`}>
              {processedImages} / {totalImages}
            </div>
            <div class={style.statLabel}>Images Processed</div>
          </div>

          <div class={style.statItem}>
            <div class={style.statValue}>{savingsPercent}%</div>
            <div class={style.statLabel}>Total Savings</div>
          </div>

          <div class={style.statItem}>
            <div class={style.statValue}>{this.formatFileSize(originalSize)}</div>
            <div class={style.statLabel}>Original Size</div>
          </div>

          <div class={style.statItem}>
            <div class={style.statValue}>{this.formatFileSize(compressedSize)}</div>
            <div class={style.statLabel}>Compressed Size</div>
          </div>
        </div>

        <button 
          class={style.downloadButton}
          onClick={onDownloadAll}
          disabled={processedImages === 0}
          aria-disabled={processedImages === 0}
          aria-label={processedImages === 0 ? "No processed images to download" : "Download all processed images"}
        >
          {processedImages === 0 ? "No Images to Download" : "Download All Images"}
        </button>
      </div>
    );
  }
}