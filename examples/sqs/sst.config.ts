/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "sqs",
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
    const queue = new sst.aws.Queue("MyQueue");
    queue.subscribe("build/dev/javascript/sqs/sqs.handler");

    const app = new sst.aws.Function("MyApp", {
      handler: "publisher.handler",
      link: [queue],
      url: true,
    });

    return {
      app: app.url,
      queue: queue.url,
    };
  },
});
