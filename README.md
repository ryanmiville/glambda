# glambda

Write AWS Lambda functions in Gleam!

[![Package Version](https://img.shields.io/hexpm/v/glambda)](https://hex.pm/packages/glambda)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glambda/)

```sh
gleam add glambda
```
```gleam
  // .src/handler.gleam
  import glambda.{
    type ApiGatewayProxyEventV2, type ApiGatewayProxyResultV2, type Context,
    type JsContext, type JsEvent, type JsResult, ApiGatewayProxyResultV2,
  }
  import gleam/javascript/promise.{type Promise}

  pub fn typed_handler(event: ApiGatewayProxyEventV2, ctx: Context) -> Promise(ApiGatewayProxyResultV2) {
    let response =
      ApiGatewayProxyResultV2(
        status_code: 200,
        headers: dict.from_list([#("Content-Type", "text/plain")]),
        body: Some("hello! from " <> ctx.function_name),
        is_base64_encoded: False,
        cookies: [],
      )
    promise.new(fn(resolve) { resolve(response) })
  }

  pub fn handler(event: JsEvent, ctx: JsContext) -> Promise(JsResult) {
    glambda.api_gateway_proxy_v2_handler(typed_handler)(event, ctx)
  }
```

Further documentation can be found at <https://hexdocs.pm/glambda>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
