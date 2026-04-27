import { router } from '@kit.ArkUI';
import { ProjectViewModel } from '../../viewmodels/ProjectViewModel';
import { SparkProject } from '../../data/models/SparkProject';

@Builder
function EmptyDialogBuilder() {}

@CustomDialog
struct AddProjectDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: EmptyDialogBuilder })
  onConfirm: (title: string, description: string) => void = () => {}
  @State projectTitle: string = '';
  @State projectDescription: string = '';

  build() {
    Column() {
      Text('创建项目')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      TextInput({ placeholder: '请输入项目标题', text: $$this.projectTitle })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(12)
        .padding(12)
        .width('100%')
        .margin({ bottom: 12 })

      TextInput({ placeholder: '项目描述（可选）', text: $$this.projectDescription })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(12)
        .padding(12)
        .width('100%')
        .margin({ bottom: 20 })

      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor($r('app.color.secondary_button'))
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .height(44)
          .borderRadius(12)
          .onClick(() => {
            this.controller.close();
          })

        Button('创建')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.primary'))
          .layoutWeight(1)
          .height(44)
          .borderRadius(12)
          .margin({ left: 12 })
          .onClick(() => {
            if (this.projectTitle.trim()) {
              this.onConfirm(this.projectTitle.trim(), this.projectDescription.trim());
              this.controller.close();
            }
          })
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
  }
}

@Component
export struct ProjectListPage {
  @State viewModel: ProjectViewModel = new ProjectViewModel();
  @StorageProp('dataVersion') @Watch('onDataVersionChange') dataVersion: number = 0;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddProjectDialog({
      onConfirm: (title: string, description: string) => {
        this.createProject(title, description);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true,
    autoCancel: true
  })

  onDataVersionChange(): void {
    this.viewModel.loadProjects();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildProjectList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding({
      top: AppStorage.get<number>('statusBarHeight') || 0,
      bottom: 16
    })
    .onAppear(() => {
      this.viewModel.loadProjects();
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Text('项目')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Blank()

      Button('➕')
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.dialogController.open();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    .margin({ left: 16, right: 16 })
  }

  @Builder
  buildProjectList() {
    if (this.viewModel.projects.length === 0) {
      Column() {
        Text('📁')
          .fontSize(64)
          .margin({ bottom: 16 })
        Text('还没有项目')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 8 })
        Text('点击右上角创建你的第一个项目')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.viewModel.projects, (project: SparkProject) => {
          ListItem() {
            this.buildProjectCard(project)
          }
          .padding({ left: 16, right: 16, bottom: 12 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto)
      .padding({ bottom: 80 })
    }
  }

  @Builder
  buildProjectCard(project: SparkProject) {
    Column() {
      Row() {
        Column() {
          Row() {
            if (project.isPinned === 1) {
              Text('📌')
                .fontSize(12)
                .margin({ right: 4 })
            }
            Text(project.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')

          if (project.description) {
            Text(project.description)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        this.buildStatusTag(project.status)

        Text('⋮')
          .fontSize(20)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
          .bindMenu([
            {
              value: project.isPinned === 1 ? '取消置顶' : '置顶',
              action: () => {
                this.viewModel.togglePinProject(project);
              }
            },
            {
              value: '删除',
              action: () => {
                this.viewModel.deleteProject(project.id);
              }
            }
          ], { placement: Placement.Bottom })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        Row() {
          Text(`${project.progress}%`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Blank()

          Text(`${this.getCompletedTasksCount(project.id)}/${this.getTotalTasksCount(project.id)} 任务`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .margin({ bottom: 4 })

        Progress({ value: project.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(6)
          .color($r('app.color.primary'))
          .backgroundColor($r('app.color.divider'))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .shadow({ radius: 8, color: $r('app.color.card_shadow'), offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/project/ProjectDetailPage',
        params: { id: project.id }
      }, router.RouterMode.Standard);
    })
  }

  @Builder
  buildStatusTag(status: string) {
    Text(this.getStatusLabel(status))
      .fontSize(11)
      .fontColor(this.getStatusColor(status))
      .backgroundColor(this.getStatusTagBackground(status))
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .borderRadius(4)
  }

  getStatusTagBackground(status: string): ResourceStr {
    switch (status) {
      case 'active':
        return $r('app.color.status_active_bg');
      case 'completed':
        return $r('app.color.status_completed_bg');
      case 'paused':
        return $r('app.color.status_paused_bg');
      default:
        return $r('app.color.status_active_bg');
    }
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case 'active':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'paused':
        return '已暂停';
      default:
        return '进行中';
    }
  }

  getStatusColor(status: string): ResourceStr {
    switch (status) {
      case 'active':
        return $r('app.color.primary');
      case 'completed':
        return $r('app.color.success');
      case 'paused':
        return $r('app.color.warning');
      default:
        return $r('app.color.primary');
    }
  }

  getCompletedTasksCount(projectId: number): number {
    return 0;
  }

  getTotalTasksCount(projectId: number): number {
    return 0;
  }

  async createProject(title: string, description: string): Promise<void> {
    const project = new SparkProject();
    project.title = title;
    project.description = description;
    project.status = 'active';
    project.progress = 0;
    await this.viewModel.createProject(project);
  }
}
