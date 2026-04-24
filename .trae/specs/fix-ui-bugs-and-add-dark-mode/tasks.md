# Tasks

- [x] Task 1: 修复 EntryAbility 初始化逻辑
  - [x] SubTask 1.1: 在 EntryAbility.onWindowStageCreate 中初始化 RdbHelper（使用 this.context）
  - [x] SubTask 1.2: 在 EntryAbility.onWindowStageCreate 中初始化 SettingsService（使用 this.context）
  - [x] SubTask 1.3: 在初始化完成后读取用户保存的主题模式并应用（调用 setColorMode）
  - [x] SubTask 1.4: 修复 statusBarHeight 单位换算——将 px 值用 px2vp 转为 vp 后存入 AppStorage

- [x] Task 2: 修复所有页面顶部间距
  - [x] SubTask 2.1: 修改 HomePage.ets 顶部 padding，使用转换后的 statusBarHeight vp 值
  - [x] SubTask 2.2: 修改 CapturePage.ets 顶部 padding
  - [x] SubTask 2.3: 修改 InspirationListPage.ets 顶部 padding
  - [x] SubTask 2.4: 修改 ProjectListPage.ets 顶部 padding
  - [x] SubTask 2.5: 修改 ProjectDetailPage.ets 顶部 padding
  - [x] SubTask 2.6: 修改 InspirationDetailPage.ets 顶部 padding
  - [x] SubTask 2.7: 修改 AiChatPage.ets 顶部 padding
  - [x] SubTask 2.8: 修改 SettingsPage.ets 顶部 padding

- [x] Task 3: 修复项目页"+"按钮添加项目功能
  - [x] SubTask 3.1: 在 ProjectListPage.ets 中实现创建项目的 CustomDialog 对话框
  - [x] SubTask 3.2: 对话框包含项目标题输入框和描述输入框
  - [x] SubTask 3.3: 确认按钮调用 ProjectViewModel.createProject() 创建项目并刷新列表

- [x] Task 4: 添加 AI 大模型预设配置
  - [x] SubTask 4.1: 在 AppConstants.ets 中定义 AiPreset 类和预设模型常量数组
  - [x] SubTask 4.2: 预设包括：OpenAI GPT-4o-mini、DeepSeek、通义千问(Qwen)、智谱GLM、月之暗面(Moonshot/Kimi)、Claude
  - [x] SubTask 4.3: 在 SettingsPage.ets 的 AI 设置区域添加预设选择 Chip 行
  - [x] SubTask 4.4: 选择预设后自动填充 Base URL 和 Model 字段
  - [x] SubTask 4.5: 保留手动编辑能力，预设仅作为快捷填充

- [x] Task 5: 实现深色模式完整功能
  - [x] SubTask 5.1: 修改 SettingsViewModel.saveThemeMode()，保存后通过 AppStorage 通知全局
  - [x] SubTask 5.2: 在 EntryAbility 中实现主题模式应用方法，根据用户选择调用 setColorMode
  - [x] SubTask 5.3: 修改 MainPage.ets 的 TabBar 样式使用 $r() 资源引用以响应深色模式
  - [x] SubTask 5.4: 检查并补充 dark/element/color.json 中缺失的颜色定义（error、warning、status_*_bg、card_shadow）
  - [x] SubTask 5.5: 确保所有硬编码颜色值替换为 $r() 资源引用
  - [x] SubTask 5.6: 应用启动时恢复用户保存的主题偏好

- [x] Task 6: 修复数据刷新和编译错误
  - [x] SubTask 6.1: 修复数据库初始化竞态条件——将初始化移至 onWindowStageCreate（在 loadContent 前）
  - [x] SubTask 6.2: 修复页面返回后数据不刷新——MainPage.onPageShow 递增 dataVersion，子组件 @Watch 自动刷新
  - [x] SubTask 6.3: 修复 ArkTS 严格模式编译错误（匿名对象类型、组件属性默认值、内联接口）
  - [x] SubTask 6.4: 替换硬编码阴影颜色为 card_shadow 资源引用

# Task Dependencies
- Task 2 (顶部间距) 依赖 Task 1 (EntryAbility 初始化中的 px2vp 修复)
- Task 3 (项目创建) 无外部依赖
- Task 4 (AI 预设) 依赖 Task 1 (SettingsService 初始化)
- Task 5 (深色模式) 依赖 Task 1 (EntryAbility 中应用主题)
- Task 6 (编译修复) 依赖 Task 1-5 全部完成
