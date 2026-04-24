import http from '@ohos.net.http';
import { SettingsService } from '../storage/SettingsService';

export interface AnalysisResult {
  feasibility: number;
  potential: number;
  risk: number;
  suggestions: string;
}

export interface MindMapNode {
  name: string;
  children?: MindMapNode[];
}

export interface ChatMessage {
  role: string;
  content: string;
}

export interface ApiConfig {
  baseUrl: string;
  apiKey: string;
  model: string;
}

export interface HttpRequestData {
  model: string;
  messages: ChatMessage[];
  temperature: number;
  response_format?: ResponseFormat;
  stream?: boolean;
}

export interface ResponseFormat {
  type: string;
}

export interface HttpResponse {
  responseCode: number;
  result: string;
}

interface ApiMessage {
  role: string;
  content: string;
}

interface ApiChoice {
  message: ApiMessage;
}

interface ApiResponse {
  choices: ApiChoice[];
}

interface StreamDelta {
  content?: string;
}

interface StreamChoice {
  delta: StreamDelta;
}

interface StreamChunk {
  choices: StreamChoice[];
}

export class AiService {
  private static instance: AiService | null = null;
  private settingsService: SettingsService;

  private constructor() {
    this.settingsService = SettingsService.getInstance();
  }

  static getInstance(): AiService {
    if (!AiService.instance) {
      AiService.instance = new AiService();
    }
    return AiService.instance;
  }

  private async getApiConfig(): Promise<ApiConfig> {
    const baseUrl = await this.settingsService.getBaseUrl();
    const apiKey = await this.settingsService.getApiKey();
    const model = await this.settingsService.getModel();
    return { baseUrl, apiKey, model };
  }

  private extractErrorMessage(errorStr: string): string {
    try {
      const msgMatch = errorStr.match(/"message"\s*:\s*"([^"]+)"/);
      if (msgMatch && msgMatch[1]) {
        return msgMatch[1];
      }
    } catch {}
    return errorStr;
  }

  async analyzeInspiration(content: string): Promise<AnalysisResult> {
    const config = await this.getApiConfig();

    const httpRequest = http.createHttp();
    const url = config.baseUrl + '/chat/completions';

    const systemMsg: ChatMessage = {
      role: 'system',
      content: '你是一个创意分析助手。请分析用户的灵感，并返回JSON格式的分析结果，包含：feasibility(可行性1-10)、potential(潜力1-10)、risk(风险1-10)、suggestions(行动建议字符串)。只返回JSON，不要其他文字。'
    };
    const userMsg: ChatMessage = {
      role: 'user',
      content: '请分析这个灵感：' + content
    };

    const requestData: HttpRequestData = {
      model: config.model,
      messages: [systemMsg, userMsg],
      temperature: 0.7,
      response_format: { type: 'json_object' }
    };

    try {
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + config.apiKey
          },
          extraData: JSON.stringify(requestData),
          connectTimeout: 30000,
          readTimeout: 30000
        }
      );

      if (response.responseCode === 200) {
        const resultStr = response.result as string;
        const result: ApiResponse = JSON.parse(resultStr);
        const responseContent = result.choices[0].message.content;
        return JSON.parse(responseContent) as AnalysisResult;
      } else {
        const errorStr = response.result as string;
        let errorMsg = 'HTTP ' + response.responseCode;
        const extracted = this.extractErrorMessage(errorStr);
        if (extracted !== errorStr) {
          errorMsg = extracted;
        }
        throw new Error(errorMsg);
      }
    } catch (err) {
      httpRequest.destroy();
      const msg = err instanceof Error ? err.message : JSON.stringify(err);
      console.error('[AiService] analyzeInspiration error: ' + msg);
      throw new Error('Failed to analyze inspiration: ' + msg);
    } finally {
      httpRequest.destroy();
    }
  }

  async generateMindMap(content: string): Promise<MindMapNode> {
    const config = await this.getApiConfig();

    const httpRequest = http.createHttp();
    const url = config.baseUrl + '/chat/completions';

    const systemMsg: ChatMessage = {
      role: 'system',
      content: '你是一个思维导图生成助手。请基于用户的灵感生成一个树状结构的思维导图，返回JSON格式：{ name: "中心主题", children: [{ name: "分支1", children: [...] }] }。只返回JSON，不要其他文字。'
    };
    const userMsg: ChatMessage = {
      role: 'user',
      content: '请为这个灵感生成思维导图：' + content
    };

    const requestData: HttpRequestData = {
      model: config.model,
      messages: [systemMsg, userMsg],
      temperature: 0.7,
      response_format: { type: 'json_object' }
    };

    try {
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + config.apiKey
          },
          extraData: JSON.stringify(requestData),
          connectTimeout: 30000,
          readTimeout: 30000
        }
      );

      if (response.responseCode === 200) {
        const resultStr = response.result as string;
        const result: ApiResponse = JSON.parse(resultStr);
        const responseContent = result.choices[0].message.content;
        return JSON.parse(responseContent) as MindMapNode;
      } else {
        const errorStr = response.result as string;
        let errorMsg = 'HTTP ' + response.responseCode;
        const extracted = this.extractErrorMessage(errorStr);
        if (extracted !== errorStr) {
          errorMsg = extracted;
        }
        throw new Error(errorMsg);
      }
    } catch (err) {
      httpRequest.destroy();
      const msg = err instanceof Error ? err.message : JSON.stringify(err);
      console.error('[AiService] generateMindMap error: ' + msg);
      throw new Error('Failed to generate mind map: ' + msg);
    } finally {
      httpRequest.destroy();
    }
  }

  async chat(messages: ChatMessage[]): Promise<string> {
    const config = await this.getApiConfig();

    const httpRequest = http.createHttp();
    const url = config.baseUrl + '/chat/completions';

    const requestData: HttpRequestData = {
      model: config.model,
      messages: messages,
      temperature: 0.7
    };

    try {
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + config.apiKey
          },
          extraData: JSON.stringify(requestData),
          connectTimeout: 30000,
          readTimeout: 30000
        }
      );

      if (response.responseCode === 200) {
        const resultStr = response.result as string;
        const result: ApiResponse = JSON.parse(resultStr);
        return result.choices[0].message.content;
      } else {
        const errorStr = response.result as string;
        let errorMsg = 'HTTP ' + response.responseCode;
        const extracted = this.extractErrorMessage(errorStr);
        if (extracted !== errorStr) {
          errorMsg = extracted;
        }
        throw new Error(errorMsg);
      }
    } catch (err) {
      httpRequest.destroy();
      const msg = err instanceof Error ? err.message : JSON.stringify(err);
      console.error('[AiService] chat error: ' + msg);
      throw new Error(msg);
    } finally {
      httpRequest.destroy();
    }
  }

  async chatStream(
    messages: ChatMessage[],
    onData: (chunk: string) => void
  ): Promise<void> {
    const config = await this.getApiConfig();

    const httpRequest = http.createHttp();
    const url = config.baseUrl + '/chat/completions';

    const requestData: HttpRequestData = {
      model: config.model,
      messages: messages,
      temperature: 0.7,
      stream: true
    };

    return new Promise((resolve, reject) => {
      let buffer = '';

      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        const uint8Array = new Uint8Array(data);
        let text = '';
        for (let i = 0; i < uint8Array.length; i++) {
          text += String.fromCharCode(uint8Array[i]);
        }
        buffer += text;

        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          if (line.startsWith('data: ')) {
            const jsonStr = line.substring(6);
            if (jsonStr === '[DONE]') {
              continue;
            }
            try {
              const chunk: StreamChunk = JSON.parse(jsonStr);
              const delta = chunk.choices[0].delta.content;
              if (delta) {
                onData(delta);
              }
            } catch {
            }
          }
        }
      });

      httpRequest.on('dataEnd', () => {
        httpRequest.destroy();
        resolve();
      });

      httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + config.apiKey
          },
          extraData: JSON.stringify(requestData),
          connectTimeout: 60000,
          readTimeout: 60000
        },
        (err: Error) => {
          if (err) {
            console.error('[AiService] chatStream error: ' + JSON.stringify(err));
            httpRequest.destroy();
            reject(new Error('Stream request failed: ' + JSON.stringify(err)));
          }
        }
      );
    });
  }
}
