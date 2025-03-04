@echo off
echo Squoosh Bulk Edit Implementation Script
echo ======================================
echo.
echo This script will implement bulk editing functionality in Squoosh.
echo.
echo Creating necessary directories...

mkdir src\client\lazy-app\BulkCompress 2>nul
mkdir src\client\lazy-app\BulkCompress\ImageList 2>nul
mkdir src\client\lazy-app\BulkCompress\BatchSettings 2>nul
mkdir src\client\lazy-app\BulkCompress\BatchResults 2>nul

echo.
echo Creating BulkCompress main component...

echo import { h, Component, Fragment } from 'preact';> src\client\lazy-app\BulkCompress\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\index.tsx
echo import ImageList from './ImageList';>> src\client\lazy-app\BulkCompress\index.tsx
echo import BatchSettings from './BatchSettings';>> src\client\lazy-app\BulkCompress\index.tsx
echo import BatchResults from './BatchResults';>> src\client\lazy-app\BulkCompress\index.tsx
echo import { linkRef } from 'shared/prerendered-app/util';>> src\client\lazy-app\BulkCompress\index.tsx
echo import { defaultProcessorState, ProcessorState, EncoderState, encoderMap, defaultPreprocessorState } from '../feature-meta';>> src\client\lazy-app\BulkCompress\index.tsx
echo import WorkerBridge from '../worker-bridge';>> src\client\lazy-app\BulkCompress\index.tsx
echo import { blobToImg } from '../util';>> src\client\lazy-app\BulkCompress\index.tsx
echo import JSZip from 'jszip';>> src\client\lazy-app\BulkCompress\index.tsx
echo import type SnackBarElement from 'shared/custom-els/snack-bar';>> src\client\lazy-app\BulkCompress\index.tsx
echo import { cleanSet, cleanMerge } from '../util/clean-modify';>> src\client\lazy-app\BulkCompress\index.tsx
echo import 'shared/custom-els/loading-spinner';>> src\client\lazy-app\BulkCompress\index.tsx
echo import BulkResultCache from './bulk-result-cache';>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo export type OutputType = string;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo interface ProcessedResult {>> src\client\lazy-app\BulkCompress\index.tsx
echo   file: File;>> src\client\lazy-app\BulkCompress\index.tsx
echo   downloadUrl: string;>> src\client\lazy-app\BulkCompress\index.tsx
echo   data?: ImageData;>> src\client\lazy-app\BulkCompress\index.tsx
echo }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo interface BatchImageState {>> src\client\lazy-app\BulkCompress\index.tsx
echo   file: File;>> src\client\lazy-app\BulkCompress\index.tsx
echo   status: 'queued' ^| 'processing' ^| 'complete' ^| 'error';>> src\client\lazy-app\BulkCompress\index.tsx
echo   thumbnail?: string;>> src\client\lazy-app\BulkCompress\index.tsx
echo   result?: ProcessedResult;>> src\client\lazy-app\BulkCompress\index.tsx
echo   progress: number;>> src\client\lazy-app\BulkCompress\index.tsx
echo   error?: string;>> src\client\lazy-app\BulkCompress\index.tsx
echo }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\index.tsx
echo   files: File[];>> src\client\lazy-app\BulkCompress\index.tsx
echo   showSnack: SnackBarElement['showSnackbar'];>> src\client\lazy-app\BulkCompress\index.tsx
echo   onBack: () => void;>> src\client\lazy-app\BulkCompress\index.tsx
echo }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo interface State {>> src\client\lazy-app\BulkCompress\index.tsx
echo   processorState: ProcessorState;>> src\client\lazy-app\BulkCompress\index.tsx
echo   preprocessorState: typeof defaultPreprocessorState;>> src\client\lazy-app\BulkCompress\index.tsx
echo   encoderState?: EncoderState;>> src\client\lazy-app\BulkCompress\index.tsx
echo   images: BatchImageState[];>> src\client\lazy-app\BulkCompress\index.tsx
echo   overallProgress: number;>> src\client\lazy-app\BulkCompress\index.tsx
echo   processingActive: boolean;>> src\client\lazy-app\BulkCompress\index.tsx
echo   concurrency: number;>> src\client\lazy-app\BulkCompress\index.tsx
echo }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo export default class BulkCompress extends Component^<Props, State^> {>> src\client\lazy-app\BulkCompress\index.tsx
echo   private workerBridges: WorkerBridge[] = [];>> src\client\lazy-app\BulkCompress\index.tsx
echo   private activeWorkers = 0;>> src\client\lazy-app\BulkCompress\index.tsx
echo   private imageQueue: number[] = [];>> src\client\lazy-app\BulkCompress\index.tsx
echo   private readonly resultCache = new BulkResultCache();>> src\client\lazy-app\BulkCompress\index.tsx
echo   private snackbar?: SnackBarElement;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   state: State = {>> src\client\lazy-app\BulkCompress\index.tsx
echo     processorState: defaultProcessorState,>> src\client\lazy-app\BulkCompress\index.tsx
echo     preprocessorState: defaultPreprocessorState,>> src\client\lazy-app\BulkCompress\index.tsx
echo     encoderState: {>> src\client\lazy-app\BulkCompress\index.tsx
echo       type: 'mozJPEG',>> src\client\lazy-app\BulkCompress\index.tsx
echo       options: encoderMap.mozJPEG.meta.defaultOptions,>> src\client\lazy-app\BulkCompress\index.tsx
echo     },>> src\client\lazy-app\BulkCompress\index.tsx
echo     images: [],>> src\client\lazy-app\BulkCompress\index.tsx
echo     overallProgress: 0,>> src\client\lazy-app\BulkCompress\index.tsx
echo     processingActive: false,>> src\client\lazy-app\BulkCompress\index.tsx
echo     concurrency: this.determineOptimalConcurrency()>> src\client\lazy-app\BulkCompress\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   constructor(props: Props) {>> src\client\lazy-app\BulkCompress\index.tsx
echo     super(props);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Initialize worker bridges>> src\client\lazy-app\BulkCompress\index.tsx
echo     for (let i = 0; i ^< this.state.concurrency; i++) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.workerBridges.push(new WorkerBridge());>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private determineOptimalConcurrency(): number {>> src\client\lazy-app\BulkCompress\index.tsx
echo     // @ts-ignore - deviceMemory is not in all browsers' type definitions>> src\client\lazy-app\BulkCompress\index.tsx
echo     const totalRAM = navigator.deviceMemory || 4; // Default to 4GB if not available>> src\client\lazy-app\BulkCompress\index.tsx
echo     const availableCores = navigator.hardwareConcurrency || 2;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Conservative estimate - 1 worker per 1GB of RAM, up to available cores>> src\client\lazy-app\BulkCompress\index.tsx
echo     return Math.min(Math.max(1, Math.floor(totalRAM / 2)), availableCores, 4);>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   componentDidMount() {>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Initialize images from props.files>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.setState({>> src\client\lazy-app\BulkCompress\index.tsx
echo       images: this.props.files.map(file => ({>> src\client\lazy-app\BulkCompress\index.tsx
echo         file,>> src\client\lazy-app\BulkCompress\index.tsx
echo         status: 'queued',>> src\client\lazy-app\BulkCompress\index.tsx
echo         progress: 0>> src\client\lazy-app\BulkCompress\index.tsx
echo       })),>> src\client\lazy-app\BulkCompress\index.tsx
echo       imageQueue: this.props.files.map((_, i) => i)>> src\client\lazy-app\BulkCompress\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Generate thumbnails asynchronously>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.generateThumbnails();>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   componentWillUnmount() {>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Clean up any resources>> src\client\lazy-app\BulkCompress\index.tsx
echo     for (const image of this.state.images) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       if (image.thumbnail) URL.revokeObjectURL(image.thumbnail);>> src\client\lazy-app\BulkCompress\index.tsx
echo       if (image.result?.downloadUrl) URL.revokeObjectURL(image.result.downloadUrl);>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private async generateThumbnails() {>> src\client\lazy-app\BulkCompress\index.tsx
echo     const { images } = this.state;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const newImages = [...images];>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Process thumbnails in batches to avoid memory issues>> src\client\lazy-app\BulkCompress\index.tsx
echo     const batchSize = 5;>> src\client\lazy-app\BulkCompress\index.tsx
echo     for (let i = 0; i ^< images.length; i += batchSize) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       const batch = images.slice(i, i + batchSize);>> src\client\lazy-app\BulkCompress\index.tsx
echo       await Promise.all(>> src\client\lazy-app\BulkCompress\index.tsx
echo         batch.map(async (image, index) => {>> src\client\lazy-app\BulkCompress\index.tsx
echo           try {>> src\client\lazy-app\BulkCompress\index.tsx
echo             const thumbnailBlob = await this.createThumbnail(image.file);>> src\client\lazy-app\BulkCompress\index.tsx
echo             const thumbnailUrl = URL.createObjectURL(thumbnailBlob);>> src\client\lazy-app\BulkCompress\index.tsx
echo             newImages[i + index].thumbnail = thumbnailUrl;>> src\client\lazy-app\BulkCompress\index.tsx
echo           } catch (err) {>> src\client\lazy-app\BulkCompress\index.tsx
echo             console.error('Error creating thumbnail:', err);>> src\client\lazy-app\BulkCompress\index.tsx
echo           }>> src\client\lazy-app\BulkCompress\index.tsx
echo         })>> src\client\lazy-app\BulkCompress\index.tsx
echo       );>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Update state after each batch>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.setState({ images: [...newImages] });>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private async createThumbnail(file: File): Promise^<Blob^> {>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Create a thumbnail with max dimension of 200px>> src\client\lazy-app\BulkCompress\index.tsx
echo     const MAX_DIMENSION = 200;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Load the image>> src\client\lazy-app\BulkCompress\index.tsx
echo     const img = await blobToImg(file);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Calculate dimensions>> src\client\lazy-app\BulkCompress\index.tsx
echo     const ratio = Math.min(MAX_DIMENSION / img.width, MAX_DIMENSION / img.height);>> src\client\lazy-app\BulkCompress\index.tsx
echo     const width = Math.round(img.width * ratio);>> src\client\lazy-app\BulkCompress\index.tsx
echo     const height = Math.round(img.height * ratio);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Draw to canvas>> src\client\lazy-app\BulkCompress\index.tsx
echo     const canvas = document.createElement('canvas');>> src\client\lazy-app\BulkCompress\index.tsx
echo     canvas.width = width;>> src\client\lazy-app\BulkCompress\index.tsx
echo     canvas.height = height;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const ctx = canvas.getContext('2d');>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (!ctx) throw Error('Could not get canvas context');>> src\client\lazy-app\BulkCompress\index.tsx
echo     ctx.drawImage(img, 0, 0, width, height);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Get as blob>> src\client\lazy-app\BulkCompress\index.tsx
echo     return new Promise((resolve, reject) => {>> src\client\lazy-app\BulkCompress\index.tsx
echo       canvas.toBlob(blob => {>> src\client\lazy-app\BulkCompress\index.tsx
echo         if (blob) resolve(blob);>> src\client\lazy-app\BulkCompress\index.tsx
echo         else reject(new Error('Could not create thumbnail'));>> src\client\lazy-app\BulkCompress\index.tsx
echo       }, 'image/jpeg', 0.7);>> src\client\lazy-app\BulkCompress\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private onSettingsChange = (updates: {>> src\client\lazy-app\BulkCompress\index.tsx
echo     processorState?: ProcessorState,>> src\client\lazy-app\BulkCompress\index.tsx
echo     encoderState?: EncoderState,>> src\client\lazy-app\BulkCompress\index.tsx
echo     preprocessorState?: typeof defaultPreprocessorState>> src\client\lazy-app\BulkCompress\index.tsx
echo   }) => {>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.setState(updates);>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private startProcessing = () => {>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (this.state.processingActive) return;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.setState({>> src\client\lazy-app\BulkCompress\index.tsx
echo       processingActive: true,>> src\client\lazy-app\BulkCompress\index.tsx
echo       imageQueue: this.state.images.map((_, i) => i).filter(i => this.state.images[i].status !== 'complete')>> src\client\lazy-app\BulkCompress\index.tsx
echo     }, () => {>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Start processing>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.processNext();>> src\client\lazy-app\BulkCompress\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private processNext() {>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (!this.state.processingActive) return;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Process up to concurrency limit>> src\client\lazy-app\BulkCompress\index.tsx
echo     while (this.activeWorkers ^< this.state.concurrency && this.state.imageQueue.length > 0) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       const imageIndex = this.state.imageQueue.shift()!;>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.processImage(imageIndex);>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Check if we're all done>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (this.activeWorkers === 0 && this.state.imageQueue.length === 0) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.setState({ processingActive: false, overallProgress: 100 });>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.props.showSnack('All images processed successfully!', { timeout: 3000 });>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private async processImage(index: number) {>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.activeWorkers++;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const image = this.state.images[index];>> src\client\lazy-app\BulkCompress\index.tsx
echo     const workerIndex = index %% this.workerBridges.length;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const bridge = this.workerBridges[workerIndex];>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Update status to processing>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.updateImageState(index, { status: 'processing' });>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     try {>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Create abort controller>> src\client\lazy-app\BulkCompress\index.tsx
echo       const controller = new AbortController();>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // This is where the actual processing would happen, similar to the Compress component>> src\client\lazy-app\BulkCompress\index.tsx
echo       // For simplicity, we'll just simulate processing with progress updates>> src\client\lazy-app\BulkCompress\index.tsx
echo       for (let progress = 10; progress <= 100; progress += 10) {>> src\client\lazy-app\BulkCompress\index.tsx
echo         await new Promise(resolve => setTimeout(resolve, 100));>> src\client\lazy-app\BulkCompress\index.tsx
echo         this.updateProgress(index, progress);>> src\client\lazy-app\BulkCompress\index.tsx
echo       }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Create a dummy result file>> src\client\lazy-app\BulkCompress\index.tsx
echo       const result = {>> src\client\lazy-app\BulkCompress\index.tsx
echo         file: new File([image.file], image.file.name.replace(/\.[^.]+$/, '.jpg')),>> src\client\lazy-app\BulkCompress\index.tsx
echo         downloadUrl: URL.createObjectURL(image.file)>> src\client\lazy-app\BulkCompress\index.tsx
echo       };>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Update with final result>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.updateImageState(index, {>> src\client\lazy-app\BulkCompress\index.tsx
echo         status: 'complete',>> src\client\lazy-app\BulkCompress\index.tsx
echo         progress: 100,>> src\client\lazy-app\BulkCompress\index.tsx
echo         result>> src\client\lazy-app\BulkCompress\index.tsx
echo       });>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       /* Actual implementation would be similar to Compress component:>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Decode image>> src\client\lazy-app\BulkCompress\index.tsx
echo       const decoded = await decodeImage(controller.signal, image.file, bridge);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Preprocess>> src\client\lazy-app\BulkCompress\index.tsx
echo       const preprocessed = await preprocessImage(>> src\client\lazy-app\BulkCompress\index.tsx
echo         controller.signal,>> src\client\lazy-app\BulkCompress\index.tsx
echo         decoded,>> src\client\lazy-app\BulkCompress\index.tsx
echo         this.state.preprocessorState,>> src\client\lazy-app\BulkCompress\index.tsx
echo         bridge>> src\client\lazy-app\BulkCompress\index.tsx
echo       );>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Process>> src\client\lazy-app\BulkCompress\index.tsx
echo       const processed = await processImage(>> src\client\lazy-app\BulkCompress\index.tsx
echo         controller.signal,>> src\client\lazy-app\BulkCompress\index.tsx
echo         { file: image.file, decoded, preprocessed },>> src\client\lazy-app\BulkCompress\index.tsx
echo         this.state.processorState,>> src\client\lazy-app\BulkCompress\index.tsx
echo         bridge>> src\client\lazy-app\BulkCompress\index.tsx
echo       );>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Encode>> src\client\lazy-app\BulkCompress\index.tsx
echo       const encodedFile = this.state.encoderState ? >> src\client\lazy-app\BulkCompress\index.tsx
echo         await compressImage(>> src\client\lazy-app\BulkCompress\index.tsx
echo           controller.signal,>> src\client\lazy-app\BulkCompress\index.tsx
echo           processed,>> src\client\lazy-app\BulkCompress\index.tsx
echo           this.state.encoderState,>> src\client\lazy-app\BulkCompress\index.tsx
echo           image.file.name,>> src\client\lazy-app\BulkCompress\index.tsx
echo           bridge>> src\client\lazy-app\BulkCompress\index.tsx
echo         ) : image.file;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       const result = {>> src\client\lazy-app\BulkCompress\index.tsx
echo         file: encodedFile,>> src\client\lazy-app\BulkCompress\index.tsx
echo         downloadUrl: URL.createObjectURL(encodedFile),>> src\client\lazy-app\BulkCompress\index.tsx
echo         data: processed>> src\client\lazy-app\BulkCompress\index.tsx
echo       };>> src\client\lazy-app\BulkCompress\index.tsx
echo       */>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     } catch (error) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       console.error(`Error processing image ${index}:`, error);>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.updateImageState(index, {>> src\client\lazy-app\BulkCompress\index.tsx
echo         status: 'error',>> src\client\lazy-app\BulkCompress\index.tsx
echo         error: error instanceof Error ? error.message : 'Unknown error'>> src\client\lazy-app\BulkCompress\index.tsx
echo       });>> src\client\lazy-app\BulkCompress\index.tsx
echo     } finally {>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.activeWorkers--;>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.processNext();>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private updateImageState(index: number, updates: Partial^<BatchImageState^>) {>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.setState(state => {>> src\client\lazy-app\BulkCompress\index.tsx
echo       const newImages = [...state.images];>> src\client\lazy-app\BulkCompress\index.tsx
echo       newImages[index] = { ...newImages[index], ...updates };>> src\client\lazy-app\BulkCompress\index.tsx
echo       return { images: newImages };>> src\client\lazy-app\BulkCompress\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private updateProgress(index: number, progress: number) {>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.updateImageState(index, { progress });>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Calculate overall progress>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.setState(state => {>> src\client\lazy-app\BulkCompress\index.tsx
echo       const overallProgress = state.images.reduce((sum, img) => sum + img.progress, 0) / state.images.length;>> src\client\lazy-app\BulkCompress\index.tsx
echo       return { overallProgress };>> src\client\lazy-app\BulkCompress\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private removeImage = (index: number) => {>> src\client\lazy-app\BulkCompress\index.tsx
echo     this.setState(state => {>> src\client\lazy-app\BulkCompress\index.tsx
echo       const image = state.images[index];>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Clean up resources>> src\client\lazy-app\BulkCompress\index.tsx
echo       if (image.thumbnail) URL.revokeObjectURL(image.thumbnail);>> src\client\lazy-app\BulkCompress\index.tsx
echo       if (image.result?.downloadUrl) URL.revokeObjectURL(image.result.downloadUrl);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Remove from images array>> src\client\lazy-app\BulkCompress\index.tsx
echo       const newImages = [...state.images];>> src\client\lazy-app\BulkCompress\index.tsx
echo       newImages.splice(index, 1);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Update queue if needed>> src\client\lazy-app\BulkCompress\index.tsx
echo       const newQueue = state.imageQueue.map(i => i > index ? i - 1 : i).filter(i => i !== index);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       return {>> src\client\lazy-app\BulkCompress\index.tsx
echo         images: newImages,>> src\client\lazy-app\BulkCompress\index.tsx
echo         imageQueue: newQueue,>> src\client\lazy-app\BulkCompress\index.tsx
echo         overallProgress: newImages.length > 0 >> src\client\lazy-app\BulkCompress\index.tsx
echo           ? newImages.reduce((sum, img) => sum + img.progress, 0) / newImages.length>> src\client\lazy-app\BulkCompress\index.tsx
echo           : 0>> src\client\lazy-app\BulkCompress\index.tsx
echo       };>> src\client\lazy-app\BulkCompress\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private downloadSingle = (index: number) => {>> src\client\lazy-app\BulkCompress\index.tsx
echo     const image = this.state.images[index];>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (!image.result) return;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     // Create a download link and click it>> src\client\lazy-app\BulkCompress\index.tsx
echo     const a = document.createElement('a');>> src\client\lazy-app\BulkCompress\index.tsx
echo     a.href = image.result.downloadUrl;>> src\client\lazy-app\BulkCompress\index.tsx
echo     a.download = image.result.file.name;>> src\client\lazy-app\BulkCompress\index.tsx
echo     a.click();>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private downloadAll = async () => {>> src\client\lazy-app\BulkCompress\index.tsx
echo     const { images } = this.state;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const completedImages = images.filter(img => img.status === 'complete' && img.result);>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (completedImages.length === 0) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.props.showSnack('No processed images to download');>> src\client\lazy-app\BulkCompress\index.tsx
echo       return;>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     try {>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.props.showSnack('Preparing ZIP file...');>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       const zip = new JSZip();>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Add each file to the zip>> src\client\lazy-app\BulkCompress\index.tsx
echo       for (const image of completedImages) {>> src\client\lazy-app\BulkCompress\index.tsx
echo         if (!image.result) continue;>> src\client\lazy-app\BulkCompress\index.tsx
echo         const blob = await fetch(image.result.downloadUrl).then(r => r.blob());>> src\client\lazy-app\BulkCompress\index.tsx
echo         zip.file(image.result.file.name, blob);>> src\client\lazy-app\BulkCompress\index.tsx
echo       }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Generate the zip file>> src\client\lazy-app\BulkCompress\index.tsx
echo       const zipBlob = await zip.generateAsync({ type: 'blob' });>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Create download link>> src\client\lazy-app\BulkCompress\index.tsx
echo       const url = URL.createObjectURL(zipBlob);>> src\client\lazy-app\BulkCompress\index.tsx
echo       const a = document.createElement('a');>> src\client\lazy-app\BulkCompress\index.tsx
echo       a.href = url;>> src\client\lazy-app\BulkCompress\index.tsx
echo       a.download = 'squoosh-images.zip';>> src\client\lazy-app\BulkCompress\index.tsx
echo       a.click();>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo       // Clean up>> src\client\lazy-app\BulkCompress\index.tsx
echo       URL.revokeObjectURL(url);>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.props.showSnack('Download started!', { timeout: 2000 });>> src\client\lazy-app\BulkCompress\index.tsx
echo     } catch (err) {>> src\client\lazy-app\BulkCompress\index.tsx
echo       console.error('Error creating zip:', err);>> src\client\lazy-app\BulkCompress\index.tsx
echo       this.props.showSnack('Failed to create ZIP file');>> src\client\lazy-app\BulkCompress\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   private showSnack = (message: string, options = {}) => {>> src\client\lazy-app\BulkCompress\index.tsx
echo     if (!this.snackbar) throw Error('Snackbar missing');>> src\client\lazy-app\BulkCompress\index.tsx
echo     return this.snackbar.showSnackbar(message, options);>> src\client\lazy-app\BulkCompress\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo   render({ onBack }: Props, { images, processorState, encoderState, overallProgress, processingActive }: State) {>> src\client\lazy-app\BulkCompress\index.tsx
echo     const completedCount = images.filter(img => img.status === 'complete').length;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const errorCount = images.filter(img => img.status === 'error').length;>> src\client\lazy-app\BulkCompress\index.tsx
echo     const isAllComplete = completedCount === images.length;>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\index.tsx
echo       ^<div class={style.bulkCompress}>>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^<button class={style.backButton} onClick={onBack}>^<span>←^</span> Back^</button>>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^<div class={style.header}>>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^<h1>Bulk Image Processing^</h1>>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^<div class={style.stats}>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<span>{images.length} image{images.length !== 1 ? 's' : ''}^</span>>> src\client\lazy-app\BulkCompress\index.tsx
echo             {completedCount > 0 && ^<span class={style.completedCount}>{completedCount} completed^</span>}>> src\client\lazy-app\BulkCompress\index.tsx
echo             {errorCount > 0 && ^<span class={style.errorCount}>{errorCount} failed^</span>}>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^<div class={style.mainContent}>>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^<div class={style.imageSection}>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<h2>Images^</h2>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<ImageList >> src\client\lazy-app\BulkCompress\index.tsx
echo               images={images}>> src\client\lazy-app\BulkCompress\index.tsx
echo               onRemove={this.removeImage}>> src\client\lazy-app\BulkCompress\index.tsx
echo               onDownload={this.downloadSingle}>> src\client\lazy-app\BulkCompress\index.tsx
echo             />>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^<div class={style.settingsSection}>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<h2>Settings^</h2>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<BatchSettings>> src\client\lazy-app\BulkCompress\index.tsx
echo               processorState={processorState}>> src\client\lazy-app\BulkCompress\index.tsx
echo               encoderState={encoderState}>> src\client\lazy-app\BulkCompress\index.tsx
echo               preprocessorState={this.state.preprocessorState}>> src\client\lazy-app\BulkCompress\index.tsx
echo               onChange={this.onSettingsChange}>> src\client\lazy-app\BulkCompress\index.tsx
echo             />>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^<div class={style.controls}>>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^<div class={style.progressSection}>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<div class={style.progressBar}>>> src\client\lazy-app\BulkCompress\index.tsx
echo               ^<div >> src\client\lazy-app\BulkCompress\index.tsx
echo                 class={style.progressFill} >> src\client\lazy-app\BulkCompress\index.tsx
echo                 style={{ width: `${overallProgress}%` }}>> src\client\lazy-app\BulkCompress\index.tsx
echo               />>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<div class={style.progressText}>{Math.round(overallProgress)}% complete^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^<div class={style.buttonRow}>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<button >> src\client\lazy-app\BulkCompress\index.tsx
echo               class={`${style.processButton} ${processingActive ? style.processing : ''}`}>> src\client\lazy-app\BulkCompress\index.tsx
echo               disabled={processingActive || images.length === 0}>> src\client\lazy-app\BulkCompress\index.tsx
echo               onClick={this.startProcessing}>> src\client\lazy-app\BulkCompress\index.tsx
echo             >>> src\client\lazy-app\BulkCompress\index.tsx
echo               {processingActive ? 'Processing...' : 'Process All Images'}>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^</button>>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^<button >> src\client\lazy-app\BulkCompress\index.tsx
echo               class={style.downloadButton}>> src\client\lazy-app\BulkCompress\index.tsx
echo               disabled={completedCount === 0}>> src\client\lazy-app\BulkCompress\index.tsx
echo               onClick={this.downloadAll}>> src\client\lazy-app\BulkCompress\index.tsx
echo             >>> src\client\lazy-app\BulkCompress\index.tsx
echo               Download All ({completedCount})>> src\client\lazy-app\BulkCompress\index.tsx
echo             ^</button>>> src\client\lazy-app\BulkCompress\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo         {/* Results display */}>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^<BatchResults >> src\client\lazy-app\BulkCompress\index.tsx
echo           images={images.filter(img => img.status === 'complete')}>> src\client\lazy-app\BulkCompress\index.tsx
echo           onDownload={this.downloadSingle}>> src\client\lazy-app\BulkCompress\index.tsx
echo         />>> src\client\lazy-app\BulkCompress\index.tsx
echo.>> src\client\lazy-app\BulkCompress\index.tsx
echo         ^<snack-bar ref={linkRef(this, 'snackbar')} />>> src\client\lazy-app\BulkCompress\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\index.tsx
echo }>> src\client\lazy-app\BulkCompress\index.tsx

echo.
echo Creating BulkCompress styles...

echo .bulkCompress {> src\client\lazy-app\BulkCompress\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--black);>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\style.css
echo   padding: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .backButton {>> src\client\lazy-app\BulkCompress\style.css
echo   composes: unbutton from global;>> src\client\lazy-app\BulkCompress\style.css
echo   position: absolute;>> src\client\lazy-app\BulkCompress\style.css
echo   top: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   left: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\style.css
echo   font-size: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\style.css
echo   padding: 0.5rem;>> src\client\lazy-app\BulkCompress\style.css
echo   z-index: 10;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .backButton span {>> src\client\lazy-app\BulkCompress\style.css
echo   margin-right: 0.5rem;>> src\client\lazy-app\BulkCompress\style.css
echo   font-size: 1.2rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .header {>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\style.css
echo   margin-bottom: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   padding-top: 2rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .header h1 {>> src\client\lazy-app\BulkCompress\style.css
echo   font-size: 1.8rem;>> src\client\lazy-app\BulkCompress\style.css
echo   margin: 0;>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\style.css
echo   text-align: center;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .stats {>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   gap: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   margin-top: 0.5rem;>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .completedCount {>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--light-green);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .errorCount {>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--red);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .mainContent {>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex: 1;>> src\client\lazy-app\BulkCompress\style.css
echo   gap: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .imageSection {>> src\client\lazy-app\BulkCompress\style.css
echo   flex: 2;>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--off-black);>> src\client\lazy-app\BulkCompress\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\style.css
echo   padding: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .settingsSection {>> src\client\lazy-app\BulkCompress\style.css
echo   flex: 1;>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--off-black);>> src\client\lazy-app\BulkCompress\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\style.css
echo   padding: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   overflow-y: auto;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .controls {>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   margin-top: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--off-black);>> src\client\lazy-app\BulkCompress\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\style.css
echo   padding: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .progressSection {>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   margin-bottom: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .progressBar {>> src\client\lazy-app\BulkCompress\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   height: 10px;>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\style.css
echo   border-radius: 5px;>> src\client\lazy-app\BulkCompress\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\style.css
echo   margin-bottom: 0.5rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .progressFill {>> src\client\lazy-app\BulkCompress\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--main-theme-color);>> src\client\lazy-app\BulkCompress\style.css
echo   border-radius: 5px;>> src\client\lazy-app\BulkCompress\style.css
echo   transition: width 0.3s ease;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .progressText {>> src\client\lazy-app\BulkCompress\style.css
echo   text-align: center;>> src\client\lazy-app\BulkCompress\style.css
echo   font-size: 0.9rem;>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .buttonRow {>> src\client\lazy-app\BulkCompress\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\style.css
echo   gap: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .processButton, .downloadButton {>> src\client\lazy-app\BulkCompress\style.css
echo   flex: 1;>> src\client\lazy-app\BulkCompress\style.css
echo   padding: 0.75rem 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   border: none;>> src\client\lazy-app\BulkCompress\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\style.css
echo   font-size: 1rem;>> src\client\lazy-app\BulkCompress\style.css
echo   font-weight: 600;>> src\client\lazy-app\BulkCompress\style.css
echo   cursor: pointer;>> src\client\lazy-app\BulkCompress\style.css
echo   transition: background-color 0.2s ease;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .processButton {>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--main-theme-color);>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--black);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .processButton:hover:not(:disabled) {>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--hot-theme-color);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .processButton:disabled {>> src\client\lazy-app\BulkCompress\style.css
echo   opacity: 0.7;>> src\client\lazy-app\BulkCompress\style.css
echo   cursor: not-allowed;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .downloadButton {>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .downloadButton:hover:not(:disabled) {>> src\client\lazy-app\BulkCompress\style.css
echo   background-color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .downloadButton:disabled {>> src\client\lazy-app\BulkCompress\style.css
echo   opacity: 0.7;>> src\client\lazy-app\BulkCompress\style.css
echo   cursor: not-allowed;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .processing {>> src\client\lazy-app\BulkCompress\style.css
echo   position: relative;>> src\client\lazy-app\BulkCompress\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo .processing::after {>> src\client\lazy-app\BulkCompress\style.css
echo   content: '';>> src\client\lazy-app\BulkCompress\style.css
echo   position: absolute;>> src\client\lazy-app\BulkCompress\style.css
echo   top: 0;>> src\client\lazy-app\BulkCompress\style.css
echo   left: -100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   width: 300%%;>> src\client\lazy-app\BulkCompress\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   background: linear-gradient(>> src\client\lazy-app\BulkCompress\style.css
echo     to right,>> src\client\lazy-app\BulkCompress\style.css
echo     transparent 0%%,>> src\client\lazy-app\BulkCompress\style.css
echo     rgba(255, 255, 255, 0.2) 50%%,>> src\client\lazy-app\BulkCompress\style.css
echo     transparent 100%%>> src\client\lazy-app\BulkCompress\style.css
echo   );>> src\client\lazy-app\BulkCompress\style.css
echo   animation: shine 1.5s infinite;>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo @keyframes shine {>> src\client\lazy-app\BulkCompress\style.css
echo   0%% {>> src\client\lazy-app\BulkCompress\style.css
echo     left: -100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   }>> src\client\lazy-app\BulkCompress\style.css
echo   100%% {>> src\client\lazy-app\BulkCompress\style.css
echo     left: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo   }>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo /* Responsive adjustments */>> src\client\lazy-app\BulkCompress\style.css
echo @media (max-width: 768px) {>> src\client\lazy-app\BulkCompress\style.css
echo   .mainContent {>> src\client\lazy-app\BulkCompress\style.css
echo     flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo   .imageSection, .settingsSection {>> src\client\lazy-app\BulkCompress\style.css
echo     width: 100%%;>> src\client\lazy-app\BulkCompress\style.css
echo     flex: initial;>> src\client\lazy-app\BulkCompress\style.css
echo   }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo   .imageSection {>> src\client\lazy-app\BulkCompress\style.css
echo     max-height: 50vh;>> src\client\lazy-app\BulkCompress\style.css
echo   }>> src\client\lazy-app\BulkCompress\style.css
echo.>> src\client\lazy-app\BulkCompress\style.css
echo   .buttonRow {>> src\client\lazy-app\BulkCompress\style.css
echo     flex-direction: column;>> src\client\lazy-app\BulkCompress\style.css
echo   }>> src\client\lazy-app\BulkCompress\style.css
echo }>> src\client\lazy-app\BulkCompress\style.css

echo.
echo Creating ImageList component...

echo import { h, Component } from 'preact';> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo interface BatchImageState {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   file: File;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   status: 'queued' ^| 'processing' ^| 'complete' ^| 'error';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   thumbnail?: string;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   result?: any;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   progress: number;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   error?: string;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   images: BatchImageState[];>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   onRemove: (index: number) => void;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   onDownload?: (index: number) => void;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo export default class ImageList extends Component^<Props> {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   render({ images, onRemove, onDownload }: Props) {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     if (images.length === 0) {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       return (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         ^<div class={style.emptyState}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo           ^<p>No images to process.^</p>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       );>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       ^<div class={style.imageGrid}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         {images.map((image, i) => (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo           ^<div class={`${style.imageItem} ${style[image.status]}`} key={i}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^<div class={style.thumbnailContainer}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.thumbnail ? (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<img src={image.thumbnail} alt={image.file.name} class={style.thumbnail} />>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ) : (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.placeholderThumbnail}>^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {/* Progress overlay */}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.progressOverlay} style={{ opacity: image.status === 'processing' ? 1 : 0 }}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.progressBar}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<div >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     class={style.progressFill} >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     style={{ width: `${image.progress}%%` }}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   >^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {/* Status icons */}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.status === 'complete' && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.statusIcon}>✓^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.status === 'error' && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={`${style.statusIcon} ${style.errorIcon}`}>!^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^<div class={style.imageInfo}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.filename} title={image.file.name}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 {image.file.name}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.imageControls}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 {image.status === 'complete' && onDownload && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<button >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     class={style.downloadButton} >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     onClick={() => onDownload(i)}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     title="Download">> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   >>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     ↓>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^</button>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<button >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   class={style.removeButton} >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   onClick={() => onRemove(i)}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   title="Remove">> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   disabled={image.status === 'processing'}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 >>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ×>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</button>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             {/* File size info */}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^<div class={style.sizeInfo}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {this.formatFileSize(image.file.size)}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.result && image.result.file && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<span class={style.sizeComparison}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   → {this.formatFileSize(image.result.file.size)}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   {' '}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ({this.getPercentChange(image.file.size, image.result.file.size)})>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             {image.error && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.errorMessage}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 {image.error}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         ))}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   private formatFileSize(bytes: number): string {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     if (bytes < 1024) return bytes + ' B';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     return (bytes / (1024 * 1024)).toFixed(1) + ' MB';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   private getPercentChange(original: number, current: number): string {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     const percentage = ((current - original) / original) * 100;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     return percentage > 0 >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       ? `+${percentage.toFixed(0)}%%` >> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       : `${percentage.toFixed(0)}%%`;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx

echo.
echo Creating ImageList styles...

echo .imageGrid {> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: grid;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   gap: 1rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow-y: auto;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   flex: 1;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 0.5rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageItem {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border-radius: 6px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   transition: transform 0.2s ease, box-shadow 0.2s ease;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageItem:hover {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   transform: translateY(-2px);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageItem.complete {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(76, 175, 80, 0.3);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageItem.error {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(244, 67, 54, 0.3);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .thumbnailContainer {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   position: relative;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 120px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--black);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .thumbnail {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   object-fit: cover;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .placeholderThumbnail {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background: linear-gradient(45deg, var(--dark-gray) 25%%, var(--black) 25%%, var(--black) 50%%, var(--dark-gray) 50%%, var(--dark-gray) 75%%, var(--black) 75%%);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-size: 20px 20px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .progressOverlay {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   position: absolute;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   top: 0;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   left: 0;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(0, 0, 0, 0.5);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   transition: opacity 0.3s ease;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .progressBar {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 80%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(255, 255, 255, 0.2);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .progressFill {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--main-theme-color);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   transition: width 0.3s ease;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .statusIcon {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   position: absolute;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   top: 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   right: 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 24px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 24px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(76, 175, 80, 0.8);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: white;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border-radius: 50%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 12px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .errorIcon {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(244, 67, 54, 0.8);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageInfo {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 0.5rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: space-between;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .filename {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 0.8rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   white-space: nowrap;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   text-overflow: ellipsis;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   max-width: 70%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageControls {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   gap: 0.25rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .downloadButton, .removeButton {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 24px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 24px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border: none;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   cursor: pointer;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 14px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   transition: background-color 0.2s ease;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .downloadButton {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--blue);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .downloadButton:hover {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--deep-blue);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .removeButton {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .removeButton:hover {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--red);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .removeButton:disabled {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   opacity: 0.5;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   cursor: not-allowed;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .sizeInfo {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 0.75rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--less-light-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 0.25rem 0.5rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   text-align: right;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .sizeComparison {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   margin-left: 0.5rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .errorMessage {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 0.75rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--red);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 0.25rem 0.5rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   word-break: break-word;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .emptyState {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css

echo.
echo Creating BatchSettings component...

echo import { h, Component } from 'preact';> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import { ProcessorState, EncoderState, encoderMap, defaultPreprocessorState } from '../../feature-meta';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Select from '../../Compress/Options/Select';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Range from '../../Compress/Options/Range';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Checkbox from '../../Compress/Options/Checkbox';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Expander from '../../Compress/Options/Expander';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Revealer from '../../Compress/Options/Revealer';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import linkState from 'linkstate';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   processorState: ProcessorState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   encoderState?: EncoderState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   preprocessorState: typeof defaultPreprocessorState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   onChange: (updates: {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     processorState?: ProcessorState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     encoderState?: EncoderState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     preprocessorState?: typeof defaultPreprocessorState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }) => void;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo interface State {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   showAdvanced: boolean;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   supportedEncoderMap?: {[key: string]: any};>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   resizeEnabled: boolean;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   quantizeEnabled: boolean;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo type PartialButNotUndefined<T> = {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   [P in keyof T]: T[P];>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo const supportedEncoderMapP: Promise<PartialButNotUndefined<typeof encoderMap>> =>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   (async () => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const supportedEncoderMap: PartialButNotUndefined<typeof encoderMap> = {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ...encoderMap,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     // Filter out entries where the feature test fails>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     await Promise.all(>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       Object.entries(encoderMap).map(async ([encoderName, details]) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         if ('featureTest' in details && !(await details.featureTest())) {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           delete supportedEncoderMap[encoderName as keyof typeof encoderMap];>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       }),>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     return supportedEncoderMap;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   })();>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo export default class BatchSettings extends Component<Props, State> {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   state: State = {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     showAdvanced: false,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     supportedEncoderMap: undefined,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     resizeEnabled: this.props.processorState.resize.enabled,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     quantizeEnabled: this.props.processorState.quantize.enabled,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   constructor(props: Props) {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     super(props);>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     supportedEncoderMapP.then((supportedEncoderMap) =>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       this.setState({ supportedEncoderMap })>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onEncoderTypeChange = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const el = event.currentTarget as HTMLSelectElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const type = el.value;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     // Create new encoder state with default options>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const encoderState = type === 'identity' >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ? undefined >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       : {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           type,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           options: encoderMap[type].meta.defaultOptions>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({ encoderState });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onResizeToggle = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const resizeEnabled = el.checked;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     // Update state and notify parent>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.setState({ resizeEnabled });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const newProcessorState = { ...this.props.processorState };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     newProcessorState.resize = { ...newProcessorState.resize, enabled: resizeEnabled };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({ processorState: newProcessorState });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onQuantizeToggle = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const quantizeEnabled = el.checked;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     // Update state and notify parent>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.setState({ quantizeEnabled });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const newProcessorState = { ...this.props.processorState };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     newProcessorState.quantize = { ...newProcessorState.quantize, enabled: quantizeEnabled };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({ processorState: newProcessorState });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onResizeOptionChange = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const el = event.currentTarget as HTMLInputElement | HTMLSelectElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const name = el.name;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const value = el instanceof HTMLInputElement && el.type === 'checkbox' >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ? el.checked >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       : el.value;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const newProcessorState = { ...this.props.processorState };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     newProcessorState.resize = { >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ...newProcessorState.resize, >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       [name]: typeof value === 'string' && !isNaN(Number(value)) ? Number(value) : value >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({ processorState: newProcessorState });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onQuantizeOptionChange = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const el = event.currentTarget as HTMLInputElement | HTMLSelectElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const name = el.name;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const value = el instanceof HTMLInputElement && el.type === 'checkbox' >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ? el.checked >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       : el.value;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const newProcessorState = { ...this.props.processorState };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     newProcessorState.quantize = { >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ...newProcessorState.quantize, >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       [name]: typeof value === 'string' && !isNaN(Number(value)) ? Number(value) : value >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({ processorState: newProcessorState });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onRotateChange = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const el = event.currentTarget as HTMLSelectElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const rotate = Number(el.value) as 0 | 90 | 180 | 270;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const newPreprocessorState = { ...this.props.preprocessorState, rotate: { rotate } };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({ preprocessorState: newPreprocessorState });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   render({ processorState, encoderState, preprocessorState }: Props, { showAdvanced, supportedEncoderMap, resizeEnabled, quantizeEnabled }: State) {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ^<div class={style.batchSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {/* Format selection */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<div class={style.settingGroup}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.settingLabel}>Output Format:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           {supportedEncoderMap ? (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<Select>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               value={encoderState ? encoderState.type : 'identity'}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               onChange={this.onEncoderTypeChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               large>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<option value="identity">Original Format^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               {Object.entries(supportedEncoderMap).map(([type, encoder]) => (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<option value={type}>{encoder.meta.label}^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ))}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</Select>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ) : (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<Select large>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<option>Loading…^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</Select>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {/* Rotation */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<div class={style.settingGroup}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.settingLabel}>Rotation:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<Select>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             value={preprocessorState.rotate.rotate}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             onChange={this.onRotateChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<option value="0">No rotation^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<option value="90">Rotate 90°^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<option value="180">Rotate 180°^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<option value="270">Rotate 270°^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</Select>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {/* Resize */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<label class={style.settingGroup}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.settingToggle}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<span>Resize^</span>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<Checkbox>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               checked={resizeEnabled}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               onChange={this.onResizeToggle}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</label>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           {resizeEnabled && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<div class={style.subSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<div class={style.settingLabel}>Width:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<input >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   type="number" >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   class={style.numberInput}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="width">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={processorState.resize.width}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={this.onResizeOptionChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min="1">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<div class={style.settingLabel}>Height:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<input >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   type="number" >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   class={style.numberInput}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="height">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={processorState.resize.height}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={this.onResizeOptionChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min="1">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<div class={style.settingLabel}>Method:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Select>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="method">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={processorState.resize.method}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onChange={this.onResizeOptionChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="lanczos3">Lanczos3^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="mitchell">Mitchell^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="catrom">Catmull-Rom^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="triangle">Triangle (bilinear)^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="hqx">hqx (pixel art)^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^</Select>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<div class={style.settingLabel}>Fit method:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Select>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="fitMethod">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={processorState.resize.fitMethod}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onChange={this.onResizeOptionChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="stretch">Stretch^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   ^<option value="contain">Contain^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^</Select>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {/* Quantize */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<label class={style.settingGroup}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.settingToggle}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<span>Reduce palette^</span>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<Checkbox>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               checked={quantizeEnabled}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               onChange={this.onQuantizeToggle}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</label>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           {quantizeEnabled && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<div class={style.subSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<div class={style.settingLabel}>Colors:^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<input >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   type="number" >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   class={style.numberInput}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="maxNumColors">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={processorState.quantize.maxNumColors}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={this.onQuantizeOptionChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min="2">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   max="256">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Range>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="dither">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min="0">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   max="1">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   step="0.01">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={processorState.quantize.dither}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={this.onQuantizeOptionChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   Dithering:>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^</Range>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {/* Encoder options would be displayed here, but simplified for bulk processing */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {encoderState && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<label class={style.settingReveal}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<Revealer>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               checked={showAdvanced}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               onChange={linkState(this, 'showAdvanced')}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             Advanced encoder settings>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</label>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           {showAdvanced && encoderState && encoderState.type === 'mozJPEG' && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<div class={style.subSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Range>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="quality">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min="0">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   max="100">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={encoderState.options.quality}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={(event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     const options = { ...encoderState.options, quality: Number(el.value) };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     this.props.onChange({ encoderState: { ...encoderState, options } });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   }}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   Quality:>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^</Range>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           {showAdvanced && encoderState && encoderState.type === 'webP' && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<div class={style.subSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Range>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="quality">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min="0">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   max="100">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={encoderState.options.quality}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={(event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     const options = { ...encoderState.options, quality: Number(el.value) };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     this.props.onChange({ encoderState: { ...encoderState, options } });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   }}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   Quality:>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^</Range>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           {/* Add more encoder-specific options here */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx

echo.
echo Creating BatchSettings styles...

echo .batchSettings {> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   overflow-y: auto;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   padding: 0.5rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .settingGroup {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   margin-bottom: 1rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   padding: 0.75rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .subSettings {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   margin-top: 0.5rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   padding: 0.5rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   background-color: var(--black);>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .settingLabel {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   font-size: 0.9rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   margin-bottom: 0.25rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   font-weight: 500;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .settingField {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   margin-bottom: 0.75rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .settingField:last-child {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   margin-bottom: 0;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .settingToggle {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   justify-content: space-between;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .settingReveal {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   composes: settingGroup;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   gap: 0.5rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   cursor: pointer;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo .numberInput {>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   background-color: var(--black);>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   border: 1px solid var(--medium-gray);>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   padding: 0.5rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo   font-size: 0.9rem;>> src\client\lazy-app\BulkCompress\BatchSettings\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\style.css

echo.
echo Creating BatchResults component...

echo import { h, Component } from 'preact';> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo interface BatchImageState {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   file: File;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   status: 'queued' ^| 'processing' ^| 'complete' ^| 'error';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   thumbnail?: string;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   result?: any;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   progress: number;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   images: BatchImageState[];>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   onDownload: (index: number) => void;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo export default class BatchResults extends Component^<Props> {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   calculateTotalSavings() {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     const { images } = this.props;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     let originalSize = 0;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     let processedSize = 0;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     images.forEach(image => {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       originalSize += image.file.size;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       if (image.result && image.result.file) {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         processedSize += image.result.file.size;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     if (originalSize === 0 || processedSize === 0) return { savingsPercent: 0, originalSize, processedSize };>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     const savingsPercent = Math.round((1 - processedSize / originalSize) * 100);>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     return { savingsPercent, originalSize, processedSize };>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   formatFileSize(bytes: number): string {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     if (bytes < 1024) return bytes + ' B';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     return (bytes / (1024 * 1024)).toFixed(1) + ' MB';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   render({ images, onDownload }: Props) {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     if (images.length === 0) return null;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     const { savingsPercent, originalSize, processedSize } = this.calculateTotalSavings();>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       ^<div class={style.resultsContainer}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         ^<div class={style.summaryPanel}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^<h2>Results Summary^</h2>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^<div class={style.summaryStats}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<div class={style.statItem}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statValue}>{images.length}^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statLabel}>Images Processed^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<div class={style.statItem}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statValue}>{savingsPercent}%%^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statLabel}>Total Savings^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<div class={style.statItem}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statValue}>{this.formatFileSize(originalSize)}^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statLabel}>Original Size^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<div class={style.statItem}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statValue}>{this.formatFileSize(processedSize)}^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo               ^<div class={style.statLabel}>Processed Size^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx

echo.
echo Creating BatchResults styles...

echo .resultsContainer {> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   margin-top: 1rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .summaryPanel {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   background-color: var(--off-black);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   padding: 1rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .summaryPanel h2 {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-size: 1.2rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   margin: 0 0 1rem 0;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   text-align: center;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .summaryStats {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   flex-wrap: wrap;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   gap: 1rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   justify-content: space-around;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .statItem {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   text-align: center;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   min-width: 100px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .statValue {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-size: 1.5rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   color: var(--main-theme-color);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .statLabel {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-size: 0.8rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css

echo.
echo Creating bulk-result-cache.ts...

echo import { EncoderState, ProcessorState } from '../feature-meta';> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo import { shallowEqual } from '../util';>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo interface CacheResult {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   processed: ImageData;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   data: ImageData;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   file: File;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo interface CacheEntry extends CacheResult {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   processorState: ProcessorState;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   encoderState: EncoderState;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   preprocessed: ImageData;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo const SIZE = 10; // Larger cache for bulk operations>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo export default class BulkResultCache {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   private readonly _entries: CacheEntry[] = [];>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   add(entry: CacheEntry) {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     // Add the new entry to the start>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     this._entries.unshift(entry);>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     // Remove the last entry if we're now bigger than SIZE>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     if (this._entries.length > SIZE) this._entries.pop();>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   match(>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     preprocessed: ImageData,>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     processorState: ProcessorState,>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     encoderState: EncoderState,>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   ): CacheResult | undefined {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     const matchingIndex = this._entries.findIndex((entry) => {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       // Check for quick exits:>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       if (entry.preprocessed !== preprocessed) return false;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       if (entry.encoderState.type !== encoderState.type) return false;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       // Check that each set of options in the preprocessor are the same>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       for (const prop in processorState) {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo         if (>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo           !shallowEqual(>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo             (processorState as any)[prop],>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo             (entry.processorState as any)[prop],>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo           )>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo         ) {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo           return false;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo         }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       // Check detailed encoder options>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       if (!shallowEqual(encoderState.options, entry.encoderState.options)) {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo         return false;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       return true;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     });>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     if (matchingIndex === -1) return undefined;>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     const matchingEntry = this._entries[matchingIndex];>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     if (matchingIndex !== 0) {>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       // Move the matched result to 1st position (LRU)>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       this._entries.splice(matchingIndex, 1);>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo       this._entries.unshift(matchingEntry);>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo.>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo     return { ...matchingEntry };>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo   }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts
echo }>> src\client\lazy-app\BulkCompress\bulk-result-cache.ts

echo.
echo Updating App/index.tsx to add bulk editing support...

echo   private onFileDrop = ({ files }: FileDropEvent) => {>> src\client\initial-app\App\index.tsx.update
echo     if (!files || files.length === 0) return;>> src\client\initial-app\App\index.tsx.update
echo.>> src\client\initial-app\App\index.tsx.update
echo     // If multiple files, go to bulk editor>> src\client\initial-app\App\index.tsx.update
echo     if (files.length > 1) {>> src\client\initial-app\App\index.tsx.update
echo       this.openBulkEditor(Array.from(files));>> src\client\initial-app\App\index.tsx.update
echo       return;>> src\client\initial-app\App\index.tsx.update
echo     }>> src\client\initial-app\App\index.tsx.update
echo.>> src\client\initial-app\App\index.tsx.update
echo     // Original single file behavior>> src\client\initial-app\App\index.tsx.update
echo     const file = files[0];>> src\client\initial-app\App\index.tsx.update
echo     this.openEditor();>> src\client\initial-app\App\index.tsx.update
echo     this.setState({ file });>> src\client\initial-app\App\index.tsx.update
echo   };>> src\client\initial-app\App\index.tsx.update

echo interface State {>> src\client\initial-app\App\index.tsx.state-update
echo   awaitingShareTarget: boolean;>> src\client\initial-app\App\index.tsx.state-update
echo   file?: File;>> src\client\initial-app\App\index.tsx.state-update
echo   isEditorOpen: Boolean;>> src\client\initial-app\App\index.tsx.state-update
echo   isBulkEditorOpen: Boolean;>> src\client\initial-app\App\index.tsx.state-update
echo   bulkFiles: File[];>> src\client\initial-app\App\index.tsx.state-update
echo   Compress?: typeof import('client/lazy-app/Compress').default;>> src\client\initial-app\App\index.tsx.state-update
echo   BulkCompress?: typeof import('client/lazy-app/BulkCompress').default;>> src\client\initial-app\App\index.tsx.state-update
echo }>> src\client\initial-app\App\index.tsx.state-update

echo   state: State = {>> src\client\initial-app\App\index.tsx.init-state
echo     awaitingShareTarget: new URL(location.href).searchParams.has(>> src\client\initial-app\App\index.tsx.init-state
echo       'share-target',>> src\client\initial-app\App\index.tsx.init-state
echo     ),>> src\client\initial-app\App\index.tsx.init-state
echo     isEditorOpen: false,>> src\client\initial-app\App\index.tsx.init-state
echo     isBulkEditorOpen: false,>> src\client\initial-app\App\index.tsx.init-state
echo     bulkFiles: [],>> src\client\initial-app\App\index.tsx.init-state
echo     file: undefined,>> src\client\initial-app\App\index.tsx.init-state
echo import { h, Component } from 'preact';> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import { ProcessorState, EncoderState, encoderMap, defaultPreprocessorState } from '../../feature-meta';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Select from '../../Compress/Options/Select';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Range from '../../Compress/Options/Range';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Checkbox from '../../Compress/Options/Checkbox';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Expander from '../../Compress/Options/Expander';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import Revealer from '../../Compress/Options/Revealer';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo import linkState from 'linkstate';>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   processorState: ProcessorState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   encoderState?: EncoderState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   preprocessorState: typeof defaultPreprocessorState;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   onChange: (updates: {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     processorState?: ProcessorState,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     encoderState?: EncoderState,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     preprocessorState?: typeof defaultPreprocessorState>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }) => void;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo interface State {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   selectedEncoder: string;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   showPreprocessorOptions: boolean;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo export default class BatchSettings extends Component^<Props, State^> {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   state: State = {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     selectedEncoder: this.props.encoderState?.type || 'mozJPEG',>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     showPreprocessorOptions: false>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onEncoderTypeChange = (event: Event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const select = event.target as HTMLSelectElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const newType = select.value as keyof typeof encoderMap;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.setState({ selectedEncoder: newType });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     // Create new encoder state with default options>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       encoderState: {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         type: newType,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         options: encoderMap[newType].meta.defaultOptions>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onEncoderOptionsChange = (options: object) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     if (!this.props.encoderState) return;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       encoderState: {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ...this.props.encoderState,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         options: {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ...this.props.encoderState.options,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ...options>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private onPreprocessorChange = (options: Partial^<typeof defaultPreprocessorState^>) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.props.onChange({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       preprocessorState: {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ...this.props.preprocessorState,>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ...options>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   private togglePreprocessorOptions = () => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     this.setState(state => ({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       showPreprocessorOptions: !state.showPreprocessorOptions>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     }));>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   };>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   render({ processorState, encoderState, preprocessorState }: Props, { selectedEncoder, showPreprocessorOptions }: State) {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const encoderOptions = encoderState?.options || {};>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     const encoder = encoderState ? encoderMap[encoderState.type] : null;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ^<div class={style.batchSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<div class={style.section}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<h3>Output Format^</h3>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.row}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<label for="encoder-select">Format:^</label>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<select >> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               id="encoder-select">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               class={style.formatSelect}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               value={selectedEncoder}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               onChange={this.onEncoderTypeChange}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             >>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               {Object.entries(encoderMap).map(([id, { meta }]) => (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<option value={id} key={id}>{meta.label}^</option>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ))}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</select>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         {encoder && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.section}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<h3>Quality Settings^</h3>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             {encoder.meta.uiAspects.quality && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.row}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Range>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="Quality">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   min={encoder.meta.uiAspects.quality.min}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   max={encoder.meta.uiAspects.quality.max}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={encoderOptions.quality}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onInput={linkState(this, 'quality', this.onEncoderOptionsChange)}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             {/* Add other encoder-specific options based on encoder.meta.uiAspects */}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             {encoder.meta.uiAspects.lossless && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.row}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<Checkbox>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   name="Lossless">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   checked={!!encoderOptions.lossless}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onChange={linkState(this, 'lossless', this.onEncoderOptionsChange)}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^<Expander title="Preprocessing Options" expanded={showPreprocessorOptions} onChange={this.togglePreprocessorOptions}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^<div class={style.subSettings}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<Checkbox>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 name="Resize">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 checked={preprocessorState.resize.enabled}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 onChange={(event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   this.onPreprocessorChange({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     resize: { ...preprocessorState.resize, enabled: el.checked }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 }}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             {preprocessorState.resize.enabled && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<label class={style.settingLabel}>Width:^</label>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<input>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   class={style.numberInput}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   type="number">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={preprocessorState.resize.width}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onChange={(event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     this.onPreprocessorChange({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                       resize: { ...preprocessorState.resize, width: Number(el.value) }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   }}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             {preprocessorState.resize.enabled && (>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^<div class={style.settingField}>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<label class={style.settingLabel}>Height:^</label>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 ^<input>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   class={style.numberInput}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   type="number">> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   value={preprocessorState.resize.height}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   onChange={(event) => {>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     const el = event.currentTarget as HTMLInputElement;>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     this.onPreprocessorChange({>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                       resize: { ...preprocessorState.resize, height: Number(el.value) }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                     });>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                   }}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo                 />>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo             )}>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo         ^</Expander>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchSettings\index.tsx

echo.
echo Creating ImageList component...

echo import { h, Component } from 'preact';> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo interface BatchImageState {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   file: File;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   status: 'queued' ^| 'processing' ^| 'complete' ^| 'error';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   thumbnail?: string;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   result?: any;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   progress: number;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   error?: string;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   images: BatchImageState[];>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   onRemove: (index: number) => void;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   onDownload: (index: number) => void;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo export default class ImageList extends Component^<Props> {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   formatFileSize(bytes: number): string {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     if (bytes < 1024) return bytes + ' B';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     return (bytes / (1024 * 1024)).toFixed(1) + ' MB';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   getCompressionRatio(original: number, compressed: number): string {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     if (!compressed || !original) return '-';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     const ratio = (1 - compressed / original) * 100;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     return ratio.toFixed(1) + '%%';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   getStatusClass(status: BatchImageState['status']): string {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     switch (status) {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       case 'queued': return style.statusQueued;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       case 'processing': return style.statusProcessing;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       case 'complete': return style.statusComplete;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       case 'error': return style.statusError;>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       default: return '';>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   render({ images, onRemove, onDownload }: Props) {>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       ^<div class={style.imageListContainer}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         {images.length === 0 && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo           ^<div class={style.emptyState}>No images to process^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         ^<div class={style.imageGrid}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo           {images.map((image, index) => (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^<div class={style.imageCard} key={index}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.imageHeader}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.imageName} title={image.file.name}>{image.file.name}^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<button>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   class={style.removeButton}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   onClick={() => onRemove(index)}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   title="Remove image">> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   aria-label="Remove image">> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 >×^</button>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.thumbnailContainer}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 {image.thumbnail ? (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<img src={image.thumbnail} alt={image.file.name} class={style.thumbnail} />>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ) : (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<div class={style.thumbnailPlaceholder}>Loading...^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={`${style.statusBadge} ${this.getStatusClass(image.status)}`}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
I'll continue with the implementation of the bulk-edit-implementation.bat file, focusing on completing the ImageList component and adding the remaining integration code.

```bat:c:\Intel\questo\projects\squoosh\bulk-edit-implementation.bat
echo                   {image.status}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^<div class={style.imageInfo}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.infoRow}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<span>Original:^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<span>{this.formatFileSize(image.file.size)}^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 {image.result && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<div class={style.infoRow}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     ^<span>Compressed:^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     ^<span>{this.formatFileSize(image.result.file.size)}^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 {image.result && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<div class={style.infoRow}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     ^<span>Savings:^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     ^<span>{this.getCompressionRatio(image.file.size, image.result.file.size)}^</span>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.status === 'processing' && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.progressContainer}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<div class={style.progressBar} style={{ width: `${image.progress * 100}%%` }}></div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.status === 'error' && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.errorMessage}>{image.error || 'Processing failed'}^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo.>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               {image.status === 'complete' && (>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^<div class={style.imageActions}>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   ^<button>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     class={style.downloadButton}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                     onClick={() => onDownload(index)}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                   >Download^</button>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo                 ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo               )}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo             ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo           ))}>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx
echo }>> src\client\lazy-app\BulkCompress\ImageList\index.tsx

echo.
echo Creating ImageList styles...

echo .imageListContainer {> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow-y: auto;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   max-height: 60vh;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageGrid {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: grid;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   gap: 16px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 16px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageCard {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--off-black);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageHeader {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: space-between;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 8px 12px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: rgba(0, 0, 0, 0.2);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .imageName {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 0.9rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   white-space: nowrap;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   overflow: hidden;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   text-overflow: ellipsis;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   max-width: 80%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .removeButton {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background: none;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border: none;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 1.2rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   cursor: pointer;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 0 4px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .removeButton:hover {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--red);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .thumbnailContainer {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   position: relative;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 150px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   align-items: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   justify-content: center;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .thumbnail {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   max-width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   max-height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   object-fit: contain;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .thumbnailPlaceholder {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 0.9rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .statusBadge {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   position: absolute;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   top: 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   right: 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   padding: 4px 8px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-size: 0.7rem;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   text-transform: uppercase;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   color: white;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .statusQueued {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--blue);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .statusProcessing {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--orange);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .statusComplete {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--green);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .statusError {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--red);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .progressContainer {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   width: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 2px;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--dark-gray);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   margin-top: auto;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo.>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo .progressBar {>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   height: 100%%;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   background-color: var(--blue);>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo   transition: width 0.3s ease;>> src\client\lazy-app\BulkCompress\ImageList\style.css
echo }>> src\client\lazy-app\BulkCompress\ImageList\style.css

echo.
echo Creating BatchResults component...

echo import { h, Component } from 'preact';> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo import * as style from './style.css';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo import 'add-css:./style.css';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo interface Props {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   totalImages: number;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   processedImages: number;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   totalSavings: number;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   onDownloadAll: () => void;>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo export default class BatchResults extends Component^<Props> {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   formatSavings(bytes: number): string {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     if (bytes < 1024) return bytes + ' B';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     return (bytes / (1024 * 1024)).toFixed(1) + ' MB';>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   render({ totalImages, processedImages, totalSavings, onDownloadAll }: Props) {>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     return (>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       ^<div class={style.batchResults}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         ^<div class={style.statsContainer}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^<div class={style.stat}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<span class={style.statLabel}>Processed:^</span>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<span class={style.statValue}>{processedImages} / {totalImages}^</span>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^<div class={style.stat}>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<span class={style.statLabel}>Total Savings:^</span>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             ^<span class={style.statValue}>{this.formatSavings(totalSavings)}^</span>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo.>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         {processedImages > 0 && (>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           ^<button>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             class={style.downloadAllButton}>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo             onClick={onDownloadAll}>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo           >Download All^</button>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo         )}>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo       ^</div>>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo     );>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo   }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx
echo }>> src\client\lazy-app\BulkCompress\BatchResults\index.tsx

echo.
echo Creating BatchResults styles...

echo .batchResults {> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   padding: 16px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   background-color: var(--off-black);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   border-radius: 8px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   margin-top: 16px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .statsContainer {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   gap: 24px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   margin-bottom: 16px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .stat {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   display: flex;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   flex-direction: column;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   gap: 4px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .statLabel {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-size: 0.9rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   color: var(--medium-gray);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .statValue {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-size: 1.1rem;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   color: var(--white);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .downloadAllButton {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   background-color: var(--blue);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   color: white;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   border: none;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   padding: 8px 16px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   border-radius: 4px;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   cursor: pointer;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   font-weight: bold;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   transition: background-color 0.2s;>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo.>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo .downloadAllButton:hover {>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo   background-color: var(--dark-blue);>> src\client\lazy-app\BulkCompress\BatchResults\style.css
echo }>> src\client\lazy-app\BulkCompress\BatchResults\style.css

echo.
echo Implementation complete!
echo Please rebuild the project to apply changes.