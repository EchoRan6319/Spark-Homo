# 「灵光」(Spark) 鸿蒙原生版 产品需求文档 (PRD)

## 1. 产品概述

### 1.1 产品背景
「灵光」是一款面向创意工作者的灵感管理与项目落地工具。原版本基于 Flutter 构建，支持多平台。现计划推出 HarmonyOS 原生版本，以充分利用鸿蒙系统的原生性能、分布式能力与原生设计体验，为用户提供更流畅、更贴合鸿蒙生态的创意管理体验。

### 1.2 产品目标
- 打造一款符合 HarmonyOS Design 设计规范的原生创意管理应用
- 提供从「灵感捕捉」到「项目落地」的完整工作流
- 深度集成 AI 能力，辅助用户分析灵感、生成思维导图、智能对话
- 支持 Light / Dark 模式，提供精致、现代的视觉体验

### 1.3 目标用户
- 创意工作者（设计师、作家、产品经理、开发者）
- 需要随时记录灵感并跟进执行的个人用户
- HarmonyOS 手机/平板用户

### 1.4 平台与版本
- **目标平台**：HarmonyOS（手机、平板、2in1 设备）
- **API 版本**：6.0.2 (22)
- **技术栈**：ArkTS + ArkUI + 鸿蒙原生数据能力 + 鸿蒙网络能力

---

## 2. 产品架构

### 2.1 信息架构
```
灵光 (Spark)
├── 首页 (Home)
│   ├── 最近灵感速览
│   ├── 快捷操作入口（捕捉灵感 / 查看项目）
│   └── 今日待办提醒
├── 灵感 (Inspiration)
│   ├── 灵感列表（搜索 + 情绪过滤）
│   ├── 灵感详情
│   ├── 捕捉灵感（新建/编辑）
│   └── AI 分析 / 思维导图 / 对话
├── 项目 (Project)
│   ├── 项目列表（进度展示）
│   ├── 项目详情（任务列表）
│   └── 灵感转项目
└── 我的 (Me)
    ├── AI 设置（API Key / Base URL / 模型选择）
    ├── 主题设置（跟随系统 / 浅色 / 深色）
    └── 关于应用
```

### 2.2 页面路由结构
| 页面 | 路由 | 说明 |
|------|------|------|
| 主框架 | `pages/MainPage` | Tabs 底部导航容器 |
| 首页 | `pages/home/HomePage` | TabContent - 首页 |
| 灵感列表 | `pages/inspiration/InspirationListPage` | TabContent - 灵感 |
| 灵感详情 | `pages/inspiration/InspirationDetailPage` | 子页面，从列表/首页进入 |
| 捕捉灵感 | `pages/inspiration/CapturePage` | 子页面，新建/编辑灵感 |
| 思维导图 | `pages/inspiration/MindMapPage` | 子页面，从灵感详情进入 |
| AI 对话 | `pages/ai/AiChatPage` | 子页面，从灵感详情进入 |
| 项目列表 | `pages/project/ProjectListPage` | TabContent - 项目 |
| 项目详情 | `pages/project/ProjectDetailPage` | 子页面，从列表进入 |
| 设置 | `pages/settings/SettingsPage` | TabContent - 我的 |

---

## 3. 功能需求

### 3.1 首页 (Home)

#### 3.1.1 页面布局
- **顶部**：应用标题「灵光」+ 当前日期
- **中部**：最近 3 条灵感卡片横向滑动展示（Swiper）
- **快捷操作区**：
  - 「✨ 捕捉灵感」大按钮 → 跳转 CapturePage
  - 「📁 查看项目」按钮 → 跳转 ProjectListPage
- **底部**：今日待办任务摘要（如有）

#### 3.1.2 交互细节
- 灵感卡片左滑显示「删除」操作
- 点击卡片跳转灵感详情
- 空状态显示引导文案「记录你的第一个灵感吧」

### 3.2 灵感列表 (Inspiration List)

#### 3.2.1 页面布局
- **顶部搜索栏**：实时搜索灵感内容/标签
- **情绪过滤栏**：横向滚动标签（全部 😊 😔 😡 😲 🤔），点击过滤
- **列表区域**：纵向卡片列表，按时间倒序

#### 3.2.2 灵感卡片设计
- 卡片圆角 16vp，背景使用系统卡片色（`$r('sys.color.ohos_id_color_foreground_contrary')`）
- 内容预览（最多 2 行）
- 情绪图标 + 创建时间
- 标签列表（最多 3 个）
- 左滑删除，点击进入详情

#### 3.2.3 空状态
- 无灵感时显示插画 + 「还没有灵感，点击右上角添加」

### 3.3 捕捉灵感 (Capture)

#### 3.3.1 新建灵感
- **内容输入**：多行文本输入框，占位符「此刻的想法是...」
- **情绪选择**：横向图标选择器，5 种情绪（开心/难过/愤怒/惊讶/思考）
- **标签输入**：支持输入标签并回车添加，显示为 Chip 样式，可删除
- **保存按钮**：底部固定，点击保存并返回

#### 3.3.2 编辑灵感
- 与新建共用页面，传入灵感 ID 预填充数据
- 保存时更新 `updatedAt`

### 3.4 灵感详情 (Inspiration Detail)

#### 3.4.1 页面布局
- **顶部**：情绪大图标 + 创建时间 + 标签列表
- **内容区**：灵感完整内容，可编辑（点击唤起编辑）
- **AI 功能区**：
  - 「🧠 AI 分析」按钮 → 调用 AI 分析，展示可行性/潜力/风险评分（1-10 分）+ 行动建议
  - 「🗺️ 思维导图」按钮 → 跳转 MindMapPage
  - 「💬 AI 对话」按钮 → 跳转 AiChatPage（携带灵感上下文）
- **操作区**：「转为项目」按钮 + 删除按钮

#### 3.4.2 AI 分析结果展示
- 三个评分使用进度条/环形图展示
- 行动建议以引用块样式展示
- 支持重新分析

### 3.5 思维导图 (Mind Map)

#### 3.5.1 页面布局
- 全屏 Canvas 绘制思维导图
- 中心节点为灵感主题
- 子节点为 AI 生成的关联概念/分支
- 支持双指缩放与拖拽

#### 3.5.2 数据格式
- AI 返回树状 JSON，前端解析后递归绘制节点与连线
- 节点样式：圆角矩形，不同层级使用不同颜色

### 3.6 AI 对话 (AI Chat)

#### 3.6.1 页面布局
- 顶部：灵感摘要（上下文提示）
- 中部：消息气泡列表（用户右对齐，AI 左对齐）
- 底部：输入框 + 发送按钮

#### 3.6.2 交互细节
- 支持流式响应，AI 回复逐字显示
- 支持清空对话
- 支持重新生成回复

### 3.7 项目列表 (Project List)

#### 3.7.1 页面布局
- 项目卡片列表，每个卡片展示：
  - 项目名称
  - 关联灵感摘要
  - 进度条（已完成任务 / 总任务）
  - 状态标签（进行中 / 已完成 / 已暂停）
- 点击卡片进入项目详情

### 3.8 项目详情 (Project Detail)

#### 3.8.1 页面布局
- **顶部**：项目名称 + 进度百分比 + 状态切换
- **任务列表**：可勾选完成的任务项
- **底部**：添加任务输入框

#### 3.8.2 任务管理
- 勾选任务自动更新项目进度
- 左滑删除任务
- 所有任务完成后项目状态自动变为「已完成」

### 3.9 灵感转项目

#### 3.9.1 流程
1. 用户在灵感详情页点击「转为项目」
2. 弹出确认对话框，预填充项目名（灵感前 20 字）
3. 确认后创建新项目，复制灵感内容到项目描述
4. 自动创建一条默认任务：「梳理灵感思路」
5. 跳转至项目详情页

### 3.10 设置 (Settings)

#### 3.10.1 AI 设置
- API Key 输入框（密文显示，支持显示/隐藏）
- Base URL 输入框（默认 `https://api.openai.com/v1`）
- 模型选择（默认 `gpt-4o-mini`，支持自定义输入）
- 「测试连接」按钮

#### 3.10.2 主题设置
- 选项：跟随系统 / 浅色模式 / 深色模式
- 切换后立即生效

#### 3.10.3 关于
- 应用名称、版本号、开发者信息

---

## 4. 数据模型

### 4.1 Inspiration（灵感）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 主键 |
| content | TEXT NOT NULL | 灵感内容 |
| emotion | TEXT | 情绪类型：happy/sad/angry/surprised/thinking |
| tags | TEXT | 标签 JSON 数组字符串 |
| aiAnalysis | TEXT | AI 分析结果 JSON 字符串 |
| createdAt | INTEGER | 创建时间戳 |
| updatedAt | INTEGER | 更新时间戳 |

### 4.2 SparkProject（项目）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 主键 |
| inspirationId | INTEGER | 关联灵感 ID（可为空） |
| title | TEXT NOT NULL | 项目名称 |
| description | TEXT | 项目描述 |
| progress | INTEGER DEFAULT 0 | 进度 0-100 |
| status | TEXT DEFAULT 'active' | 状态：active/completed/paused |
| createdAt | INTEGER | 创建时间戳 |
| updatedAt | INTEGER | 更新时间戳 |

### 4.3 SparkTask（任务）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 主键 |
| projectId | INTEGER NOT NULL | 所属项目 ID |
| title | TEXT NOT NULL | 任务标题 |
| isCompleted | INTEGER DEFAULT 0 | 是否完成 0/1 |
| createdAt | INTEGER | 创建时间戳 |
| updatedAt | INTEGER | 更新时间戳 |

---

## 5. 非功能需求

### 5.1 性能需求
- 页面首屏加载时间 < 300ms
- 列表滑动帧率 >= 55fps
- 数据库操作异步执行，不阻塞 UI

### 5.2 兼容性
- 支持 HarmonyOS 手机（API 6.0.2+）
- 适配平板/2in1 设备的横屏布局

### 5.3 安全
- API Key 使用 Preferences 存储，不硬编码
- 数据库文件存储在应用私有目录

### 5.4 本地化
- 默认中文界面
- 所有用户可见字符串提取到 `string.json`

---

## 6. 设计规范

### 6.1 色彩体系
- **主色**：`#007AFF` (鸿蒙蓝)
- **Light 模式背景**：`#F2F2F7` (系统灰)
- **Dark 模式背景**：`#000000` / `#1C1C1E`
- **卡片背景**：使用系统 Token `$r('sys.color.ohos_id_color_foreground_contrary')`
- **文字主色**：`$r('sys.color.ohos_id_color_primary')`
- **文字次色**：`$r('sys.color.ohos_id_color_secondary')`

### 6.2 字体与排版
- 使用鸿蒙系统默认字体（HarmonyOS Sans）
- 标题：20fp Bold
- 正文：16fp Regular
- 辅助文字：14fp / 12fp

### 6.3 间距与圆角
- 页面边距：16vp
- 卡片内边距：16vp
- 卡片圆角：16vp
- 按钮圆角：12vp
- 元素间距：8vp / 12vp / 16vp

### 6.4 图标
- 使用鸿蒙系统图标或自定义 SVG 图标
- Tab 图标尺寸：24vp

---

## 7. 附录

### 7.1 情绪映射
| 情绪 | 标识 | 颜色 |
|------|------|------|
| 开心 | happy | `#34C759` |
| 难过 | sad | `#5856D6` |
| 愤怒 | angry | `#FF3B30` |
| 惊讶 | surprised | `#FF9500` |
| 思考 | thinking | `#007AFF` |

### 7.2 AI 接口规范
- **协议**：OpenAI 兼容协议
- **分析接口**：`/chat/completions`，返回结构化 JSON
- **思维导图接口**：`/chat/completions`，返回树状 JSON
- **对话接口**：`/chat/completions`，支持 stream=true 流式返回
