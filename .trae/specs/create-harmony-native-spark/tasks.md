# Tasks

## Phase 1: 项目基础与架构搭建
- [x] Task 1: 配置项目基础资源与主题系统
  - [x] SubTask 1.1: 在 `AppScope/resources/base/element/string.json` 中定义应用名称、模块描述等全局字符串
  - [x] SubTask 1.2: 在 `entry/src/main/resources/base/element/color.json` 中定义 Light 模式色彩体系（主色、背景、文字、分割线等）
  - [x] SubTask 1.3: 在 `entry/src/main/resources/dark/element/color.json` 中定义 Dark 模式色彩体系
  - [x] SubTask 1.4: 在 `entry/src/main/resources/base/element/float.json` 中定义全局尺寸 Token（圆角、间距、字体大小等）
  - [x] SubTask 1.5: 创建 `entry/src/main/ets/constants/AppConstants.ets` 存放业务常量（数据库名、表名、API 默认配置等）

- [x] Task 2: 搭建数据库与数据层
  - [x] SubTask 2.1: 创建 `entry/src/main/ets/data/models/Inspiration.ets` 定义灵感数据模型
  - [x] SubTask 2.2: 创建 `entry/src/main/ets/data/models/SparkProject.ets` 定义项目数据模型
  - [x] SubTask 2.3: 创建 `entry/src/main/ets/data/models/SparkTask.ets` 定义任务数据模型
  - [x] SubTask 2.4: 创建 `entry/src/main/ets/data/datasources/RdbHelper.ets` 封装 RDB 数据库初始化、建表、升级逻辑
  - [x] SubTask 2.5: 创建 `entry/src/main/ets/data/repositories/InspirationRepository.ets` 实现灵感的增删改查
  - [x] SubTask 2.6: 创建 `entry/src/main/ets/data/repositories/ProjectRepository.ets` 实现项目与任务的增删改查

- [x] Task 3: 搭建服务层与工具类
  - [x] SubTask 3.1: 创建 `entry/src/main/ets/services/storage/SettingsService.ets` 封装 Preferences 读写（API Key、主题设置等）
  - [x] SubTask 3.2: 创建 `entry/src/main/ets/services/ai/AiService.ets` 封装 HTTP 请求，实现 AI 分析、思维导图、对话接口
  - [x] SubTask 3.3: 创建 `entry/src/main/ets/core/utils/DateUtil.ets` 日期格式化工具
  - [x] SubTask 3.4: 创建 `entry/src/main/ets/core/utils/EmotionMapper.ets` 情绪映射工具（图标/颜色/文字）

## Phase 2: 核心页面与 UI 组件
- [x] Task 4: 实现底部导航与主框架
  - [x] SubTask 4.1: 创建 `entry/src/main/ets/pages/MainPage.ets` 作为应用主框架，使用 `Tabs` + `TabContent` 实现底部导航
  - [x] SubTask 4.2: 注册主页面到 `main_pages.json`
  - [x] SubTask 4.3: 修改 `EntryAbility.ets` 加载 `pages/MainPage` 作为入口

- [x] Task 5: 实现「首页」页面
  - [x] SubTask 5.1: 创建 `entry/src/main/ets/pages/home/HomePage.ets`，展示最近灵感、快捷操作入口
  - [x] SubTask 5.2: 创建 `entry/src/main/ets/viewmodels/HomeViewModel.ets` 管理首页数据状态

- [x] Task 6: 实现「灵感」相关页面
  - [x] SubTask 6.1: 创建 `entry/src/main/ets/pages/inspiration/InspirationListPage.ets`，展示灵感列表，支持搜索与情绪过滤
  - [x] SubTask 6.2: 创建 `entry/src/main/ets/pages/inspiration/InspirationDetailPage.ets`，展示灵感详情、AI 分析结果
  - [x] SubTask 6.3: 创建 `entry/src/main/ets/pages/inspiration/CapturePage.ets`，实现灵感快速记录页面（支持文本输入、情绪选择、标签添加）
  - [x] SubTask 6.4: 创建 `entry/src/main/ets/viewmodels/InspirationViewModel.ets` 管理灵感列表与过滤状态

- [x] Task 7: 实现「项目」相关页面
  - [x] SubTask 7.1: 创建 `entry/src/main/ets/pages/project/ProjectListPage.ets`，展示项目列表与进度
  - [x] SubTask 7.2: 创建 `entry/src/main/ets/pages/project/ProjectDetailPage.ets`，展示项目详情与关联任务
  - [x] SubTask 7.3: 创建 `entry/src/main/ets/viewmodels/ProjectViewModel.ets` 管理项目数据状态

- [x] Task 8: 实现「我的」设置页面
  - [x] SubTask 8.1: 创建 `entry/src/main/ets/pages/settings/SettingsPage.ets`，包含 API Key 配置、主题切换、关于应用
  - [x] SubTask 8.2: 创建 `entry/src/main/ets/viewmodels/SettingsViewModel.ets` 管理设置状态

## Phase 3: AI 功能与高级交互
- [x] Task 9: 实现 AI 分析与思维导图
  - [x] SubTask 9.1: 在灵感详情页集成 AI 分析按钮，调用 `AiService` 获取分析结果并展示
  - [x] SubTask 9.2: 创建 `entry/src/main/ets/pages/inspiration/MindMapPage.ets`，使用 `Canvas` 自定义绘制思维导图
  - [x] SubTask 9.3: 实现 AI 对话页面 `entry/src/main/ets/pages/ai/AiChatPage.ets`，支持流式响应展示

- [x] Task 10: 实现「灵感转项目」流程
  - [x] SubTask 10.1: 在灵感详情页添加「转为项目」按钮
  - [x] SubTask 10.2: 实现数据迁移逻辑：将灵感内容复制到新项目，并创建默认任务
  - [x] SubTask 10.3: 跳转至项目详情页并展示迁移结果

## Phase 4: 动画、优化与验证
- [x] Task 11: 添加动画与微交互
  - [x] SubTask 11.1: 为列表项添加进入动画（`animateTo` 或 `ListItem` 动画）
  - [x] SubTask 11.2: 为页面跳转添加 `pageTransition` 转场动画
  - [x] SubTask 11.3: 为按钮/卡片添加按压状态反馈（`stateStyles`）

- [x] Task 12: 验证与测试
  - [x] SubTask 12.1: 运行 `ohpm install` 确保依赖完整
  - [x] SubTask 12.2: 运行 `hvigorw build` 或 DevEco Studio 构建，确保无编译错误
  - [x] SubTask 12.3: 手动验证：启动应用确认主框架正常、创建灵感并验证数据库写入、测试 AI 配置与调用、验证灵感转项目流程

# Task Dependencies
- Task 2 (数据库) 依赖 Task 1 (基础配置)
- Task 3 (服务层) 依赖 Task 1 (基础配置)
- Task 4 (主框架) 依赖 Task 1 (基础配置)
- Task 5/6/7/8 (业务页面) 依赖 Task 2 (数据库) 和 Task 3 (服务层) 和 Task 4 (主框架)
- Task 9 (AI 功能) 依赖 Task 6 (灵感页面) 和 Task 3 (AiService)
- Task 10 (灵感转项目) 依赖 Task 6 (灵感页面) 和 Task 7 (项目页面)
- Task 11 (动画) 依赖所有页面任务完成
- Task 12 (验证) 依赖全部功能实现
