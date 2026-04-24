import relationalStore from '@ohos.data.relationalStore';

export class SparkProject {
  id: number;
  inspirationId?: number;
  title: string;
  description: string;
  progress: number;
  status: string;
  isPinned: number;
  createdAt: number;
  updatedAt: number;

  constructor(
    id: number = 0,
    inspirationId?: number,
    title: string = '',
    description: string = '',
    progress: number = 0,
    status: string = 'active',
    isPinned: number = 0,
    createdAt: number = Date.now(),
    updatedAt: number = Date.now()
  ) {
    this.id = id;
    this.inspirationId = inspirationId;
    this.title = title;
    this.description = description;
    this.progress = progress;
    this.status = status;
    this.isPinned = isPinned;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  toRdbValues(): relationalStore.ValuesBucket {
    const values: relationalStore.ValuesBucket = {
      'title': this.title,
      'description': this.description,
      'progress': this.progress,
      'status': this.status,
      'isPinned': this.isPinned,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    };
    if (this.id > 0) {
      values['id'] = this.id;
    }
    if (this.inspirationId !== undefined) {
      values['inspirationId'] = this.inspirationId;
    }
    return values;
  }

  static fromRdbValues(values: relationalStore.ValuesBucket): SparkProject {
    return new SparkProject(
      values['id'] as number ?? 0,
      values['inspirationId'] as number ?? undefined,
      values['title'] as string ?? '',
      values['description'] as string ?? '',
      values['progress'] as number ?? 0,
      values['status'] as string ?? 'active',
      values['isPinned'] as number ?? 0,
      values['createdAt'] as number ?? Date.now(),
      values['updatedAt'] as number ?? Date.now()
    );
  }
}
