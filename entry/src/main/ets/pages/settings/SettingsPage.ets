import { router } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { SettingsViewModel } from '../../viewmodels/SettingsViewModel';
import { AppConstants, AiPreset } from '../../constants/AppConstants';

@CustomDialog
struct AddPresetDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: AddPresetDialog({}) })
  onConfirm: (name: string, baseUrl: string, model: string) => void = () => {}
  @State presetName: string = ''
  @State presetBaseUrl: string = ''
  @State presetModel: string = ''

  build() {
    Column() {
      Text('添加自定义预设')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      TextInput({ placeholder: '预设名称', text: $$this.presetName })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(12)
        .padding(12)
        .width('100%')
        .margin({ bottom: 12 })

      TextInput({ placeholder: 'Base URL', text: $$this.presetBaseUrl })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(12)
        .padding(12)
        .width('100%')
        .margin({ bottom: 12 })

      TextInput({ placeholder: '模型名称', text: $$this.presetModel })
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

        Button('添加')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.primary'))
          .layoutWeight(1)
          .height(44)
          .borderRadius(12)
          .margin({ left: 12 })
          .onClick(() => {
            if (this.presetName.trim() && this.presetBaseUrl.trim() && this.presetModel.trim()) {
              this.onConfirm(this.presetName.trim(), this.presetBaseUrl.trim(), this.presetModel.trim());
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
export struct SettingsPage {
  @State viewModel: SettingsViewModel = new SettingsViewModel();
  @State showPassword: boolean = false;
  @State selectedPreset: string = '';
  @State preferredModel: string = '';

  // UI状态 - 使用@State确保UI响应
  @State connectionStatus: 'none' | 'testing' | 'success' | 'error' = 'none';
  @State saveStatus: 'none' | 'saving' | 'success' | 'error' = 'none';
  @State errorMessage: string = '';

  private presetDialogController: CustomDialogController = new CustomDialogController({
    builder: AddPresetDialog({
      onConfirm: (name: string, baseUrl: string, model: string) => {
        this.addCustomPreset(name, baseUrl, model);
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true,
    autoCancel: true
  })

  aboutToAppear(): void {
    // 设置ViewModel的回调，将状态变化同步到UI
    this.viewModel.onConnectionStatusChanged = (status) => {
      this.connectionStatus = status;
    };
    this.viewModel.onSaveStatusChanged = (status) => {
      this.saveStatus = status;
    };
    this.viewModel.onErrorMessageChanged = (message) => {
      this.errorMessage = message;
    };

    this.viewModel.loadSettings().then(() => {
      this.selectedPreset = this.viewModel.currentPresetName;
      this.preferredModel = this.viewModel.preferredModel;
    });
  }

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
      bottom: 16
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
    .margin({ left: 16, right: 16 })
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
        Text('优先使用模型')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 8 })

        Scroll() {
          Row() {
            Text('不指定')
              .fontSize(13)
              .fontColor(this.preferredModel === '' ? Color.White : $r('app.color.text_primary'))
              .backgroundColor(this.preferredModel === '' ? $r('app.color.primary') : $r('app.color.input_background'))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .margin({ right: 8 })
              .onClick(() => {
                this.preferredModel = '';
                this.viewModel.setPreferredModel('');
              })

            ForEach(this.viewModel.getAllPresets(), (preset: AiPreset) => {
              Text(preset.name)
                .fontSize(13)
                .fontColor(this.preferredModel === preset.name ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.preferredModel === preset.name ? $r('app.color.primary') : $r('app.color.input_background'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => {
                  this.preferredModel = preset.name;
                  this.viewModel.setPreferredModel(preset.name);
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

        Text('当前编辑: ' + (this.viewModel.currentPresetName || '未选择'))
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ bottom: 8 })

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

        Row() {
          Button('测试连接')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.getConnectionButtonColor())
            .layoutWeight(1)
            .height(44)
            .borderRadius(12)
            .onClick(() => {
              this.viewModel.testConnection();
            })

          Button('保存设置')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.primary'))
            .layoutWeight(1)
            .height(44)
            .borderRadius(12)
            .margin({ left: 12 })
            .onClick(() => {
              this.viewModel.saveAllSettings();
            })
        }
        .width('100%')
        .margin({ top: 8 })

        if (this.connectionStatus === 'success') {
          Text('✓ 连接成功')
            .fontSize(13)
            .fontColor($r('app.color.success'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        } else if (this.connectionStatus === 'error') {
          Text('✗ ' + (this.errorMessage || '连接失败，请检查配置'))
            .fontSize(13)
            .fontColor($r('app.color.error'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        }

        if (this.saveStatus === 'success') {
          Text('✓ 保存成功')
            .fontSize(13)
            .fontColor($r('app.color.success'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        } else if (this.saveStatus === 'error') {
          Text('✗ ' + (this.errorMessage || '保存失败'))
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

      this.buildPresetManager()
    }
    .width('100%')
  }

  @Builder
  buildPresetManager() {
    Column() {
      Text('模型预设管理')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Column() {
        ForEach(this.viewModel.getAllPresets(), (preset: AiPreset) => {
          Row() {
            Column() {
              Text(preset.name)
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Medium)

              Text(preset.model)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (this.isCustomPreset(preset.name)) {
              Button('删除')
                .fontSize(12)
                .fontColor($r('app.color.error'))
                .backgroundColor(Color.Transparent)
                .height(32)
                .onClick(() => {
                  this.deleteCustomPreset(preset.name);
                })
            }

            Button('编辑')
              .fontSize(12)
              .fontColor($r('app.color.primary'))
              .backgroundColor(Color.Transparent)
              .height(32)
              .margin({ left: 8 })
              .onClick(() => {
                this.selectedPreset = preset.name;
                this.viewModel.selectPreset(preset);
              })
          }
          .width('100%')
          .height(56)
          .padding({ left: 12, right: 12 })

          Divider()
            .height(1)
            .width('100%')
            .color($r('app.color.divider'))
            .margin({ top: 4, bottom: 4 })
        })

        Row() {
          Text('+ 添加自定义预设')
            .fontSize(15)
            .fontColor($r('app.color.primary'))
            .layoutWeight(1)

          Button('')
            .width(0)
            .height(0)
            .backgroundColor(Color.Transparent)
        }
        .width('100%')
        .height(48)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.presetDialogController.open();
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

  isCustomPreset(name: string): boolean {
    return this.viewModel.customPresets.some(p => p.name === name);
  }

  async addCustomPreset(name: string, baseUrl: string, model: string): Promise<void> {
    await this.viewModel.addCustomPreset(name, baseUrl, model);
    this.selectedPreset = name;
    await this.viewModel.selectPreset({ name, baseUrl, model });
  }

  async deleteCustomPreset(name: string): Promise<void> {
    await this.viewModel.deleteCustomPreset(name);
    if (this.selectedPreset === name) {
      this.selectedPreset = '';
    }
    if (this.preferredModel === name) {
      this.preferredModel = '';
    }
  }

  getConnectionButtonColor(): ResourceStr {
    if (this.connectionStatus === 'success') {
      return $r('app.color.success');
    } else if (this.connectionStatus === 'error') {
      return $r('app.color.error');
    } else if (this.connectionStatus === 'testing') {
      return $r('app.color.warning');
    }
    return $r('app.color.primary');
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
