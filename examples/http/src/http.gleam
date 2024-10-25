import glambda.{type Context}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response, Response}
import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option, Some}

pub fn handle_request(
  _req: Request(Option(String)),
  ctx: Context,
) -> Promise(Response(Option(String))) {
  let json = "{\"functionName\": \"" <> ctx.function_name <> "\"}"
  Response(
    200,
    [#("content-type", "application/json; charset=utf-8")],
    Some(json),
  )
  |> promise.resolve
}

pub fn handler(event, ctx) {
  glambda.http_handler(handle_request)(event, ctx)
}
