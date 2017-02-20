# knife-art
Enables usage of Knife with basic authentication against an Artifactory backend (serving as the supermarket repo)  

### Installation
`chef gem install knife-art`

### Client Configuration
The only requirement is to setup the supermarket url in your `knife.rb` file as follows:
`knife[:supermarket_site] = 'http://user:apiKey@art.company.com:8080/artifactory/api/chef/myRepo'`

### Artifactory Configuration
See the [Artifactory User Guide](https://www.jfrog.com/confluence/display/RTF/Chef+Supermarket)

#### The knife-art plugin exposes all `knife supermarket` (or `knife cookbook site`) commands by using `knife artifactory`:
```
knife artifactory download COOKBOOK [VERSION] (options)
knife artifactory install COOKBOOK [VERSION] (options)
knife artifactory list (options)
knife artifactory search QUERY (options)
knife artifactory share COOKBOOK [CATEGORY] (options)
knife artifactory show COOKBOOK [VERSION] (options)
knife artifactory unshare COOKBOOK VERSION
```

### Caveats
In some installations the chefdk location may not be included in your $PATH which will cause
the plugin not to be loaded (chef gem will show a warning about this if that is the case).
To fix this you simply need to include the chefdk location in your path, i.e. for bash:

In .bashrc:
```
export PATH=$PATH:~/.chefdk/gem/ruby/2.3.0/bin
```
Then reload it with ```source ~/.bashrc```