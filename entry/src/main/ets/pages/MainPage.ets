import { router } from '@kit.ArkUI';
import { HomePage } from './home/HomePage';
import { InspirationListPage } from './inspiration/InspirationListPage';
import { ProjectListPage } from './project/ProjectListPage';
import { SettingsPage } from './settings/SettingsPage';

@Entry
@Component
struct MainPage {
  @State selectedTabIndex: number = 0;
  @StorageProp('dataVersion') dataVersion: number = 0;
  @StorageProp('switchToTab') @Watch('onSwitchTab') switchToTab: number = -1;

  onPageShow(): void {
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') || 0) + 1);
  }

  onSwitchTab(): void {
    if (this.switchToTab >= 0 && this.switchToTab <= 3) {
      this.selectedTabIndex = this.switchToTab;
      AppStorage.setOrCreate<number>('switchToTab', -1);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, index: this.selectedTabIndex }) {
        TabContent() {
          HomePage()
        }

        TabContent() {
          InspirationListPage()
        }

        TabContent() {
          ProjectListPage()
        }

        TabContent() {
          SettingsPage()
        }
      }
      .vertical(false)
      .barHeight(0)
      .scrollable(false)
      .animationDuration(300)
      .backgroundColor($r('app.color.page_background'))
      .onChange((index: number) => {
        this.selectedTabIndex = index;
      })

      // 悬浮 TabBar
      this.buildFloatingTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildFloatingTabBar() {
    Column() {
      Row() {
        this.buildTabItem('首页', '✨', 0)
        this.buildTabItem('灵感', '💡', 1)
        this.buildTabItem('项目', '📁', 2)
        this.buildTabItem('我的', '👤', 3)
      }
      .width('92%')
      .height(52)
      .backgroundColor($r('app.color.tab_bar_background'))
      .borderRadius(26)
      .shadow({ radius: 16, color: $r('app.color.divider'), offsetX: 0, offsetY: 4 })
      .backdropBlur(20)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ bottom: this.getSafeBottomPadding() })
    .margin({ bottom: 8 })
  }

  @Builder
  buildTabItem(title: string, icon: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(20)
        .margin({ bottom: 1 })
        .opacity(this.selectedTabIndex === index ? 1 : 0.5)

      Text(title)
        .fontSize(10)
        .opacity(this.selectedTabIndex === index ? 1 : 0.5)
        .fontColor(this.selectedTabIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary'))
    }
    .width('25%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedTabIndex = index;
    })
  }

  getSafeBottomPadding(): number {
    const bottomHeight = AppStorage.get<number>('navigationBarHeight') || 0;
    return bottomHeight > 0 ? bottomHeight : 8;
  }
}