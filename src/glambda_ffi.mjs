import { List } from "./gleam.mjs";
import { Some, None, unwrap } from "../gleam_stdlib/gleam/option.mjs";
import * as $dict from "../gleam_stdlib/gleam/dict.mjs";
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
  ApiGatewayEventClientCertificate,
  Context,
  CognitoIdentity,
  ClientContext,
  ClientContextClient,
  ClientContextEnv,
  ApiGatewayEventValidity,
  EventBridgeEvent,
  SqsEvent,
  SqsRecord,
  SqsRecordAttributes,
  SqsMessageAttribute,
  SqsBatchResponse,
  SqsBatchItemFailure,
} from "./glambda.mjs";

export function toApiGatewayProxyEventV2(event) {
  return new ApiGatewayProxyEventV2(
    event.version,
    event.routeKey,
    event.rawPath,
    event.rawQueryString,
    maybeList(event.cookies),
    toDict(event.headers),
    maybeDict(event.queryStringParameters),
    maybeDict(event.pathParameters),
    maybeDict(event.stageVariables),
    toRequestContext(event.requestContext),
    maybe(event.body),
    event.isBase64Encoded,
  );
}

function toRequestContext(ctx) {
  return new ApiGatewayRequestContextV2(
    ctx.routeKey,
    ctx.accountId,
    ctx.stage,
    ctx.requestId,
    maybe(toAuthorizer(ctx.authorizer)),
    ctx.apiId,
    ctx.domainName,
    ctx.domainPrefix,
    ctx.time,
    ctx.timeEpoch,
    toHttp(ctx.http),
    maybe(toAuthentication(ctx.authentication)),
  );
}

function toHttp(http) {
  return new ApiGatewayEventRequestContextHttp(
    http.method,
    http.path,
    http.protocol,
    http.sourceIp,
    http.userAgent,
  );
}

function toAuthentication(auth) {
  if (!auth) {
    return undefined;
  }
  return new ApiGatewayEventRequestContextAuthentication(
    toClientCert(auth.clientCert),
  );
}

function toClientCert(cert) {
  return new ApiGatewayEventClientCertificate(
    cert.clientCertPem,
    cert.issuerDN,
    cert.serialNumber,
    cert.subjectDN,
    toValidity(cert.validity),
  );
}

function toValidity(validity) {
  return new ApiGatewayEventValidity(validity.notAfter, validity.notBefore);
}
function toAuthorizer(auth) {
  if (!auth) {
    return undefined;
  }
  if (auth.iam) {
    return new Iam(toIamAuthorizer(auth.iam));
  }
  if (auth.jwt) {
    return new Jwt(
      auth.principalId,
      auth.integrationLatency,
      toJwtAuthorizer(auth.jwt),
    );
  }
  return new Lambda(auth.lambda);
}

function toIamAuthorizer(iam) {
  return new ApiGatewayEventRequestContextIamAuthorizer(
    iam.accessKey,
    iam.accountId,
    iam.callerId,
    iam.principalOrgId,
    iam.userArn,
    iam.userId,
  );
}

function toJwtAuthorizer(jwt) {
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

function maybeDict(a) {
  if (a) {
    return new Some(toDict(a));
  }
  return new None();
}

export function fromApiGatewayProxyResultV2(result) {
  return {
    statusCode: result.status_code,
    headers: Object.fromEntries(result.headers.entries()),
    body: unwrap(result.body, undefined),
    isBase64Encoded: result.is_base64_encoded,
    cookies: result.cookies.toArray(),
  };
}

export function toContext(ctx) {
  return new Context(
    ctx.callbackWaitsForEmptyEventLoop,
    ctx.functionName,
    ctx.functionVersion,
    ctx.invokedFunctionArn,
    ctx.memoryLimitInMB,
    ctx.awsRequestId,
    ctx.logGroupName,
    ctx.logStreamName,
    maybe(toCognitoIdentity(ctx.identity)),
    maybe(toClientContext(ctx.clientContext)),
  );
}

function toCognitoIdentity(identity) {
  if (!identity) {
    return undefined;
  }
  return new CognitoIdentity(
    identity.cognitoIdentityId,
    identity.cognitoIdentityPoolId,
  );
}

function toClientContext(ctx) {
  if (!ctx) {
    return undefined;
  }
  return new ClientContext(
    toClientContextClient(ctx.client),
    maybe(ctx.custom),
    toClientContextEnv(ctx.env),
  );
}

function toClientContextClient(client) {
  return new ClientContextClient(
    client.appTitle,
    client.appVersionName,
    client.appVersionCode,
    client.appPackageName,
  );
}

function toClientContextEnv(env) {
  return new ClientContextEnv(
    env.platformVersion,
    env.platform,
    env.make,
    env.model,
    env.locale,
    env.timezone,
  );
}

function toDict(obj) {
  return $dict.from_list(List.fromArray(Object.entries(obj)));
}

export function toEventBridgeEvent(event) {
  return new EventBridgeEvent(
    event.id,
    event.version,
    event.account,
    event.time,
    event.region,
    List.fromArray(event.resources),
    event.source,
    event.detail,
  );
}

export function toSqsEvent(event) {
  return new SqsEvent(List.fromArray(event.Records.map(toSqsRecord)));
}

function toSqsRecord(record) {
  return new SqsRecord(
    record.messageId,
    record.receiptHandle,
    record.body,
    toSqsRecordAttributes(record.attributes),
    toMessageAttributes(record.messageAttributes),
    record.md5OfBody,
    record.eventSource,
    record.eventSourceARN,
    record.awsRegion,
  );
}

function toSqsRecordAttributes(attrs) {
  return new SqsRecordAttributes(
    maybe(attrs.AWSTraceHeader),
    attrs.ApproximateReceiveCount,
    attrs.SentTimestamp,
    attrs.SenderId,
    attrs.ApproximateFirstReceiveTimestamp,
    maybe(attrs.SequenceNumber),
    maybe(attrs.MessageGroupId),
    maybe(attrs.MessageDeduplicationId),
    maybe(attrs.DeadLetterQueueSourceArn),
  );
}

function toMessageAttributes(attrs) {
  let entries = Object.entries(attrs).map(([key, value]) => {
    let v = toSqsMessageAttribute(value);
    return [key, v];
  });
  return $dict.from_list(List.fromArray(entries));
}

function toSqsMessageAttribute(attr) {
  return new SqsMessageAttribute(
    maybe(attr.stringValue),
    maybe(attr.binaryValue),
    maybe(attr.stringListValue),
    maybe(attr.binaryListValue),
    attr.dataType,
  );
}

export function fromSqsBatchResponse(response) {
  return {
    batchItemFailures: response.batch_item_failures
      .toArray()
      .map(fromSqsBatchItemFailure),
  };
}

function fromSqsBatchItemFailure(failure) {
  return {
    itemIdentifier: failure.item_identifier,
  };
}
