import { jest } from '@jest/globals';
import { drawableToImageData } from '../canvas';

describe('canvas utilities', () => {
  let mockCanvas: HTMLCanvasElement;
  let mockContext: CanvasRenderingContext2D;

  beforeEach(() => {
    // Mock canvas and context
    mockContext = {
      drawImage: jest.fn(),
      getImageData: jest
        .fn()
        .mockReturnValue({
          data: new Uint8ClampedArray(),
          width: 100,
          height: 100,
        }),
    } as unknown as CanvasRenderingContext2D;

    mockCanvas = {
      getContext: jest.fn().mockReturnValue(mockContext),
      width: 0,
      height: 0,
    } as unknown as HTMLCanvasElement;

    // Mock document.createElement to return our mock canvas
    document.createElement = jest.fn().mockImplementation((tagName) => {
      if (tagName === 'canvas') return mockCanvas;
      return {} as any;
    }) as unknown as typeof document.createElement;
  });

  describe('drawableToImageData', () => {
    it('should convert an HTMLImageElement to ImageData', () => {
      const mockImage = {
        width: 100,
        height: 200,
      } as HTMLImageElement;

      const result = drawableToImageData(mockImage);

      // Check canvas was sized correctly
      expect(mockCanvas.width).toBe(100);
      expect(mockCanvas.height).toBe(200);

      // Check image was drawn
      expect(mockContext.drawImage).toHaveBeenCalledWith(mockImage, 0, 0);

      // Check image data was retrieved
      expect(mockContext.getImageData).toHaveBeenCalledWith(0, 0, 100, 200);
    });

    it('should convert an ImageBitmap to ImageData', () => {
      const mockBitmap = {
        width: 150,
        height: 250,
      } as ImageBitmap;

      const result = drawableToImageData(mockBitmap);

      // Check canvas was sized correctly
      expect(mockCanvas.width).toBe(150);
      expect(mockCanvas.height).toBe(250);

      // Check bitmap was drawn
      expect(mockContext.drawImage).toHaveBeenCalledWith(mockBitmap, 0, 0);

      // Check image data was retrieved
      expect(mockContext.getImageData).toHaveBeenCalledWith(0, 0, 150, 250);
    });

    it('should handle errors when getting context', () => {
      // Mock getContext to return null (simulating failure)
      mockCanvas.getContext = jest
        .fn()
        .mockReturnValue(null) as unknown as typeof mockCanvas.getContext;

      expect(() => {
        drawableToImageData({ width: 100, height: 100 } as HTMLImageElement);
      }).toThrow('Could not create canvas context');
    });
  });
});
