import { Context } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { AiPreset } from '../../constants/AppConstants';

export interface AiModelConfig {
  presetName: string;
  baseUrl: string;
  model: string;
  apiKey: string;
}

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

  async setCurrentPresetName(name: string): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('currentPresetName', name);
    await this.preference.flush();
  }

  async getCurrentPresetName(): Promise<string> {
    if (!this.preference) return '';
    return await this.preference.get('currentPresetName', '') as string;
  }

  async saveCustomPresets(presets: AiPreset[]): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('customPresets', JSON.stringify(presets));
    await this.preference.flush();
  }

  async getCustomPresets(): Promise<AiPreset[]> {
    if (!this.preference) return [];
    const data = await this.preference.get('customPresets', '[]') as string;
    try {
      return JSON.parse(data) as AiPreset[];
    } catch {
      return [];
    }
  }

  async saveModelConfig(config: AiModelConfig): Promise<void> {
    if (!this.preference) return;
    const key = `modelConfig_${config.presetName}`;
    await this.preference.put(key, JSON.stringify(config));
    await this.preference.flush();
  }

  async getModelConfig(presetName: string): Promise<AiModelConfig | null> {
    if (!this.preference) return null;
    const key = `modelConfig_${presetName}`;
    const data = await this.preference.get(key, '') as string;
    if (!data) return null;
    try {
      return JSON.parse(data) as AiModelConfig;
    } catch {
      return null;
    }
  }

  async deleteModelConfig(presetName: string): Promise<void> {
    if (!this.preference) return;
    const key = `modelConfig_${presetName}`;
    await this.preference.delete(key);
    await this.preference.flush();
  }

  async setPreferredModel(name: string): Promise<void> {
    if (!this.preference) return;
    await this.preference.put('preferredModel', name);
    await this.preference.flush();
  }

  async getPreferredModel(): Promise<string> {
    if (!this.preference) return '';
    return await this.preference.get('preferredModel', '') as string;
  }

  async saveMindMap(inspirationId: number, mindMapData: string): Promise<void> {
    if (!this.preference) return;
    const key = `mindMap_${inspirationId}`;
    await this.preference.put(key, mindMapData);
    await this.preference.flush();
  }

  async getMindMap(inspirationId: number): Promise<string> {
    if (!this.preference) return '';
    const key = `mindMap_${inspirationId}`;
    return await this.preference.get(key, '') as string;
  }

  async deleteMindMap(inspirationId: number): Promise<void> {
    if (!this.preference) return;
    const key = `mindMap_${inspirationId}`;
    await this.preference.delete(key);
    await this.preference.flush();
  }
}