/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "simple-example",
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
    const api = new sst.aws.Function("SimpleExample", {
      handler: "build/dev/javascript/handler/handler.handler",
      url: true,
    });
    return {
      url: api.url,
    };
  },
});
