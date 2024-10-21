import { List } from "./gleam.mjs";
import { Some, None, unwrap } from "../gleam_stdlib/gleam/option.mjs";
import {
  ApiGatewayProxyEventV2,
  ApiGatewayRequestContextV2,
  ApiGatewayEventRequestContextAuthentication,
  ApiGatewayEventRequestContextIamAuthorizer,
  ApiGatewayEventRequestContextJwtAuthorizer,
  Iam,
  Jwt,
  Lambda,
  ApiGatewayEventRequestContextHttp,
  APIGatewayEventClientCertificate,
  Context,
  CognitoIdentity,
  ClientContext,
  ClientContextClient,
  ClientContextEnv,
  APIGatewayEventValidity,
} from "./glambda.mjs";

export function to_api_gateway_proxy_event_v2(event) {
  return new ApiGatewayProxyEventV2(
    event.version,
    event.routeKey,
    event.rawPath,
    event.rawQueryString,
    maybeList(event.cookies),
    event.headers,
    maybe(event.queryStringParameters),
    maybe(event.pathParameters),
    maybe(event.stageVariables),
    to_request_context(event.requestContext),
    maybe(event.body),
    event.isBase64Encoded,
  );
}

function to_request_context(ctx) {
  return new ApiGatewayRequestContextV2(
    ctx.routeKey,
    ctx.accountId,
    ctx.stage,
    ctx.requestId,
    maybe(to_authorizer(ctx.authorizer)),
    ctx.apiId,
    ctx.domainName,
    ctx.domainPrefix,
    ctx.time,
    ctx.timeEpoch,
    to_http(ctx.http),
    maybe(to_authentication(ctx.authentication)),
  );
}

function to_http(http) {
  return new ApiGatewayEventRequestContextHttp(
    http.method,
    http.path,
    http.protocol,
    http.sourceIp,
    http.userAgent,
  );
}

function to_authentication(auth) {
  if (!auth) {
    return undefined;
  }
  return new ApiGatewayEventRequestContextAuthentication(
    to_client_cert(auth.clientCert),
  );
}

function to_client_cert(cert) {
  return new APIGatewayEventClientCertificate(
    cert.clientCertPem,
    cert.issuerDN,
    cert.serialNumber,
    cert.subjectDN,
    to_validity(cert.validity),
  );
}

function to_validity(validity) {
  return new APIGatewayEventValidity(validity.notAfter, validity.notBefore);
}
function to_authorizer(auth) {
  if (!auth) {
    return undefined;
  }
  if (auth.iam) {
    return new Iam(to_iam_authorizer(auth.iam));
  }
  if (auth.jwt) {
    return new Jwt(
      auth.principalId,
      auth.integrationLatency,
      to_jwt_authorizer(auth.jwt),
    );
  }
  return new Lambda(auth.lambda);
}

function to_iam_authorizer(iam) {
  return new ApiGatewayEventRequestContextIamAuthorizer(
    iam.accessKey,
    iam.accountId,
    iam.callerId,
    iam.principalOrgId,
    iam.userArn,
    iam.userId,
  );
}

function to_jwt_authorizer(jwt) {
  return new ApiGatewayEventRequestContextJwtAuthorizer(
    jwt.claims,
    maybeList(jwt.scopes),
  );
}

function maybe(a) {
  if (a) {
    return new Some(a);
  }
  return new None();
}

function maybeList(a) {
  if (a) {
    return new Some(List.fromArray(a));
  }
  return new None();
}

export function from_api_gateway_proxy_result_v2(result) {
  return {
    statusCode: result.status_code,
    headers: Object.fromEntries(result.headers.entries()),
    body: unwrap(result.body, undefined),
    isBase64Encoded: result.is_base64_encoded,
    cookies: result.cookies.toArray(),
  };
}

export function to_context(ctx) {
  return new Context(
    ctx.callbackWaitsForEmptyEventLoop,
    ctx.functionName,
    ctx.functionVersion,
    ctx.invokedFunctionArn,
    ctx.memoryLimitInMB,
    ctx.awsRequestId,
    ctx.logGroupName,
    ctx.logStreamName,
    maybe(to_cognito_identity(ctx.identity)),
    maybe(to_client_context(ctx.clientContext)),
  );
}

function to_cognito_identity(identity) {
  if (!identity) {
    return undefined;
  }
  console.log(identity);
  return new CognitoIdentity(
    identity.cognitoIdentityId,
    identity.cognitoIdentityPoolId,
  );
}

function to_client_context(ctx) {
  if (!ctx) {
    return undefined;
  }
  return new ClientContext(
    to_client_context_client(ctx.client),
    maybe(ctx.custom),
    to_client_context_env(ctx.env),
  );
}

function to_client_context_client(client) {
  return new ClientContextClient(
    client.appTitle,
    client.appVersionName,
    client.appVersionCode,
    client.appPackageName,
  );
}

function to_client_context_env(env) {
  return new ClientContextEnv(
    env.platformVersion,
    env.platform,
    env.make,
    env.model,
    env.locale,
    env.timezone,
  );
}
