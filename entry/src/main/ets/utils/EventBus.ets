import emitter from '@ohos.events.emitter';

export interface Event {

  on(callback: (data: emitter.EventData, priority?: emitter.EventPriority) => void): void

  once(callback: (data: emitter.EventData, priority?: emitter.EventPriority) => void): void

  emit(priority?: emitter.EventPriority, data?: emitter.EventData): void

  off(): void

}

export class EventImpl implements Event {
  private readonly eventId: number;

  constructor(eventId: number) {
    this.eventId = eventId
  }

  on(callback: (data: emitter.EventData) => void, priority: emitter.EventPriority = emitter.EventPriority.LOW): void {
    emitter.on({ eventId: this.eventId, priority: priority }, callback);
  }

  once(callback: (data: emitter.EventData) => void, priority: emitter.EventPriority = emitter.EventPriority.LOW): void {
    emitter.once({ eventId: this.eventId, priority: priority }, callback);
  }

  emit(priority: emitter.EventPriority = emitter.EventPriority.LOW, data: emitter.EventData = undefined): void {
    if (data) {
      emitter.emit({ eventId: this.eventId, priority: priority }, data)
    } else {
      emitter.emit({ eventId: this.eventId, priority: priority })
    }
  }

  off(): void {
    emitter.off(this.eventId)
  }
}

/**
 * 首页数据源改变
 */
export const SOURCE_CHANGED_EVENT: Event = new EventImpl(1)

/**
 * 历史记录改变
 */
export const HISTORY_CHANGED_EVENT: Event = new EventImpl(2)