import glambda.{
  type Context, type SqsBatchResponse, type SqsEvent, SqsBatchResponse,
}
import gleam/io
import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option, None}

pub fn handle_request(
  event: SqsEvent,
  _ctx: Context,
) -> Promise(Option(SqsBatchResponse)) {
  io.debug(event)
  promise.resolve(None)
}

pub fn handler(event, ctx) {
  glambda.sqs_handler(handle_request)(event, ctx)
}
