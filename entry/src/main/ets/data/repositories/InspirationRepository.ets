import relationalStore from '@ohos.data.relationalStore';
import { Inspiration } from '../models/Inspiration';
import { RdbHelper } from '../datasources/RdbHelper';

export class InspirationRepository {
  private static instance: InspirationRepository | null = null;
  private readonly TABLE_NAME = 'inspirations';

  private constructor() {}

  static getInstance(): InspirationRepository {
    if (!InspirationRepository.instance) {
      InspirationRepository.instance = new InspirationRepository();
    }
    return InspirationRepository.instance;
  }

  async insert(inspiration: Inspiration): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const values = inspiration.toRdbValues();
      const result = await rdbStore.insert(this.TABLE_NAME, values);
      return result;
    } catch (err) {
      console.error('[InspirationRepository] insert failed: ' + JSON.stringify(err));
      throw new Error('Failed to insert inspiration: ' + JSON.stringify(err));
    }
  }

  async update(inspiration: Inspiration): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const values = inspiration.toRdbValues();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', inspiration.id);
      const result = await rdbStore.update(values, predicates);
      return result;
    } catch (err) {
      console.error('[InspirationRepository] update failed: ' + JSON.stringify(err));
      throw new Error('Failed to update inspiration: ' + JSON.stringify(err));
    }
  }

  async delete(id: number): Promise<number> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      const result = await rdbStore.delete(predicates);
      return result;
    } catch (err) {
      console.error('[InspirationRepository] delete failed: ' + JSON.stringify(err));
      throw new Error('Failed to delete inspiration: ' + JSON.stringify(err));
    }
  }

  async getById(id: number): Promise<Inspiration | null> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      const resultSet = await rdbStore.query(predicates);

      if (resultSet.goToFirstRow()) {
        const values = await this.parseResultSet(resultSet);
        resultSet.close();
        return Inspiration.fromRdbValues(values);
      }

      resultSet.close();
      return null;
    } catch (err) {
      console.error('[InspirationRepository] getById failed: ' + JSON.stringify(err));
      throw new Error('Failed to get inspiration: ' + JSON.stringify(err));
    }
  }

  async getAll(): Promise<Inspiration[]> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.orderByDesc('isPinned');
      predicates.orderByDesc('createdAt');
      const resultSet = await rdbStore.query(predicates);

      const inspirations: Inspiration[] = [];
      while (resultSet.goToNextRow()) {
        const values = await this.parseResultSet(resultSet);
        inspirations.push(Inspiration.fromRdbValues(values));
      }

      resultSet.close();
      return inspirations;
    } catch (err) {
      console.error('[InspirationRepository] getAll failed: ' + JSON.stringify(err));
      throw new Error('Failed to get all inspirations: ' + JSON.stringify(err));
    }
  }

  async search(keyword: string): Promise<Inspiration[]> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.like('content', '%' + keyword + '%')
        .or()
        .like('tags', '%' + keyword + '%');
      predicates.orderByDesc('isPinned');
      predicates.orderByDesc('createdAt');
      const resultSet = await rdbStore.query(predicates);

      const inspirations: Inspiration[] = [];
      while (resultSet.goToNextRow()) {
        const values = await this.parseResultSet(resultSet);
        inspirations.push(Inspiration.fromRdbValues(values));
      }

      resultSet.close();
      return inspirations;
    } catch (err) {
      console.error('[InspirationRepository] search failed: ' + JSON.stringify(err));
      throw new Error('Failed to search inspirations: ' + JSON.stringify(err));
    }
  }

  async filterByEmotion(emotion: string): Promise<Inspiration[]> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('emotion', emotion);
      predicates.orderByDesc('isPinned');
      predicates.orderByDesc('createdAt');
      const resultSet = await rdbStore.query(predicates);

      const inspirations: Inspiration[] = [];
      while (resultSet.goToNextRow()) {
        const values = await this.parseResultSet(resultSet);
        inspirations.push(Inspiration.fromRdbValues(values));
      }

      resultSet.close();
      return inspirations;
    } catch (err) {
      console.error('[InspirationRepository] filterByEmotion failed: ' + JSON.stringify(err));
      throw new Error('Failed to filter inspirations: ' + JSON.stringify(err));
    }
  }

  async pinInspiration(id: number): Promise<void> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      const values: relationalStore.ValuesBucket = {
        'isPinned': 1,
        'updatedAt': Date.now()
      };
      await rdbStore.update(values, predicates);
    } catch (err) {
      console.error('[InspirationRepository] pinInspiration failed: ' + JSON.stringify(err));
      throw new Error('Failed to pin inspiration: ' + JSON.stringify(err));
    }
  }

  async unpinInspiration(id: number): Promise<void> {
    try {
      const rdbStore = await RdbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id);
      const values: relationalStore.ValuesBucket = {
        'isPinned': 0,
        'updatedAt': Date.now()
      };
      await rdbStore.update(values, predicates);
    } catch (err) {
      console.error('[InspirationRepository] unpinInspiration failed: ' + JSON.stringify(err));
      throw new Error('Failed to unpin inspiration: ' + JSON.stringify(err));
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