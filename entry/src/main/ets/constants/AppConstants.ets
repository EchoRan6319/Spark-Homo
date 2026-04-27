export class EmotionType {
  key: string = '';
  label: string = '';
}

export class AiPreset {
  name: string = '';
  baseUrl: string = '';
  model: string = '';
}

export class PreferredModel {
  name: string = '';
  baseUrl: string = '';
  model: string = '';
  apiKey: string = '';
}

export class AppConstants {
  static readonly DATABASE_NAME: string = 'spark.db';
  static readonly DATABASE_VERSION: number = 1;

  static readonly TABLE_INSPIRATIONS: string = 'inspirations';
  static readonly TABLE_PROJECTS: string = 'projects';
  static readonly TABLE_TASKS: string = 'tasks';

  static readonly DEFAULT_API_BASE_URL: string = 'https://api.openai.com/v1';
  static readonly DEFAULT_MODEL: string = 'gpt-4o-mini';

  static readonly EMOTION_TYPES: EmotionType[] = [
    { key: 'happy', label: '开心' } as EmotionType,
    { key: 'sad', label: '难过' } as EmotionType,
    { key: 'angry', label: '愤怒' } as EmotionType,
    { key: 'surprised', label: '惊讶' } as EmotionType,
    { key: 'thinking', label: '思考' } as EmotionType
  ];

  static readonly AI_PRESETS: AiPreset[] = [
    { name: 'OpenAI', baseUrl: 'https://api.openai.com/v1', model: 'gpt-4o-mini' } as AiPreset,
    { name: 'DeepSeek', baseUrl: 'https://api.deepseek.com/v1', model: 'deepseek-chat' } as AiPreset,
    { name: '通义千问', baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1', model: 'qwen-turbo' } as AiPreset,
    { name: '智谱GLM', baseUrl: 'https://open.bigmodel.cn/api/paas/v4', model: 'glm-4-flash' } as AiPreset,
    { name: '月之暗面', baseUrl: 'https://api.moonshot.cn/v1', model: 'moonshot-v1-8k' } as AiPreset,
    { name: 'Claude', baseUrl: 'https://api.anthropic.com/v1', model: 'claude-3-haiku-20240307' } as AiPreset
  ];
}
