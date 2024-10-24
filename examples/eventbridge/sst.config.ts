/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "eventbridge",
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
    const bus = new sst.aws.Bus("Bus");

    const fn = new sst.aws.Function("Fn", {
      handler: "build/dev/javascript/eventbridge/producer.handler",
      url: true,
      link: [bus],
    });
    bus.subscribe("build/dev/javascript/eventbridge/eventbridge.handler");

    return {
      url: fn.url,
    };
  },
});
