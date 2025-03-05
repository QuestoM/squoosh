/**
 * Mock implementation of the abortable utility function for testing
 */
export const abortable = jest.fn().mockImplementation((signal, promise) => {
  if (signal.aborted) {
    return Promise.reject(new DOMException('AbortError', 'AbortError'));
  }

  return promise.catch((err) => {
    if (signal.aborted) {
      throw new DOMException('AbortError', 'AbortError');
    }
    throw err;
  });
});
