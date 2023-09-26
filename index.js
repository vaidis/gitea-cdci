const express = require("express")
const bodyParser = require("body-parser")
const { exec } = require('child_process');
const fs = require('fs')
const app = express()
const PORT = 4444

// logger
function logger(msg) {
  const cmd = `/usr/bin/logger ${msg}`
  exec(cmd)
}

// Execute a repo script
function webhookHandler(params) {
  const script = './init.sh'
  try {
    if (fs.existsSync(script)) {
      const cmd = `/bin/bash ${script} ${params.event} ${params.name} ${params.type} ${params.url} ${params.email} ${params.user}`
      exec(cmd)
    }
  } catch (err) {
    logger.error(err)
  }
}

// Recieve event object
app.use(bodyParser.json())
app.post("/webhook", (req, res) => {
  var params = {
    event: req.headers['x-gitea-event'],
    name: req.body.repository.name,
    type: req.body.repository.description,
    url: req.body.repository.ssh_url,
    email: req.body.repository.owner.email,
    user: req.body.pusher.username
  }
  logger(`🫖 gitea-cdci  ${JSON.stringify(params)}`)
  webhookHandler(params);
  res.status(200).end();
})

// Start the server
app.listen(PORT, '0.0.0.0', () => logger(`🚀 gitea-cdci: start lisening on port ${PORT}`))

