import { router, componentSnapshot, promptAction } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { Inspiration } from '../../data/models/Inspiration';
import { InspirationRepository } from '../../data/repositories/InspirationRepository';
import { AiService, MindMapNode } from '../../services/ai/AiService';
import { SettingsService } from '../../services/storage/SettingsService';
import { image } from '@kit.ImageKit';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';

interface LayoutNode {
  node: MindMapNode;
  x: number;
  y: number;
  subtreeHeight: number;
  depth: number;
  children: LayoutNode[];
}

const NODE_WIDTH = 170;
const NODE_HEIGHT = 50;
const LEVEL_X_GAP = 140;
const SIBLING_Y_GAP = 14;
const NODE_RADIUS = 10;
const ROOT_START_X = 30;

const DEPTH_COLORS: string[] = [
  '#2563EB', // root - blue
  '#059669', // depth 1 - emerald
  '#D97706', // depth 2 - amber
  '#7C3AED', // depth 3 - violet
];

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
  @State showExportMenu: boolean = false;
  @State isExporting: boolean = false;

  private inspirationId: number = 0;
  private inspirationRepository: InspirationRepository = InspirationRepository.getInstance();
  private aiService: AiService = AiService.getInstance();
  private settingsService: SettingsService = SettingsService.getInstance();
  private layoutRoot: LayoutNode | null = null;
  private lastPinchScale: number = 1;

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
          this.buildLayout();
          return;
        } catch {
          console.warn('Failed to parse cached mind map, regenerating...');
        }
      }

      this.isLoading = true;
      const data = await this.aiService.generateMindMap(this.inspiration.content);
      this.mindMapData = data;
      this.isLoading = false;
      this.buildLayout();

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
      this.layoutRoot = null;

      const data = await this.aiService.generateMindMap(this.inspiration.content);
      this.mindMapData = data;
      this.isLoading = false;
      this.buildLayout();

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
      // 左侧按钮区：占位符与右侧按钮等宽，确保标题居中不偏移
      // 右侧有导出(44) + 刷新(44) 两个按钮，故左侧需 44 + 44 = 88 宽度
      Row() {
        Button('←')
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_primary'))
          .constraintSize({ minWidth: 44 })
          .onClick(() => {
            router.back();
          })
      }
      .width(88)

      Text('思维导图')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧按钮区
      Row() {
        Button('↗')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_primary'))
          .constraintSize({ minWidth: 44 })
          .onClick(() => {
            this.showExportMenu = true;
          })

        Button('⟳')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_primary'))
          .constraintSize({ minWidth: 44 })
          .onClick(() => {
            this.regenerateMindMap();
          })
      }
      .width(88)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildMindMapCanvas() {
    Column() {
      Stack() {
        Canvas(this.getCanvasContext())
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.card_background'))
          .id('mindMapCanvas')
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
                .onActionStart((event: GestureEvent) => {
                  this.lastPinchScale = 1;
                })
                .onActionUpdate((event: GestureEvent) => {
                  const relativeScale = event.scale / this.lastPinchScale;
                  this.mapScale = Math.max(0.3, Math.min(3, this.mapScale * relativeScale));
                  this.lastPinchScale = event.scale;
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

        Row() {
          Button('−')
            .fontSize(22)
            .fontColor(Color.White)
            .backgroundColor('#66000000')
            .width(44)
            .height(44)
            .borderRadius(22)
            .onClick(() => {
              this.mapScale = Math.max(0.3, this.mapScale - 0.2);
              this.drawMindMap();
            })

          Button('⟳')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#66000000')
            .width(44)
            .height(44)
            .borderRadius(22)
            .margin({ left: 12, right: 12 })
            .onClick(() => {
              this.mapScale = 1;
              this.offsetX = 0;
              this.offsetY = 0;
              this.drawMindMap();
            })

          Button('+')
            .fontSize(22)
            .fontColor(Color.White)
            .backgroundColor('#66000000')
            .width(44)
            .height(44)
            .borderRadius(22)
            .onClick(() => {
              this.mapScale = Math.min(3, this.mapScale + 0.2);
              this.drawMindMap();
            })
        }
        .position({ x: 16, y: 16 })
        .padding(6)
        .borderRadius(28)
        .backgroundColor('#33000000')
        .justifyContent(FlexAlign.Center)

        if (this.showExportMenu) {
          this.buildExportMenu()
        }
      }
      .width('100%')
      .height('100%')
      .clip(true)
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

  // --- Layout computation (cached, rebuilt only when data changes) ---

  buildLayout(): void {
    if (!this.mindMapData) {
      this.layoutRoot = null;
      return;
    }
    const root = this.buildLayoutTree(this.mindMapData, 0);
    this.computeHeights(root);
    this.assignPositions(root, ROOT_START_X, 0);
    this.layoutRoot = root;
  }

  buildLayoutTree(node: MindMapNode, depth: number): LayoutNode {
    const children: LayoutNode[] = [];
    if (node.children) {
      for (const child of node.children) {
        children.push(this.buildLayoutTree(child, depth + 1));
      }
    }
    return { node, x: 0, y: 0, subtreeHeight: 0, depth, children };
  }

  computeHeights(layout: LayoutNode): number {
    if (layout.children.length === 0) {
      layout.subtreeHeight = NODE_HEIGHT;
      return NODE_HEIGHT;
    }

    let total = 0;
    for (const child of layout.children) {
      total += this.computeHeights(child);
    }
    total += SIBLING_Y_GAP * (layout.children.length - 1);
    layout.subtreeHeight = Math.max(NODE_HEIGHT, total);
    return layout.subtreeHeight;
  }

  assignPositions(layout: LayoutNode, x: number, y: number): void {
    layout.x = x;
    layout.y = y;

    if (layout.children.length === 0) return;

    const childX = x + NODE_WIDTH + LEVEL_X_GAP;
    let currentY = y - layout.subtreeHeight / 2;

    for (const child of layout.children) {
      const childCenterY = currentY + child.subtreeHeight / 2;
      this.assignPositions(child, childX, childCenterY);
      currentY += child.subtreeHeight + SIBLING_Y_GAP;
    }
  }

  // --- Drawing ---

  drawMindMap(): void {
    const ctx = this.canvasContext;
    if (!ctx || !this.layoutRoot) return;

    const width = this.canvasWidth || 360;
    const height = this.canvasHeight || 640;

    ctx.clearRect(0, 0, width, height);

    ctx.save();
    ctx.translate(width / 2, height / 2);
    ctx.scale(this.mapScale, this.mapScale);
    ctx.translate(this.offsetX, this.offsetY);

    this.drawConnections(this.layoutRoot, ctx);
    this.drawAllNodes(this.layoutRoot, ctx);

    ctx.restore();
  }

  drawConnections(layout: LayoutNode, ctx: CanvasRenderingContext2D): void {
    for (const child of layout.children) {
      const startX = layout.x + NODE_WIDTH / 2;
      const startY = layout.y;
      const endX = child.x - NODE_WIDTH / 2;
      const endY = child.y;

      const cpOffsetX = Math.abs(endX - startX) * 0.45;

      ctx.strokeStyle = '#D0D5DD';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(startX, startY);
      ctx.bezierCurveTo(
        startX + cpOffsetX, startY,
        endX - cpOffsetX, endY,
        endX, endY
      );
      ctx.stroke();

      this.drawConnections(child, ctx);
    }
  }

  drawAllNodes(layout: LayoutNode, ctx: CanvasRenderingContext2D): void {
    const x = layout.x;
    const y = layout.y;
    const depth = layout.depth;
    const node = layout.node;
    const color = DEPTH_COLORS[depth % DEPTH_COLORS.length];
    const halfW = NODE_WIDTH / 2;
    const halfH = NODE_HEIGHT / 2;

    // Shadow
    ctx.shadowColor = 'rgba(0, 0, 0, 0.08)';
    ctx.shadowBlur = 6;
    ctx.shadowOffsetX = 0;
    ctx.shadowOffsetY = 2;

    // Node background
    ctx.fillStyle = depth === 0 ? color : (color + '18');
    ctx.strokeStyle = color;
    ctx.lineWidth = depth === 0 ? 2.5 : 1.5;
    ctx.beginPath();
    ctx.roundRect(x - halfW, y - halfH, NODE_WIDTH, NODE_HEIGHT, NODE_RADIUS);
    ctx.fill();
    ctx.stroke();

    // Reset shadow before text
    ctx.shadowColor = 'transparent';
    ctx.shadowBlur = 0;
    ctx.shadowOffsetX = 0;
    ctx.shadowOffsetY = 0;

    // Text — scale to fill ~85% of node box
    ctx.fillStyle = depth === 0 ? '#FFFFFF' : '#1A1A1A';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    let displayName = node.name;
    const maxChars = depth === 0 ? 8 : 9;
    if (displayName.length > maxChars) {
      displayName = displayName.substring(0, maxChars) + '…';
    }

    const baseFont = '14px sans-serif';
    ctx.font = baseFont;
    const metrics = ctx.measureText(displayName);
    const textWidth = metrics.width > 0 ? metrics.width : displayName.length * 14;
    const textHeight = 14;

    const targetW = NODE_WIDTH * 0.92;
    const targetH = NODE_HEIGHT * 0.86;
    const scaleX = targetW / textWidth;
    const scaleY = targetH / textHeight;
    const scale = Math.max(0.6, Math.min(scaleX, scaleY, 2.8));

    ctx.save();
    ctx.translate(x, y);
    ctx.scale(scale, scale);
    ctx.fillText(displayName, 0, 0);
    ctx.restore();

    // Recurse
    for (const child of layout.children) {
      this.drawAllNodes(child, ctx);
    }
  }

  // --- Export ---

  @Builder
  buildExportMenu() {
    Column() {
      Column() {
        Text('导出思维导图')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ top: 24, bottom: 20 })

        Button('PNG 图片')
          .fontSize(15)
          .fontColor('#2563EB')
          .backgroundColor('#F0F5FF')
          .width('100%')
          .height(44)
          .borderRadius(8)
          .margin({ bottom: 12 })
          .onClick(() => {
            this.exportAsPng();
          })

        Button('PDF 文档')
          .fontSize(15)
          .fontColor('#059669')
          .backgroundColor('#F0FDF4')
          .width('100%')
          .height(44)
          .borderRadius(8)
          .margin({ bottom: 20 })
          .onClick(() => {
            this.exportAsPdf();
          })

        Button('取消')
          .fontSize(14)
          .fontColor('#999999')
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height(40)
          .onClick(() => {
            this.showExportMenu = false;
          })
      }
      .width('80%')
      .padding({ left: 24, right: 24, bottom: 16 })
      .borderRadius(16)
      .backgroundColor(Color.White)
      .shadow({ radius: 20, color: '#20000000', offsetY: 8 })
      .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#40000000')
    .position({ x: 0, y: 0 })
    .onClick(() => {
      this.showExportMenu = false;
    })
  }

  async exportAsPng(): Promise<void> {
    await this.doExport('image/png', 'png');
  }

  async exportAsPdf(): Promise<void> {
    await this.doExport('image/jpeg', 'pdf');
  }

  async doExport(format: string, extension: string): Promise<void> {
    this.showExportMenu = false;

    try {
      const pixelMap: image.PixelMap | undefined = await componentSnapshot.get('mindMapCanvas');
      if (!pixelMap) {
        promptAction.showToast({ message: '截图失败，请重试' });
        return;
      }

      this.isExporting = true;

      const packer: image.ImagePacker = image.createImagePacker();
      const packedData: ArrayBuffer = await packer.packing(pixelMap, {
        format: format,
        quality: 95
      });

      let fileData: ArrayBuffer;
      if (extension === 'pdf') {
        fileData = this.generatePdf(pixelMap, packedData);
      } else {
        fileData = packedData;
      }

      const context: Context = getContext(this) as Context;
      const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      const uris: string[] = await documentPicker.save(undefined);

      if (uris && uris.length > 0) {
        const destFile: fs.File = fs.openSync(uris[0], fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
        fs.writeSync(destFile.fd, fileData);
        fs.closeSync(destFile.fd);
        promptAction.showToast({ message: '导出成功' });
      } else {
        promptAction.showToast({ message: '已取消' });
      }

      pixelMap.release();
    } catch (err) {
      console.error('Export error: ' + JSON.stringify(err));
      promptAction.showToast({ message: '导出失败' });
    } finally {
      this.isExporting = false;
    }
  }

  generatePdf(pixelMap: image.PixelMap, jpegData: ArrayBuffer): ArrayBuffer {
    const info = pixelMap.getImageInfoSync();
    const width = info.size.width;
    const height = info.size.height;
    const jpegBytes = new Uint8Array(jpegData);

    const obj1Bytes = this.stringToBytes('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');
    const obj2Bytes = this.stringToBytes('2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');
    const obj3Bytes = this.stringToBytes('3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ' + width + ' ' + height + '] /Contents 4 0 R /Resources << /XObject << /Im1 5 0 R >> >> >>\nendobj\n');
    const obj4Bytes = this.stringToBytes('4 0 obj\n<< /Length 45 >>\nstream\nq ' + width + ' 0 0 ' + height + ' 0 0 cm /Im1 Do Q\nendstream\nendobj\n');

    const imgHeader = '5 0 obj\n<< /Type /XObject /Subtype /Image /Width ' + width + ' /Height ' + height + ' /ColorSpace /DeviceRGB /BitsPerComponent 8 /Length ' + jpegBytes.length + ' /Filter /DCTDecode >>\nstream\n';
    const imgHeaderBytes = this.stringToBytes(imgHeader);
    const imgFooterBytes = this.stringToBytes('\nendstream\nendobj\n');

    let offset = 0;
    const offsets: number[] = [];
    const parts: Uint8Array[] = [];

    offsets.push(offset); parts.push(obj1Bytes); offset += obj1Bytes.length;
    offsets.push(offset); parts.push(obj2Bytes); offset += obj2Bytes.length;
    offsets.push(offset); parts.push(obj3Bytes); offset += obj3Bytes.length;
    offsets.push(offset); parts.push(obj4Bytes); offset += obj4Bytes.length;
    offsets.push(offset); parts.push(imgHeaderBytes); offset += imgHeaderBytes.length;
    parts.push(jpegBytes); offset += jpegBytes.length;
    parts.push(imgFooterBytes); offset += imgFooterBytes.length;

    const xrefStr = 'xref\n0 6\n0000000000 65535 f \n' +
      this.padOffset(offsets[0]) + ' 00000 n \n' +
      this.padOffset(offsets[1]) + ' 00000 n \n' +
      this.padOffset(offsets[2]) + ' 00000 n \n' +
      this.padOffset(offsets[3]) + ' 00000 n \n' +
      this.padOffset(offsets[4]) + ' 00000 n \n';
    const xrefBytes = this.stringToBytes(xrefStr);

    const trailerStr = 'trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n' + offset + '\n%%EOF';
    const trailerBytes = this.stringToBytes(trailerStr);

    const totalSize = offset + xrefBytes.length + trailerBytes.length;
    const result = new Uint8Array(totalSize);
    let pos = 0;
    for (let i = 0; i < parts.length; i++) {
      result.set(parts[i], pos);
      pos += parts[i].length;
    }
    result.set(xrefBytes, pos); pos += xrefBytes.length;
    result.set(trailerBytes, pos);

    return result.buffer as ArrayBuffer;
  }

  stringToBytes(str: string): Uint8Array {
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      bytes[i] = str.charCodeAt(i) & 0xFF;
    }
    return bytes;
  }

  padOffset(num: number): string {
    let s = num.toString();
    while (s.length < 10) {
      s = '0' + s;
    }
    return s;
  }
}
