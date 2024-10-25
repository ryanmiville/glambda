import glambda.{
  type ApiGatewayProxyEventV2, type ApiGatewayProxyResultV2, type Context,
  ApiGatewayProxyResultV2,
}
import gleam/dict
import gleam/javascript/promise.{type Promise}
import gleam/option.{Some}

fn handle_request(
  _event: ApiGatewayProxyEventV2,
  ctx: Context,
) -> Promise(ApiGatewayProxyResultV2) {
  ApiGatewayProxyResultV2(
    status_code: 200,
    headers: dict.from_list([#("content-type", "application/json")]),
    body: Some("{\"functionName\": \"" <> ctx.function_name <> "\"}"),
    is_base64_encoded: False,
    cookies: [],
  )
  |> promise.resolve
}

pub fn handler(event, ctx) {
  glambda.api_gateway_proxy_v2_handler(handle_request)(event, ctx)
}
