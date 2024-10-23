# glambda

Write AWS Lambda functions in Gleam!

[![Package Version](https://img.shields.io/hexpm/v/glambda)](https://hex.pm/packages/glambda)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glambda/)

Write your Lambda function as a [wisp](https://github.com/gleam-wisp/wisp) handler, or accept direct events as normal Gleam types.

Glambda works by compiling your Gleam code to JavaScript, and then using the AWS Lambda Node.js runtime to run your code.

```sh
gleam add glambda
```

## Wisp Handler

```gleam
import glambda.{type Context}
import gleam/javascript/promise.{type Promise}
import gleam/json
import wisp.{type Request, type Reponse}

fn handle_request(req: Request, ctx: Context) -> Promise(Response) {
  string_builder.from_string(
    "{\"functionName\": \"" <> ctx.function_name <> "\"}",
  )
  |> wisp.json_response(200)
  |> promise.resolve
}

pub fn handler(event, ctx) {
  glambda.wisp_handler(handle_request)(event, ctx)
}
```

## Event Handler

```gleam
import glambda.{
  type ApiGatewayProxyEventV2, type ApiGatewayProxyResultV2, type Context,
  ApiGatewayProxyResultV2,
}
import gleam/dict
import gleam/javascript/promise.{type Promise}
import gleam/option.{Some}

fn event_handler(
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
  glambda.api_gateway_proxy_v2_handler(event_handler)(event, ctx)
}
```

## Supported Events
* `ApiGatewayProxyEventV2`

Further documentation can be found at <https://hexdocs.pm/glambda>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
