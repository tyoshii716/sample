#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'kconv'
require 'yaml'
require 'json'
require 'pp'

def main()

    ### mechanize
    agent = Mechanize.new
    
    ### login
    login = 'https://www.google.com/accounts/Login?hl=ja&continue=http://www.google.co.jp/'
    agent.get( login );

    form = agent.page.forms.first
    form.Email  = 'tyoshii716@gmail.com'
    form.Passwd = 'xxxxxxxxxx'
    
    agent.submit(form)
    
    ### fetch method : this method is recursive
    puts fetch( agent, { 'did' => 'sports' } ).to_yaml
end 

def fetch( agent, did_ref )

    # set temp hashref
    name = nil
    key  = nil
    if did_ref['did'] == 'sports' then 
        name = 'sports'
        key  = 'event'
    elsif /^leagues:(.*)$/ =~ did_ref['did'] then
        name = $1
        key  = 'league'
    elsif /^team/ =~ did_ref['did'] then
        /\s-\s(.*)$/ =~ did_ref['title']
        name = $1 ? $1 : did_ref['title']
        key  = 'calendar'
    end

    temp = { 'name' => name, key => [] };

    # fetch
    if key == 'calendar' then
        fetch_dir( agent, did_ref['did'] ).each{|res|
            # pp res
            /render\?cid=(.*?)%23sports/ =~ fetch_cal( agent, res['did'] )
            temp[key] << $1 
        }    
    else
        fetch_dir( agent, did_ref['did'] ).each{|res|
            # pp res
            temp[key] << fetch( agent, res )
        }
    end

    return temp
end

### fetch directory api
def fetch_dir( agent, did )
    dir_url = 'https://www.google.com/calendar/directory?pli1&did=%s'

    dir = nil
    begin
        agent.get( sprintf( dir_url, did ) )
        dir = JSON.parse( agent.page.body )
    rescue
        dir = []
    end

    return dir
end

### fetch calendar api
def fetch_cal( agent, src )
    cal_url = 'https://www.google.com/calendar/htmlembed?epr=3&chrome=NAVIGATION&src=%s'

    begin
        agent.get( sprintf( cal_url, src ) )
    rescue
    end
    
    return agent.page.body
end


main()
