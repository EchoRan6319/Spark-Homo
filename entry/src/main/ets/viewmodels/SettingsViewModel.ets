import { SettingsService } from '../services/storage/SettingsService';
import { AiService, ChatMessage } from '../services/ai/AiService';

export class SettingsViewModel {
  apiKey: string = '';
  baseUrl: string = 'https://api.openai.com/v1';
  model: string = 'gpt-4o-mini';
  themeMode: string = 'system';
  connectionStatus: 'none' | 'testing' | 'success' | 'error' = 'none';
  errorMessage: string = '';
  onThemeChanged?: (mode: string) => void;

  private settingsService: SettingsService;
  private aiService: AiService;

  constructor() {
    this.settingsService = SettingsService.getInstance();
    this.aiService = AiService.getInstance();
  }

  async loadSettings(): Promise<void> {
    try {
      this.apiKey = await this.settingsService.getApiKey();
      this.baseUrl = await this.settingsService.getBaseUrl();
      this.model = await this.settingsService.getModel();
      this.themeMode = await this.settingsService.getThemeMode();
    } catch (err) {
      console.error(`Failed to load settings: ${JSON.stringify(err)}`);
    }
  }

  async saveApiKey(key: string): Promise<void> {
    this.apiKey = key;
    try {
      await this.settingsService.setApiKey(key);
    } catch (err) {
      console.error(`Failed to save API key: ${JSON.stringify(err)}`);
    }
  }

  async saveBaseUrl(url: string): Promise<void> {
    this.baseUrl = url;
    try {
      await this.settingsService.setBaseUrl(url);
    } catch (err) {
      console.error(`Failed to save base URL: ${JSON.stringify(err)}`);
    }
  }

  async saveModel(model: string): Promise<void> {
    this.model = model;
    try {
      await this.settingsService.setModel(model);
    } catch (err) {
      console.error(`Failed to save model: ${JSON.stringify(err)}`);
    }
  }

  async saveThemeMode(mode: string): Promise<void> {
    this.themeMode = mode;
    try {
      await this.settingsService.setThemeMode(mode);
      AppStorage.setOrCreate('themeMode', mode);
      if (this.onThemeChanged) {
        this.onThemeChanged(mode);
      }
    } catch (err) {
      console.error(`Failed to save theme mode: ${JSON.stringify(err)}`);
    }
  }

  async testConnection(): Promise<void> {
    this.connectionStatus = 'testing';
    this.errorMessage = '';
    try {
      if (!this.apiKey) {
        this.connectionStatus = 'error';
        this.errorMessage = '请输入 API Key';
        return;
      }

      const testMsg: ChatMessage = { role: 'user', content: 'Hello' } as ChatMessage;
      await this.aiService.chat([testMsg]);
      this.connectionStatus = 'success';
    } catch (err) {
      console.error(`AI connection test failed: ${JSON.stringify(err)}`);
      this.connectionStatus = 'error';
      this.errorMessage = err instanceof Error ? err.message : JSON.stringify(err);
    }
  }
}
