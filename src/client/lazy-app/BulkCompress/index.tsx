import { h, Component, Fragment } from 'preact';
import * as style from './style.css';
import 'add-css:./style.css';
import ImageList from './ImageList';
import BatchSettings from './BatchSettings';
import BatchResults from './BatchResults';
import { linkRef } from 'shared/prerendered-app/util';
import { defaultProcessorState, ProcessorState, EncoderState, encoderMap, defaultPreprocessorState } from '../feature-meta';
import WorkerBridge from '../worker-bridge';
import { blobToImg } from '../util';
import JSZip from 'jszip';
import type SnackBarElement from 'shared/custom-els/snack-bar';
import { cleanSet, cleanMerge } from '../util/clean-modify';
import 'shared/custom-els/loading-spinner';
import BulkResultCache from './bulk-result-cache';

export type OutputType = string;

interface ProcessedResult {
  file: File;
  downloadUrl: string;
  data?: ImageData;
}

interface BatchImageState {
  file: File;
  status: 'queued' | 'processing' | 'complete' | 'error';
  thumbnail?: string;
  result?: ProcessedResult;
  progress: number;
  error?: string;
}

interface Props {
  files: File[];
  showSnack: SnackBarElement['showSnackbar'];
  onBack: () =
}

interface State {
  processorState: ProcessorState;
  preprocessorState: typeof defaultPreprocessorState;
  encoderState?: EncoderState;
  images: BatchImageState[];
  overallProgress: number;
  processingActive: boolean;
  concurrency: number;
}

export default class BulkCompress extends Component<Props, State> {
  private workerBridges: WorkerBridge[] = [];
  private activeWorkers = 0;
  private imageQueue: number[] = [];
  private readonly resultCache = new BulkResultCache();
  private snackbar?: SnackBarElement;

  state: State = {
    processorState: defaultProcessorState,
    preprocessorState: defaultPreprocessorState,
    encoderState: {
      type: 'mozJPEG',
      options: encoderMap.mozJPEG.meta.defaultOptions,
    },
    images: [],
    overallProgress: 0,
    processingActive: false,
    concurrency: this.determineOptimalConcurrency()
  };

  constructor(props: Props) {
    super(props);

    // Initialize worker bridges
    for (let i = 0; i < this.state.concurrency; i++) {
      this.workerBridges.push(new WorkerBridge());
    }
  }

  private determineOptimalConcurrency(): number {
    // @ts-ignore - deviceMemory is not in all browsers' type definitions

    // Conservative estimate - 1 worker per 1GB of RAM, up to available cores
    return Math.min(Math.max(1, Math.floor(totalRAM / 2)), availableCores, 4);
  }

  componentDidMount() {
    // Initialize images from props.files
    this.setState({
      images: this.props.files.map(file =
        file,
        status: 'queued',
      })),
      imageQueue: this.props.files.map((_, i) =
    });

    // Generate thumbnails asynchronously
    this.generateThumbnails();
  }

  componentWillUnmount() {
    // Clean up any resources
    for (const image of this.state.images) {
      if (image.thumbnail) URL.revokeObjectURL(image.thumbnail);
      if (image.result?.downloadUrl) URL.revokeObjectURL(image.result.downloadUrl);
    }
  }

  private async generateThumbnails() {
    const { images } = this.state;
    const newImages = [...images];

    // Process thumbnails in batches to avoid memory issues
    const batchSize = 5;
    for (let i = 0; i < images.length; i += batchSize) {
      const batch = images.slice(i, i + batchSize);
      await Promise.all(
        batch.map(async (image, index) =
          try {
            const thumbnailBlob = await this.createThumbnail(image.file);
            const thumbnailUrl = URL.createObjectURL(thumbnailBlob);
            newImages[i + index].thumbnail = thumbnailUrl;
          } catch (err) {
            console.error('Error creating thumbnail:', err);
          }
        })
      );

      // Update state after each batch
      this.setState({ images: [...newImages] });
    }
  }

  private async createThumbnail(file: File): Promise<Blob> {
    // Create a thumbnail with max dimension of 200px
    const MAX_DIMENSION = 200;

    // Load the image
    const img = await blobToImg(file);

    // Calculate dimensions
    const ratio = Math.min(MAX_DIMENSION / img.width, MAX_DIMENSION / img.height);
    const width = Math.round(img.width * ratio);
    const height = Math.round(img.height * ratio);

    // Draw to canvas
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    if (!ctx) throw Error('Could not get canvas context');
    ctx.drawImage(img, 0, 0, width, height);

    // Get as blob
    return new Promise((resolve, reject) =
      canvas.toBlob(blob =
        if (blob) resolve(blob);
        else reject(new Error('Could not create thumbnail'));
      }, 'image/jpeg', 0.7);
    });
  }

  private onSettingsChange = (updates: {
    processorState?: ProcessorState,
    encoderState?: EncoderState,
    preprocessorState?: typeof defaultPreprocessorState
  }) =
    this.setState(updates);
  }

  private startProcessing = () =
    if (this.state.processingActive) return;

    this.setState({
      processingActive: true,
      imageQueue: this.state.images.map((_, i) = !== 'complete')
    }, () =
      // Start processing
      this.processNext();
    });
  }

  private processNext() {
    if (!this.state.processingActive) return;

    // Process up to concurrency limit
    while (this.activeWorkers < this.state.concurrency && this.state.imageQueue.length > 0) {
      const imageIndex = this.state.imageQueue.shift()!;
      this.processImage(imageIndex);
    }

    // Check if we're all done
    if (this.activeWorkers === 0 && this.state.imageQueue.length === 0) {
      this.setState({ processingActive: false, overallProgress: 100 });
      this.props.showSnack('All images processed successfully!', { timeout: 3000 });
    }
  }

  private async processImage(index: number) {
    this.activeWorkers++;
    const image = this.state.images[index];
    const workerIndex = index % this.workerBridges.length;
    const bridge = this.workerBridges[workerIndex];

    // Update status to processing
    this.updateImageState(index, { status: 'processing', progress: 0 });

    try {
      // Create abort controller for cancellation support
      const controller = new AbortController();

      // Decode image
      const decoded = await bridge.decode(image.file, controller.signal);
      this.updateProgress(index, 25);

      // Preprocess image
      const preprocessed = await bridge.preprocess(
        decoded,
        this.state.preprocessorState,
        controller.signal
      );
      this.updateProgress(index, 50);

      // Process image
      const processed = await bridge.process(
        preprocessed,
        this.state.processorState,
        controller.signal
      );
      this.updateProgress(index, 75);

      // Encode image
      const encodedBlob = await bridge.encode(
        processed,
        this.state.encoderState!,
        controller.signal
      );

      // Create result file with proper extension
      const extension = this.getFileExtension(this.state.encoderState!.type);
      const newFileName = image.file.name.replace(/\.[^.]+$/, `.${extension}`);
      const result = {
        file: new File([encodedBlob], newFileName, { type: encodedBlob.type }),
        downloadUrl: URL.createObjectURL(encodedBlob),
        data: processed
      };

      // Update with final result
      this.updateImageState(index, {
        status: 'complete',
        progress: 100,
        result
      });

      /* Actual implementation would be similar to Compress component:

      // Decode image
      const decoded = await decodeImage(controller.signal, image.file, bridge);

      // Preprocess
      const preprocessed = await preprocessImage(
        controller.signal,
        decoded,
        this.state.preprocessorState,
        bridge
      );

      // Process
      const processed = await processImage(
        controller.signal,
        { file: image.file, decoded, preprocessed },
        this.state.processorState,
        bridge
      );

      // Encode
      const encodedFile = this.state.encoderState ? 
        await compressImage(
          controller.signal,
          processed,
          this.state.encoderState,
          image.file.name,
          bridge
        ) : image.file;

      const result = {
        file: encodedFile,
        downloadUrl: URL.createObjectURL(encodedFile),
        data: processed
      };
      */

    } catch (error) {
      console.error(`Error processing image ${index}:`, error);
      this.updateImageState(index, {
        status: 'error',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    } finally {
      this.activeWorkers--;
      this.processNext();
    }
  }

  private updateImageState(index: number, updates: Partial<BatchImageState>) {
    this.setState(state =
      const newImages = [...state.images];
      newImages[index] = { ...newImages[index], ...updates };
      return { images: newImages };
    });
  }

  private updateProgress(index: number, progress: number) {
    this.updateImageState(index, { progress });

    // Calculate overall progress
    this.setState(state => {
      const overallProgress = state.images.reduce((sum, img) => sum + img.progress, 0) / state.images.length;
      return { overallProgress };
    });
  }

  private getFileExtension(encoderType: EncoderState['type']): string {
    switch (encoderType) {
      case 'mozJPEG':
        return 'jpg';
      case 'webP':
        return 'webp';
      case 'avif':
        return 'avif';
      case 'oxiPNG':
        return 'png';
      case 'jxl':
        return 'jxl';
      default:
        return 'jpg';
    }
  }

  private removeImage = (index: number) =
    this.setState(state =
      const image = state.images[index];

      // Clean up resources
      if (image.thumbnail) URL.revokeObjectURL(image.thumbnail);
      if (image.result?.downloadUrl) URL.revokeObjectURL(image.result.downloadUrl);

      // Remove from images array
      const newImages = [...state.images];
      newImages.splice(index, 1);

      // Update queue if needed
      const newQueue = state.imageQueue.map(i = ? i - 1 : i).filter(i = !== index);

      return {
        images: newImages,
        imageQueue: newQueue,
        overallProgress: newImages.length 
          ? newImages.reduce((sum, img) = + img.progress, 0) / newImages.length
      };
    });
  }

  private downloadSingle = (index: number) =
    const image = this.state.images[index];
    if (!image.result) return;

    // Create a download link and click it
    const a = document.createElement('a');
    a.href = image.result.downloadUrl;
    a.download = image.result.file.name;
    a.click();
  }

  private downloadAll = async () =
    const { images } = this.state;

    if (completedImages.length === 0) {
      this.props.showSnack('No processed images to download');
      return;
    }

    try {
      this.props.showSnack('Preparing ZIP file...');

      const zip = new JSZip();

      // Add each file to the zip
      for (const image of completedImages) {
        if (!image.result) continue;
        const blob = await fetch(image.result.downloadUrl).then(r =
        zip.file(image.result.file.name, blob);
      }

      // Generate the zip file
      const zipBlob = await zip.generateAsync({ type: 'blob' });

      // Create download link
      const url = URL.createObjectURL(zipBlob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'squoosh-images.zip';
      a.click();

      // Clean up
      URL.revokeObjectURL(url);
      this.props.showSnack('Download started!', { timeout: 2000 });
    } catch (err) {
      console.error('Error creating zip:', err);
      this.props.showSnack('Failed to create ZIP file');
    }
  }

  private showSnack = (message: string, options = {}) =
    if (!this.snackbar) throw Error('Snackbar missing');
    return this.snackbar.showSnackbar(message, options);
  };

  render({ onBack }: Props, { images, processorState, encoderState, overallProgress, processingActive }: State) {
    const completedCount = images.filter(img = === 'complete').length;
    const errorCount = images.filter(img = === 'error').length;
    const isAllComplete = completedCount === images.length;

    return (
