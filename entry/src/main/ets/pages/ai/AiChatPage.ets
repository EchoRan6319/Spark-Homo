import { router } from '@kit.ArkUI';
import { Inspiration } from '../../data/models/Inspiration';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { AiService } from '../../services/ai/AiService';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

interface ChatMessageBuilder {
  role: string;
  content: string;
}

@Entry
@Component
struct AiChatPage {
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isStreaming: boolean = false;
  @State inspiration: Inspiration | null = null;

  private inspirationId: number = 0;
  private inspirationRepository: InspirationRepository = InspirationRepository.getInstance();
  private aiService: AiService = AiService.getInstance();
  private scrollController: Scroller = new Scroller();

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
      if (this.inspiration) {
        const prefix = '我已经了解了你的灵感："' + this.inspiration.content.substring(0, 50) + (this.inspiration.content.length > 50 ? '...' : '') + '"\n\n有什么我可以帮你的吗？';
        const initMsg: ChatMessage = { role: 'assistant', content: prefix };
        this.messages.push(initMsg);
      }
    } catch (err) {
      console.error('Failed to load inspiration: ' + JSON.stringify(err));
    }
  }

  async sendMessage(): Promise<void> {
    if (!this.inputText.trim() || this.isStreaming) return;

    const userMessage = this.inputText.trim();
    this.messages.push({ role: 'user', content: userMessage });
    this.inputText = '';
    this.isStreaming = true;

    const aiMessageIndex = this.messages.length;
    this.messages.push({ role: 'assistant', content: '' });

    try {
      const chatMessages = this.buildChatMessages();
      const response = await this.aiService.chat(chatMessages);
      this.messages[aiMessageIndex].content = response || '(空回复)';
      this.messages = [...this.messages];
    } catch (err) {
      console.error(`Chat failed: ${JSON.stringify(err)}`);
      this.messages[aiMessageIndex].content = '抱歉，发生了错误：' + (err instanceof Error ? err.message : '请稍后重试。');
      this.messages = [...this.messages];
    } finally {
      this.isStreaming = false;
    }
  }

  buildChatMessages(): ChatMessageBuilder[] {
    const messages: ChatMessageBuilder[] = [];

    if (this.inspiration) {
      const systemMsg: ChatMessageBuilder = { role: 'system', content: '' };
      systemMsg.content = '你是一个创意助手。用户有一个灵感："' + this.inspiration.content + '"。请基于这个灵感提供帮助和建议。';
      messages.push(systemMsg);
    }

    for (let i = 0; i < this.messages.length; i++) {
      const msg = this.messages[i];
      if (msg.role !== 'assistant' || msg.content) {
        const msgBuilder: ChatMessageBuilder = { role: msg.role, content: msg.content };
        messages.push(msgBuilder);
      }
    }

    return messages;
  }

  clearChat(): void {
    this.messages = [];
    if (this.inspiration) {
      const prefix = '我已经了解了你的灵感："' + this.inspiration.content.substring(0, 50) + (this.inspiration.content.length > 50 ? '...' : '') + '"\n\n有什么我可以帮你的吗？';
      const initMsg: ChatMessage = { role: 'assistant', content: prefix };
      this.messages.push(initMsg);
    }
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildMessageList()
      this.buildInputArea()
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

      Column() {
        Text('AI 对话')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        if (this.inspiration) {
          Text(this.inspiration.content.substring(0, 20) + (this.inspiration.content.length > 20 ? '...' : ''))
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .textAlign(TextAlign.Center)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Button('清空')
        .fontSize(13)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.primary'))
        .constraintSize({ minWidth: 44 })
        .onClick(() => {
          this.clearChat();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildMessageList() {
    List({ scroller: this.scrollController }) {
      ForEach(this.messages, (message: ChatMessage, index: number) => {
        ListItem() {
          if (message.role === 'user') {
            this.buildUserMessage(message.content)
          } else {
            this.buildAiMessage(message.content, index)
          }
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
  }

  @Builder
  buildUserMessage(content: string) {
    Row() {
      Blank()

      Column() {
        Text(content)
          .fontSize(15)
          .fontColor(Color.White)
          .constraintSize({ maxWidth: '80%' })
      }
      .padding(12)
      .backgroundColor($r('app.color.primary'))
      .borderRadius(16)
      .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  buildAiMessage(content: string, index: number) {
    Row() {
      Column() {
        Text('🤖')
          .fontSize(24)
          .margin({ right: 8 })
      }

      Column() {
        Text(content || (this.isStreaming && index === this.messages.length - 1 ? '思考中...' : ''))
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
          .constraintSize({ maxWidth: '80%' })
      }
      .padding(12)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })

      Blank()
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  buildInputArea() {
    Row() {
      TextInput({ placeholder: '输入消息...', text: $$this.inputText })
        .placeholderColor($r('app.color.text_secondary'))
        .fontSize(15)
        .height(48)
        .backgroundColor($r('app.color.input_background'))
        .borderRadius(24)
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .onSubmit(() => {
          this.sendMessage();
        })

      Button('发送')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.inputText.trim() && !this.isStreaming ? $r('app.color.primary') : $r('app.color.divider'))
        .fontColor(this.inputText.trim() && !this.isStreaming ? Color.White : $r('app.color.text_secondary'))
        .height(48)
        .margin({ left: 8 })
        .onClick(() => {
          this.sendMessage();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
  }
}
