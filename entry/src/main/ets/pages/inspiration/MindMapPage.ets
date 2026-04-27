import { router } from '@kit.ArkUI';
import { Inspiration } from '../../data/models/Inspiration';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { AiService, MindMapNode } from '../../services/ai/AiService';
import { SettingsService } from '../../services/storage/SettingsService';

@Entry
@Component
struct MindMapPage {
  @State inspiration: Inspiration | null = null;
  @State mindMapData: MindMapNode | null = null;
  @State isLoading: boolean = false;
  @State mapScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State canvasWidth: number = 0;
  @State canvasHeight: number = 0;
  @State lastPanX: number = 0;
  @State lastPanY: number = 0;

  private inspirationId: number = 0;
  private inspirationRepository: InspirationRepository = InspirationRepository.getInstance();
  private aiService: AiService = AiService.getInstance();
  private settingsService: SettingsService = SettingsService.getInstance();

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
      if (!this.inspiration) return;

      const cachedData = await this.settingsService.getMindMap(this.inspirationId);
      if (cachedData) {
        try {
          this.mindMapData = JSON.parse(cachedData) as MindMapNode;
          return;
        } catch {
          console.warn('Failed to parse cached mind map, regenerating...');
        }
      }

      this.isLoading = true;
      const data = await this.aiService.generateMindMap(this.inspiration.content);
      this.mindMapData = data;
      this.isLoading = false;

      await this.settingsService.saveMindMap(this.inspirationId, JSON.stringify(data));
    } catch (err) {
      console.error(`Failed to load mind map: ${JSON.stringify(err)}`);
      this.isLoading = false;
    }
  }

  async regenerateMindMap(): Promise<void> {
    try {
      if (!this.inspiration) return;

      this.isLoading = true;
      this.mindMapData = null;

      const data = await this.aiService.generateMindMap(this.inspiration.content);
      this.mindMapData = data;
      this.isLoading = false;

      await this.settingsService.saveMindMap(this.inspirationId, JSON.stringify(data));
    } catch (err) {
      console.error(`Failed to regenerate mind map: ${JSON.stringify(err)}`);
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
              this.regenerateMindMap();
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

      Button('⟳')
        .fontSize(20)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.text_primary'))
        .onClick(() => {
          this.regenerateMindMap();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16 })
  }

  @Builder
  buildMindMapCanvas() {
    Column() {
      Stack() {
        Canvas(this.getCanvasContext())
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .onReady(() => {
            this.drawMindMap();
          })
          .onAreaChange((oldArea, newArea) => {
            this.canvasWidth = newArea.width as number;
            this.canvasHeight = newArea.height as number;
            this.drawMindMap();
          })
          .gesture(
            GestureGroup(GestureMode.Parallel,
              PinchGesture()
                .onActionUpdate((event: GestureEvent) => {
                  this.mapScale = Math.max(0.3, Math.min(3, event.scale));
                  this.drawMindMap();
                }),
              PanGesture()
                .onActionStart((event: GestureEvent) => {
                  this.lastPanX = event.offsetX;
                  this.lastPanY = event.offsetY;
                })
                .onActionUpdate((event: GestureEvent) => {
                  const deltaX = event.offsetX - this.lastPanX;
                  const deltaY = event.offsetY - this.lastPanY;
                  this.offsetX += deltaX / this.mapScale;
                  this.offsetY += deltaY / this.mapScale;
                  this.lastPanX = event.offsetX;
                  this.lastPanY = event.offsetY;
                  this.drawMindMap();
                })
            )
          )
      }
      .width('100%')
      .height('100%')
      .clip(true)

      Row() {
        Button('➖')
          .fontSize(20)
          .backgroundColor($r('app.color.card_background'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.mapScale = Math.max(0.3, this.mapScale - 0.2);
            this.drawMindMap();
          })

        Button('⟲')
          .fontSize(20)
          .backgroundColor($r('app.color.card_background'))
          .width(40)
          .height(40)
          .margin({ left: 8, right: 8 })
          .onClick(() => {
            this.mapScale = 1;
            this.offsetX = 0;
            this.offsetY = 0;
            this.drawMindMap();
          })

        Button('➕')
          .fontSize(20)
          .backgroundColor($r('app.color.card_background'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.mapScale = Math.min(3, this.mapScale + 0.2);
            this.drawMindMap();
          })
      }
      .position({ x: 16, y: 16 })
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

    const width = this.canvasWidth || 600;
    const height = this.canvasHeight || 800;

    ctx.clearRect(0, 0, width, height);
    ctx.save();
    ctx.scale(this.mapScale, this.mapScale);
    ctx.translate(this.offsetX + width / (2 * this.mapScale), this.offsetY + height / (2 * this.mapScale));

    this.drawNode(ctx, this.mindMapData, 0, 0, 0, 0);

    ctx.restore();
  }

  drawNode(ctx: CanvasRenderingContext2D, node: MindMapNode, x: number, y: number, level: number, angle: number): void {
    const nodeWidth = Math.max(120, node.name.length * 14 + 20);
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
      const distance = 140 + level * 30;

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