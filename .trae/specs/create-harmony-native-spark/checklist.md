# Checklist

## Phase 1: 项目基础与架构搭建
- [x] 应用名称、模块描述等全局字符串已配置在 `AppScope/resources/base/element/string.json`
- [x] Light 模式色彩体系已定义在 `entry/src/main/resources/base/element/color.json`
- [x] Dark 模式色彩体系已定义在 `entry/src/main/resources/dark/element/color.json`
- [x] 全局尺寸 Token（圆角、间距、字体大小）已定义在 `entry/src/main/resources/base/element/float.json`
- [x] 业务常量文件 `AppConstants.ets` 已创建并包含数据库名、表名、API 默认配置
- [x] 灵感数据模型 `Inspiration.ets` 已创建，字段包含 id, content, emotion, tags, aiAnalysis, createdAt, updatedAt
- [x] 项目数据模型 `SparkProject.ets` 已创建，字段包含 id, inspirationId, title, progress, status, createdAt, updatedAt
- [x] 任务数据模型 `SparkTask.ets` 已创建，字段包含 id, projectId, title, isCompleted, createdAt, updatedAt
- [x] RDB 数据库帮助类 `RdbHelper.ets` 已实现初始化、建表、升级逻辑
- [x] `InspirationRepository.ets` 已实现灵感的增删改查方法
- [x] `ProjectRepository.ets` 已实现项目与任务的增删改查方法
- [x] `SettingsService.ets` 已封装 Preferences 读写，支持 API Key、主题设置等
- [x] `AiService.ets` 已封装 HTTP 请求，支持 AI 分析、思维导图、对话接口
- [x] `DateUtil.ets` 日期格式化工具已实现
- [x] `EmotionMapper.ets` 情绪映射工具已实现（图标/颜色/文字映射）

## Phase 2: 核心页面与 UI 组件
- [x] 主框架 `MainPage.ets` 已创建，使用 `Tabs` + `TabContent` 实现底部导航（首页/灵感/项目/我的）
- [x] `MainPage` 已注册到 `main_pages.json`
- [x] `EntryAbility.ets` 已修改为加载 `pages/MainPage` 作为入口
- [x] 首页 `HomePage.ets` 已实现，展示最近灵感、快捷操作入口
- [x] `HomeViewModel.ets` 已创建并管理首页数据状态
- [x] 灵感列表页 `InspirationListPage.ets` 已实现，展示灵感列表，支持搜索与情绪过滤
- [x] 灵感详情页 `InspirationDetailPage.ets` 已实现，展示灵感详情与 AI 分析结果
- [x] 灵感记录页 `CapturePage.ets` 已实现，支持文本输入、情绪选择、标签添加
- [x] `InspirationViewModel.ets` 已创建并管理灵感列表与过滤状态
- [x] 项目列表页 `ProjectListPage.ets` 已实现，展示项目列表与进度
- [x] 项目详情页 `ProjectDetailPage.ets` 已实现，展示项目详情与关联任务
- [x] `ProjectViewModel.ets` 已创建并管理项目数据状态
- [x] 设置页 `SettingsPage.ets` 已实现，包含 API Key 配置、主题切换、关于应用
- [x] `SettingsViewModel.ets` 已创建并管理设置状态

## Phase 3: AI 功能与高级交互
- [x] 灵感详情页已集成 AI 分析按钮，调用 `AiService` 获取分析结果并展示
- [x] 思维导图页 `MindMapPage.ets` 已创建，使用 `Canvas` 自定义绘制思维导图
- [x] AI 对话页 `AiChatPage.ets` 已实现，支持流式响应展示
- [x] 灵感详情页已添加「转为项目」按钮
- [x] 灵感转项目的数据迁移逻辑已实现（灵感内容复制到新项目，创建默认任务）
- [x] 灵感转项目后正确跳转至项目详情页

## Phase 4: 动画、优化与验证
- [x] 列表项进入动画已实现
- [x] 页面跳转 `pageTransition` 转场动画已配置
- [x] 按钮/卡片按压状态反馈已实现
- [x] `ohpm install` 运行成功，无依赖缺失
- [x] `hvigorw build` 构建成功，无编译错误
- [x] 手动验证：应用启动后主框架正常显示
- [x] 手动验证：创建灵感后数据库正确写入
- [x] 手动验证：AI 配置保存与调用正常
- [x] 手动验证：灵感转项目流程完整可用
