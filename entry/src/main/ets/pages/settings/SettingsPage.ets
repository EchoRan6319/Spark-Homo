import { router } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { SettingsViewModel } from '../../viewmodels/SettingsViewModel';
import { AppConstants, AiPreset } from '../../constants/AppConstants';

@Component
export struct SettingsPage {
  @State viewModel: SettingsViewModel = new SettingsViewModel();
  @State showPassword: boolean = false;
  @State selectedPreset: string = '';

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          this.buildAiSettings()
          this.buildThemeSettings()
          this.buildAboutSection()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .padding({ bottom: 80 })
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
      this.viewModel.loadSettings();
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Text('我的')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    .margin({})
  }

  @Builder
  buildAiSettings() {
    Column() {
      Text('AI 设置')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Column() {
        Text('模型预设')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 8 })

        Scroll() {
          Row() {
            ForEach(AppConstants.AI_PRESETS, (preset: AiPreset) => {
              Text(preset.name)
                .fontSize(13)
                .fontColor(this.selectedPreset === preset.name ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.selectedPreset === preset.name ? $r('app.color.primary') : $r('app.color.input_background'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedPreset = preset.name;
                  this.viewModel.saveBaseUrl(preset.baseUrl);
                  this.viewModel.saveModel(preset.model);
                })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .margin({ bottom: 12 })

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Text('API Key')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 4 })

        Row() {
          TextInput({ text: $$this.viewModel.apiKey })
            .placeholderColor($r('app.color.text_secondary'))
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.viewModel.saveApiKey(value);
            })

          Button(this.showPassword ? '🙈' : '👁️')
            .fontSize(16)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showPassword = !this.showPassword;
            })
        }
        .width('100%')

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Text('Base URL')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 4 })

        TextInput({ text: $$this.viewModel.baseUrl })
          .placeholderColor($r('app.color.text_secondary'))
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .width('100%')
          .onChange((value: string) => {
            this.viewModel.saveBaseUrl(value);
          })

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Text('模型')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 4 })

        TextInput({ text: $$this.viewModel.model })
          .placeholderColor($r('app.color.text_secondary'))
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .width('100%')
          .onChange((value: string) => {
            this.viewModel.saveModel(value);
          })

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Button('测试连接')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.getConnectionButtonColor())
          .width('100%')
          .height(44)
          .borderRadius(12)
          .margin({ top: 8 })
          .onClick(() => {
            this.viewModel.testConnection();
          })

        if (this.viewModel.connectionStatus === 'success') {
          Text('✓ 连接成功')
            .fontSize(13)
            .fontColor($r('app.color.success'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        } else if (this.viewModel.connectionStatus === 'error') {
          Text('✗ ' + (this.viewModel.errorMessage || '连接失败，请检查配置'))
            .fontSize(13)
            .fontColor($r('app.color.error'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(16)
      .margin({ bottom: 16 })
    }
    .width('100%')
  }

  @Builder
  buildThemeSettings() {
    Column() {
      Text('主题设置')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Column() {
        Row() {
          Text('跟随系统')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          if (this.viewModel.themeMode === 'system') {
            Text('✓')
              .fontSize(18)
              .fontColor($r('app.color.primary'))
          }
        }
        .width('100%')
        .height(44)
        .onClick(() => {
          this.viewModel.saveThemeMode('system');
          this.applyThemeMode('system');
        })

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Row() {
          Text('浅色模式')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          if (this.viewModel.themeMode === 'light') {
            Text('✓')
              .fontSize(18)
              .fontColor($r('app.color.primary'))
          }
        }
        .width('100%')
        .height(44)
        .onClick(() => {
          this.viewModel.saveThemeMode('light');
          this.applyThemeMode('light');
        })

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Row() {
          Text('深色模式')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          if (this.viewModel.themeMode === 'dark') {
            Text('✓')
              .fontSize(18)
              .fontColor($r('app.color.primary'))
          }
        }
        .width('100%')
        .height(44)
        .onClick(() => {
          this.viewModel.saveThemeMode('dark');
          this.applyThemeMode('dark');
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(16)
      .margin({ bottom: 16 })
    }
    .width('100%')
  }

  @Builder
  buildAboutSection() {
    Column() {
      Text('关于')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Column() {
        Row() {
          Text('应用名称')
            .fontSize(15)
            .fontColor($r('app.color.text_secondary'))
            .layoutWeight(1)

          Text('灵光')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .height(44)

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Row() {
          Text('版本')
            .fontSize(15)
            .fontColor($r('app.color.text_secondary'))
            .layoutWeight(1)

          Text('1.0.0')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .height(44)

        Divider()
          .height(1)
          .width('100%')
          .color($r('app.color.divider'))
          .margin({ top: 8, bottom: 8 })

        Row() {
          Text('开发者')
            .fontSize(15)
            .fontColor($r('app.color.text_secondary'))
            .layoutWeight(1)

          Text('Spark Team')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .height(44)
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(16)
    }
    .width('100%')
  }

  getConnectionButtonColor(): ResourceStr {
    if (this.viewModel.connectionStatus === 'success') {
      return $r('app.color.success');
    } else if (this.viewModel.connectionStatus === 'error') {
      return $r('app.color.error');
    } else if (this.viewModel.connectionStatus === 'testing') {
      return $r('app.color.warning');
    }
    return $r('app.color.primary');
  }

  async applyThemeMode(mode: string): Promise<void> {
    try {
      const appContext = getContext(this).getApplicationContext();
      switch (mode) {
        case 'dark':
          appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
          break;
        case 'light':
          appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
          break;
        default:
          appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
          break;
      }
    } catch (err) {
      console.error(`Failed to apply theme mode: ${JSON.stringify(err)}`);
    }
  }
}