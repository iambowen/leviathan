###Dev Free
For web developer, often times we need to prepare the development env and it is sometimes a pain and people just suffer from the same pain again and again, that's the reason why google/stackoverflow is popular. My idea about the project is:
1. To put everything in an virtual box and developers can public/push box which development env has set up well. 
2. An web server/proxy like nginx/apache/varnish has been installed well in the box. The correspoding config can be pulled/updated from the certain repo, so that you can easily set up an prod like/ e2e env in the virtual box by utilizing the linux container tech.
3. The services you need to talk to will be started in docker containers and behind the web service wrapper.

###Aim
Share the similar philosophy with docker.
1. build box once and use it everywhere.
2. config once and use it everywhere. 

###Tasks
1. scripts and command to build an dev box with certain env like ruby 2.0.0
2. scripts to push and pull dev box locally
3. scripts to publish/pull web wrapper config
4. scripts to build/pull services in docker images

