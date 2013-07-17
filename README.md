## Express Chat

Example chat application using the following technologies:

  * [Node.js](http://nodejs.org)
  * [Express](http://expressjs.com/)
  * [Redis](http://redis.io) 
  * [Faye](http://faye.jcoglan.com/) 
  * [Backbone.js](http://backbonejs.org)
  * [Gravatar](http://gravatar.com) (for profile information)

Example hosted at: [http://chat.nickdesteffen.com](http://chat.nickdesteffen.com)

#### Installing
Install [Node Version Manager](https://github.com/creationix/nvm)  

`npm install`  
`npm install -g coffee-script`  
`npm install -g express`  
`npm install -g supervisor`

#### Running
`coffee -c -w ./`  
`supervisor app.js`

#### Deploying
`bundle exec cap deploy`