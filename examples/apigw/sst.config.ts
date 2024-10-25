/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "apigw",
      removal: input?.stage === "production" ? "retain" : "remove",
      home: "aws",
      providers: {
        aws: {
          region: "us-east-1",
          profile: "personal",
        },
      },
    };
  },
  async run() {
    const api = new sst.aws.Function("ApiGatewayExample", {
      handler: "build/dev/javascript/apigw/apigw.handler",
      url: true,
    });
    return {
      url: api.url,
    };
  },
});
