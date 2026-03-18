type TokenFetcher = () => Promise<string | null>;

class ApiClient {
  private tokenFetcher: TokenFetcher | null = null;
  private baseUrl: string = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";

  setTokenFetcher(fetcher: TokenFetcher) {
    this.tokenFetcher = fetcher;
  }

  async fetch(endpoint: string, options: RequestInit = {}): Promise<Response> {
    const headers = new Headers(options.headers);
    
    if (this.tokenFetcher) {
      const token = await this.tokenFetcher();
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
    }

    const url = endpoint.startsWith("http") ? endpoint : `${this.baseUrl}${endpoint}`;
    
    return fetch(url, { ...options, headers });
  }
}

export const apiClient = new ApiClient();
