import relationalStore from '@ohos.data.relationalStore';

export class SparkTask {
  id: number;
  projectId: number;
  title: string;
  isCompleted: number;
  isPinned: number;
  createdAt: number;
  updatedAt: number;

  constructor(
    id: number = 0,
    projectId: number = 0,
    title: string = '',
    isCompleted: number = 0,
    isPinned: number = 0,
    createdAt: number = Date.now(),
    updatedAt: number = Date.now()
  ) {
    this.id = id;
    this.projectId = projectId;
    this.title = title;
    this.isCompleted = isCompleted;
    this.isPinned = isPinned;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  toRdbValues(): relationalStore.ValuesBucket {
    const values: relationalStore.ValuesBucket = {
      'projectId': this.projectId,
      'title': this.title,
      'isCompleted': this.isCompleted,
      'isPinned': this.isPinned,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    };
    if (this.id > 0) {
      values['id'] = this.id;
    }
    return values;
  }

  static fromRdbValues(values: relationalStore.ValuesBucket): SparkTask {
    return new SparkTask(
      values['id'] as number ?? 0,
      values['projectId'] as number ?? 0,
      values['title'] as string ?? '',
      values['isCompleted'] as number ?? 0,
      values['isPinned'] as number ?? 0,
      values['createdAt'] as number ?? Date.now(),
      values['updatedAt'] as number ?? Date.now()
    );
  }
}
