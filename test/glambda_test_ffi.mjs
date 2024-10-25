export function parse(json) {
  return JSON.parse(json);
}

export function stringify(obj) {
  return JSON.stringify(obj, null, 2);
}

export function context() {
  return {
    awsRequestId: "ae1529c7-fd82-4a73-8fa7-53a8b6ce6a03",
    invokedFunctionArn:
      "arn:aws:lambda:us-east-1:000000000000:function:TestFunction",
    identity: undefined,
    clientContext: undefined,
    functionName: "TestFunction",
    functionVersion: "$LATEST",
    memoryLimitInMB: undefined,
    logGroupName: "",
    logStreamName: "",
    callbackWaitsForEmptyEventLoop: true,
  };
}
