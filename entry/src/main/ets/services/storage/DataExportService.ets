import { Context } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { ProjectRepository } from '../../data/repositories/ProjectRepository';
import { SettingsService } from './SettingsService';
import { RdbHelper } from '../../data/datasources/RdbHelper';

interface ExportData {
  version: number;
  inspirations: InspirationData[];
  projects: ProjectData[];
  tasks: TaskData[];
  settings: Record<string, string>;
}

interface InspirationData {
  id: number;
  content: string;
  emotion: string;
  tags: string;
  aiAnalysis: string;
  isPinned: number;
  createdAt: number;
  updatedAt: number;
}

interface ProjectData {
  id: number;
  inspirationId: number;
  title: string;
  description: string;
  progress: number;
  status: string;
  isPinned: number;
  createdAt: number;
  updatedAt: number;
}

interface TaskData {
  id: number;
  projectId: number;
  title: string;
  isCompleted: number;
  isPinned: number;
  createdAt: number;
  updatedAt: number;
}

export class DataExportService {
  private static instance: DataExportService | null = null;
  private inspirationRepository: InspirationRepository;
  private projectRepository: ProjectRepository;
  private settingsService: SettingsService;

  private constructor() {
    this.inspirationRepository = InspirationRepository.getInstance();
    this.projectRepository = ProjectRepository.getInstance();
    this.settingsService = SettingsService.getInstance();
  }

  static getInstance(): DataExportService {
    if (!DataExportService.instance) {
      DataExportService.instance = new DataExportService();
    }
    return DataExportService.instance;
  }

  async exportData(context: Context): Promise<void> {
    const inspirations = await this.inspirationRepository.getAll();
    const projects = await this.projectRepository.getAllProjects();

    const allTasks: TaskData[] = [];
    for (let i = 0; i < projects.length; i++) {
      const tasks = await this.projectRepository.getTasksByProjectId(projects[i].id);
      for (let j = 0; j < tasks.length; j++) {
        const t: TaskData = {
          id: tasks[j].id,
          projectId: tasks[j].projectId,
          title: tasks[j].title,
          isCompleted: tasks[j].isCompleted,
          isPinned: tasks[j].isPinned,
          createdAt: tasks[j].createdAt,
          updatedAt: tasks[j].updatedAt
        };
        allTasks.push(t);
      }
    }

    const settings: Record<string, string> = {};
    settings['currentPresetName'] = await this.settingsService.getCurrentPresetName();
    settings['apiKey'] = await this.settingsService.getApiKey();
    settings['baseUrl'] = await this.settingsService.getBaseUrl();
    settings['model'] = await this.settingsService.getModel();
    settings['themeMode'] = await this.settingsService.getThemeMode();
    settings['preferredModel'] = await this.settingsService.getPreferredModel();
    settings['customPresets'] = JSON.stringify(await this.settingsService.getCustomPresets());

    const inspData: InspirationData[] = [];
    for (let i = 0; i < inspirations.length; i++) {
      const d: InspirationData = {
        id: inspirations[i].id,
        content: inspirations[i].content,
        emotion: inspirations[i].emotion,
        tags: inspirations[i].tags,
        aiAnalysis: inspirations[i].aiAnalysis,
        isPinned: inspirations[i].isPinned,
        createdAt: inspirations[i].createdAt,
        updatedAt: inspirations[i].updatedAt
      };
      inspData.push(d);
    }

    const projData: ProjectData[] = [];
    for (let i = 0; i < projects.length; i++) {
      const d: ProjectData = {
        id: projects[i].id,
        inspirationId: projects[i].inspirationId ?? 0,
        title: projects[i].title,
        description: projects[i].description,
        progress: projects[i].progress,
        status: projects[i].status,
        isPinned: projects[i].isPinned,
        createdAt: projects[i].createdAt,
        updatedAt: projects[i].updatedAt
      };
      projData.push(d);
    }

    const exportData: ExportData = {
      version: 1,
      inspirations: inspData,
      projects: projData,
      tasks: allTasks,
      settings: settings
    };

    const sandboxDir: string = context.getApplicationContext().tempDir;
    const jsonPath: string = sandboxDir + '/spark_data.json';

    const jsonStr: string = JSON.stringify(exportData);
    const jsonFile: fs.File = fs.openSync(jsonPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    fs.writeSync(jsonFile.fd, jsonStr);
    fs.closeSync(jsonFile.fd);

    const documentPicker = new picker.DocumentViewPicker(context);
    const uris: string[] = await documentPicker.save(undefined);

    if (uris && uris.length > 0) {
      const destUri: string = uris[0];
      const stat: fs.Stat = fs.statSync(jsonPath);
      const srcFile: fs.File = fs.openSync(jsonPath, fs.OpenMode.READ_ONLY);
      const destFile: fs.File = fs.openSync(destUri, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      const buf: ArrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(srcFile.fd, buf);
      fs.writeSync(destFile.fd, buf);
      fs.closeSync(srcFile.fd);
      fs.closeSync(destFile.fd);
    }

    try {
      fs.unlinkSync(jsonPath);
    } catch {}
  }

  async importData(context: Context): Promise<string> {
    const documentPicker = new picker.DocumentViewPicker(context);
    const uris: string[] = await documentPicker.select(undefined);

    if (!uris || uris.length === 0) {
      return '已取消';
    }

    const zipUri: string = uris[0];
    const sandboxDir: string = context.getApplicationContext().tempDir;
    const destPath: string = sandboxDir + '/import_data.json';

    const srcFile: fs.File = fs.openSync(zipUri, fs.OpenMode.READ_ONLY);
    const destFile: fs.File = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    const stat: fs.Stat = fs.statSync(zipUri);
    const buf: ArrayBuffer = new ArrayBuffer(stat.size);
    fs.readSync(srcFile.fd, buf);
    fs.writeSync(destFile.fd, buf);
    fs.closeSync(srcFile.fd);
    fs.closeSync(destFile.fd);

    const jsonFile: fs.File = fs.openSync(destPath, fs.OpenMode.READ_ONLY);
    const jsonStat: fs.Stat = fs.statSync(destPath);
    const jsonBuf: ArrayBuffer = new ArrayBuffer(jsonStat.size);
    fs.readSync(jsonFile.fd, jsonBuf);
    fs.closeSync(jsonFile.fd);

    const uint8Array: Uint8Array = new Uint8Array(jsonBuf);
    let jsonStr: string = '';
    for (let i = 0; i < uint8Array.length; i++) {
      jsonStr += String.fromCharCode(uint8Array[i]);
    }

    const importData: ExportData = JSON.parse(jsonStr);

    if (!importData.inspirations || !importData.projects || !importData.tasks) {
      throw new Error('无效的数据文件');
    }

    const rdbStore = await RdbHelper.getInstance().getRdbStore();
    await rdbStore.executeSql('DELETE FROM tasks');
    await rdbStore.executeSql('DELETE FROM projects');
    await rdbStore.executeSql('DELETE FROM inspirations');

    for (let i = 0; i < importData.inspirations.length; i++) {
      const insp = importData.inspirations[i];
      await rdbStore.executeSql(
        'INSERT INTO inspirations (id, content, emotion, tags, aiAnalysis, isPinned, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [insp.id, insp.content, insp.emotion, insp.tags, insp.aiAnalysis, insp.isPinned, insp.createdAt, insp.updatedAt]
      );
    }

    for (let i = 0; i < importData.projects.length; i++) {
      const proj = importData.projects[i];
      const hasInspiration: number = proj.inspirationId ? proj.inspirationId : 0;
      await rdbStore.executeSql(
        'INSERT INTO projects (id, inspirationId, title, description, progress, status, isPinned, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [proj.id, hasInspiration, proj.title, proj.description, proj.progress, proj.status, proj.isPinned, proj.createdAt, proj.updatedAt]
      );
    }

    for (let i = 0; i < importData.tasks.length; i++) {
      const task = importData.tasks[i];
      await rdbStore.executeSql(
        'INSERT INTO tasks (id, projectId, title, isCompleted, isPinned, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [task.id, task.projectId, task.title, task.isCompleted, task.isPinned, task.createdAt, task.updatedAt]
      );
    }

    if (importData.settings) {
      const s = importData.settings;
      if (s['currentPresetName']) {
        await this.settingsService.setCurrentPresetName(s['currentPresetName']);
      }
      if (s['apiKey']) {
        await this.settingsService.setApiKey(s['apiKey']);
      }
      if (s['baseUrl']) {
        await this.settingsService.setBaseUrl(s['baseUrl']);
      }
      if (s['model']) {
        await this.settingsService.setModel(s['model']);
      }
      if (s['themeMode']) {
        await this.settingsService.setThemeMode(s['themeMode']);
      }
      if (s['customPresets']) {
        await this.settingsService.saveCustomPresets(JSON.parse(s['customPresets']));
      }
    }

    try {
      fs.unlinkSync(destPath);
    } catch {}

    return '导入成功';
  }
}
