import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, display } from '@kit.ArkUI';
import { RdbHelper } from '../data/datasources/RdbHelper';
import { SettingsService } from '../services/storage/SettingsService';

const DOMAIN = 0x0000;
const DEFAULT_STATUS_BAR_HEIGHT = 40;
const DEFAULT_NAVIGATION_BAR_HEIGHT = 20;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      await RdbHelper.getInstance().init(this.context);
      await SettingsService.getInstance().init(this.context);
      const settingsService = SettingsService.getInstance();
      const themeMode = await settingsService.getThemeMode();
      this.applyThemeMode(themeMode);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize services. Cause: %{public}s', JSON.stringify(err));
    }

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    const mainWindow = windowStage.getMainWindowSync();
    this.setupImmersiveWindow(mainWindow);
  }

  private async setupImmersiveWindow(mainWindow: window.Window): Promise<void> {
    try {
      await mainWindow.setWindowLayoutFullScreen(true);
      await mainWindow.setWindowSystemBarEnable(['status', 'navigation']);
      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: '#000000'
      });

      const avoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const statusBarHeightPx = avoidArea.topRect.height || DEFAULT_STATUS_BAR_HEIGHT;
      const navigationBarHeightPx = avoidArea.bottomRect.height || DEFAULT_NAVIGATION_BAR_HEIGHT;
      const density = display.getDefaultDisplaySync().densityPixels;
      const statusBarHeight = statusBarHeightPx / density;
      const navigationBarHeight = navigationBarHeightPx / density;
      AppStorage.setOrCreate('statusBarHeight', statusBarHeight);
      AppStorage.setOrCreate('navigationBarHeight', navigationBarHeight);
      hilog.info(DOMAIN, 'testTag', 'StatusBarHeight: %{public}d, NavigationBarHeight: %{public}d',
        statusBarHeight, navigationBarHeight);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to setup immersive window. Cause: %{public}s', JSON.stringify(err));
      AppStorage.setOrCreate('statusBarHeight', DEFAULT_STATUS_BAR_HEIGHT);
      AppStorage.setOrCreate('navigationBarHeight', DEFAULT_NAVIGATION_BAR_HEIGHT);
    }
  }

  private applyThemeMode(mode: string): void {
    try {
      const appContext = this.context.getApplicationContext();
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
      AppStorage.setOrCreate('themeMode', mode);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to apply theme mode. Cause: %{public}s', JSON.stringify(err));
    }
  }

  onConfigurationChange(newConfig: Configuration): void {
    hilog.info(DOMAIN, 'testTag', 'Configuration changed');
    const currentThemeMode = AppStorage.get<string>('themeMode') || 'system';
    if (currentThemeMode === 'system') {
      const colorMode = newConfig.colorMode;
      const appContext = this.context.getApplicationContext();
      if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      } else {
        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      }
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
