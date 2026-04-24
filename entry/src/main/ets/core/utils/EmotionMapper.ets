export interface EmotionInfo {
  key: string;
  label: string;
  color: string;
  icon: string;
}

export class EmotionMapper {
  private static readonly emotions: EmotionInfo[] = [
    { key: 'happy', label: '开心', color: '#34C759', icon: '😊' },
    { key: 'sad', label: '难过', color: '#5856D6', icon: '😢' },
    { key: 'angry', label: '愤怒', color: '#FF3B30', icon: '😠' },
    { key: 'surprised', label: '惊讶', color: '#FF9500', icon: '😲' },
    { key: 'thinking', label: '思考', color: '#007AFF', icon: '🤔' }
  ];

  static getEmotionList(): EmotionInfo[] {
    return EmotionMapper.emotions;
  }

  static getLabel(key: string): string {
    const emotion = EmotionMapper.emotions.find(e => e.key === key);
    return emotion ? emotion.label : '未知';
  }

  static getColor(key: string): string {
    const emotion = EmotionMapper.emotions.find(e => e.key === key);
    return emotion ? emotion.color : '#8E8E93';
  }

  static getIcon(key: string): string {
    const emotion = EmotionMapper.emotions.find(e => e.key === key);
    return emotion ? emotion.icon : '❓';
  }
}
