/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "http",
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
    const api = new sst.aws.Function("HttpExample", {
      handler: "build/dev/javascript/http/http.handler",
      url: true,
    });
    return {
      url: api.url,
    };
  },
});
