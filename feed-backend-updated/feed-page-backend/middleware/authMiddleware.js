const authMiddleware = (req, res, next) => {
    console.log(`🔍 Request made to: ${req.method} ${req.originalUrl}`);
    next();
  };
  
  module.exports = authMiddleware;
  