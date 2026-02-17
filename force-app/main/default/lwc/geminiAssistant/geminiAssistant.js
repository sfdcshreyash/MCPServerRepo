import { LightningElement, track } from 'lwc';
import processUserIntent from '@salesforce/apex/GeminiService.processUserIntent';

export default class GeminiAssistant extends LightningElement {

    // ── State ────────────────────────────────────────────────────────────
    @track messages    = [];
    @track promptValue = '';
    @track isLoading   = false;
    msgCounter         = 0;

    // ── Derived getters ──────────────────────────────────────────────────
    get isEmpty()        { return this.messages.length === 0; }
    get messageCount()   { return this.messages.filter(m => !m.isLoading).length; }
    get isSendDisabled() { return this.isLoading || !this.promptValue.trim(); }
    get askBtnClass() {
        return 'ga-ask-btn' + (this.isSendDisabled ? ' ga-ask-btn--off' : ' ga-ask-btn--on');
    }

    // ── Input handlers ───────────────────────────────────────────────────
    handleInput(evt) { this.promptValue = evt.target.value; }
    clearInput()     { this.promptValue = ''; }

    handleKeyUp(evt) {
        if (evt.key === 'Enter' && !this.isSendDisabled) {
            this.handleSend();
        }
    }

    // ── Send ─────────────────────────────────────────────────────────────
    async handleSend() {
        const text = this.promptValue.trim();
        if (!text || this.isLoading) return;

        this.addMessage({ text, isUser: true });
        this.promptValue = '';
        this.isLoading   = true;

        const loadingId = this.addMessage({ isUser: false, isLoading: true });

        try {
            const response = await processUserIntent({ userMessage: text });
            this.replaceMessage(loadingId, response);
        } catch (err) {
            const msg = (err && err.body && err.body.message) || (err && err.message) || 'Something went wrong.';
            this.replaceMessage(loadingId, 'Error: ' + msg, true);
        } finally {
            this.isLoading = false;
            this.scrollToBottom();
        }
    }

    // ── Message helpers ──────────────────────────────────────────────────
    addMessage({ text = '', isUser = false, isLoading = false }) {
        const id = ++this.msgCounter;
        this.messages = [
            ...this.messages,
            {
                id,
                text,
                isUser,
                isLoading,
                isSuccess  : !isUser && !isLoading && this.isSuccess(text),
                isError    : !isUser && !isLoading && this.isErr(text),
                rowClass   : 'ga-row ' + (isUser ? 'ga-row--user' : 'ga-row--ai'),
                bubbleClass: 'ga-bubble ga-bubble-ai' + (isLoading ? ' ga-bubble-loading' : ''),
            }
        ];
        return id;
    }

    replaceMessage(id, text, forceError = false) {
        this.messages = this.messages.map(m => {
            if (m.id !== id) return m;
            const isError   = forceError || this.isErr(text);
            const isSuccess = !isError   && this.isSuccess(text);
            return {
                ...m,
                text,
                isLoading   : false,
                isSuccess,
                isError,
                bubbleClass : 'ga-bubble ga-bubble-ai' + (isError ? ' ga-bubble-ai--err' : ''),
            };
        });
    }

    isSuccess(t) {
        return t && (
            t.includes('successfully') ||
            t.includes('created') ||
            t.includes('updated')
        );
    }

    isErr(t) {
        if (!t) return false;
        const l = t.toLowerCase();
        return l.startsWith('error') || l.startsWith('failed') ||
               t.includes('does not exist') || t.startsWith('No ');
    }

    // ── Clear ─────────────────────────────────────────────────────────────
    clearChat() {
        this.messages    = [];
        this.msgCounter  = 0;
        this.promptValue = '';
    }

    // ── Scroll ───────────────────────────────────────────────────────────
    scrollToBottom() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const area = this.template.querySelector('.ga-conversation');
            if (area) area.scrollTop = area.scrollHeight;
        }, 80);
    }
}