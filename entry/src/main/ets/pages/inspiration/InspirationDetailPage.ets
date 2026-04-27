import { router } from '@kit.ArkUI';
import { Inspiration } from '../../data/models/Inspiration';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { AiService, AnalysisResult } from '../../services/ai/AiService';
import { DateUtil } from '../../core/utils/DateUtil';
import { EmotionMapper } from '../../core/utils/EmotionMapper';

@Entry
@Component
struct InspirationDetailPage {
  @State inspiration: Inspiration | null = null;
  @State isAnalyzing: boolean = false;
  @State analysisResult: AnalysisResult | null = null;
  @State isEditing: boolean = false;
  @State editContent: string = '';

  private inspirationId: number = 0;
  private inspirationRepository: InspirationRepository = InspirationRepository.getInstance();
  private aiService: AiService = AiService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.inspirationId = params.id;
      this.loadInspiration();
    }
  }

  async loadInspiration(): Promise<void> {
    try {
      this.inspiration = await this.inspirationRepository.getById(this.inspirationId);
      if (this.inspiration && this.inspiration.aiAnalysis) {
        try {
          this.analysisResult = JSON.parse(this.inspiration.aiAnalysis) as AnalysisResult;
        } catch {
          this.analysisResult = null;
        }
      }
    } catch (err) {
      console.error(`Failed to load inspiration: ${JSON.stringify(err)}`);
    }
  }

  async analyzeInspiration(): Promise<void> {
    if (!this.inspiration) return;
    this.isAnalyzing = true;
    try {
      const result = await this.aiService.analyzeInspiration(this.inspiration.content);
      this.analysisResult = result;
      if (this.inspiration) {
        this.inspiration.aiAnalysis = JSON.stringify(result);
        await this.inspirationRepository.update(this.inspiration);
      }
    } catch (err) {
      console.error(`AI analysis failed: ${JSON.stringify(err)}`);
    } finally {
      this.isAnalyzing = false;
    }
  }

  async deleteInspiration(): Promise<void> {
    try {
      await this.inspirationRepository.delete(this.inspirationId);
      router.back();
    } catch (err) {
      console.error(`Failed to delete inspiration: ${JSON.stringify(err)}`);
    }
  }

  async convertToProject(): Promise<void> {
    if (!this.inspiration) return;
    router.pushUrl({
      url: 'pages/project/ProjectDetailPage',
      params: {
        inspirationId: this.inspiration.id,
        title: this.inspiration.content.substring(0, 20)
      }
    }, router.RouterMode.Standard);
  }

  async saveContent(): Promise<void> {
    if (!this.inspiration) return;
    this.inspiration.content = this.editContent;
    this.inspiration.updatedAt = DateUtil.now();
    await this.inspirationRepository.update(this.inspiration);
    this.isEditing = false;
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          this.buildEmotionSection()
          this.buildContentSection()
          this.buildAiSection()
          this.buildActionButtons()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
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
      Button('←')
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.text_primary'))
        .onClick(() => {
          router.back();
        })

      Blank()

      if (this.isEditing) {
        Button('保存')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.primary'))
          .onClick(() => {
            this.saveContent();
          })
      } else {
        Button('✏️')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.editContent = this.inspiration?.content || '';
            this.isEditing = true;
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16 })
  }

  @Builder
  buildEmotionSection() {
    if (this.inspiration) {
      Column() {
        Text(EmotionMapper.getIcon(this.inspiration.emotion))
          .fontSize(48)
          .margin({ bottom: 8 })

        Text(EmotionMapper.getLabel(this.inspiration.emotion))
          .fontSize(16)
          .fontColor(EmotionMapper.getColor(this.inspiration.emotion))
          .margin({ bottom: 4 })

        Text(DateUtil.format(this.inspiration.createdAt))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))

        if (this.inspiration.getParsedTags().length > 0) {
          Row() {
            ForEach(this.inspiration.getParsedTags(), (tag: string) => {
              Text(tag)
                .fontSize(12)
                .fontColor($r('app.color.primary'))
                .backgroundColor($r('app.color.tag_background'))
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(6)
                .margin({ right: 8 })
            })
          }
          .width('100%')
          .margin({ top: 12 })
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(16)
      .margin({ bottom: 16 })
    }
  }

  @Builder
  buildContentSection() {
    if (this.inspiration) {
      Column() {
        if (this.isEditing) {
          TextArea({ text: $$this.editContent })
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.input_background'))
            .borderRadius(12)
            .padding(12)
            .height(200)
        } else {
          Text(this.inspiration.content)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .lineHeight(24)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(16)
      .margin({ bottom: 16 })
    }
  }

  @Builder
  buildAiSection() {
    Column() {
      Text('AI 助手')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        Button('AI分析')
          .fontSize(13)
          .backgroundColor($r('app.color.primary'))
          .height(40)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.analyzeInspiration();
          })

        Blank().width(8)

        Button('思维导图')
          .fontSize(13)
          .backgroundColor($r('app.color.secondary_button'))
          .fontColor($r('app.color.text_primary'))
          .height(40)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/inspiration/MindMapPage',
              params: { id: this.inspirationId }
            }, router.RouterMode.Standard);
          })

        Blank().width(8)

        Button('AI对话')
          .fontSize(13)
          .backgroundColor($r('app.color.secondary_button'))
          .fontColor($r('app.color.text_primary'))
          .height(40)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ai/AiChatPage',
              params: { id: this.inspirationId }
            }, router.RouterMode.Standard);
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.isAnalyzing) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color($r('app.color.primary'))
          Text('AI 正在分析...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20)
      }

      if (this.analysisResult) {
        this.buildAnalysisResult()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .margin({ bottom: 16 })
  }

  @Builder
  buildAnalysisResult() {
    Column() {
      Row() {
        this.buildScoreItem('可行性', this.analysisResult?.feasibility || 0, $r('app.color.success'))
        this.buildScoreItem('潜力', this.analysisResult?.potential || 0, $r('app.color.primary'))
        this.buildScoreItem('风险', this.analysisResult?.risk || 0, $r('app.color.error'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 16 })

      Column() {
        Text('💡 行动建议')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .margin({ bottom: 8 })

        Text(this.analysisResult?.suggestions || '')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .lineHeight(22)
      }
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.tag_background'))
      .borderRadius(8)
    }
    .width('100%')
  }

  @Builder
  buildScoreItem(label: string, score: number, color: ResourceStr) {
    Column() {
      Stack() {
        Circle({ width: 60, height: 60 })
          .fill(Color.Transparent)
          .stroke($r('app.color.divider'))
          .strokeWidth(4)

        Circle({ width: 60, height: 60 })
          .fill(Color.Transparent)
          .stroke(color)
          .strokeWidth(4)
          .strokeDashArray([score * 3.77, 377])
          .strokeDashOffset(94.25)
          .rotate({ angle: -90 })

        Text(`${score}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
  }

  @Builder
  buildActionButtons() {
    Row() {
      Button('转为项目')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.primary'))
        .layoutWeight(1)
        .height(48)
        .borderRadius(12)
        .onClick(() => {
          this.convertToProject();
        })

      Button('删除')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.error'))
        .width(80)
        .height(48)
        .borderRadius(12)
        .margin({ left: 12 })
        .onClick(() => {
          this.deleteInspiration();
        })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}
