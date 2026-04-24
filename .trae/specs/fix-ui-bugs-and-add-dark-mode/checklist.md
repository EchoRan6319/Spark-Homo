# Checklist

## 顶部间距修复
- [x] EntryAbility 中 statusBarHeight 使用 px2vp 转换后再存入 AppStorage
- [x] 所有页面（HomePage、CapturePage、InspirationListPage、ProjectListPage、ProjectDetailPage、InspirationDetailPage、AiChatPage、SettingsPage、MindMapPage）顶部间距 `|| 40` 改为 `|| 0`
- [x] 移除各页面 Header 的冗余 `.margin({ top: 8 })`

## 服务初始化修复
- [x] EntryAbility.onWindowStageCreate 中在 loadContent 前初始化 RdbHelper
- [x] EntryAbility.onWindowStageCreate 中在 loadContent 前初始化 SettingsService
- [x] 灵感保存功能：数据库初始化竞态条件已修复，保存后 router.back() 返回正常

## 数据刷新机制
- [x] MainPage.onPageShow 递增 AppStorage 中的 dataVersion
- [x] HomePage 使用 @StorageProp('dataVersion') + @Watch 自动刷新
- [x] InspirationListPage 使用 @StorageProp('dataVersion') + @Watch 自动刷新
- [x] ProjectListPage 使用 @StorageProp('dataVersion') + @Watch 自动刷新

## 项目创建功能
- [x] 项目列表页点击"+"按钮弹出 AddProjectDialog 自定义对话框
- [x] 对话框包含项目标题输入框和描述输入框
- [x] 输入标题后点击确认，项目成功创建并出现在列表中

## AI 大模型预设
- [x] AppConstants.ets 中定义 AiPreset 类和预设常量数组（使用 as AiPreset 满足 ArkTS 严格模式）
- [x] AI 设置页面显示预设模型选择 Chip 行
- [x] 预设包含：OpenAI、DeepSeek、通义千问、智谱GLM、月之暗面、Claude
- [x] 点击预设后 Base URL 和 Model 字段自动填充
- [x] 用户仍可手动修改任何字段
- [x] AI 测试连接功能：SettingsViewModel 中移除内联 interface，改用从 AiService 导入 ChatMessage

## 深色模式
- [x] SettingsPage 中每个主题选项（跟随系统/浅色/深色）点击后调用 applyThemeMode 并 saveThemeMode
- [x] EntryAbility.applyThemeMode 根据模式调用 setColorMode
- [x] 应用启动时恢复主题：onWindowStageCreate 中读取保存的 themeMode 并 applyThemeMode
- [x] onConfigurationChange 处理系统主题变化（跟随系统模式时响应）
- [x] MainPage TabBar 使用 $r('app.color.tab_bar_background') 响应深色
- [x] 硬编码颜色值替换为 $r() 资源引用（主页面、设置页、项目页、灵感页的状态颜色、删除红色等）
- [x] dark/element/color.json 包含完整颜色定义（error、warning、status_*_bg、card_shadow）
- [x] 卡片阴影颜色使用 $r('app.color.card_shadow') 资源引用

## ArkTS 编译兼容
- [x] AppConstants.ets：EmotionType/AiPreset 类替代匿名对象类型，as Xxx 满足类型推断
- [x] AddProjectDialog：controller 和 onConfirm 有符合 mandatory-default-value 的默认值
- [x] SettingsViewModel：移除内联 interface，使用 AiService 导出的 ChatMessage
- [x] ForEach 回调参数使用具名类型（AiPreset）而非匿名对象类型
