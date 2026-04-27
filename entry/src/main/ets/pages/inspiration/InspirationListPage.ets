import { router } from '@kit.ArkUI';
import { InspirationViewModel } from '../../viewmodels/InspirationViewModel';
import { Inspiration } from '../../data/models/Inspiration';
import { EmotionMapper, EmotionInfo } from '../../core/utils/EmotionMapper';
import { DateUtil } from '../../core/utils/DateUtil';

@Component
export struct InspirationListPage {
  @State viewModel: InspirationViewModel = new InspirationViewModel();
  @State searchText: string = '';
  @StorageProp('dataVersion') @Watch('onDataVersionChange') dataVersion: number = 0;

  onDataVersionChange(): void {
    this.viewModel.loadInspirations();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildSearchBar()
      this.buildEmotionFilter()
      this.buildInspirationList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding({
      top: AppStorage.get<number>('statusBarHeight') || 0,
      bottom: 16
    })
    .onAppear(() => {
      this.viewModel.loadInspirations();
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Text('灵感')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Blank()

      Button('➕')
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.text_primary'))
        .onClick(() => {
          router.pushUrl({ url: 'pages/inspiration/CapturePage' }, router.RouterMode.Standard);
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    .margin({ left: 16, right: 16 })
  }

  @Builder
  buildSearchBar() {
    Row() {
      TextInput({ placeholder: '搜索灵感内容或标签...', text: $$this.searchText })
        .placeholderColor($r('app.color.text_secondary'))
        .fontSize(14)
        .height(40)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .width('100%')
        .onChange((value: string) => {
          this.viewModel.searchKeyword = value;
          this.viewModel.filterInspirations();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 12 })
  }

  @Builder
  buildEmotionFilter() {
    Scroll() {
      Row() {
        this.buildEmotionChip('全部', '', true)
        ForEach(EmotionMapper.getEmotionList(), (emotion: EmotionInfo) => {
          this.buildEmotionChip(emotion.label, emotion.key, false)
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .margin({ bottom: 12 })
  }

  @Builder
  buildEmotionChip(label: string, key: string, isAll: boolean) {
    Text(label)
      .fontSize(13)
      .fontColor(this.viewModel.selectedEmotion === key ? Color.White : $r('app.color.text_primary'))
      .backgroundColor(this.viewModel.selectedEmotion === key ? $r('app.color.primary') : $r('app.color.card_background'))
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        this.viewModel.selectedEmotion = key;
        this.viewModel.filterInspirations();
      })
  }

  @Builder
  buildInspirationList() {
    if (this.viewModel.filteredInspirations.length === 0) {
      Column() {
        Text('💭')
          .fontSize(64)
          .margin({ bottom: 16 })
        Text('还没有灵感')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 8 })
        Text('点击右上角添加你的第一个灵感')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.viewModel.filteredInspirations, (inspiration: Inspiration) => {
          ListItem() {
            this.buildInspirationCard(inspiration)
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
  buildInspirationCard(inspiration: Inspiration) {
    Column() {
      Row() {
        Row() {
          if (inspiration.isPinned === 1) {
            Text('📌')
              .fontSize(12)
              .margin({ right: 4 })
          }
          Text(EmotionMapper.getIcon(inspiration.emotion))
            .fontSize(20)
            .margin({ right: 8 })
          Text(EmotionMapper.getLabel(inspiration.emotion))
            .fontSize(13)
            .fontColor(EmotionMapper.getColor(inspiration.emotion))
        }

        Blank()

        Text('⋮')
          .fontSize(20)
          .fontColor($r('app.color.text_secondary'))
          .bindMenu([
            {
              value: inspiration.isPinned === 1 ? '取消置顶' : '置顶',
              action: () => {
                this.viewModel.togglePinInspiration(inspiration);
              }
            },
            {
              value: '删除',
              action: () => {
                this.viewModel.deleteInspiration(inspiration.id);
              }
            }
          ], { placement: Placement.Bottom })

        Text(DateUtil.formatRelative(inspiration.createdAt))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
      }
      .width('100%')

      Text(inspiration.content)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 8, bottom: 8 })

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
      }, router.RouterMode.Standard);
    })
  }
}