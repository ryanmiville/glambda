import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/http
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response, Response}
import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/string

pub type JsEvent

pub type JsContext

pub type JsResult {
  JsResult
  Void
}

pub type JsHandler =
  fn(JsEvent, JsContext) -> Promise(JsResult)

pub type Handler(event, result) =
  fn(event, Context) -> Promise(result)

// --- Context ----------------------------------------------------------------

pub type Context {
  Context(
    callback_waits_for_empty_event_loop: Bool,
    function_name: String,
    function_version: String,
    invoked_function_arn: String,
    memory_limit_in_mb: String,
    aws_request_id: String,
    log_group_name: String,
    log_stream_name: String,
    identity: Option(CognitoIdentity),
    client_context: Option(ClientContext),
  )
}

pub type CognitoIdentity {
  CognitoIdentity(cognito_identity_id: String, cognito_identity_pool_id: String)
}

pub type ClientContext {
  ClientContext(
    client: ClientContextClient,
    custom: Option(Dynamic),
    env: ClientContextEnv,
  )
}

pub type ClientContextClient {
  ClientContextClient(
    installation_id: String,
    app_title: String,
    app_version_name: String,
    app_package_name: String,
  )
}

pub type ClientContextEnv {
  ClientContextEnv(
    platform_version: String,
    platform: String,
    make: String,
    model: String,
    locale: String,
  )
}

// --- API Gateway ------------------------------------------------------------

pub type ApiGatewayProxyEventV2 {
  ApiGatewayProxyEventV2(
    version: String,
    route_key: String,
    raw_path: String,
    raw_query_string: String,
    cookies: Option(List(String)),
    headers: Dict(String, String),
    query_string_parameters: Option(Dict(String, String)),
    path_parameters: Option(Dict(String, String)),
    stage_variables: Option(Dict(String, String)),
    request_context: ApiGatewayRequestContextV2,
    body: Option(String),
    is_base64_encoded: Bool,
  )
}

pub type ApiGatewayRequestContextV2 {
  ApiGatewayRequestContextV2(
    route_key: String,
    account_id: String,
    stage: String,
    request_id: String,
    authorizer: Option(ApiGatewayRequestContextAuthorizer),
    api_id: String,
    domain_name: String,
    domain_prefix: String,
    time: String,
    time_epoch: Int,
    http: ApiGatewayEventRequestContextHttp,
    authentication: Option(ApiGatewayEventRequestContextAuthentication),
  )
}

pub type ApiGatewayRequestContextAuthorizer {
  Iam(iam: ApiGatewayEventRequestContextIamAuthorizer)
  Jwt(
    principal_id: String,
    integration_latency: Int,
    jwt: ApiGatewayEventRequestContextJwtAuthorizer,
  )
  Lambda(lambda: Dynamic)
}

pub type ApiGatewayEventRequestContextHttp {
  ApiGatewayEventRequestContextHttp(
    method: String,
    path: String,
    protocol: String,
    source_ip: String,
    user_agent: String,
  )
}

pub type ApiGatewayEventRequestContextAuthentication {
  ApiGatewayEventRequestContextAuthentication(
    client_cert: ApiGatewayEventClientCertificate,
  )
}

pub type ApiGatewayEventClientCertificate {
  ApiGatewayEventClientCertificate(
    client_cert_pem: String,
    issuer_dn: String,
    serial_number: String,
    subject_dn: String,
    validity: ApiGatewayEventValidity,
  )
}

pub type ApiGatewayEventValidity {
  ApiGatewayEventValidity(not_after: String, not_before: String)
}

pub type ApiGatewayEventRequestContextIamAuthorizer {
  ApiGatewayEventRequestContextIamAuthorizer(
    access_key: String,
    account_id: String,
    caller_id: String,
    principal_org_id: String,
    user_arn: String,
    user_id: String,
  )
}

pub type ApiGatewayEventRequestContextJwtAuthorizer {
  ApiGatewayEventRequestContextJwtAuthorizer(
    claims: Dict(String, String),
    scopes: Option(List(String)),
  )
}

pub type ApiGatewayProxyResultV2 {
  ApiGatewayProxyResultV2(
    status_code: Int,
    headers: Dict(String, String),
    body: Option(String),
    is_base64_encoded: Bool,
    cookies: List(String),
  )
}

// --- EventBridge ------------------------------------------------------------

pub type EventBridgeEvent {
  EventBridgeEvent(
    id: String,
    version: String,
    account: String,
    time: String,
    region: String,
    resources: List(String),
    source: String,
    detail: Dynamic,
  )
}

// --- SQS --------------------------------------------------------------------

pub type SqsEvent {
  SqsEvent(records: List(SqsRecord))
}

pub type SqsRecord {
  SqsRecord(
    message_id: String,
    receipt_handle: String,
    body: String,
    attributes: SqsRecordAttributes,
    message_attributes: Dict(String, SqsMessageAttribute),
    md5_of_body: String,
    event_source: String,
    event_source_arn: String,
    aws_region: String,
  )
}

pub type SqsRecordAttributes {
  SqsRecordAttributes(
    aws_trace_header: Option(String),
    approximate_receive_count: String,
    sent_timestamp: String,
    sender_id: String,
    approximate_first_receive_timestamp: String,
    sequence_number: Option(String),
    message_group_id: Option(String),
    message_deduplication_id: Option(String),
    dead_letter_queue_source_arn: Option(String),
  )
}

pub type SqsMessageAttribute {
  SqsMessageAttribute(
    string_value: Option(String),
    binary_value: Option(String),
    string_list_values: Option(List(String)),
    binary_list_values: Option(List(String)),
    data_type: String,
  )
}

pub type SqsBatchResponse {
  SqsBatchResponse(batch_item_failures: List(SqsBatchItemFailure))
}

pub type SqsBatchItemFailure {
  SqsBatchItemFailure(item_identifier: String)
}

// --- Adapters ---------------------------------------------------------------

pub fn http_handler(
  handler: Handler(Request(Option(String)), Response(Option(String))),
) -> JsHandler {
  api_gateway_proxy_v2_handler(fn(event, ctx) {
    event
    |> create_request
    |> handler(ctx)
    |> promise.map(from_response)
  })
}

pub fn create_request(event: ApiGatewayProxyEventV2) -> Request(Option(String)) {
  let body = event.body
  let method =
    event.request_context.http.method
    |> http.parse_method
    |> result.unwrap(http.Get)
  let headers = case event.cookies {
    Some([_] as cookies) -> {
      event.headers
      |> dict.insert("cookie", string.join(cookies, "; "))
      |> dict.to_list
    }
    _ -> dict.to_list(event.headers)
  }
  let host = event.request_context.domain_name
  let path = event.raw_path
  let query = string.to_option(event.raw_query_string)

  Request(
    method:,
    headers:,
    body:,
    scheme: http.Https,
    host:,
    port: None,
    path:,
    query:,
  )
}

fn from_response(response: Response(Option(String))) -> ApiGatewayProxyResultV2 {
  let is_base64_encoded = is_base64_encoded(response)
  let body = case response.body {
    Some(body) if is_base64_encoded -> Some(base64_encode(body))
    _ -> response.body
  }
  let cookies = get_cookies(response)

  ApiGatewayProxyResultV2(
    status_code: response.status,
    headers: dict.from_list(response.headers),
    body: body,
    is_base64_encoded:,
    cookies:,
  )
}

fn is_base64_encoded(response: Response(Option(String))) {
  let is_content_type_binary =
    response.get_header(response, "content-type")
    |> result.map(is_content_type_binary)

  case is_content_type_binary {
    Ok(True) -> True
    _ -> {
      response.get_header(response, "content-encoding")
      |> result.map(is_content_encoding_binary)
      |> result.unwrap(False)
    }
  }
}

fn base64_encode(body: String) -> String {
  body
  |> bit_array.from_string
  |> bit_array.base64_encode(False)
}

fn get_cookies(response: Response(_)) -> List(String) {
  response.get_cookies(response)
  |> list.map(fn(cookie) { cookie.0 <> "=" <> cookie.1 })
}

fn is_content_type_binary(content_type: String) -> Bool {
  let assert Ok(re) =
    regex.from_string(
      "!/^(text\\/(plain|html|css|javascript|csv).*|application\\/(.*json|.*xml).*|image\\/svg\\+xml.*)$/",
    )
  regex.check(re, content_type)
}

fn is_content_encoding_binary(content_encoding: String) -> Bool {
  let assert Ok(re) = regex.from_string("/^(gzip|deflate|compress|br)/")
  regex.check(re, content_encoding)
}

pub fn api_gateway_proxy_v2_handler(
  handler: Handler(ApiGatewayProxyEventV2, ApiGatewayProxyResultV2),
) -> JsHandler {
  fn(event: JsEvent, ctx: JsContext) -> Promise(JsResult) {
    let event = to_api_gateway_proxy_event_v2(event)
    let ctx = to_context(ctx)
    handler(event, ctx)
    |> promise.map(from_api_gateway_proxy_result_v2)
  }
}

pub fn eventbridge_handler(handler: Handler(EventBridgeEvent, Nil)) -> JsHandler {
  fn(event: JsEvent, ctx: JsContext) -> Promise(JsResult) {
    let event = to_eventbridge_event(event)
    let ctx = to_context(ctx)
    handler(event, ctx)
    |> promise.map(fn(_) { Void })
  }
}

// --- FFI --------------------------------------------------------------------

@external(javascript, "./glambda_ffi.mjs", "toApiGatewayProxyEventV2")
pub fn to_api_gateway_proxy_event_v2(event: JsEvent) -> ApiGatewayProxyEventV2

@external(javascript, "./glambda_ffi.mjs", "fromApiGatewayProxyResultV2")
pub fn from_api_gateway_proxy_result_v2(
  result: ApiGatewayProxyResultV2,
) -> JsResult

@external(javascript, "./glambda_ffi.mjs", "toContext")
fn to_context(ctx: JsContext) -> Context

@external(javascript, "./glambda_ffi.mjs", "toEventBridgeEvent")
pub fn to_eventbridge_event(event: JsEvent) -> EventBridgeEvent
