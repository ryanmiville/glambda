import birdie
import glambda.{
  type ApiGatewayProxyResultV2, type Handler, type JsContext, type JsEvent,
  type JsHandler, ApiGatewayProxyResultV2, SqsBatchItemFailure, SqsBatchResponse,
}
import gleam/dict
import gleam/http/response.{Response}
import gleam/javascript/promise
import gleam/option.{None, Some}
import gleeunit
import pprint.{BitArraysAsString, Config, Labels, Unstyled}
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn http_request_test() {
  js_event("./test/testdata/apigw-v2-request-no-authorizer.json")
  |> request_snap(glambda.http_handler, Response(200, [], None), "HTTP request")
}

pub fn http_minimal_response_test() {
  Response(200, [], None)
  |> response_snap(
    glambda.http_handler,
    js_event("./test/testdata/apigw-v2-request-no-authorizer.json"),
    "Minimal HTTP response",
  )
}

pub fn http_response_test() {
  Response(
    status: 200,
    headers: [
      #(
        "Accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      ),
      #("Accept-Encoding", "gzip, deflate, lzma, sdch, br"),
      #("Accept-Language", "en-US,en;q=0.8"),
      #("CloudFront-Forwarded-Proto", "https"),
      #("CloudFront-Is-Desktop-Viewer", "true"),
      #("CloudFront-Is-Mobile-Viewer", "false"),
      #("CloudFront-Is-SmartTV-Viewer", "false"),
      #("CloudFront-Is-Tablet-Viewer", "false"),
      #("CloudFront-Viewer-Country", "US"),
      #("Host", "wt6mne2s9k.execute-api.us-west-2.amazonaws.com"),
      #("Upgrade-Insecure-Requests", "1"),
      #(
        "User-Agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.82 Safari/537.36 OPR/39.0.2256.48",
      ),
      #(
        "Via",
        "1.1 fb7cca60f0ecd82ce07790c9c5eef16c.cloudfront.net (CloudFront)",
      ),
      #(
        "X-Amz-Cf-Id",
        "nBsWBOrSHMgnaROZJK1wGCZ9PcRcSpq_oSXZNQwQ10OTZL4cimZo3g==",
      ),
      #("X-Forwarded-For", "192.168.100.1, 192.168.1.1"),
      #("X-Forwarded-Port", "443"),
      #("X-Forwarded-Proto", "https"),
      #("set-cookie", "cookie1=1; cookie2=2"),
    ],
    body: Some("Hello World"),
  )
  |> response_snap(
    glambda.http_handler,
    js_event("./test/testdata/apigw-v2-request-no-authorizer.json"),
    "HTTP response",
  )
}

pub fn api_gateway_v2_http_request_no_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-no-authorizer.json")
  |> api_gateway_request_snap("API Gateway V2 HTTP request with no authorizer")
}

pub fn api_gateway_v2_http_request_iam_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-iam.json")
  |> api_gateway_request_snap("API Gateway V2 HTTP request with IAM authorizer")
}

pub fn api_gateway_v2_http_request_jwt_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-jwt-authorizer.json")
  |> api_gateway_request_snap("API Gateway V2 HTTP request with JWT authorizer")
}

pub fn api_gateway_v2_http_request_lambda_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-lambda-authorizer.json")
  |> api_gateway_request_snap(
    "API Gateway V2 HTTP request with Lambda authorizer",
  )
}

pub fn api_gateway_v2_http_response_test() {
  ApiGatewayProxyResultV2(
    status_code: 200,
    headers: dict.from_list([
      #(
        "Accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      ),
      #("Accept-Encoding", "gzip, deflate, lzma, sdch, br"),
      #("Accept-Language", "en-US,en;q=0.8"),
      #("CloudFront-Forwarded-Proto", "https"),
      #("CloudFront-Is-Desktop-Viewer", "true"),
      #("CloudFront-Is-Mobile-Viewer", "false"),
      #("CloudFront-Is-SmartTV-Viewer", "false"),
      #("CloudFront-Is-Tablet-Viewer", "false"),
      #("CloudFront-Viewer-Country", "US"),
      #("Host", "wt6mne2s9k.execute-api.us-west-2.amazonaws.com"),
      #("Upgrade-Insecure-Requests", "1"),
      #(
        "User-Agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.82 Safari/537.36 OPR/39.0.2256.48",
      ),
      #(
        "Via",
        "1.1 fb7cca60f0ecd82ce07790c9c5eef16c.cloudfront.net (CloudFront)",
      ),
      #(
        "X-Amz-Cf-Id",
        "nBsWBOrSHMgnaROZJK1wGCZ9PcRcSpq_oSXZNQwQ10OTZL4cimZo3g==",
      ),
      #("X-Forwarded-For", "192.168.100.1, 192.168.1.1"),
      #("X-Forwarded-Port", "443"),
      #("X-Forwarded-Proto", "https"),
    ]),
    cookies: ["cookie1=1", "cookie2=2"],
    body: Some("Hello World"),
    is_base64_encoded: False,
  )
  |> response_snap(
    glambda.api_gateway_proxy_v2_handler,
    js_event("./test/testdata/apigw-v2-request-no-authorizer.json"),
    "API Gateway V2 HTTP Response",
  )
}

pub fn api_gateway_v2_http_response_valid_empty_fields_test() {
  ApiGatewayProxyResultV2(
    status_code: 200,
    headers: dict.new(),
    cookies: [],
    body: None,
    is_base64_encoded: False,
  )
  |> response_snap(
    glambda.api_gateway_proxy_v2_handler,
    js_event("./test/testdata/apigw-v2-request-no-authorizer.json"),
    "API Gateway V2 HTTP Response with valid empty fields",
  )
}

pub fn eventbridge_event_test() {
  js_event("./test/testdata/eventbridge-event.json")
  |> request_snap(glambda.eventbridge_handler, Nil, "EventBridge event")
}

pub fn sqs_event_test() {
  js_event("./test/testdata/sqs-event.json")
  |> request_snap(glambda.sqs_handler, None, "SQS event")
}

pub fn sqs_response_test() {
  Some(SqsBatchResponse([SqsBatchItemFailure("item_id")]))
  |> response_snap(
    glambda.sqs_handler,
    js_event("./test/testdata/sqs-event.json"),
    "SQS batch response",
  )
}

// pub fn wisp_request_test() {
//   js_event("./test/testdata/apigw-v2-request-jwt-authorizer.json")
//   |> glambda.to_api_gateway_proxy_event_v2
//   |> glambda.create_request
//   |> format
//   |> birdie.snap("Wisp request from API Gateway V2 HTTP request with JWT authorizer")
// }

fn request_snap(
  event: JsEvent,
  adapter: fn(Handler(e, r)) -> JsHandler,
  response: r,
  snap_title: String,
) {
  adapter(fn(event, _) {
    event
    |> format
    |> birdie.snap(snap_title)

    promise.resolve(response)
  })(event, js_context())
}

fn response_snap(
  response: r,
  adapter: fn(Handler(e, r)) -> JsHandler,
  event: JsEvent,
  snap_title: String,
) {
  let handler = adapter(fn(_, _) { promise.resolve(response) })

  use resp <- promise.tap(handler(event, js_context()))
  resp
  |> stringify
  |> birdie.snap(snap_title)
}

fn api_gateway_request_snap(event: JsEvent, snap_title: String) {
  request_snap(
    event,
    glambda.api_gateway_proxy_v2_handler,
    ApiGatewayProxyResultV2(
      status_code: 200,
      headers: dict.new(),
      cookies: [],
      body: None,
      is_base64_encoded: False,
    ),
    snap_title,
  )
}

pub fn format(value: a) -> String {
  pprint.with_config(value, Config(Unstyled, BitArraysAsString, Labels))
}

fn js_event(json_path: String) -> JsEvent {
  let assert Ok(json) = simplifile.read(json_path)
  to_js_event(json)
}

@external(javascript, "./glambda_test_ffi.mjs", "parse")
fn to_js_event(json: String) -> JsEvent

@external(javascript, "./glambda_test_ffi.mjs", "context")
fn js_context() -> JsContext

@external(javascript, "./glambda_test_ffi.mjs", "stringify")
fn stringify(a: a) -> String
