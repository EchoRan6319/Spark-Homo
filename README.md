<div align="center">
  <h1>✨ 灵光 · Spark</h1>
  <p><strong>灵感捕捉与创意管理工具</strong></p>
  <p>HarmonyOS 原生应用 · 基于 ArkTS + ArkUI</p>
  <br>
  <p>
    <img src="https://img.shields.io/badge/HarmonyOS-NEXT-007AFF?style=flat-square" alt="HarmonyOS">
    <img src="https://img.shields.io/badge/API-6.1.0(23)-34C759?style=flat-square" alt="API">
    <img src="https://img.shields.io/badge/ArkTS-Yes-FF9500?style=flat-square" alt="ArkTS">
    <img src="https://img.shields.io/badge/license-MIT-8E8E93?style=flat-square" alt="License">
  </p>
</div>

---

## 📖 项目简介

**灵光 (Spark)** 是一款面向创意工作者的灵感管理工具，帮助用户随时随地捕捉灵感、分析创意、生成思维导图并进行项目管理。应用完全基于 HarmonyOS NEXT 平台开发，使用 ArkTS 语言和 ArkUI 框架。

### 核心功能

| 功能 | 说明 |
|------|------|
| 💡 **灵感捕捉** | 快速记录灵感，支持表情标签和分类 |
| 🤖 **AI 分析** | 接入 LLM API，自动分析灵感可行性、潜力与风险 |
| 🗺️ **思维导图** | AI 自动生成树状思维导图，支持缩放与平移 |
| 💬 **AI 对话** | 针对灵感进行深度对话讨论 |
| 📁 **项目管理** | 将灵感转化为项目，跟踪任务进度 |
| 🌓 **主题切换** | 支持浅色/深色/跟随系统三种主题模式 |

---

## 🛠️ 技术栈

| 层面 | 技术 |
|------|------|
| **语言** | [ArkTS](https://developer.harmonyos.com/) (基于 TypeScript) |
| **UI 框架** | [ArkUI](https://developer.harmonyos.com/) (声明式 UI) |
| **构建系统** | Hvgor |
| **API 版本** | HarmonyOS NEXT 6.1.0 (API 23) |
| **数据持久化** | RDB (关系型数据库) + Preferences (键值存储) |
| **网络** | `@ohos.net.http` (原生 HTTP 客户端) |
| **AI 接口** | OpenAI 兼容 API (流式/非流式) |

### 架构模式

```
View (ArkUI Pages)
  ↕  @State 数据绑定
ViewModel (业务逻辑 + 状态管理)
  ↕
Repository (数据访问抽象层)
  ↕
DataSource (RdbHelper / Preferences)
```

---

## 🚀 快速开始

### 环境要求

- [DevEco Studio](https://developer.harmonyos.com/deveco-studio) 5.0+
- HarmonyOS SDK API 6.1.0 (23)
- HarmonyOS NEXT 设备或模拟器

### 运行步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/yourusername/Spark-Homo.git
   ```

2. **打开项目**
   - 启动 DevEco Studio
   - 选择 `File → Open`，选择项目目录

3. **配置 SDK**
   - 确保已安装 HarmonyOS SDK API 6.1.0 (23)
   - 在 `build-profile.json5` 中确认 SDK 版本配置

4. **运行应用**
   - 连接 HarmonyOS NEXT 设备或启动模拟器
   - 点击 `Run → Run 'entry'`

---

## ⚙️ AI 配置

应用依赖 LLM API 提供 AI 功能，使用前需在"我的"页面完成配置：

1. **选择预设**
   - 内置 OpenAI、DeepSeek、通义千问、智谱 GLM、月之暗面、Claude 等预设
   - 也可自定义预设

2. **填写 API Key**
   - 输入对应 AI 服务的 API 密钥

3. **测试连接**
   - 点击"测试连接"验证配置是否正确

### 默认预设

| 服务商 | 默认模型 |
|--------|----------|
| OpenAI | `gpt-4o-mini` |
| DeepSeek | `deepseek-v4-flash` |
| 通义千问 | `qwen-turbo` |
| 智谱 GLM | `glm-4-flash` |
| 月之暗面 | `moonshot-v1-8k` |
| Claude | `claude-3-haiku-20240307` |

---

## 📦 数据管理

### 导出数据

将应用内的灵感、项目、任务和 AI 配置导出为 JSON 文件：

1. 进入"我的"页面
2. 点击"导出数据"
3. 选择保存位置

### 导入数据

从之前导出的 JSON 文件恢复数据：

1. 进入"我的"页面
2. 点击"导入数据"
3. 选择对应的 JSON 文件

> ⚠️ 导入操作会覆盖现有数据，请谨慎操作

---

## 📁 项目结构

```
entry/src/main/ets/
├── constants/              # 常量定义 (AppConstants)
├── core/utils/             # 工具类 (DateUtil, EmotionMapper)
├── data/
│   ├── datasources/        # 数据源 (RdbHelper)
│   ├── models/             # 数据模型 (Inspiration, SparkProject, SparkTask)
│   └── repositories/       # 数据仓库 (InspirationRepository, ProjectRepository)
├── entryability/           # 应用入口 (EntryAbility)
├── pages/
│   ├── MainPage.ets        # 主页面 (Tab 导航)
│   ├── home/               # 首页
│   ├── inspiration/        # 灵感相关 (列表/详情/思维导图/捕捉)
│   ├── ai/                 # AI 对话
│   ├── project/            # 项目管理
│   └── settings/           # 设置页面
├── services/
│   ├── ai/                 # AI 服务 (AiService)
│   └── storage/            # 存储服务 (SettingsService, DataExportService)
└── viewmodels/             # 视图模型层
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: 添加某个特性'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

## 📄 许可证

本项目基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

---

<div align="center">
  <sub>Built with ❤️ using HarmonyOS NEXT</sub>
</div>
