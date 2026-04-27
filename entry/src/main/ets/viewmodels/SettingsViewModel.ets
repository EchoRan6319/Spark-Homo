import { SettingsService, AiModelConfig } from '../services/storage/SettingsService';
import { AiService, ChatMessage } from '../services/ai/AiService';
import { AppConstants, AiPreset, PreferredModel } from '../constants/AppConstants';

export class SettingsViewModel {
  apiKey: string = '';
  baseUrl: string = 'https://api.openai.com/v1';
  model: string = 'gpt-4o-mini';
  themeMode: string = 'system';
  currentPresetName: string = '';
  preferredModel: string = '';
  customPresets: AiPreset[] = [];
  errorMessage: string = '';
  onThemeChanged?: (mode: string) => void;

  // UI状态回调
  onConnectionStatusChanged?: (status: 'none' | 'testing' | 'success' | 'error') => void;
  onSaveStatusChanged?: (status: 'none' | 'saving' | 'success' | 'error') => void;
  onErrorMessageChanged?: (message: string) => void;

  private settingsService: SettingsService;
  private aiService: AiService;

  constructor() {
    this.settingsService = SettingsService.getInstance();
    this.aiService = AiService.getInstance();
  }

  async loadSettings(): Promise<void> {
    try {
      this.currentPresetName = await this.settingsService.getCurrentPresetName();
      this.preferredModel = await this.settingsService.getPreferredModel();
      this.customPresets = await this.settingsService.getCustomPresets();

      if (this.currentPresetName) {
        const config = await this.settingsService.getModelConfig(this.currentPresetName);
        if (config) {
          this.apiKey = config.apiKey;
          this.baseUrl = config.baseUrl;
          this.model = config.model;
        } else {
          await this.loadLegacySettings();
        }
      } else {
        await this.loadLegacySettings();
      }

      this.themeMode = await this.settingsService.getThemeMode();
    } catch (err) {
      console.error(`Failed to load settings: ${JSON.stringify(err)}`);
    }
  }

  private async loadLegacySettings(): Promise<void> {
    this.apiKey = await this.settingsService.getApiKey();
    this.baseUrl = await this.settingsService.getBaseUrl();
    this.model = await this.settingsService.getModel();
  }

  async saveCurrentConfig(): Promise<void> {
    if (!this.currentPresetName) return;

    const config: AiModelConfig = {
      presetName: this.currentPresetName,
      baseUrl: this.baseUrl,
      model: this.model,
      apiKey: this.apiKey
    };

    try {
      await this.settingsService.saveModelConfig(config);
      await this.settingsService.setCurrentPresetName(this.currentPresetName);
    } catch (err) {
      console.error(`Failed to save model config: ${JSON.stringify(err)}`);
    }
  }

  async saveAllSettings(): Promise<boolean> {
    this.onSaveStatusChanged?.('saving');
    try {
      if (!this.currentPresetName) {
        this.onSaveStatusChanged?.('error');
        this.errorMessage = '请先选择一个模型预设';
        this.onErrorMessageChanged?.(this.errorMessage);
        return false;
      }

      const config: AiModelConfig = {
        presetName: this.currentPresetName,
        baseUrl: this.baseUrl,
        model: this.model,
        apiKey: this.apiKey
      };

      await this.settingsService.saveModelConfig(config);
      await this.settingsService.setCurrentPresetName(this.currentPresetName);
      await this.settingsService.setPreferredModel(this.preferredModel);

      this.onSaveStatusChanged?.('success');
      return true;
    } catch (err) {
      console.error(`Failed to save settings: ${JSON.stringify(err)}`);
      this.onSaveStatusChanged?.('error');
      this.errorMessage = '保存失败';
      this.onErrorMessageChanged?.(this.errorMessage);
      return false;
    }
  }

  async saveApiKey(key: string): Promise<void> {
    this.apiKey = key;
    await this.saveCurrentConfig();
  }

  async saveBaseUrl(url: string): Promise<void> {
    this.baseUrl = url;
    await this.saveCurrentConfig();
  }

  async saveModel(model: string): Promise<void> {
    this.model = model;
    await this.saveCurrentConfig();
  }

  async selectPreset(preset: AiPreset): Promise<void> {
    this.currentPresetName = preset.name;
    this.baseUrl = preset.baseUrl;
    this.model = preset.model;

    const config = await this.settingsService.getModelConfig(preset.name);
    if (config) {
      this.apiKey = config.apiKey;
    } else {
      this.apiKey = '';
    }

    await this.saveCurrentConfig();
  }

  async setPreferredModel(name: string): Promise<void> {
    this.preferredModel = name;
    await this.settingsService.setPreferredModel(name);
  }

  async addCustomPreset(name: string, baseUrl: string, model: string): Promise<void> {
    const preset: AiPreset = { name, baseUrl, model };
    this.customPresets.push(preset);
    await this.settingsService.saveCustomPresets(this.customPresets);
  }

  async deleteCustomPreset(name: string): Promise<void> {
    this.customPresets = this.customPresets.filter(p => p.name !== name);
    await this.settingsService.saveCustomPresets(this.customPresets);
    await this.settingsService.deleteModelConfig(name);

    if (this.currentPresetName === name) {
      this.currentPresetName = '';
      this.apiKey = '';
      await this.settingsService.setCurrentPresetName('');
    }
    if (this.preferredModel === name) {
      this.preferredModel = '';
      await this.settingsService.setPreferredModel('');
    }
  }

  getAllPresets(): AiPreset[] {
    return [...AppConstants.AI_PRESETS, ...this.customPresets];
  }

  getAllModelsWithConfig(): PreferredModel[] {
    const models: PreferredModel[] = [];
    const allPresets = this.getAllPresets();

    for (const preset of allPresets) {
      const model: PreferredModel = {
        name: preset.name,
        baseUrl: preset.baseUrl,
        model: preset.model,
        apiKey: ''
      };
      models.push(model);
    }

    return models;
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
    this.onConnectionStatusChanged?.('testing');
    this.errorMessage = '';
    this.onErrorMessageChanged?.('');
    try {
      if (!this.apiKey) {
        this.onConnectionStatusChanged?.('error');
        this.errorMessage = '请输入 API Key';
        this.onErrorMessageChanged?.(this.errorMessage);
        return;
      }

      if (!this.currentPresetName) {
        this.onConnectionStatusChanged?.('error');
        this.errorMessage = '请先选择一个模型预设';
        this.onErrorMessageChanged?.(this.errorMessage);
        return;
      }

      // 测试前先将当前配置保存到 SettingsService，确保 AiService 能读取到最新配置
      const config: AiModelConfig = {
        presetName: this.currentPresetName,
        baseUrl: this.baseUrl,
        model: this.model,
        apiKey: this.apiKey
      };
      await this.settingsService.saveModelConfig(config);
      await this.settingsService.setCurrentPresetName(this.currentPresetName);

      const testMsg: ChatMessage = { role: 'user', content: 'Hello' } as ChatMessage;
      await this.aiService.chat([testMsg]);
      this.onConnectionStatusChanged?.('success');
    } catch (err) {
      console.error(`AI connection test failed: ${JSON.stringify(err)}`);
      this.onConnectionStatusChanged?.('error');
      this.errorMessage = err instanceof Error ? err.message : JSON.stringify(err);
      this.onErrorMessageChanged?.(this.errorMessage);
    }
  }
}
