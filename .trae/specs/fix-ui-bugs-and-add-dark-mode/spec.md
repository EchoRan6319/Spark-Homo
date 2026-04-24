# 修复 UI 问题与深色模式完善 Spec

## Why
当前应用存在多个关键功能缺陷和 UI 问题：所有页面顶部存在过量空白、灵感保存功能不可用、项目创建功能缺失对话框、AI 设置缺少预设模型且测试连接不可用、深色模式仅有选项但无实际切换功能。这些问题严重影响用户体验，需要系统性修复。

## What Changes
- 修复所有页面顶部空白过大的问题（statusBarHeight 单位不匹配，px 被当作 vp 使用）
- 修复灵感保存失败的问题（RdbHelper 和 SettingsService 在 EntryAbility 中未初始化）
- 修复项目页面"+"按钮无法添加项目（缺少创建项目对话框）
- 在 AI 设置中增加更多大模型预设（DeepSeek、通义千问、智谱 GLM 等），同时保留 OpenAI 及兼容接口
- 修复 AI 测试连接功能（依赖 SettingsService 初始化）
- 实现深色模式完整功能：运行时主题切换，UI 实时响应

## Impact
- 受影响的能力：灵感记录与保存、项目管理、AI 配置与测试、主题切换
- 受影响代码：
  - `EntryAbility.ets`（初始化数据库和设置服务、应用主题模式）
  - `MainPage.ets`（顶部间距修正、TabBar 深色模式适配）
  - `HomePage.ets`（顶部间距修正）
  - `CapturePage.ets`（顶部间距修正、保存功能间接修复）
  - `InspirationListPage.ets`（顶部间距修正）
  - `ProjectListPage.ets`（顶部间距修正、添加项目对话框）
  - `ProjectDetailPage.ets`（顶部间距修正）
  - `InspirationDetailPage.ets`（顶部间距修正）
  - `AiChatPage.ets`（顶部间距修正）
  - `SettingsPage.ets`（顶部间距修正、AI 预设模型、深色模式切换）
  - `SettingsViewModel.ets`（主题模式应用逻辑、AI 预设模型数据）
  - `SettingsService.ets`（新增 AI 预设相关存储）
  - `AppConstants.ets`（新增 AI 预设模型常量）
  - `color.json`（深色/浅色模式补充颜色）

## ADDED Requirements

### Requirement: 合理的页面顶部间距
The system SHALL 所有页面的顶部安全区域间距使用正确的单位换算，将 px 值转换为 vp 值使用。

#### Scenario: 顶部间距正确显示
- **WHEN** 应用在任意设备上启动
- **THEN** 所有页面顶部间距应为状态栏高度对应的 vp 值，不超过状态栏实际高度
- **AND** 不会出现大面积空白

### Requirement: 服务初始化
The system SHALL 在应用启动时初始化所有必要的服务（数据库、首选项存储）。

#### Scenario: 应用启动初始化
- **WHEN** 应用启动并创建 EntryAbility
- **THEN** RdbHelper 和 SettingsService 必须在使用前完成初始化
- **AND** 初始化使用 ApplicationContext

#### Scenario: 灵感保存成功
- **WHEN** 用户在"捕捉灵感"页面填写内容并点击"保存灵感"
- **THEN** 灵感数据成功写入数据库
- **AND** 页面正确返回上一页

### Requirement: 项目创建对话框
The system SHALL 在项目列表页点击"+"按钮时弹出创建项目对话框。

#### Scenario: 创建项目
- **WHEN** 用户在项目列表页点击"+"按钮
- **THEN** 弹出对话框，包含项目标题输入框和确认/取消按钮
- **WHEN** 用户输入标题并点击确认
- **THEN** 创建新项目并刷新列表

### Requirement: AI 大模型预设
The system SHALL 在 AI 设置中提供多个大模型预设配置，同时保留手动输入能力。

#### Scenario: 选择模型预设
- **WHEN** 用户进入 AI 设置页面
- **THEN** 可看到预设模型列表，包括：OpenAI (GPT-4o-mini)、DeepSeek、通义千问 (Qwen)、智谱 GLM、月之暗面 (Moonshot/Kimi)、Claude
- **WHEN** 用户选择某个预设
- **THEN** 自动填充对应的 Base URL 和默认模型名称
- **AND** 用户仍可手动修改任何字段

#### Scenario: 保留 OpenAI 兼容接口
- **WHEN** 用户使用任意预设或手动配置
- **THEN** AI 服务始终使用 OpenAI 兼容的 `/chat/completions` 接口格式
- **AND** 支持自定义 Base URL 以接入兼容接口

### Requirement: AI 测试连接
The system SHALL 测试 AI 连接时能够正确读取已保存的配置并执行请求。

#### Scenario: 测试连接成功
- **WHEN** 用户配置了有效的 API Key 和 Base URL 后点击"测试连接"
- **THEN** 系统发送测试请求并返回连接成功状态

#### Scenario: 测试连接失败
- **WHEN** 用户配置无效或服务不可达时点击"测试连接"
- **THEN** 显示连接失败提示

### Requirement: 深色模式完整实现
The system SHALL 实现深色模式的完整功能，包括运行时切换和 UI 实时响应。

#### Scenario: 切换到深色模式
- **WHEN** 用户在设置页面选择"深色模式"
- **THEN** 应用立即切换为深色外观（深色背景、浅色文字、深色卡片等）
- **AND** 所有页面、TabBar、对话框均使用深色主题

#### Scenario: 切换到浅色模式
- **WHEN** 用户在设置页面选择"浅色模式"
- **THEN** 应用立即切换为浅色外观

#### Scenario: 跟随系统
- **WHEN** 用户选择"跟随系统"
- **THEN** 应用主题跟随系统设置自动切换
- **AND** 系统主题变化时应用实时响应

#### Scenario: 应用启动恢复主题
- **WHEN** 应用重新启动
- **THEN** 读取用户保存的主题偏好并应用

## MODIFIED Requirements

### Requirement: 应用入口生命周期
**原实现**：仅设置沉浸式窗口和加载页面
**新实现**：
- 在 `onCreate` 中初始化 RdbHelper 和 SettingsService
- 在初始化完成后读取并应用用户保存的主题模式
- 使用 `px2vp` 工具函数修正状态栏高度的单位换算

### Requirement: 设置页面 AI 配置
**原实现**：仅包含手动输入的 API Key、Base URL、Model 字段
**新实现**：
- 新增模型预设选择区域（以 Chip 或列表形式展示）
- 选择预设后自动填充 Base URL 和 Model
- 保留手动输入能力，预设仅作为快捷填充
- 测试连接功能依赖已修复的 SettingsService 初始化

### Requirement: 项目列表页
**原实现**：点击"+"按钮仅设置 `showAddDialog` 状态但无对话框
**新实现**：
- 实现 `AlertDialog` 或 `CustomDialog` 用于创建项目
- 对话框包含标题输入、描述输入（可选）
- 确认后调用 `ProjectViewModel.createProject()` 创建项目

## REMOVED Requirements

无移除的需求。
