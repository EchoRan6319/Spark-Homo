import { Context } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export class SettingsService {
  private static instance: SettingsService | null = null;
  private preference: preferences.Preferences | null = null;
  private readonly PREFERENCE_NAME = 'spark_settings';

  private constructor() {}

  static getInstance(): SettingsService {
    if (!SettingsService.instance) {
      SettingsService.instance = new SettingsService();
    }
    return SettingsService.instance;
  }

  async init(context: Context): Promise<void> {
    if (this.preference) {
      return;
    }
    this.preference = await preferences.getPreferences(context, this.PREFERENCE_NAME);
  }

  async setApiKey(key: string): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('apiKey', key);
    await this.preference.flush();
  }

  async getApiKey(): Promise<string> {
    if (!this.preference) return '';
    return await this.preference.get('apiKey', '') as string;
  }

  async setBaseUrl(url: string): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('baseUrl', url);
    await this.preference.flush();
  }

  async getBaseUrl(): Promise<string> {
    if (!this.preference) return 'https://api.openai.com/v1';
    return await this.preference.get('baseUrl', 'https://api.openai.com/v1') as string;
  }

  async setModel(model: string): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('model', model);
    await this.preference.flush();
  }

  async getModel(): Promise<string> {
    if (!this.preference) return 'gpt-4o-mini';
    return await this.preference.get('model', 'gpt-4o-mini') as string;
  }

  async setThemeMode(mode: string): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('themeMode', mode);
    await this.preference.flush();
  }

  async getThemeMode(): Promise<string> {
    if (!this.preference) return 'system';
    return await this.preference.get('themeMode', 'system') as string;
  }
}
