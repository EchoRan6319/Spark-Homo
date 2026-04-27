import { Router, router } from '@kit.ArkUI';
import { HomeViewModel } from '../../viewmodels/HomeViewModel';
import { Inspiration } from '../../data/models/Inspiration';
import { SparkTask } from '../../data/models/SparkTask';
import { DateUtil } from '../../core/utils/DateUtil';
import { EmotionMapper } from '../../core/utils/EmotionMapper';

@Component
export struct HomePage {
  @State viewModel: HomeViewModel = new HomeViewModel();
  @StorageProp('dataVersion') @Watch('onDataVersionChange') dataVersion: number = 0;

  onDataVersionChange(): void {
    this.viewModel.loadData();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildRecentInspirations()
      this.buildQuickActions()
      this.buildTodayTasks()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding({
      top: AppStorage.get<number>('statusBarHeight') || 0,
      left: 16,
      right: 16,
      bottom: 16
    })
    .onAppear(() => {
      this.viewModel.loadData();
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('灵光')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(DateUtil.formatDate(DateUtil.now()))
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button('➕')
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.text_primary'))
        .onClick(() => {
          router.pushUrl({ url: 'pages/inspiration/CapturePage' });
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  buildRecentInspirations() {
    Column() {
      Text('最近灵感')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      if (this.viewModel.recentInspirations.length === 0) {
        this.buildEmptyState()
      } else {
        Swiper() {
          ForEach(this.viewModel.recentInspirations.slice(0, 3), (inspiration: Inspiration) => {
            this.buildInspirationCard(inspiration)
          })
        }
        .height(140)
        .indicator(true)
        .loop(false)
        .itemSpace(12)
      }
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  buildInspirationCard(inspiration: Inspiration) {
    Column() {
      Row() {
        Text(EmotionMapper.getIcon(inspiration.emotion))
          .fontSize(24)
        Text(DateUtil.format(inspiration.createdAt))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(inspiration.content)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 8 })

      if (inspiration.getParsedTags().length > 0) {
        Row() {
          ForEach(inspiration.getParsedTags().slice(0, 3), (tag: string) => {
            Text(tag)
              .fontSize(11)
              .fontColor($r('app.color.primary'))
              .backgroundColor($r('app.color.tag_background'))
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 6 })
          })
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .shadow({ radius: 8, color: $r('app.color.card_shadow'), offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/inspiration/InspirationDetailPage',
        params: { id: inspiration.id }
      });
    })
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('💭')
        .fontSize(48)
        .margin({ bottom: 12 })
      Text('记录你的第一个灵感吧')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .height(140)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .onClick(() => {
      router.pushUrl({ url: 'pages/inspiration/CapturePage' });
    })
  }

  @Builder
  buildQuickActions() {
    Column() {
      Text('快捷操作')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        Button('✨ 捕捉灵感')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.primary'))
          .width('48%')
          .height(48)
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/inspiration/CapturePage' });
          })

        Button('📁 查看项目')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.secondary_button'))
          .fontColor($r('app.color.text_primary'))
          .width('48%')
          .height(48)
          .borderRadius(12)
          .onClick(() => {
            AppStorage.setOrCreate<number>('switchToTab', 2);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  buildTodayTasks() {
    Column() {
      Text('今日待办')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      if (this.viewModel.todayTasks.length === 0) {
        Text('今天没有待办任务，享受美好的一天吧！')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
      } else {
        Column() {
          ForEach(this.viewModel.todayTasks.slice(0, 5), (task: SparkTask) => {
            Row() {
              if (task.isPinned === 1) {
                Text('📌')
                  .fontSize(12)
                  .margin({ right: 4 })
              }
              Text(task.title)
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
              Text(task.isCompleted === 1 ? '✓' : '○')
                .fontSize(16)
                .fontColor(task.isCompleted === 1 ? $r('app.color.success') : $r('app.color.text_secondary'))
                .width(32)
                .height(32)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  this.viewModel.toggleTaskComplete(task);
                })
            }
            .width('100%')
            .padding(12)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(8)
            .margin({ bottom: 8 })
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
                  this.viewModel.deleteTask(task);
                }
              }
            ])
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .margin({ bottom: 80 })
  }
}