module.exports = {
  ...require("./kafka/client"),
  ...require("./redis/client"),
  ...require("./observability/logger"),
  ...require("./observability/correlation")
};
