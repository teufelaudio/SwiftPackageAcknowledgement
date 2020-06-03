# SwiftPackageAcknowledgement

Creates a PLIST file out of a Swift Package Manager resolved JSON, including
its GitHub license. The PLIST can then be used by your app to show the
third-party libraries included in your app, by using one of the many
Acknowledgement ViewControllers available for CocoaPods, such as
https://github.com/vtourraine/AcknowList which is the one this script was
tested with.

Because this script's output matches perfectly the one from CocoaPods, you
can merge both PLISTs into one and have your Acknowledgement screen showing
all the dependencies you use in your app either if they come from SPM or Pods.

The license is fetched from GitHub and the unauthenticated API limit is around
60 requests per hour. If this is not enough for you, this script supports
OAuth Client credentials, so you can register your own GitHub application and
call this script using your ClientID and ClientSecret and increase the limits
to about 5000 per hour.

To register a GitHub application please follow this link:
https://github.com/settings/developers


## How to use

Without GitHub token
```
> swift run spm-ack generate-plist ~/MyProject/MyProject.xcworkspace ~/MyProject/Resources/SwiftPackageManager.plist
```

With GitHub token
```
> swift run spm-ack generate-plist ~/MyProject/MyProject.xcworkspace ~/MyProject/Resources/SwiftPackageManager.plist MyClientID MyClientToken
```

## Future plans

Instead of using CocoaPods PLIST as output, we plan to have our own JSON and allow
this script to also convert CocoaPods PLIST into this JSON format. The benefit is
allowing more information to be stored in the JSON, such as GitHub etag to avoid
fetching when this is not needed. The drawback is that this will break
compatibility with other Acknowledgement ViewControllers implementations, and
we'll need to provide a new one. To avoid that, when this is implemented, both
options will be available for you to choose.

Also it's planned to support other SPM sources such as BitBucket or GitLab, but
this is not our first priority at this point, so please feel free to contribute
in case this is useful for you.