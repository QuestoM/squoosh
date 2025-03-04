/**
 * A simple cache for bulk processing results to avoid reprocessing images
 * when the user navigates away and back to the bulk processing page.
 */
export default class BulkResultCache {
  private cache = new Map<string, any>();
  private readonly MAX_CACHE_SIZE = 50; // Maximum number of results to cache
  
  /**
   * Get a cached result for a file
   * @param file The file to get the result for
   * @returns The cached result or undefined if not found
   */
  get(file: File): any | undefined {
    const key = this.getFileKey(file);
    return this.cache.get(key);
  }
  
  /**
   * Store a result in the cache
   * @param file The file the result is for
   * @param result The processing result
   */
  set(file: File, result: any): void {
    const key = this.getFileKey(file);
    
    // If cache is full, remove oldest entry
    if (this.cache.size >= this.MAX_CACHE_SIZE) {
      const oldestKey = this.cache.keys().next().value;
      this.cache.delete(oldestKey);
    }
    
    this.cache.set(key, result);
  }
  
  /**
   * Check if a file has a cached result
   * @param file The file to check
   * @returns True if the file has a cached result
   */
  has(file: File): boolean {
    const key = this.getFileKey(file);
    return this.cache.has(key);
  }
  
  /**
   * Clear all cached results
   */
  clear(): void {
    this.cache.clear();
  }
  
  /**
   * Generate a unique key for a file based on name, size, and last modified date
   * @param file The file to generate a key for
   * @returns A string key
   */
  private getFileKey(file: File): string {
    return `${file.name}-${file.size}-${file.lastModified}`;
  }
}