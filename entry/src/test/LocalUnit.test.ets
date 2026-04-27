import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { AiService, AnalysisResult, MindMapNode, ChatMessage } from '../main/ets/services/ai/AiService';
import { SettingsService } from '../main/ets/services/storage/SettingsService';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    beforeAll(() => {
    })
    beforeEach(() => {
    })
    afterEach(() => {
    })
    afterAll(() => {
    })
    it('assertContain', 0, () => {
      let a = 'abc';
      let b = 'b';
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });
  });

  describe('AiServiceTests', () => {
    let aiService: AiService;
    let settingsService: SettingsService;

    beforeAll(() => {
      aiService = AiService.getInstance();
      settingsService = SettingsService.getInstance();
    });

    beforeEach(() => {
    });

    afterEach(() => {
    });

    afterAll(() => {
    });

    it('testExtractErrorMessage_shouldExtractMessageFromJson', 0, () => {
      const errorJson = '{"error":{"message":"Invalid API key","type":"invalid_request_error"}}';
      const service = AiService.getInstance();
      const result = (service as any).extractErrorMessage(errorJson);
      expect(result).assertEqual('Invalid API key');
    });

    it('testExtractErrorMessage_shouldReturnOriginalWhenNoMessage', 0, () => {
      const errorStr = 'Some random error';
      const service = AiService.getInstance();
      const result = (service as any).extractErrorMessage(errorStr);
      expect(result).assertEqual(errorStr);
    });

    it('testChatMessageInterface', 0, () => {
      const message: ChatMessage = {
        role: 'user',
        content: 'Hello'
      };
      expect(message.role).assertEqual('user');
      expect(message.content).assertEqual('Hello');
    });

    it('testAnalysisResultInterface', 0, () => {
      const result: AnalysisResult = {
        feasibility: 8,
        potential: 9,
        risk: 3,
        suggestions: 'Test suggestion'
      };
      expect(result.feasibility).assertEqual(8);
      expect(result.potential).assertEqual(9);
      expect(result.risk).assertEqual(3);
      expect(result.suggestions).assertEqual('Test suggestion');
    });

    it('testMindMapNodeInterface', 0, () => {
      const node: MindMapNode = {
        name: 'Root',
        children: [
          { name: 'Child1' },
          { name: 'Child2', children: [{ name: 'GrandChild' }] }
        ]
      };
      expect(node.name).assertEqual('Root');
      expect(node.children?.length).assertEqual(2);
      expect(node.children?.[0].name).assertEqual('Child1');
      expect(node.children?.[1].children?.[0].name).assertEqual('GrandChild');
    });

    it('testAiServiceSingleton', 0, () => {
      const instance1 = AiService.getInstance();
      const instance2 = AiService.getInstance();
      expect(instance1 === instance2).assertTrue();
    });
  });
}
