# Deploy parse-server and parse-dashboard in 5 minutes

Hey There

This repo contains a script (and it is a perfect manuals at the same time) that lets you deploy a Parse Platform Server and Dashboard in a matter of minutes. It requires a fresh Ubuntu 16.04

You're welcome to browse the .sh file and hack your own out of it, or just use the commands below to quickly get the job done.

## Features

- Completely automated deployment process, one script to do it all
- `app-id`, `master-key` and dashboard login key are generated, and not stored in the repo

## Deployment

- Deploy an ubuntu 16.04 VPS instance with your favorite provider and login as root
- run `bash <(curl -s -L https://github.com/truemetal/parse-server-deploy/raw/master/deploy-parse.sh)`
- upon start, the script will uudigen credentials and pause; you can just copy those and hit enter to proceed

And in around 5 minutes you're done! 

## What the script does:

- update the system
- install node
- install mongo
- generate files for basic `parse-server` and `parse-dashboard`
- `npm install` and run the app using `pm2`

## Warning: not production safe, for development instances only!

## TODO:

- https / letsencrypt
- nginx 
- ufw (firewall)

---

Please feel free to open an issue or drop me a pull request.

Bogdan (Dan) Pashchenko
https://ios-engineer.com
