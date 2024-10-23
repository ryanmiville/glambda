import glambda.{type Context}
import gleam/javascript/promise.{type Promise}
import gleam/string_builder
import wisp.{type Request, type Response}

pub fn handle_request(_req: Request, ctx: Context) -> Promise(Response) {
  string_builder.from_string(
    "{\"functionName\": \"" <> ctx.function_name <> "\"}",
  )
  |> wisp.json_response(200)
  |> promise.resolve
}

pub fn handler(event, ctx) {
  glambda.wisp_handler(handle_request)(event, ctx)
}
