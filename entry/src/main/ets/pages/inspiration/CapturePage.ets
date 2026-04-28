import { router } from '@kit.ArkUI';
import { Inspiration } from '../../data/models/Inspiration';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { EmotionMapper, EmotionInfo } from '../../core/utils/EmotionMapper';
import { DateUtil } from '../../core/utils/DateUtil';

@Entry
@Component
struct CapturePage {
  @State content: string = '';
  @State selectedEmotion: string = 'thinking';
  @State tags: string[] = [];
  @State tagInput: string = '';
  @State isEditing: boolean = false;
  @State inspirationId: number = 0;

  private inspirationRepository: InspirationRepository = InspirationRepository.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.inspirationId = params.id;
      this.isEditing = true;
      this.loadInspiration();
    }
  }

  async loadInspiration(): Promise<void> {
    try {
      const inspiration = await this.inspirationRepository.getById(this.inspirationId);
      if (inspiration) {
        this.content = inspiration.content;
        this.selectedEmotion = inspiration.emotion || 'thinking';
        this.tags = inspiration.getParsedTags();
      }
    } catch (err) {
      console.error(`Failed to load inspiration: ${JSON.stringify(err)}`);
    }
  }

  async saveInspiration(): Promise<void> {
    if (!this.content.trim()) {
      return;
    }

    const inspiration = new Inspiration();
    inspiration.content = this.content.trim();
    inspiration.emotion = this.selectedEmotion;
    inspiration.tags = JSON.stringify(this.tags);
    inspiration.updatedAt = DateUtil.now();

    try {
      if (this.isEditing && this.inspirationId > 0) {
        inspiration.id = this.inspirationId;
        inspiration.createdAt = DateUtil.now();
        await this.inspirationRepository.update(inspiration);
      } else {
        inspiration.createdAt = DateUtil.now();
        await this.inspirationRepository.insert(inspiration);
      }
      router.back();
    } catch (err) {
      console.error(`Failed to save inspiration: ${JSON.stringify(err)}`);
    }
  }

  addTag(): void {
    const tag = this.tagInput.trim();
    if (tag && !this.tags.includes(tag)) {
      this.tags.push(tag);
      this.tagInput = '';
    }
  }

  removeTag(tag: string): void {
    const index = this.tags.indexOf(tag);
    if (index > -1) {
      this.tags.splice(index, 1);
    }
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          this.buildContentInput()
          this.buildEmotionSelector()
          this.buildTagInput()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)

      this.buildSaveButton()
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
        .constraintSize({ minWidth: 44 })
        .onClick(() => {
          router.back();
        })

      Text(this.isEditing ? '编辑灵感' : '捕捉灵感')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('')
        .constraintSize({ minWidth: 44 })
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildContentInput() {
    Column() {
      Text('灵感内容')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 8 })

      TextArea({ text: $$this.content })
        .placeholderColor($r('app.color.text_secondary'))
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(12)
        .padding(12)
        .height(200)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  buildEmotionSelector() {
    Column() {
      Text('情绪')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        ForEach(EmotionMapper.getEmotionList(), (emotion: EmotionInfo) => {
          Column() {
            Text(emotion.icon)
              .fontSize(28)
              .margin({ bottom: 4 })

            Text(emotion.label)
              .fontSize(12)
              .fontColor(this.selectedEmotion === emotion.key ? emotion.color : $r('app.color.text_secondary'))
          }
          .width('20%')
          .padding(8)
          .backgroundColor(this.selectedEmotion === emotion.key ? $r('app.color.tag_background') : Color.Transparent)
          .borderRadius(12)
          .onClick(() => {
            this.selectedEmotion = emotion.key;
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  buildTagInput() {
    Column() {
      Text('标签')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        TextInput({ placeholder: '添加标签...', text: $$this.tagInput })
          .placeholderColor($r('app.color.text_secondary'))
          .fontSize(14)
          .height(40)
          .backgroundColor($r('app.color.input_background'))
          .borderRadius(8)
          .layoutWeight(1)
          .onSubmit(() => {
            this.addTag();
          })

        Button('添加')
          .fontSize(14)
          .backgroundColor($r('app.color.primary'))
          .height(40)
          .margin({ left: 8 })
          .onClick(() => {
            this.addTag();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tags, (tag: string) => {
            Row() {
              Text(tag)
                .fontSize(13)
                .fontColor($r('app.color.primary'))
                .margin({ right: 4 })

              Text('✕')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .onClick(() => {
                  this.removeTag(tag);
                })
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor($r('app.color.tag_background'))
            .borderRadius(8)
            .margin({ right: 8, bottom: 8 })
          })
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  buildSaveButton() {
    Button(this.isEditing ? '保存修改' : '保存灵感')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .backgroundColor($r('app.color.primary'))
      .width('90%')
      .height(52)
      .borderRadius(12)
      .margin({ bottom: 24 })
      .onClick(() => {
        this.saveInspiration();
      })
  }
}