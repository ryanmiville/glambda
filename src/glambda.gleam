import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option}

pub type JsEvent

pub type JsContext

pub type JsResult

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
    client_cert: APIGatewayEventClientCertificate,
  )
}

pub type APIGatewayEventClientCertificate {
  APIGatewayEventClientCertificate(
    client_cert_pem: String,
    issuer_dn: String,
    serial_number: String,
    subject_dn: String,
    validity: APIGatewayEventValidity,
  )
}

pub type APIGatewayEventValidity {
  APIGatewayEventValidity(not_after: String, not_before: String)
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

// --- Adapters ---------------------------------------------------------------

pub fn to_handler(
  handler: fn(event, Context) -> Promise(result),
  to_event: fn(JsEvent) -> event,
  from_result: fn(result) -> JsResult,
) -> fn(JsEvent, JsContext) -> Promise(JsResult) {
  fn(event: JsEvent, ctx: JsContext) -> Promise(JsResult) {
    let event = to_event(event)
    let ctx = to_context(ctx)
    handler(event, ctx)
    |> promise.map(from_result)
  }
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

// --- FFI --------------------------------------------------------------------

@external(javascript, "./glambda_ffi.mjs", "to_api_gateway_proxy_event_v2")
pub fn to_api_gateway_proxy_event_v2(event: JsEvent) -> ApiGatewayProxyEventV2

@external(javascript, "./glambda_ffi.mjs", "from_api_gateway_proxy_result_v2")
pub fn from_api_gateway_proxy_result_v2(
  result: ApiGatewayProxyResultV2,
) -> JsResult

@external(javascript, "./glambda_ffi.mjs", "to_context")
fn to_context(ctx: JsContext) -> Context
