import { router } from '@kit.ArkUI';
import { Inspiration } from '../../data/models/Inspiration';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { AiService, MindMapNode } from '../../services/ai/AiService';

@Entry
@Component
struct MindMapPage {
  @State inspiration: Inspiration | null = null;
  @State mindMapData: MindMapNode | null = null;
  @State isLoading: boolean = false;
  @State mapScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;

  private inspirationId: number = 0;
  private inspirationRepository: InspirationRepository = InspirationRepository.getInstance();
  private aiService: AiService = AiService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.inspirationId = params.id;
      this.loadMindMap();
    }
  }

  async loadMindMap(): Promise<void> {
    try {
      this.inspiration = await this.inspirationRepository.getById(this.inspirationId);
      if (this.inspiration) {
        this.isLoading = true;
        const data = await this.aiService.generateMindMap(this.inspiration.content);
        this.mindMapData = data;
        this.isLoading = false;
      }
    } catch (err) {
      console.error(`Failed to load mind map: ${JSON.stringify(err)}`);
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      this.buildHeader()

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.primary'))
          Text('正在生成思维导图...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.mindMapData) {
        this.buildMindMapCanvas()
      } else {
        Column() {
          Text('生成失败')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
          Button('重试')
            .fontSize(14)
            .backgroundColor($r('app.color.primary'))
            .margin({ top: 12 })
            .onClick(() => {
              this.loadMindMap();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
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

      Text('思维导图')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Blank()

      Button('')
        .width(40)
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16 })
  }

  @Builder
  buildMindMapCanvas() {
    Column() {
      Canvas(this.getCanvasContext())
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(16)
        .onReady(() => {
          this.drawMindMap();
        })
        .gesture(
          PinchGesture()
            .onActionUpdate((event: GestureEvent) => {
              this.mapScale = Math.max(0.5, Math.min(2, event.scale));
            })
        )
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
  }

  private canvasContext: CanvasRenderingContext2D | null = null;

  getCanvasContext(): CanvasRenderingContext2D {
    if (!this.canvasContext) {
      this.canvasContext = new CanvasRenderingContext2D();
    }
    return this.canvasContext;
  }

  drawMindMap(): void {
    const ctx = this.canvasContext;
    if (!ctx || !this.mindMapData) return;

    const canvasWidth = 600;
    const canvasHeight = 800;

    ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    ctx.save();
    ctx.scale(this.mapScale, this.mapScale);
    ctx.translate(this.offsetX, this.offsetY);

    const centerX = canvasWidth / 2;
    const centerY = 100;

    this.drawNode(ctx, this.mindMapData, centerX, centerY, 0, 0);

    ctx.restore();
  }

  drawNode(ctx: CanvasRenderingContext2D, node: MindMapNode, x: number, y: number, level: number, angle: number): void {
    const nodeWidth = 120;
    const nodeHeight = 40;
    const colors = ['#007AFF', '#34C759', '#FF9500', '#5856D6', '#FF3B30'];
    const color = colors[level % colors.length];

    ctx.fillStyle = color + '20';
    ctx.strokeStyle = color;
    ctx.lineWidth = 2;

    ctx.beginPath();
    ctx.roundRect(x - nodeWidth / 2, y - nodeHeight / 2, nodeWidth, nodeHeight, 8);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = '#000000';
    ctx.font = '14px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(node.name, x, y);

    if (node.children && node.children.length > 0) {
      const childCount = node.children.length;
      const spreadAngle = Math.min(120, childCount * 30);
      const startAngle = angle - spreadAngle / 2;
      const angleStep = spreadAngle / (childCount - 1 || 1);
      const distance = 120 + level * 20;

      node.children.forEach((child, index) => {
        const childAngle = startAngle + angleStep * index;
        const radian = (childAngle * Math.PI) / 180;
        const childX = x + Math.cos(radian) * distance;
        const childY = y + Math.sin(radian) * distance + 60;

        ctx.strokeStyle = color + '60';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(x, y + nodeHeight / 2);
        ctx.lineTo(childX, childY - nodeHeight / 2);
        ctx.stroke();

        this.drawNode(ctx, child, childX, childY, level + 1, childAngle);
      });
    }
  }
}
