# Amazon adapter

The Amazon bidder adapter allows you to connect _Amazon Publisher Services_ in-app bidder SDK with _Smart Display SDK_.

You will find in this repository the classes you need to connect _Amazon Publisher Services_ in-app bidding and _Smart Display SDK_, as well as a sample in the [Sample directory](Sample/).

## Bidder implementation structure

The _Amazon bidder adapter_ is splitted into two different classes:

- ```SASAmazonBidderAdapter```: this class is a [SASBidderAdapterProtocol](http://help.smartadserver.com/iOS/V6.9/Content/AppleDoc/Protocols/SASBidderAdapterProtocol.html) implementation and must be provided to the _Smart Display SDK_ when loading ads
- ```SASAmazonBidderConfigManager```: this singleton class must be called once at app startup to configure the Amazon bidder adapter

To work properly the _Amazon bidder adapter_ must know several information: a **currency**, an **ad markup** and a **matrix of price points**. These information are retrieved automatically from an URL using the ```SASAmazonBidderConfigManager``` singleton class.

To define a configuration, you can use the _Smart Manage interface_ to create an insertion with the _**Amazon Inapp Bidding Configuration**_ template, then retrieve the direct URL of this insertion.

You can also host the configuration JSON yourself as long it complies to the following specification:

    {
      "pricePoints":"<a list of space separated price points>",
      "creativeTag":"<an HTML creative containing the 4 macros: %%KEYWORD:adWidth%% / %%KEYWORD:adHeight%% / %%KEYWORD:amzn_b%% / %%KEYWORD:amzn_h%%",
      "currencyCode":"<an ISO 4217 currency>"
    }

## Using the Amazon bidder adapter in your app

There is three major steps to use the _Amazon bidding adapter_.

### Configure the adapter

You must configure the adapter by calling ```configureWithURL:``` on the ```SASAmazonBidderConfigManager``` shared instance as soon as possible: **no in-app bidding ad call will be made until the configuration as been retrieved** _(if the configuration retrieval fails, it will be retried every time an Amazon bidder adapter is instantiated)_.

The best place to retrieve the configuration is in the ```application:didFinishLaunchingWithOptions:``` method of your application, where you should put:

    [[SASAmazonBidderConfigManager sharedInstance] configureWithURL:[NSURL URLWithString:@"<the configuration JSON URL>"]];

### Request an Amazon ad to create an instance of the Amazon bidder adapter

Request an Amazon ad using ```DTBAdLoader```, then create an instance of ```SASAmazonBidderAdapter``` using the Amazon ad response when the Amazon call is successful:

    - (void)onSuccess:(DTBAdResponse *)adResponse {
      if (adResponse != nil) {
        SASAmazonBidderAdapter *amazonBidderAdapter = [[SASAmazonBidderAdapter alloc] initWithAmazonAdResponse:response];
      }
    
      // proceed to the Smart ad view loading…
    }

Please note that an _Amazon bidder adapter_ **can only be used once**.

### Make an ad call with the Amazon bidder adapter

You can now make an ad call using the _Smart Display SDK_. Simply provide the adapter instance created earlier to Smart's AdView when loading it. If this instance is ```nil```, the _Smart Display SDK_ will make an ad call without in-app bidding so you will still get an ad.

    [smartAdView loadFormatId:<the format ID> pageId:@"<the page ID>" master:YES target:@"<the targetting string>" bidderAdapter:amazonBidderAdapter];

At this point, the adapter and the _Smart Display SDK_ will take care of everything so the most valuable ad will be displayed automatically.