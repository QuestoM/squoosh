import { jest } from '@jest/globals';
import { abortable } from '../index';

describe('abortable', () => {
  let mockAbortController: AbortController;

  beforeEach(() => {
    mockAbortController = new AbortController();
  });

  it('should resolve when promise resolves', async () => {
    const mockPromise = Promise.resolve('test result');
    const result = await abortable(mockAbortController.signal, mockPromise);
    expect(result).toBe('test result');
  });

  it('should reject when promise rejects', async () => {
    const testError = new Error('test error');
    const mockPromise = Promise.reject(testError);
    await expect(
      abortable(mockAbortController.signal, mockPromise),
    ).rejects.toThrow('test error');
  });

  it('should reject with AbortError when signal is already aborted', async () => {
    mockAbortController.abort();
    const mockPromise = new Promise((resolve) =>
      setTimeout(() => resolve('test'), 100),
    );
    await expect(
      abortable(mockAbortController.signal, mockPromise),
    ).rejects.toThrow('AbortError');
  });

  it('should reject with AbortError when signal is aborted during promise execution', async () => {
    const mockPromise = new Promise((resolve) =>
      setTimeout(() => resolve('test'), 100),
    );
    const abortablePromise = abortable(mockAbortController.signal, mockPromise);

    // Abort after a small delay
    setTimeout(() => mockAbortController.abort(), 10);

    await expect(abortablePromise).rejects.toThrow('AbortError');
  });

  it('should not affect the original promise when aborting', async () => {
    let promiseResolved = false;
    const mockPromise = new Promise<string>((resolve) => {
      setTimeout(() => {
        promiseResolved = true;
        resolve('test');
      }, 100);
    });

    const abortablePromise = abortable(mockAbortController.signal, mockPromise);
    mockAbortController.abort();

    await expect(abortablePromise).rejects.toThrow('AbortError');

    // Wait for the original promise to complete
    await new Promise((resolve) => setTimeout(resolve, 150));
    expect(promiseResolved).toBe(true);
  });
});
