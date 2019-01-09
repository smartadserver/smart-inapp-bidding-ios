# Smart AdServer — iOS in-app bidding adapters & samples

_In-App bidding_ allows you to create a real time competition between direct sales, _Smart RTB+_ and third party ad networks just like header bidding does in a web environment.

This repository contains some in-app bidding adapters that can be used with the _Smart Display SDK **7.0 and up**_.

Integration samples are also available for each adapter (third party SDK may be required to build these samples).

## Requirements

- A _Smart AdServer_ account
- _Smart Display SDK_ 7.0 and up
- _Xcode_ 10.0 or higher
- _iOS_ 8.0 or higher
- _Cocoapods_

## How does it work?

Just like header bidding on the web, your application may call a third party partner at any moment to get an ad response along with a CPM for the display of the ad.

Then, for appropriate placements, you will pass the CPM (through an adapter object) to the ad view you want to load. While making its own ad call, the ad view will forward the CPM to our ad server and _Holistic+_ competition will occur between your programmed insertions (direct and _RTB+_) and the in-app bidding winner. The ad server will determine the ad with the highest CPM and tell the SDK which creative should be displayed to maximize your revenues.

## Available adapters

Adapters are available for the following third party SDK:

| SDK | Website | Adapter & documentation |
| --- | ------- | ----------------------- |
| Amazon Publisher Services | https://ams.amazon.com/webpublisher _(login required)_ | [Amazon adapter](Amazon/) |

## Custom adapters

You can add partners for in-app bidding without having to wait for _Smart_ to integrate them for you.

The _Smart Display SDK_ has an open protocol that can be implemented by custom classes to create bidding adapters. These adapters should be initialized from the ad response you get from the in-app bidding partner and be passed to the _load_ method of the [SASBannerView](http://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASAdView.html) or the [SASInterstitialManager](http://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBaseInterstitialManager.html) when loading an ad. _Holistic+_ competition will then happen server side and the ad with the highest CPM will be displayed.

### Technical overview

In-app bidding is based on the same principle than header bidding for web integrations.

Your application will make a call to third parties networks through a third party SDK, the result of this call is passed to the _Smart Display SDK_ through an adapter object, then it is forwarded to _Smart_ ad server which will arbitrate between its own server-side connected partners, your direct campaigns and the winner ad of the in-app bidding.

The winner of this competition will then be returned to the _Smart Display SDK_ with the ultimate goal to ensure that the ad with the highest CPM is displayed.

#### Step by step workflow

1. Integrate the in-app bidding SDK of your partner(s)
2. Request ads from the SDK of your partner(s) and find the most valuable ad for you _(most partners will return only the best ad, but if you integrate several partners you will have to arbitrate which ad is the best between the different responses)_
3. Instantiate a **bidding adapter** from your partner's response with CPM, currency, name, etc… see the next section for the implementation of your adapter.
4. Pass this adapter to your [SASBannerView](http://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASAdView.html) or your [SASInterstitialManager](http://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBaseInterstitialManager.html) when loading it
5. _Smart_ will use server-side _Holistic+_ capabilities to return the ad with the best CPM from all your sources
    - If the winning ad comes from _Smart_, the _Smart Display SDK_ will display it as usual
    - If _Smart_ loses the competition against your bidding partner, the adapter will be notified and 2 situations can happen:
        - Your partner in-app bidding SDK **has capabilities to display the winner ad**: you must request it to do so, this can be done through the adapter
        - Your partner in-app bidding SDK **does not have capabilities to display the winner ad**: the _Smart Display SDK_ will display it as long as the adapter is able to provide the HMTL ad markup.

Read the next sections to learn more about the [SASBidderAdapterProtocol](http://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html) and [SASBidderAdapter](http://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBidderAdapter.html) class.

#### SASBidderAdapterProtocol

To create your custom adapter, you must create a class that conforms to [SASBidderAdapterProtocol](http://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html).

Most of the properties should be set upon initialization of your adapter even if they will only be 'consumed' server-side when the adapter informations are passed into the ad call. Please refer to the [API documentation](http://documentation.smartadserver.com/displaySDK/ios/API/index.html) for complete list of the properties to be implemented.

##### Rendering type

When initializing your adapter, make sure to set the proper ```creativeRenderingType```:

- ```SASBidderAdapterCreativeRenderingTypePrimarySDK``` means that the _Smart Display SDK_ will be responsible for rendering the winning creative whether it comes from the ad server or the in-app bidding competition. It also means that your adapter will provide the HTML ad markup to be displayed.
- ```SASBidderAdapterCreativeRenderingType3rdPartySDK``` means that your partner's SDK will be responsible for rendering the winning creative if (and only if) the ad server loses the bidding competition. If the winning creative comes from _Smart_, the display will be done by the _Smart Display SDK_.

##### Rendering methods

For the rendering of the creative to occur properly, you need to implement these methods:

    /**
     Implement this method with the HTML markup to be displayed by the primary SDK when the winning creative is the one returned by the bidder.
     This markup is available in the documentation of each in-app bidding partner and often depends on several parameters, including the creative size.
     */
    - (NSString *)bidderWinningAdMarkup;

    /**
     This method is called when the bidder's winning ad is displayed, in case the primary SDK is responsible for creative rendering.
     You may perform actions when receiving this event, like counting impressions on your side, or trigger a new in-app bidding call, etc...
     */
    - (void)primarySDKDisplayedBidderAd;

    /**
     This method is called when the bidder's winning ad is clicked, in case the primary SDK is responsible for creative rendering.
     You may perform action when receiving this event, like counting clicks on your side, etc...
     */
    - (void)primarySDKClickedBidderAd;

    /**
     This method is called when the primary SDK did not return an ad with a better CPM than the bidder ad.
     If rendering the ad is the ad server SDK responsability, there is nothing to implement here.
     If rendering the ad is a third party SDK responsability, you should cascade the information, with all necessary parameters so that the winning ad is properly displayed.
     */
    - (void)primarySDKLostBidCompetition;

The documentation of the method is pretty straightforward, just note that when choosing ```SASBidderAdapterCreativeRenderingType3rdPartySDK``` rendering type you will have to trigger the display of the creative by the in-app bidding partner's SDK when ```primarySDKLostBidCompetition``` method is called.

This means that your adapter should also keep a reference to the ad loader of the in-app bidding partner's SDK.

#### SASBidderAdapter

Another convenient way to create your custom adapter is by subclassing [SASBidderAdapter](http://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBidderAdapter.html). You will need to override all the methods of [SASBidderAdapterProtocol](http://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html).

Make sure to select the proper creative rendering type depending on whether or not your third party in-app bidding SDK is able to display its creative by itself or not.
