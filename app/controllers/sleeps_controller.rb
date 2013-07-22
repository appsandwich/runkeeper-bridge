require 'health_graph'
require "net/http"
require "uri"
require 'json'

class SleepsController < ApplicationController
  # GET /sleeps
  # GET /sleeps.json
  def index
    @sleeps = Sleep.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sleeps }
    end
  end

  # GET /sleeps/1
  # GET /sleeps/1.json
  def show
    @sleep = Sleep.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sleep }
    end
  end

  # GET /sleeps/new
  # GET /sleeps/new.json
  def new
    
    #timestamp={{FellAsleepAt}}&total_sleep={{TotalTimeSleptInSeconds}}&deep={{TimeInDeepSleepSeconds}}&light={{TimeInLightSleepSeconds}}&awake={{TimeAwakeSeconds}}
    
    json_hash = Hash.new
    
    @sleep = json_hash
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sleep }
    end
  end

  # GET /sleeps/1/edit
  def edit
    @sleep = Sleep.find(params[:id])
  end

  # POST /sleeps
  # POST /sleeps.json
  def create
    
    #timestamp={{FellAsleepAt}}&total_sleep={{TotalTimeSleptInSeconds}}&deep={{TimeInDeepSleepSeconds}}&light={{TimeInLightSleepSeconds}}&awake={{TimeAwakeSeconds}}
    
    json_hash = Hash.new
    
    description = params[:description]
    
    timestamp = params[:timestamp]
    total_sleep_seconds = params[:total_sleep]
    deep_sleep_seconds = params[:deep]
    light_sleep_seconds = params[:light]
    awake_seconds = params[:awake]
    
    if timestamp.nil? || total_sleep_seconds.nil?
      
      puts 'timestamp is nil or total_sleep_seconds is nil :('
      
    else
    
      total_sleep = total_sleep_seconds / 60.0
      deep = deep_sleep_seconds / 60.0
      light = light_sleep_seconds / 60.0
      awake = awake_seconds / 60.0
      
      post_to_twitter = false
      post_to_facebook = false
    
      # FellAsleepAt is formatted: August 23, 2013 at 11:01PM
      # Convert to Runkeeper's preferred format: Sat, 1 Jan 2011 00:00:00
      timestamp_datetime = DateTime.parse(timestamp)
      formatted_timestamp = timestamp_datetime.strftime("%a, %d %b %Y %H:%M:%S")
      
      json_hash['timestamp'] = formatted_timestamp
      json_hash['total_sleep'] = deep
      json_hash['deep'] = deep
      json_hash['light'] = light
      json_hash['awake'] = awake
      json_hash['post_to_twitter'] = post_to_twitter
      json_hash['post_to_facebook'] = post_to_facebook
      
      url = 'https://api.runkeeper.com/sleep'
      
      uri = URI.parse(url)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Bearer " + RUNKEEPER_ACCESS_TOKEN
      request["Content-Type"] = "application/vnd.com.runkeeper.NewSleep+json"
      request.body = json_hash.to_json
      
      response = http.request(request)
      
      puts response.body
      
    end
    
    @sleep = json_hash
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sleep }
    end
    
  end

  # PUT /sleeps/1
  # PUT /sleeps/1.json
  def update
    @sleep = Sleep.find(params[:id])

    respond_to do |format|
      if @sleep.update_attributes(params[:sleep])
        format.html { redirect_to @sleep, notice: 'Sleep was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sleep.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sleeps/1
  # DELETE /sleeps/1.json
  def destroy
    @sleep = Sleep.find(params[:id])
    @sleep.destroy

    respond_to do |format|
      format.html { redirect_to sleeps_url }
      format.json { head :no_content }
    end
  end
end
