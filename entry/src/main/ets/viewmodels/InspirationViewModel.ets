import { Inspiration } from '../data/models/Inspiration';
import { InspirationRepository } from '../data/repositories/InspirationRepository';

export class InspirationViewModel {
  inspirations: Inspiration[] = [];
  filteredInspirations: Inspiration[] = [];
  searchKeyword: string = '';
  selectedEmotion: string = '';

  private inspirationRepository: InspirationRepository;

  constructor() {
    this.inspirationRepository = InspirationRepository.getInstance();
  }

  async loadInspirations(): Promise<void> {
    try {
      this.inspirations = await this.inspirationRepository.getAll();
      this.filterInspirations();
    } catch (err) {
      console.error(`Failed to load inspirations: ${JSON.stringify(err)}`);
      this.inspirations = [];
      this.filteredInspirations = [];
    }
  }

  filterInspirations(): void {
    let result = [...this.inspirations];

    if (this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.toLowerCase();
      result = result.filter(item =>
        item.content.toLowerCase().includes(keyword) ||
        item.tags.toLowerCase().includes(keyword)
      );
    }

    if (this.selectedEmotion) {
      result = result.filter(item => item.emotion === this.selectedEmotion);
    }

    result.sort((a, b) => {
      if (b.isPinned !== a.isPinned) {
        return b.isPinned - a.isPinned;
      }
      return b.createdAt - a.createdAt;
    });
    this.filteredInspirations = result;
  }

  async saveInspiration(inspiration: Inspiration): Promise<number> {
    try {
      if (inspiration.id > 0) {
        await this.inspirationRepository.update(inspiration);
        return inspiration.id;
      } else {
        return await this.inspirationRepository.insert(inspiration);
      }
    } catch (err) {
      console.error(`Failed to save inspiration: ${JSON.stringify(err)}`);
      throw new Error(`Failed to save inspiration: ${JSON.stringify(err)}`);
    }
  }

  async deleteInspiration(id: number): Promise<void> {
    try {
      await this.inspirationRepository.delete(id);
      await this.loadInspirations();
    } catch (err) {
      console.error(`Failed to delete inspiration: ${JSON.stringify(err)}`);
      throw new Error(`Failed to delete inspiration: ${JSON.stringify(err)}`);
    }
  }

  async togglePinInspiration(inspiration: Inspiration): Promise<void> {
    try {
      if (inspiration.isPinned === 1) {
        await this.inspirationRepository.unpinInspiration(inspiration.id);
      } else {
        await this.inspirationRepository.pinInspiration(inspiration.id);
      }
      await this.loadInspirations();
    } catch (err) {
      console.error(`Failed to toggle pin inspiration: ${JSON.stringify(err)}`);
    }
  }

  async getInspirationById(id: number): Promise<Inspiration | null> {
    try {
      return await this.inspirationRepository.getById(id);
    } catch (err) {
      console.error(`Failed to get inspiration: ${JSON.stringify(err)}`);
      return null;
    }
  }
}
