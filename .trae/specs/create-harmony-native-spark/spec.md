# 「灵光」(Spark) 鸿蒙原生版开发规范

## Why
将现有的 Flutter 跨平台「灵光」应用迁移为 HarmonyOS 原生应用，以充分利用鸿蒙系统的原生能力（如 ArkUI 声明式 UI、原生性能、分布式软总线等），同时遵循鸿蒙设计规范，提供比跨平台方案更流畅、更原生的用户体验。

## What Changes
- **全新技术栈**：从 Flutter 迁移至 ArkTS + ArkUI，API 版本 6.0.2 (22)
- **原生 UI 设计**：放弃 `liquid_glass_widgets` 第三方库，全面采用鸿蒙原生设计系统（HarmonyOS Design），包括圆角、阴影、层级、动效等
- **数据持久化**：从 Isar (NoSQL) 迁移至鸿蒙原生关系型数据库 (`@ohos.data.relationalStore`) 或首选项 (`@ohos.data.preferences`)，结合 AppStorage/LocalStorage 做运行时状态管理
- **状态管理**：从 `flutter_riverpod` 迁移至 ArkUI 原生的 `@State`、`@Provide`/`@Consume`、`AppStorage`、`LocalStorage` 及自定义 ViewModel
- **路由管理**：从 `go_router` 迁移至鸿蒙原生的 `router` 模块与页面栈管理
- **AI 服务**：保留 OpenAI 兼容协议，使用鸿蒙网络请求能力 (`@ohos.net.http`) 实现
- **动画效果**：从 `flutter_animate` 迁移至 ArkUI 原生动画能力（属性动画、显式动画、转场动画）

## Impact
- **受影响的能力**：灵感记录、灵感列表、灵感详情、AI 分析、思维导图、项目与任务管理、设置页面
- **受影响代码**：全部 Flutter 代码将被移除或重写，替换为 ArkTS/ArkUI 实现
- **平台支持变更**：仅支持 HarmonyOS（手机、平板、2in1 设备），不再支持 iOS/Android/Windows/macOS/Linux/Web

## ADDED Requirements

### Requirement: 鸿蒙原生 UI 架构
The system SHALL 使用 ArkUI 声明式语法构建全部页面，遵循 HarmonyOS Design 设计规范。

#### Scenario: 页面结构
- **WHEN** 应用启动
- **THEN** 显示基于 `Tabs` + `TabContent` 的底部导航主界面，包含「首页」「灵感」「项目」「我的」四个主 Tab

#### Scenario: 设计规范
- **WHEN** 渲染任何 UI 组件
- **THEN** 使用鸿蒙原生设计 Token（圆角 12vp/20vp、阴影 ShadowStyle、色彩体系、字体排版）
- **AND** 支持 Light/Dark 模式自动切换

### Requirement: 数据持久化层
The system SHALL 使用鸿蒙原生数据能力替代 Isar 数据库。

#### Scenario: 灵感数据存储
- **WHEN** 用户创建或更新灵感
- **THEN** 数据通过 `@ohos.data.relationalStore` (RDB) 持久化到本地 SQLite 数据库
- **AND** 数据库表结构包含：id, content, emotion, tags, aiAnalysis, createdAt, updatedAt

#### Scenario: 配置存储
- **WHEN** 用户修改应用设置（如 API Key、主题模式）
- **THEN** 使用 `@ohos.data.preferences` 进行轻量级键值对存储

### Requirement: 状态管理
The system SHALL 使用 ArkUI 原生状态管理机制替代 Riverpod。

#### Scenario: 页面级状态
- **WHEN** 页面需要管理本地状态
- **THEN** 使用 `@State` 装饰器

#### Scenario: 跨组件状态共享
- **WHEN** 多个组件需要共享状态（如主题、用户配置）
- **THEN** 使用 `AppStorage` 或自定义 `ViewModel` 结合 `@Provide`/`@Consume`

#### Scenario: 全局数据管理
- **WHEN** 管理灵感列表、项目列表等全局数据
- **THEN** 使用单例 Service 层 + `AppStorage` 链路绑定

### Requirement: AI 服务集成
The system SHALL 保留 AI 分析、思维导图、对话能力，使用鸿蒙网络模块实现。

#### Scenario: AI 分析
- **WHEN** 用户请求对灵感进行 AI 分析
- **THEN** 使用 `@ohos.net.http` 发送请求到配置的 OpenAI 兼容接口
- **AND** 返回可行性、潜力、风险分数及行动建议

#### Scenario: 流式对话
- **WHEN** 用户与 AI 进行对话
- **THEN** 支持流式响应展示，使用 `httpRequest` 的 `on('headersReceive')`/`on('dataReceive')` 事件

### Requirement: 路由与导航
The system SHALL 使用鸿蒙原生路由能力管理页面跳转。

#### Scenario: 页面跳转
- **WHEN** 用户点击灵感卡片进入详情
- **THEN** 使用 `router.pushUrl` 进行页面跳转
- **AND** 支持参数传递与返回结果处理

#### Scenario: 页面返回
- **WHEN** 用户从详情页返回
- **THEN** 使用 `router.back` 并支持结果回传

### Requirement: 动画与交互
The system SHALL 使用 ArkUI 原生动画能力实现流畅交互。

#### Scenario: 列表动画
- **WHEN** 灵感列表加载或数据变更
- **THEN** 使用 `List` 组件的 `layoutWeight` + `animateTo` 实现平滑过渡

#### Scenario: 页面转场
- **WHEN** 页面跳转
- **THEN** 使用 `pageTransition` 定义进入/退出动画

#### Scenario: 微交互
- **WHEN** 用户点击按钮或卡片
- **THEN** 使用 `stateStyles` (pressed/normal) 或 `animation` 实现按压反馈

## MODIFIED Requirements

### Requirement: 应用入口与生命周期
**原实现**：Flutter `main.dart` / `main_dev.dart` / `main_prod.dart` 多入口
**新实现**：
- 统一使用鸿蒙 `EntryAbility.ets` 作为应用入口
- 环境区分通过 `BuildProfile` 或编译宏实现
- 开发版/正式版通过鸿蒙工程配置（`build-profile.json5` 的 `buildModeSet`）区分

### Requirement: 多环境构建
**原实现**：Flutter Flavor 系统（dev/prod 不同入口文件、包名后缀、数据库名）
**新实现**：
- 使用鸿蒙 `build-profile.json5` 的 `buildModeSet`（debug/release）
- 数据库名通过编译时注入常量区分：`spark_db` (release) / `spark_db_debug` (debug)
- 应用名称统一为「灵光」，debug 包通过签名/渠道区分

## REMOVED Requirements

### Requirement: 跨平台支持
**Reason**：转为 HarmonyOS 原生应用，不再维护跨平台代码
**Migration**：移除全部 Flutter/Dart 代码，保留业务逻辑设计文档作为参考

### Requirement: 第三方 UI 库依赖
**Reason**：鸿蒙原生 ArkUI 已提供完整设计系统，无需第三方 UI 库
**Migration**：
- `liquid_glass_widgets` → 移除，使用 ArkUI 原生 `blur`/`backdropBlur` + 背景效果替代
- `flutter_animate` → 移除，使用 ArkUI `animateTo`/`animation`/`pageTransition` 替代

### Requirement: Riverpod 状态管理
**Reason**：ArkUI 提供原生状态管理方案
**Migration**：
- `AsyncNotifier` → 使用 `Promise`/`async` + `@State` + 数据加载标志位替代
- `filteredInspirationsProvider` → 使用 `ViewModel` 中的计算属性或 `filter` 方法替代
- `aiChatProvider` → 使用 Service 层 + 页面 `@State` 管理对话状态
