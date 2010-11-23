# Subscriber is defined in default.rb which is automatically generated.
# In this file we add additional methods to the Subscriber class.
require File.expand_path(File.dirname(__FILE__)) + '/module_mixin'

module Campaigning
  class Subscriber
    include ModuleMixin   
    attr_accessor :emailAddress
    attr_accessor :name
    attr_accessor :date
    attr_accessor :state
    attr_accessor :customFields

    def initialize(emailAddress = nil, name = nil, date = nil, state = nil, customFields = nil, opts={})
      @apiKey = opts[:apiKey] || CAMPAIGN_MONITOR_API_KEY
      @emailAddress = emailAddress
      @name = name
      @date = date
      @state = state
      @customFields = customFields
    end


    #Adds a subscriber to a subscriber list, including adding custom field data for the subscriber. If the subscriber
    #(email address) already exists, the name value is updated with whatever is passed in.
    #
    #If the list has been set as double opt-in, they will be sent the verification email, otherwise they will be sent the
    #confirmation email you have set up for the list being subscribed to.
    #
    #<b>Please note</b>: If the subscriber is in an inactive state or has previously been unsubscribed, they will *not* be re-added
    #to the active list. Therefore, this method should be used with caution and only where suitable.
    #
    #*Return*:
    #
    #*Success*: Upon a successful call, this method will return a Campaigning::Result object wich consists of a +code+ and +message+ fields
    #containing a successful message.
    #
    #*Error*: An Exception containing the cause of the error will be raised.
    def add!(list_id, custom_fields={})
      params = {
        :apiKey => @apiKey,
        :listID => list_id,
        :email => @emailAddress,
        :name => @name
      }
      if custom_fields.empty?
        response = @@soap.addSubscriber(params)
        handle_response response.subscriber_AddResult
      else
        params.merge!({:customFields => custom_fields_array(custom_fields)})
        response = @@soap.addSubscriberWithCustomFields(params)
        handle_response response.subscriber_AddWithCustomFieldsResult
      end  
    end


    #Adds a subscriber to a subscriber list, including adding custom field data for the subscriber. If the subscriber (email address) already exists,
    #the name value is updated with whatever is passed in.
    #
    #If the list has been set as double opt-in, they will be sent the verification email, otherwise they will be sent the
    #confirmation email you have set up for the list being subscribed to.
    #
    #<b>Please note</b>: If the subscriber is in an inactive state or has previously been unsubscribed, they will be re-added to
    #the active list. Therefore, this method should be used with caution and only where suitable.
    #
    #*Return*:
    #
    #*Success*: Upon a successful call, this method will return a Campaigning::Result object wich consists of a +code+ and +message+ fields
    #containing a successful message.
    #
    #*Error*: An Exception containing the cause of the error will be raised.
    def add_and_resubscribe!(list_id, custom_fields={})
      params = {
        :apiKey => @apiKey,
        :listID => list_id,
        :email => @emailAddress,
        :name => @name
      }
      if custom_fields.empty?
        response = @@soap.addAndResubscribe(params)
        handle_response response.subscriber_AddAndResubscribeResult
      else
        params.merge!({:customFields => custom_fields_array(custom_fields)})
        response = @@soap.addAndResubscribeWithCustomFields(params)
        handle_response response.subscriber_AddAndResubscribeWithCustomFieldsResult
      end  
    end


    #Changes the status of an Active Subscriber to an Unsubscribed Subscriber who will no longer receive
    #campaigns sent to that Subscriber List.
    #
    #If the list is set to add unsubscribing subscribers to the suppression list, then the subscriber’s email address will
    #also be added to the suppression list.
    #
    #*Return*:
    #
    #*Success*: Upon a successful call, this method will return a Campaigning::Result object wich consists of a +code+ and +message+ fields
    #containing a successful message.
    #
    #*Error*: An Exception containing the cause of the error will be raised.
    def unsubscribe!(list_id)
      Subscriber.unsubscribe!(@emailAddress, list_id, :apiKey=> @apiKey)
    end


    #Changes the status of an Active Subscriber to an Unsubscribed Subscriber who will no longer receive
    #campaigns sent to that Subscriber List (Same that the instance method with the same name).
    #
    #Aviable _opts_ arguments are:
    #   * :apiKey - optional API key to use to make request. Will use CAMPAIGN_MONITOR_API_KEY if not set.
    def self.unsubscribe!(email, list_id, opts={})
      response = @@soap.unsubscribe(
      :apiKey => opts[:apiKey] || CAMPAIGN_MONITOR_API_KEY,
      :listID => list_id,
      :email => email
      )
      handle_response response.subscriber_UnsubscribeResult
    end

    #Returns True or False as to the existence of the given email address in the list supplied.
    def is_subscribed?(list_id)
      Subscriber.is_subscribed?(@emailAddress, list_id, :apiKey=> @apiKey)
    end

    #Returns True or False as to the existence of the given email address in the list supplied.
    #
    #Aviable _opts_ arguments are:
    #   * :apiKey - optional API key to use to make request. Will use CAMPAIGN_MONITOR_API_KEY if not set.
    def self.is_subscribed?(email, list_id, opts={})
      response = @@soap.getIsSubscribed(
      :apiKey => opts[:apiKey] || CAMPAIGN_MONITOR_API_KEY,
      :listID => list_id,
      :email => email
      )
      response = handle_response response.subscribers_GetIsSubscribedResult
      response == 'True' ? true : false
    end

    def self.get_single_subscriber(list_id, email, opts={})
      response = @@soap.getSingleSubscriber(
      :apiKey => opts[:apiKey] || CAMPAIGN_MONITOR_API_KEY,
      :listID => list_id,
      :emailAddress => email
      )
      response = handle_response response.subscribers_GetSingleSubscriberResult
    end


    protected

    def custom_fields_array(custom_fields) #:nodoc:
      arr = []
      custom_fields.each do |key, value|
        if value.is_a? Array
          value.each do |v|
            arr << {:key => key, :value => v}
          end
        else
          arr << { :key => key, :value => value }
        end
      end
      arr
    end

  end
end
