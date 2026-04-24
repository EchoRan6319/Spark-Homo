import relationalStore from '@ohos.data.relationalStore';
import { SparkProject } from '../models/SparkProject';
import { SparkTask } from '../models/SparkTask';
import { RdbHelper } from '../datasources/RdbHelper';

export class ProjectRepository {
  private static instance: ProjectRepository | null = null;
  private readonly PROJECTS_TABLE = 'projects';
  private readonly TASKS_TABLE = 'tasks';

  private constructor() {}

  static getInstance(): ProjectRepository {
    if (!ProjectRepository.instance) {
      ProjectRepository.instance = new ProjectRepository();
    }
    return ProjectRepository.instance;
  }

  async insertProject(project: SparkProject): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const values = project.toRdbValues();
      const result = await rdbStore.insert(this.PROJECTS_TABLE, values);
      return result;
    } catch (err) {
      console.error('[ProjectRepository] insertProject failed: ' + JSON.stringify(err));
      throw new Error('Failed to insert project: ' + JSON.stringify(err));
    }
  }

  async updateProject(project: SparkProject): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const values = project.toRdbValues();
      const predicates = new relationalStore.RdbPredicates(this.PROJECTS_TABLE);
      predicates.equalTo('id', project.id);
      const result = await rdbStore.update(values, predicates);
      return result;
    } catch (err) {
      console.error('[ProjectRepository] updateProject failed: ' + JSON.stringify(err));
      throw new Error('Failed to update project: ' + JSON.stringify(err));
    }
  }

  async deleteProject(id: number): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.PROJECTS_TABLE);
      predicates.equalTo('id', id);
      const result = await rdbStore.delete(predicates);
      return result;
    } catch (err) {
      console.error('[ProjectRepository] deleteProject failed: ' + JSON.stringify(err));
      throw new Error('Failed to delete project: ' + JSON.stringify(err));
    }
  }

  async getProjectById(id: number): Promise<SparkProject | null> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.PROJECTS_TABLE);
      predicates.equalTo('id', id);
      const resultSet = await rdbStore.query(predicates);

      if (resultSet.goToFirstRow()) {
        const values = await this.parseResultSet(resultSet);
        resultSet.close();
        return SparkProject.fromRdbValues(values);
      }

      resultSet.close();
      return null;
    } catch (err) {
      console.error('[ProjectRepository] getProjectById failed: ' + JSON.stringify(err));
      throw new Error('Failed to get project: ' + JSON.stringify(err));
    }
  }

  async getAllProjects(): Promise<SparkProject[]> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.PROJECTS_TABLE);
      predicates.orderByDesc('isPinned');
      predicates.orderByDesc('createdAt');
      const resultSet = await rdbStore.query(predicates);

      const projects: SparkProject[] = [];
      while (resultSet.goToNextRow()) {
        const values = await this.parseResultSet(resultSet);
        projects.push(SparkProject.fromRdbValues(values));
      }

      resultSet.close();
      return projects;
    } catch (err) {
      console.error('[ProjectRepository] getAllProjects failed: ' + JSON.stringify(err));
      throw new Error('Failed to get all projects: ' + JSON.stringify(err));
    }
  }

  async pinProject(id: number): Promise<void> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.PROJECTS_TABLE);
      predicates.equalTo('id', id);
      const values: relationalStore.ValuesBucket = {
        'isPinned': 1,
        'updatedAt': Date.now()
      };
      await rdbStore.update(values, predicates);
    } catch (err) {
      console.error('[ProjectRepository] pinProject failed: ' + JSON.stringify(err));
      throw new Error('Failed to pin project: ' + JSON.stringify(err));
    }
  }

  async unpinProject(id: number): Promise<void> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.PROJECTS_TABLE);
      predicates.equalTo('id', id);
      const values: relationalStore.ValuesBucket = {
        'isPinned': 0,
        'updatedAt': Date.now()
      };
      await rdbStore.update(values, predicates);
    } catch (err) {
      console.error('[ProjectRepository] unpinProject failed: ' + JSON.stringify(err));
      throw new Error('Failed to unpin project: ' + JSON.stringify(err));
    }
  }

  async insertTask(task: SparkTask): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const values = task.toRdbValues();
      const result = await rdbStore.insert(this.TASKS_TABLE, values);
      return result;
    } catch (err) {
      console.error('[ProjectRepository] insertTask failed: ' + JSON.stringify(err));
      throw new Error('Failed to insert task: ' + JSON.stringify(err));
    }
  }

  async updateTask(task: SparkTask): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const values = task.toRdbValues();
      const predicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      predicates.equalTo('id', task.id);
      const result = await rdbStore.update(values, predicates);
      return result;
    } catch (err) {
      console.error('[ProjectRepository] updateTask failed: ' + JSON.stringify(err));
      throw new Error('Failed to update task: ' + JSON.stringify(err));
    }
  }

  async deleteTask(id: number): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      predicates.equalTo('id', id);
      const result = await rdbStore.delete(predicates);
      return result;
    } catch (err) {
      console.error('[ProjectRepository] deleteTask failed: ' + JSON.stringify(err));
      throw new Error('Failed to delete task: ' + JSON.stringify(err));
    }
  }

  async getTasksByProjectId(projectId: number): Promise<SparkTask[]> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      predicates.equalTo('projectId', projectId);
      predicates.orderByDesc('isPinned');
      predicates.orderByAsc('createdAt');
      const resultSet = await rdbStore.query(predicates);

      const tasks: SparkTask[] = [];
      while (resultSet.goToNextRow()) {
        const values = await this.parseResultSet(resultSet);
        tasks.push(SparkTask.fromRdbValues(values));
      }

      resultSet.close();
      return tasks;
    } catch (err) {
      console.error('[ProjectRepository] getTasksByProjectId failed: ' + JSON.stringify(err));
      throw new Error('Failed to get tasks: ' + JSON.stringify(err));
    }
  }

  async pinTask(id: number): Promise<void> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      predicates.equalTo('id', id);
      const values: relationalStore.ValuesBucket = {
        'isPinned': 1,
        'updatedAt': Date.now()
      };
      await rdbStore.update(values, predicates);
    } catch (err) {
      console.error('[ProjectRepository] pinTask failed: ' + JSON.stringify(err));
      throw new Error('Failed to pin task: ' + JSON.stringify(err));
    }
  }

  async unpinTask(id: number): Promise<void> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      predicates.equalTo('id', id);
      const values: relationalStore.ValuesBucket = {
        'isPinned': 0,
        'updatedAt': Date.now()
      };
      await rdbStore.update(values, predicates);
    } catch (err) {
      console.error('[ProjectRepository] unpinTask failed: ' + JSON.stringify(err));
      throw new Error('Failed to unpin task: ' + JSON.stringify(err));
    }
  }

  async getTaskCount(projectId: number): Promise<TaskCountResult> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();

      const totalPredicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      totalPredicates.equalTo('projectId', projectId);
      const totalResultSet = await rdbStore.query(totalPredicates);
      const total = totalResultSet.rowCount;
      totalResultSet.close();

      const completedPredicates = new relationalStore.RdbPredicates(this.TASKS_TABLE);
      completedPredicates.equalTo('projectId', projectId)
        .and()
        .equalTo('isCompleted', 1);
      const completedResultSet = await rdbStore.query(completedPredicates);
      const completed = completedResultSet.rowCount;
      completedResultSet.close();

      return { total, completed };
    } catch (err) {
      console.error('[ProjectRepository] getTaskCount failed: ' + JSON.stringify(err));
      throw new Error('Failed to get task count: ' + JSON.stringify(err));
    }
  }

  private async parseResultSet(resultSet: relationalStore.ResultSet): Promise<relationalStore.ValuesBucket> {
    const values: relationalStore.ValuesBucket = {};
    const columnNames = resultSet.columnNames;

    for (let i = 0; i < columnNames.length; i++) {
      const columnName = columnNames[i];
      const index = resultSet.getColumnIndex(columnName);
      const columnType = await resultSet.getColumnType(index);

      if (columnType === 1) {
        values[columnName] = resultSet.getLong(index);
      } else if (columnType === 2) {
        values[columnName] = resultSet.getDouble(index);
      } else if (columnType === 3) {
        values[columnName] = resultSet.getString(index);
      } else if (columnType === 4) {
        values[columnName] = resultSet.getBlob(index);
      }
    }

    return values;
  }
}

export interface TaskCountResult {
  total: number;
  completed: number;
}