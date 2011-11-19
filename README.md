Akuacom DRAS OpenADR Ruby Client
================================
Release 1.0, 18 November 2011, by Adam Zaninovich
 
Introduction
------------
This package contains documentation and sample ruby code for accessing the Akuacom OpenADR DRAS client REST web service (RestWS). Complete documentation for the OpenADR client interfaces can be found at [openadr.lbl.gov](http://openadr.lbl.gov/).
 
The RestWS provides DRAS clients with a simple method for retrieving DRAS event information over the Internet. Making a single HTTP GET method call on the DRAS will return all the event information for the client in XML. Akuacom recommends making the HTTP GET method call once per minute.
 
The web service is available on the Client Developer Server in SSL and non SSL versions.

* non SSL endpoint: http://cdp.openadr.com/RestClientWS/nossl/rest2
* non SSL confirm endpoint: http://cdp.openadr.com/RestClientWS/nossl/restConfirm
* SSL endpoint: https://cdp.openadr.com/RestClientWS/rest2
* SSL confirm endpoint: https://cdp.openadr.com/RestClientWS/restConfirm
 
On production servers, only the SSL versions are available.

Schema
------
The EventState.xsd schema is available on the OpenADR archive site at [openadr.lbl.gov/src/1/EventState.xsd](http://openadr.lbl.gov/src/1/EventState.xsd)

Simple DRAS Client
------------------
A typical simple DRAS client only needs to parse the EventStatus and OperationModeValue elements of the simpleDRModeData complex type and translate the values into a shed strategy.
 
The OperationModeValue value is used to indicate the current shed level for the facility: NORMAL, MODERATE, or HIGH. A value of NORMAL indicates that no shed is being requested. MODERATE and HIGH are relative shed levels, HIGH requesting the maximum shed the facility is programmed for, and MODERATE being somewhere between HIGH and NORMAL. Exactly how these levels control the facility is left up the controls vendor and facility owner depending on desired DR performance and facility comfort.
 
The EventStatus value is used to indicate where in the event cycle the client is. FAR and NEAR are relative indications that an event has been issued and the start time is approaching. These values could be used to prepare a facility for the upcoming event by triggering behaviors such as pre-cooling. ACTIVE indicates that the client is between the start and end times of the event. When the EventStatus is ACTIVE, the OperationModeValue should be inspected to see what shed level is being indicated.

Simple DRAS Gateway
------------------- 
A simple DRAS client acting as a gateway to the facility energy management and control system might turn the OperationModeValue and EventStatus values into relay outputs. The particular mapping of values to relay outputs described below was chosen to be compatible with the Akuacom CLIR legacy DRAS client.
 
Using two relays for OperationModeValue, NORMAL would turn off both relays, MODERATE would turn on relay 1 and turn off relay 2, and HIGH would turn on both relays.
 
    --------------------------------
    | value    | relay 1 | relay 2 |
    |----------|---------|---------|
    | NORMAL   |   OFF   |   OFF   |
    |----------|---------|---------|
    | MODERATE |   ON    |   OFF   |
    |----------|---------|---------|
    | HIGH     |   ON    |   ON    |
    --------------------------------
 
Using two relays for EventStatus, FAR would turn off relay 3 and turn on relay 4, NEAR would turn on both relays, and ACTIVE would turn on relay 3 and turn off relay 4. If only three relays are available, NEAR and ACTIVE would turn on relay 3 and FAR would be ignored.
 
    ------------------------------
    | value  | relay 3 | relay 4 |
    |--------|---------|---------|
    | FAR    |   OFF   |   ON    |
    |--------|---------|---------|
    | NEAR   |   ON    |   ON    |
    |--------|---------|---------|
    | ACTIVE |   ON    |   OFF   |
    ------------------------------
 
If the returned XML was empty, all relays would be turned off.

Example Ruby Client
-------------------
See a demo of this running at [drasdemo.heroku.com](http://drasdemo.heroku.com/).

To Use:

* update config/config.yml with your credentials
* run `gem install bundler`
* run `bundle install`
* run `bundle exec thin start -p 3000`
* open localhost:3000 in your browser

TODO
----

* Add confirmation