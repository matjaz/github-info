
util      = require 'util'
nconf     = require 'nconf'
GitHubApi = require 'github'
moment    = require 'moment'

require './utils'

nconf.file './config.json'

branches = []
github   = new GitHubApi
    version: '3.0.0'


github.authenticate
    type     : 'basic',
    username : nconf.get('auth:username'),
    password : nconf.get('auth:password')

await github.repos.getBranches user: nconf.get('repo:user'), repo: nconf.get('repo:name'), defer err, res

if err?
    console.error err
    return

fetchBranchData = (branch, c) ->
    req = 
        user : nconf.get 'repo:user'
        repo : nconf.get 'repo:name'
        sha  : branch.commit.sha
    
    await github.repos.getCommit req, defer err, res
    
    if err?
        console.error err
        return

    branches.push
        name      : branch.name
        msg       : res.commit.message
        date      : res.commit.committer.date
        committer : 
            name  : res.commit.committer.name
            email : res.commit.committer.email
    c()
    return

printBranches = (options) ->
    branches.sort (a, b) -> moment(a.date) - moment b.date

    if options.json
        console.log util.inspect branches
    else
        branches.forEach (branch) ->
            console.log "#{branch.name}\t#{branch.date}\t#{branch.msg.replace /[\r\n\t]+/g, ''}\t#{}\t#{branch.committer.name}\t#{branch.committer.email}"

res.waitForEach fetchBranchData, -> printBranches json : process.argv[2] is '--json'
