import glambda.{type Context, type EventBridgeEvent}
import gleam/io
import gleam/javascript/promise.{type Promise}

pub fn handle_request(event: EventBridgeEvent, _ctx: Context) -> Promise(Nil) {
  io.debug(event)
  promise.resolve(Nil)
}

pub fn handler(event, ctx) {
  glambda.eventbridge_handler(handle_request)(event, ctx)
}
