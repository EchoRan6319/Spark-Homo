import { SparkProject } from '../data/models/SparkProject';
import { SparkTask } from '../data/models/SparkTask';
import { ProjectRepository, TaskCountResult } from '../data/repositories/ProjectRepository';
import { InspirationRepository } from '../data/repositories/InspirationRepository';
import { DateUtil } from '../core/utils/DateUtil';

export class ProjectViewModel {
  projects: SparkProject[] = [];
  currentProject: SparkProject | null = null;
  currentTasks: SparkTask[] = [];
  taskCounts: Record<number, TaskCountResult> = {};

  private projectRepository: ProjectRepository;
  private inspirationRepository: InspirationRepository;

  constructor() {
    this.projectRepository = ProjectRepository.getInstance();
    this.inspirationRepository = InspirationRepository.getInstance();
  }

  async loadProjects(): Promise<void> {
    try {
      this.projects = await this.projectRepository.getAllProjects();
      this.projects.sort((a, b) => {
        if (b.isPinned !== a.isPinned) {
          return b.isPinned - a.isPinned;
        }
        return b.updatedAt - a.updatedAt;
      });

      // 加载每个项目的任务统计
      const counts: Record<number, TaskCountResult> = {};
      for (let i = 0; i < this.projects.length; i++) {
        const pid = this.projects[i].id;
        try {
          counts[pid] = await this.projectRepository.getTaskCount(pid);
        } catch {
          counts[pid] = { total: 0, completed: 0 };
        }
      }
      this.taskCounts = counts;
    } catch (err) {
      console.error(`Failed to load projects: ${JSON.stringify(err)}`);
      this.projects = [];
      this.taskCounts = {};
    }
  }

  async loadProjectDetail(projectId: number): Promise<void> {
    try {
      this.currentProject = await this.projectRepository.getProjectById(projectId);
      if (this.currentProject) {
        await this.loadTasks(projectId);
      }
    } catch (err) {
      console.error(`Failed to load project detail: ${JSON.stringify(err)}`);
      this.currentProject = null;
      this.currentTasks = [];
    }
  }

  async loadTasks(projectId: number): Promise<void> {
    try {
      this.currentTasks = await this.projectRepository.getTasksByProjectId(projectId);
      this.currentTasks.sort((a, b) => a.isCompleted - b.isCompleted || b.createdAt - a.createdAt);
    } catch (err) {
      console.error(`Failed to load tasks: ${JSON.stringify(err)}`);
      this.currentTasks = [];
    }
  }

  async createProject(project: SparkProject): Promise<number> {
    try {
      project.createdAt = DateUtil.now();
      project.updatedAt = DateUtil.now();
      const id = await this.projectRepository.insertProject(project);
      await this.loadProjects();
      return id;
    } catch (err) {
      console.error(`Failed to create project: ${JSON.stringify(err)}`);
      throw new Error(`Failed to create project: ${JSON.stringify(err)}`);
    }
  }

  async updateProject(project: SparkProject): Promise<void> {
    try {
      project.updatedAt = DateUtil.now();
      await this.projectRepository.updateProject(project);
      await this.loadProjects();
      if (this.currentProject?.id === project.id) {
        this.currentProject = project;
      }
    } catch (err) {
      console.error(`Failed to update project: ${JSON.stringify(err)}`);
      throw new Error(`Failed to update project: ${JSON.stringify(err)}`);
    }
  }

  async deleteProject(id: number): Promise<void> {
    try {
      await this.projectRepository.deleteProject(id);
      await this.loadProjects();
    } catch (err) {
      console.error(`Failed to delete project: ${JSON.stringify(err)}`);
      throw new Error(`Failed to delete project: ${JSON.stringify(err)}`);
    }
  }

  async togglePinProject(project: SparkProject): Promise<void> {
    try {
      if (project.isPinned === 1) {
        await this.projectRepository.unpinProject(project.id);
      } else {
        await this.projectRepository.pinProject(project.id);
      }
      await this.loadProjects();
    } catch (err) {
      console.error(`Failed to toggle pin project: ${JSON.stringify(err)}`);
    }
  }

  async togglePinTask(task: SparkTask): Promise<void> {
    try {
      if (task.isPinned === 1) {
        await this.projectRepository.unpinTask(task.id);
      } else {
        await this.projectRepository.pinTask(task.id);
      }
      await this.loadTasks(task.projectId);
    } catch (err) {
      console.error(`Failed to toggle pin task: ${JSON.stringify(err)}`);
    }
  }

  async addTask(task: SparkTask): Promise<number> {
    try {
      task.createdAt = DateUtil.now();
      task.updatedAt = DateUtil.now();
      const id = await this.projectRepository.insertTask(task);
      await this.recalculateProgress(task.projectId);
      await this.loadTasks(task.projectId);
      return id;
    } catch (err) {
      console.error(`Failed to add task: ${JSON.stringify(err)}`);
      throw new Error(`Failed to add task: ${JSON.stringify(err)}`);
    }
  }

  async updateTask(task: SparkTask): Promise<void> {
    try {
      task.updatedAt = DateUtil.now();
      await this.projectRepository.updateTask(task);
      await this.recalculateProgress(task.projectId);
      await this.loadTasks(task.projectId);
    } catch (err) {
      console.error(`Failed to update task: ${JSON.stringify(err)}`);
      throw new Error(`Failed to update task: ${JSON.stringify(err)}`);
    }
  }

  async deleteTask(id: number): Promise<void> {
    try {
      const task = this.currentTasks.find(t => t.id === id);
      if (task) {
        await this.projectRepository.deleteTask(id);
        await this.recalculateProgress(task.projectId);
        await this.loadTasks(task.projectId);
      }
    } catch (err) {
      console.error(`Failed to delete task: ${JSON.stringify(err)}`);
      throw new Error(`Failed to delete task: ${JSON.stringify(err)}`);
    }
  }

  async toggleTaskComplete(taskId: number): Promise<void> {
    try {
      const task = this.currentTasks.find(t => t.id === taskId);
      if (task) {
        task.isCompleted = task.isCompleted === 1 ? 0 : 1;
        task.updatedAt = DateUtil.now();
        await this.projectRepository.updateTask(task);
        await this.recalculateProgress(task.projectId);
        await this.loadTasks(task.projectId);
      }
    } catch (err) {
      console.error(`Failed to toggle task: ${JSON.stringify(err)}`);
      throw new Error(`Failed to toggle task: ${JSON.stringify(err)}`);
    }
  }

  async recalculateProgress(projectId: number): Promise<void> {
    try {
      const stats: TaskCountResult = await this.projectRepository.getTaskCount(projectId);
      const progress = stats.total > 0 ? Math.round((stats.completed / stats.total) * 100) : 0;

      const project = await this.projectRepository.getProjectById(projectId);
      if (project) {
        project.progress = progress;
        if (progress === 100 && project.status !== 'completed') {
          project.status = 'completed';
        }
        project.updatedAt = DateUtil.now();
        await this.projectRepository.updateProject(project);

        if (this.currentProject?.id === projectId) {
          this.currentProject = project;
        }
      }
    } catch (err) {
      console.error(`Failed to recalculate progress: ${JSON.stringify(err)}`);
    }
  }

  async convertInspirationToProject(inspirationId: number, title: string): Promise<number> {
    try {
      const inspiration = await this.inspirationRepository.getById(inspirationId);
      if (!inspiration) {
        throw new Error('Inspiration not found');
      }

      const project = new SparkProject();
      project.inspirationId = inspirationId;
      project.title = title;
      project.description = inspiration.content;
      project.progress = 0;
      project.status = 'active';
      project.createdAt = DateUtil.now();
      project.updatedAt = DateUtil.now();

      const projectId = await this.projectRepository.insertProject(project);

      const defaultTask = new SparkTask();
      defaultTask.projectId = projectId;
      defaultTask.title = '梳理灵感思路';
      defaultTask.isCompleted = 0;
      defaultTask.createdAt = DateUtil.now();
      defaultTask.updatedAt = DateUtil.now();
      await this.projectRepository.insertTask(defaultTask);

      await this.loadProjects();
      return projectId;
    } catch (err) {
      console.error(`Failed to convert inspiration to project: ${JSON.stringify(err)}`);
      throw new Error(`Failed to convert inspiration to project: ${JSON.stringify(err)}`);
    }
  }
}
