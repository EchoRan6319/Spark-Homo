import { Inspiration } from '../data/models/Inspiration';
import { SparkTask } from '../data/models/SparkTask';
import { InspirationRepository } from '../data/repositories/InspirationRepository';
import { ProjectRepository } from '../data/repositories/ProjectRepository';
import { DateUtil } from '../core/utils/DateUtil';

export class HomeViewModel {
  recentInspirations: Inspiration[] = [];
  todayTasks: SparkTask[] = [];

  private inspirationRepository: InspirationRepository;
  private projectRepository: ProjectRepository;

  constructor() {
    this.inspirationRepository = InspirationRepository.getInstance();
    this.projectRepository = ProjectRepository.getInstance();
  }

  async loadData(): Promise<void> {
    await this.loadRecentInspirations();
    await this.loadTodayTasks();
  }

  async loadRecentInspirations(): Promise<void> {
    try {
      const allInspirations = await this.inspirationRepository.getAll();
      this.recentInspirations = allInspirations
        .sort((a, b) => b.createdAt - a.createdAt)
        .slice(0, 3);
    } catch (err) {
      console.error(`Failed to load recent inspirations: ${JSON.stringify(err)}`);
      this.recentInspirations = [];
    }
  }

  async loadTodayTasks(): Promise<void> {
    try {
      const projects = await this.projectRepository.getAllProjects();
      let allTasks: SparkTask[] = [];
      for (const project of projects) {
        if (project.status === 'active') {
          const tasks = await this.projectRepository.getTasksByProjectId(project.id);
          allTasks = allTasks.concat(tasks.filter(task => task.isCompleted === 0));
        }
      }

      allTasks.sort((a, b) => {
        if (b.isPinned !== a.isPinned) {
          return b.isPinned - a.isPinned;
        }
        return b.createdAt - a.createdAt;
      });
      this.todayTasks = allTasks.slice(0, 5);
    } catch (err) {
      console.error(`Failed to load today tasks: ${JSON.stringify(err)}`);
      this.todayTasks = [];
    }
  }

  async togglePinTask(task: SparkTask): Promise<void> {
    try {
      if (task.isPinned === 1) {
        await this.projectRepository.unpinTask(task.id);
      } else {
        await this.projectRepository.pinTask(task.id);
      }
      await this.loadTodayTasks();
    } catch (err) {
      console.error(`Failed to toggle pin task: ${JSON.stringify(err)}`);
    }
  }

  async deleteTask(task: SparkTask): Promise<void> {
    try {
      await this.projectRepository.deleteTask(task.id);
      await this.loadTodayTasks();
    } catch (err) {
      console.error(`Failed to delete task: ${JSON.stringify(err)}`);
    }
  }

  async deleteInspiration(id: number): Promise<void> {
    try {
      await this.inspirationRepository.delete(id);
      await this.loadRecentInspirations();
    } catch (err) {
      console.error(`Failed to delete inspiration: ${JSON.stringify(err)}`);
      throw new Error(`Failed to delete inspiration: ${JSON.stringify(err)}`);
    }
  }
}
