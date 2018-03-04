# Deploy parse-server and parse-dashboard in 5 minutes

Hey There

This repo contains a script (and it is a perfect manuals at the same time) that lets you deploy a Parse Platform Server and Dashboard in a matter of minutes. It requires a fresh Ubuntu 16.04

You're welcome to browse the .sh file and hack your own out of it, or just use the commands below to quickly get the job done.

Steps: 
- Deploy an ubuntu 16.04 VPS instance with your favorite provider and login as root
- run `curl -s -L https://github.com/truemetal/parse-server-deploy/raw/master/deploy-parse.sh -o ~/deploy.sh && chmod +x ~/deploy.sh && ~/deploy.sh`

And in around 5 minutes you're done! 

## Warning: not deployment safe, for development instances only!

## TODO:

- https / letsencrypt
- nginx 
- ufw (firewall)

---

Please feel free to open an issue or drop me a pull request.

Bogdan (Dan) Pashchenko
https://ios-engineer.com
