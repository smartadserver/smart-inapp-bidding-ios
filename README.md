# Smart AdServer — iOS - Third party in-app bidding adapters & samples

_In-App bidding_ allows you to create a real time competition between direct sales, _Smart RTB+_ and third party ad networks just like header bidding does in a web environment.

This repository contains some in-app bidding adapters that can be used with the _Smart Display SDK **7.6 and up**_.

Integration samples are also available for each adapter (third party SDK may be required to build these samples).

## Requirements

- A _Smart AdServer_ account
- _Smart Display SDK_ 7.6 or higher
- _Xcode_ 11.0 or higher
- _iOS_ 8.0 or higher
- _Cocoapods_

## How does it work?

Just like header bidding on the web, your application may call a third party partner at any moment to get an ad response along with a price associated with a third party ad.

Then, for appropriate placements, you will pass this price to the _Smart Display SDK_ ad view through a bidding adapter object. While performing its own ad call, the ad view will forward the price (or it's representation as a keyword) to our ad server and _Holistic+_ competition will occur between your programmed insertions (direct and programmatic) and the third party in-app bidding winner. The ad server will determine the ad with the highest CPM and inform _Smart Display SDK_ which creative should be displayed to maximize your revenues.

## Available adapters

Adapters are available for the following third party in-app bidding SDK:

| SDK | Website | Adapter & documentation |
| --- | ------- | ----------------------- |
| Amazon Publisher Services | https://ams.amazon.com/webpublisher _(login required)_ | [Amazon adapter](Amazon/) |

## Custom adapters

You can add partners for in-app bidding without having to wait for _Smart_ to integrate them.

The _Smart Display SDK_ has an open protocol that can be implemented by custom classes to create third party in-app bidding adapters. These adapters should be initialized from the ad response you get from the in-app bidding partner and be passed to the _load_ method of the [SASBannerView](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASAdView.html) or the [SASInterstitialManager](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBaseInterstitialManager.html) when loading an ad. _Holistic+_ competition will then happen server side and the ad with the highest CPM will be displayed.

### Technical overview

In-app bidding is based on the same principle than header bidding for web integrations.

Your application will make a call to third parties networks through a third party SDK, the result of this call is passed to the _Smart Display SDK_ through an adapter object, then it is forwarded to _Smart_ ad server which will arbitrate between its own server-side connected partners, your direct campaigns and the winner ad of the in-app bidding.

The winner of this competition will then be returned to the _Smart Display SDK_ with the ultimate goal to ensure that the ad with the highest CPM is displayed.

#### Step by step workflow

1. Integrate the in-app bidding SDK of your partner(s)
2. Request ads from the SDK of your partner(s) and find the most valuable ad for you _(most partners will return only the best ad, but if you integrate several partners you will have to arbitrate which ad is the best between the different responses)_
3. Instantiate a **bidding adapter** from your partner's response with all relevant details to run the server-side competition (CPM, currency, name, keyword, etc… see the next section for the implementation of your adapter).
4. Pass this adapter to your [SASBannerView](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASAdView.html) or your [SASInterstitialManager](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBaseInterstitialManager.html) when loading it
5. _Smart_ will use server-side _Holistic+_ capabilities to return the ad with the best CPM from all your monetization sources
    - If the winning ad comes from _Smart_, the _Smart Display SDK_ will display it as usual
    - If _Smart_ loses the competition against your bidding partner, the adapter will be notified and 2 situations can happen:
        - Your partner in-app bidding SDK **has capabilities to display the winner ad**: you must request it to do so, this can be done through the adapter by forwarding the response to your application or by mediating the rendering of the partner SDK directly with the adapter
        - Your partner in-app bidding SDK **does not have capabilities to display the winner ad**: the _Smart Display SDK_ will display it as long as the adapter is able to provide the HMTL ad markup.

Read the next sections to learn more about the [SASBidderAdapterProtocol](https://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html) and [SASBidderAdapter](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBidderAdapter.html) class.

#### SASBidderAdapterProtocol

To create your custom adapter, you must create a class that conforms to [SASBidderAdapterProtocol](https://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html).

Most of the properties should be set upon initialization of your adapter even if they will only be 'consumed' server-side when the adapter informations are passed into the ad call. Please refer to the [API documentation](https://documentation.smartadserver.com/displaySDK/ios/API/index.html) for complete list of the properties to be implemented.

##### Competition type

When initializing your adapter, make sure to set the proper ```competitionType```:

- ```SASBidderAdapterCompetitionTypePrice``` means that the _Smart Display SDK_ will pass the price and the currency as parameters of the ad call, unobfuscated. With this competition type, you must implement the properties ```price``` and ```currency``` of the adapter.
- ```SASBidderAdapterCompetitionTypeKeyword``` means that the _Smart Display SDK_ will pass a representation of the price as a keyword in the ad call. This keyword must match with the keyword targeting of a programmed insertion that has also an eCPM priority and CPM filled in the ad server. With this competition type, you must implement the property ```keyword``` of the adapter.

##### Rendering type

When initializing your adapter, make sure to set the proper ```creativeRenderingType```:

- ```SASBidderAdapterCreativeRenderingTypePrimarySDK``` means that the _Smart Display SDK_ will be responsible for rendering the winning creative whether it comes from the ad server or the in-app bidding competition. It also means that your adapter must provide the HTML ad markup to be displayed.
- ```SASBidderAdapterCreativeRenderingType3rdParty``` means that your partner's SDK will ultimately be responsible for rendering the winning creative and that a third party (such as your application) will trigger it. This situation occurs if (and only if) Smart's ad server loses the bidding competition. If the winning creative comes from _Smart_, the display will be done by the _Smart Display SDK_. 
- ```SASBidderAdapterCreativeRenderingTypeMediation``` means that your partner's SDK will ultimately be responsible for rendering the winning creative but that the _Smart Display SDK_ will mediate this rendering through the adapter and forward all necessary callbacks to the delegate of the instanciated _Smart Display SDK_ ad view. 

##### Win Notification Callback

When the ad server loses the server-side competition, meaning that it was not able to return an ad with a higher CPM than the third party bidder, _Smart Display SDK_ will trigger the method:

    /**
     This method is called when Smart Display SDK did not return an ad with a better CPM than the bidder ad.
     */
    - (void)primarySDKLostBidCompetition;

When this method is called, you should perform all actions that you think relevant to log the competition result. 

##### Rendering methods

Several methods can be called for the rendering to occur, depending on the rendering type of the adapter.


###### Smart Display SDK Creative Rendering

This corresponds to the ```SASBidderAdapterCreativeRenderingTypePrimarySDK``` rendering type. For rendering of the creative to occur properly, your adapter must implement these methods:

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

###### Third party Creative Rendering

This corresponds to the ```SASBidderAdapterCreativeRenderingType3rdParty``` rendering type. For rendering of the creative to occur properly, your adapter must implement this method:

    /**
     This method is called when Smart Display SDK did not return an ad with a better CPM than the bidder ad.
     
     If rendering the ad is a third party responsibility, you should cascade the information, with all necessary
     parameters so that the winning ad is properly displayed.
     */
    - (void)primarySDKRequestedThirdPartyRendering;

Note that with this mode, your adapter will have to trigger the display of the creative by the in-app bidding partner's SDK when the method is called. This means that your adapter should also keep a reference to the ad loader of the in-app bidding partner's SDK and will be responsible to forward ad events to the application.

###### Mediation Creative Rendering - Banners

This corresponds to the ```SASBidderAdapterCreativeRenderingTypeMediation``` rendering type for banner ads. For rendering of the creative to occur properly, your adapter must implement this method:

    /**
     This method is called when Smart Display SDK is ready to display the banner ad of the Bidder SDK.
     
     You should add your ad view as a subview of the inputed view and forward all Bidder SDK events to the delegate.
     
     @param view the view instanciated by the publisher, that should be the container of the winning ad.
     @param delegate to be informed about the ad view events, this delegate will also forward events to the publisher's integration.
    */
    - (void)loadBidderBannerAdInView:(UIView *)view delegate:(nullable id <SASBannerBidderAdapterDelegate>)delegate

When this method is called, it is the right time to trigger the rendering of the banner for the bidder's SDK.

Note that with this mode, your adapter should forward the Bidder's SDK events to the ```SASBannerBidderAdapterDelegate``` provided so that they are also forwarded to the delegate's of _Smart Display SDK_ ad view.

###### Mediation Creative Rendering - Interstitials

This corresponds to the ```SASBidderAdapterCreativeRenderingTypeMediation``` rendering type for interstitial ads. For rendering of the creative to occur properly, your adapter must implement these methods:

    /**
     This method is called when Smart Display SDK is asking the Bidder SDK to load the interstitial ad.
         
     @param delegate to be informed about the interstitial events, this delegate will also forward events to the publisher's integration.
    */
    - (void)loadBidderInterstitialWithDelegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate;

When this method is called, it is the right time to call the load method of the Interstitial for the bidder's SDK.

    /**
     This method is called when Smart Display SDK is ready to display the interstitial ad of the Bidder SDK.
      
     @param viewController the viewcontroller instance to be used as the presentor of the Insterstitial ad.
     @param delegate to be informed about the interstitial events, this delegate will also forward events to the publisher's integration.
    */
    - (void)showBidderInterstitialFromViewController:(UIViewController *)viewController delegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate;

When this method is called, it is the right time to call the show method of the Interstitial for the bidder's SDK.

    /**
     This method returns whether or not the interstitial ad is ready to be displayed
      
     @return YES if interstitial ad is ready, NO otherwise;
    */
    - (BOOL)isInterstitialAdReady;

When this method is called, the bidder's SDK should return whether or not its interstitial ad is ready to display.

Note that with this mode, your adapter should forward the Bidder's SDK events to the ```SASInterstitialBidderAdapterDelegate``` provided so that they are also forwarded to the delegate's of _Smart Display SDK_ ad view.

#### SASBidderAdapter

Another convenient way to create your custom adapter is by subclassing [SASBidderAdapter](https://documentation.smartadserver.com/displaySDK/ios/API/Classes/SASBidderAdapter.html). You will need to override all the methods of [SASBidderAdapterProtocol](https://documentation.smartadserver.com/displaySDK/ios/API/Protocols/SASBidderAdapterProtocol.html).

Make sure to select the proper competition type and creative rendering type depending on whether or not your third party in-app bidding SDK is able to display its creative by itself or not and if you prefer to have it mediated by _Smart Display SDK_.
