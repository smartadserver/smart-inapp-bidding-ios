# Amazon Bidder Adapter

The Amazon bidder adapter allows you to connect _Amazon Publisher Services_ in-app bidder SDK with _Smart Display SDK_.

You will find in this repository the classes you need to connect _Amazon Publisher Services_ in-app bidding and _Smart Display SDK_, as well as a sample in the [Sample directory](Sample/).

## Bidder implementation structure

The _Amazon bidder adapter_ is splitted into three different classes:

- ```SASAmazonBaseBidderAdapter```: this class is a [SASBidderAdapterProtocol](https://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html) implementation and must be provided to the _Smart Display SDK_ when loading ads
- ```SASAmazonBannerBidderAdapter```: this class inherits from ```SASAmazonBaseBidderAdapter``` and is the adapter you should use to load an Amazon banner ad in a [SASBannerView](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBannerView.html). Its implementation overrides the banner ads related methods of ```SASAmazonBaseBidderAdapter```.
- ```SASAmazonInterstitialBidderAdapter```: this class inherits from ```SASAmazonBaseBidderAdapter``` and is the adapter you should use to load an Amazon interstitial ad in a [SASInterstitialManager](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASInterstitialManager.html). Its implementation overrides the interstitial ads related methods of ```SASAmazonBaseBidderAdapter```.

## Using the Amazon bidder adapter in your app

There are two major steps to use a _Amazon bidding adapter_.

### Request an Amazon ad to create an instance of the Amazon bidder adapter

Request an Amazon ad using ```DTBAdLoader```, then:

For banner ads, create an instance of ```SASAmazonBannerBidderAdapter``` using the Amazon ad response when the Amazon call is successful:

    - (void)onSuccess:(DTBAdResponse *)adResponse {
      if (adResponse != nil) {
        SASAmazonBannerBidderAdapter *amazonBidderAdapter = [[SASAmazonBannerBidderAdapter alloc] initWithAmazonAdResponse:response];
      }

      // proceed to the Smart ad view loading…
    }

For interstitial ads, create an instance of ```SASAmazonInterstitialBidderAdapter``` using the Amazon ad response when the Amazon call is successful:

    - (void)onSuccess:(DTBAdResponse *)adResponse {
      if (adResponse != nil) {
        SASAmazonInterstitialBidderAdapter *amazonBidderAdapter = [[SASAmazonInterstitialBidderAdapter alloc] initWithAmazonAdResponse:response];
      }

      // proceed to the Smart ad view loading…
    }

Please note that an _Amazon bidder adapter_ **can only be used once**.

### Make an ad call to Smart Ad Server with the Amazon bidder adapter

You can now perform an ad call using the _Smart Display SDK_. Simply provide the adapter instance created earlier to Smart's ad view (or interstitial manager) when loading it. If this instance is ```nil```, the _Smart Display SDK_ will make an ad call without in-app bidding so you will still get an ad.

    // for a banner
    [bannerView loadWithPlacement:[SASAdPlacement adPlacementWithSiteId:<the site ID> pageId:<the page ID> formatId:<the format ID>] bidderAdapter:amazonBidderAdapter];

    // for an interstitial
    [interstitialManager loadWithBidderAdapter:bidderAdapter];

At this point, the adapter and the _Smart Display SDK_ will take care of everything for the most valuable ad to be displayed automatically, while still providing callbacks to the delegate of the _Smart Display SDK_ ad instance.
