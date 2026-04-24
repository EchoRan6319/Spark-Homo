import relationalStore from '@ohos.data.relationalStore';

export class Inspiration {
  id: number;
  content: string;
  emotion: string;
  tags: string;
  aiAnalysis: string;
  isPinned: number;
  createdAt: number;
  updatedAt: number;

  constructor(
    id: number = 0,
    content: string = '',
    emotion: string = '',
    tags: string = '[]',
    aiAnalysis: string = '{}',
    isPinned: number = 0,
    createdAt: number = Date.now(),
    updatedAt: number = Date.now()
  ) {
    this.id = id;
    this.content = content;
    this.emotion = emotion;
    this.tags = tags;
    this.aiAnalysis = aiAnalysis;
    this.isPinned = isPinned;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  getParsedTags(): string[] {
    try {
      if (!this.tags || this.tags.length === 0) {
        return [];
      }
      const parsed: string[] = JSON.parse(this.tags) as string[];
      if (Array.isArray(parsed)) {
        return parsed;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  toRdbValues(): relationalStore.ValuesBucket {
    const values: relationalStore.ValuesBucket = {
      'content': this.content,
      'emotion': this.emotion,
      'tags': this.tags,
      'aiAnalysis': this.aiAnalysis,
      'isPinned': this.isPinned,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    };
    if (this.id > 0) {
      values['id'] = this.id;
    }
    return values;
  }

  static fromRdbValues(values: relationalStore.ValuesBucket): Inspiration {
    return new Inspiration(
      values['id'] as number ?? 0,
      values['content'] as string ?? '',
      values['emotion'] as string ?? '',
      values['tags'] as string ?? '[]',
      values['aiAnalysis'] as string ?? '{}',
      values['isPinned'] as number ?? 0,
      values['createdAt'] as number ?? Date.now(),
      values['updatedAt'] as number ?? Date.now()
    );
  }
}
