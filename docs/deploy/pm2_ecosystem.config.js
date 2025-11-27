/**
 * PM2 ecosystem config for KiyuMart
 * Usage:
 *  - Install PM2 globally: `sudo npm i -g pm2`
 *  - Start: `pm2 start docs/deploy/pm2_ecosystem.config.js`
 *  - Save: `pm2 save`
 *  - Startup: `pm2 startup` (follow printed instruction)
 */

module.exports = {
  apps: [
    {
      name: "kiyumart",
      script: "npm",
      args: "start",
      cwd: "/home/kiyum/kiyumart", // replace with your app path
      env: {
        NODE_ENV: "production",
        PORT: 5000,
        // DATABASE_URL, SESSION_SECRET, JWT_SECRET should be set in environment or .env file
      },
      // PM2 memory/auto-restart policies
      max_memory_restart: "300M",
      instances: 1,
      autorestart: true,
      watch: false,
      merge_logs: true,
      out_file: "/var/log/kiyumart/out.log",
      error_file: "/var/log/kiyumart/err.log",
      log_date_format: "YYYY-MM-DD HH:mm Z",
      node_args: "--trace-warnings",
    },
  ],
};
