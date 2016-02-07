# Applivery iOS Deploy Step

This is the new and official [Applivery.com](http://www.applivery.com) step to deploy iOS Apps in [Bitrise.io](http://bitrise.io).

## How to use this Step

Can be run directly with the [bitrise CLI](https://github.com/bitrise-io/bitrise),
just `git clone` this repository, `cd` into it's folder in your Terminal/Command Line
and call `bitrise run test`.

*Check the `bitrise.yml` file for required inputs which have to be
added to your `.bitrise.secrets.yml` file!*

## Step configuration
* Applivery API Key: This is the API Key to access your account. Sign in to your [Applivery.com](http://dashboard.applivery.com) account, click on `Developers` menu option from the left side menu and copy it from the `Account API Key` section.
* App Id: This is the App Id that identifies your App in Applivery.com. Sign in to your [Applivery.com](http://dashboard.applivery.com) account, click on `Applications` menu option from the left side menu, click on the desired App. You'll find the `App Id` inside the (i) information block (written in red).

Check `step.yml` file for more information
