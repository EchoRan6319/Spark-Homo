import { router } from '@kit.ArkUI';
import { SparkProject } from '../../data/models/SparkProject';
import { SparkTask } from '../../data/models/SparkTask';
import { ProjectViewModel } from '../../viewmodels/ProjectViewModel';

@Entry
@Component
struct ProjectDetailPage {
  @State viewModel: ProjectViewModel = new ProjectViewModel();
  @State projectId: number = 0;
  @State inspirationId: number = 0;
  @State newTaskTitle: string = '';
  @State isNewProject: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, number | string>;
    if (params) {
      if (params.id) {
        this.projectId = params.id as number;
        this.loadProjectDetail();
      } else if (params.inspirationId) {
        this.inspirationId = params.inspirationId as number;
        this.isNewProject = true;
        this.createProjectFromInspiration((params.title as string) || '新项目');
      }
    }
  }

  async loadProjectDetail(): Promise<void> {
    await this.viewModel.loadProjectDetail(this.projectId);
  }

  async createProjectFromInspiration(title: string): Promise<void> {
    const projectId = await this.viewModel.convertInspirationToProject(this.inspirationId, title);
    this.projectId = projectId;
    await this.loadProjectDetail();
  }

  async addTask(): Promise<void> {
    if (!this.newTaskTitle.trim() || !this.viewModel.currentProject) return;

    const task = new SparkTask();
    task.projectId = this.viewModel.currentProject.id;
    task.title = this.newTaskTitle.trim();
    task.isCompleted = 0;

    await this.viewModel.addTask(task);
    this.newTaskTitle = '';
  }

  async toggleTask(task: SparkTask): Promise<void> {
    await this.viewModel.toggleTaskComplete(task.id);
  }

  async deleteTask(taskId: number): Promise<void> {
    await this.viewModel.deleteTask(taskId);
  }

  build() {
    Column() {
      this.buildHeader()

      if (this.viewModel.currentProject) {
        Scroll() {
          Column() {
            this.buildProjectInfo()
            this.buildTaskList()
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)

        this.buildAddTaskInput()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding({
      top: AppStorage.get<number>('statusBarHeight') || 0,
      bottom: 16
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Button('←')
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.text_primary'))
        .constraintSize({ minWidth: 44 })
        .onClick(() => {
          router.back();
        })

      Text(this.viewModel.currentProject?.title || '项目详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('')
        .constraintSize({ minWidth: 44 })
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildProjectInfo() {
    Column() {
      Row() {
        Column() {
          Text(`${this.viewModel.currentProject?.progress || 0}%`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary'))

          Text('完成度')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        this.buildStatusSelector()
      }
      .width('100%')
      .margin({ bottom: 16 })

      Progress({ value: this.viewModel.currentProject?.progress || 0, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(8)
        .color($r('app.color.primary'))
        .backgroundColor($r('app.color.divider'))
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .margin({ bottom: 16 })
  }

  @Builder
  buildStatusSelector() {
    Row() {
      Button('进行中')
        .fontSize(12)
        .backgroundColor(this.viewModel.currentProject?.status === 'active' ? $r('app.color.primary') : $r('app.color.secondary_button'))
        .fontColor(this.viewModel.currentProject?.status === 'active' ? Color.White : $r('app.color.text_secondary'))
        .height(32)
        .onClick(() => {
          if (this.viewModel.currentProject) {
            this.viewModel.currentProject.status = 'active';
            this.viewModel.updateProject(this.viewModel.currentProject);
          }
        })

      Button('已暂停')
        .fontSize(12)
        .backgroundColor(this.viewModel.currentProject?.status === 'paused' ? $r('app.color.warning') : $r('app.color.secondary_button'))
        .fontColor(this.viewModel.currentProject?.status === 'paused' ? Color.White : $r('app.color.text_secondary'))
        .height(32)
        .margin({ left: 8 })
        .onClick(() => {
          if (this.viewModel.currentProject) {
            this.viewModel.currentProject.status = 'paused';
            this.viewModel.updateProject(this.viewModel.currentProject);
          }
        })

      Button('已完成')
        .fontSize(12)
        .backgroundColor(this.viewModel.currentProject?.status === 'completed' ? $r('app.color.success') : $r('app.color.secondary_button'))
        .fontColor(this.viewModel.currentProject?.status === 'completed' ? Color.White : $r('app.color.text_secondary'))
        .height(32)
        .margin({ left: 8 })
        .onClick(() => {
          if (this.viewModel.currentProject) {
            this.viewModel.currentProject.status = 'completed';
            this.viewModel.updateProject(this.viewModel.currentProject);
          }
        })
    }
  }

  @Builder
  buildTaskList() {
    Column() {
      Text('任务列表')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      if (this.viewModel.currentTasks.length === 0) {
        Column() {
          Text('📝')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('还没有任务')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .padding(32)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
      } else {
        List() {
          ForEach(this.viewModel.currentTasks, (task: SparkTask) => {
            ListItem() {
              this.buildTaskItem(task)
            }
            .swipeAction({ end: this.buildDeleteTaskAction(task.id) })
            .margin({ bottom: 8 })
          })
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  buildTaskItem(task: SparkTask) {
    Row() {
      Checkbox()
        .select(task.isCompleted === 1)
        .selectedColor($r('app.color.primary'))
        .width(20)
        .height(20)
        .onChange((value: boolean) => {
          this.toggleTask(task);
        })

      if (task.isPinned === 1) {
        Text('📌')
          .fontSize(12)
          .margin({ left: 8 })
      }

      Text(task.title)
        .fontSize(15)
        .fontColor(task.isCompleted === 1 ? $r('app.color.text_secondary') : $r('app.color.text_primary'))
        .decoration({ type: task.isCompleted === 1 ? TextDecorationType.LineThrough : TextDecorationType.None })
        .margin({ left: 8 })
        .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .bindMenu([
      {
        value: task.isPinned === 1 ? '取消置顶' : '置顶',
        action: () => {
          this.viewModel.togglePinTask(task);
        }
      },
      {
        value: '删除',
        action: () => {
          this.viewModel.deleteTask(task.id);
        }
      }
    ])
  }

  @Builder
  buildDeleteTaskAction(taskId: number) {
    Row() {
      Button() {
        Text('删除')
          .fontColor(Color.White)
          .fontSize(14)
      }
      .type(ButtonType.Capsule)
      .backgroundColor($r('app.color.error'))
      .height(40)
      .onClick(() => {
        this.deleteTask(taskId);
      })
    }
    .padding({ left: 8 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildAddTaskInput() {
    Row() {
      TextInput({ placeholder: '添加新任务...', text: $$this.newTaskTitle })
        .placeholderColor($r('app.color.text_secondary'))
        .fontSize(15)
        .height(48)
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(12)
        .layoutWeight(1)
        .onSubmit(() => {
          this.addTask();
        })

      Button('添加')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.primary'))
        .height(48)
        .margin({ left: 12 })
        .onClick(() => {
          this.addTask();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
  }
}