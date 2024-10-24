import birdie
import glambda.{
  type ApiGatewayProxyResultV2, type JsEvent, ApiGatewayProxyResultV2,
  SqsBatchItemFailure, SqsBatchResponse,
}
import gleam/dict
import gleam/option.{None, Some}
import gleeunit
import pprint.{BitArraysAsString, Config, Labels, Unstyled}
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn api_gateway_v2_http_request_no_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-no-authorizer.json")
  |> glambda.to_api_gateway_proxy_event_v2
  |> format
  |> birdie.snap("API Gateway V2 HTTP request with no authorizer")
}

pub fn api_gateway_v2_http_request_iam_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-iam.json")
  |> glambda.to_api_gateway_proxy_event_v2
  |> format
  |> birdie.snap("API Gateway V2 HTTP request with IAM authorizer")
}

pub fn api_gateway_v2_http_request_jwt_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-jwt-authorizer.json")
  |> glambda.to_api_gateway_proxy_event_v2
  |> format
  |> birdie.snap("API Gateway V2 HTTP request with JWT authorizer")
}

pub fn api_gateway_v2_http_request_lambda_authorizer_test() {
  js_event("./test/testdata/apigw-v2-request-lambda-authorizer.json")
  |> glambda.to_api_gateway_proxy_event_v2
  |> format
  |> birdie.snap("API Gateway V2 HTTP request with Lambda authorizer")
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
    cookies: ["cookie1", "cookie2"],
    body: Some("Hello World"),
    is_base64_encoded: False,
  )
  |> glambda.from_api_gateway_proxy_result_v2
  |> stringify
  |> birdie.snap("API Gateway V2 HTTP Response")
}

pub fn api_gateway_v2_http_response_valid_empty_fields_test() {
  ApiGatewayProxyResultV2(
    status_code: 200,
    headers: dict.new(),
    cookies: [],
    body: None,
    is_base64_encoded: False,
  )
  |> glambda.from_api_gateway_proxy_result_v2
  |> stringify
  |> birdie.snap("API Gateway V2 HTTP Response with valid empty fields")
}

pub fn eventbridge_event_test() {
  js_event("./test/testdata/eventbridge-event.json")
  |> glambda.to_eventbridge_event
  |> format
  |> birdie.snap("EventBridge event")
}

pub fn sqs_event_test() {
  js_event("./test/testdata/sqs-event.json")
  |> glambda.to_sqs_event
  |> format
  |> birdie.snap("SQS event")
}

pub fn sqs_response_test() {
  SqsBatchResponse([SqsBatchItemFailure("item_id")])
  |> glambda.from_sqs_batch_response
  |> stringify
  |> birdie.snap("SQS batch response")
}

// pub fn wisp_request_test() {
//   js_event("./test/testdata/apigw-v2-request-jwt-authorizer.json")
//   |> glambda.to_api_gateway_proxy_event_v2
//   |> glambda.create_request
//   |> format
//   |> birdie.snap("Wisp request from API Gateway V2 HTTP request with JWT authorizer")
// }

pub fn format(value: a) -> String {
  pprint.with_config(value, Config(Unstyled, BitArraysAsString, Labels))
}

fn js_event(json_path: String) -> JsEvent {
  let assert Ok(json) = simplifile.read(json_path)
  to_js_event(json)
}

@external(javascript, "./glambda_test_ffi.mjs", "parse")
fn to_js_event(json: String) -> JsEvent

@external(javascript, "./glambda_test_ffi.mjs", "stringify")
fn stringify(a: a) -> String
