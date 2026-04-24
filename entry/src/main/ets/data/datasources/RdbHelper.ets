import relationalStore from '@ohos.data.relationalStore';
import { Context } from '@kit.AbilityKit';

export class RdbHelper {
  private static instance: RdbHelper | null = null;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly DATABASE_NAME = 'spark.db';
  private readonly DATABASE_VERSION = 1;

  private constructor() {}

  static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  async init(context: Context): Promise<void> {
    if (this.rdbStore) {
      return;
    }

    const config: relationalStore.StoreConfig = {
      name: this.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      await this.migrateTables();
      await this.rdbStore.executeSql(`PRAGMA user_version = ${this.DATABASE_VERSION}`);
    } catch (err) {
      console.error(`[RdbHelper] init failed: ${JSON.stringify(err)}`);
      throw new Error(`Failed to init RdbHelper: ${JSON.stringify(err)}`);
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('[RdbHelper] RdbStore not initialized');
    }

    const createInspirationsTable = `
      CREATE TABLE IF NOT EXISTS inspirations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        emotion TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '[]',
        aiAnalysis TEXT NOT NULL DEFAULT '{}',
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    `;

    const createProjectsTable = `
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inspirationId INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        progress INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (inspirationId) REFERENCES inspirations(id) ON DELETE SET NULL
      )
    `;

    const createTasksTable = `
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    `;

    try {
      await this.rdbStore.executeSql(createInspirationsTable);
      await this.rdbStore.executeSql(createProjectsTable);
      await this.rdbStore.executeSql(createTasksTable);
    } catch (err) {
      console.error(`[RdbHelper] createTables failed: ${JSON.stringify(err)}`);
      throw new Error(`Failed to create tables: ${JSON.stringify(err)}`);
    }
  }

  private async migrateTables(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }

    try {
      const inspirationResultSet = await this.rdbStore.querySql(
        "PRAGMA table_info('inspirations')"
      );
      let hasTagsColumn = false;
      let hasInspirationPinnedColumn = false;
      while (inspirationResultSet.goToNextRow()) {
        const columnName = inspirationResultSet.getString(inspirationResultSet.getColumnIndex('name'));
        if (columnName === 'tags') {
          hasTagsColumn = true;
        }
        if (columnName === 'isPinned') {
          hasInspirationPinnedColumn = true;
        }
      }
      inspirationResultSet.close();

      if (!hasTagsColumn) {
        await this.rdbStore.executeSql(
          "ALTER TABLE inspirations ADD COLUMN tags TEXT NOT NULL DEFAULT '[]'"
        );
      }

      if (!hasInspirationPinnedColumn) {
        await this.rdbStore.executeSql(
          "ALTER TABLE inspirations ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0"
        );
      }

      const projectResultSet = await this.rdbStore.querySql(
        "PRAGMA table_info('projects')"
      );
      let hasPinnedColumn = false;
      while (projectResultSet.goToNextRow()) {
        const columnName = projectResultSet.getString(projectResultSet.getColumnIndex('name'));
        if (columnName === 'isPinned') {
          hasPinnedColumn = true;
          break;
        }
      }
      projectResultSet.close();

      if (!hasPinnedColumn) {
        await this.rdbStore.executeSql(
          "ALTER TABLE projects ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0"
        );
      }

      const taskResultSet = await this.rdbStore.querySql(
        "PRAGMA table_info('tasks')"
      );
      let hasTaskPinnedColumn = false;
      while (taskResultSet.goToNextRow()) {
        const columnName = taskResultSet.getString(taskResultSet.getColumnIndex('name'));
        if (columnName === 'isPinned') {
          hasTaskPinnedColumn = true;
          break;
        }
      }
      taskResultSet.close();

      if (!hasTaskPinnedColumn) {
        await this.rdbStore.executeSql(
          "ALTER TABLE tasks ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0"
        );
      }
    } catch (err) {
      console.error(`[RdbHelper] migrateTables failed: ${JSON.stringify(err)}`);
    }
  }

  async onUpgrade(oldVersion: number, newVersion: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('[RdbHelper] RdbStore not initialized');
    }

    console.info(`[RdbHelper] onUpgrade from ${oldVersion} to ${newVersion}`);

    if (oldVersion < 2) {
      // Example: add new column in version 2
    }
  }

  async getRdbStore(): Promise<relationalStore.RdbStore> {
    if (!this.rdbStore) {
      throw new Error('[RdbHelper] RdbStore not initialized. Call init(context) first.');
    }
    return this.rdbStore;
  }

  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }
}
