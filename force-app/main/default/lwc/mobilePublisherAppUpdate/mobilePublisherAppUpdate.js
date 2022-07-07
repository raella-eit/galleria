import { api, LightningElement } from "lwc";

export default class DownloadLatestAppLwc extends LightningElement {
  @api
  title = "";

  @api
  text = "";

  @api
  buttonLabel = "";

  @api
  iosAppStoreLink = "";

  @api
  minAppVersionIOS = "";

  @api
  googlePlayStoreLink = "";

  @api
  minAppVersionAndroid = "";

  showBanner = false;

  connectedCallback() {
    this.updateShowBanner();
  }

  updateShowBanner() {
    let _showBanner = false;
    const appUrl = this.getAppUrl();
    const minAppVersion = this.getMinAppVersion();
    if (this.isHybrid() && appUrl && minAppVersion) {
      const appVersion = this.getAppVersion();
      _showBanner =
        appVersion.localeCompare(minAppVersion, undefined, {
          numeric: true
        }) === -1;
    }
    this.showBanner = _showBanner;
  }

  openStore() {
    window.open(this.getAppUrl());
  }

  getAppVersion() {
    const { userAgent } = navigator;
    const hybridRemote = userAgent.split(" HybridRemote ")[0];
    const appInfo = hybridRemote.substring(hybridRemote.lastIndexOf("/") + 1);
    return appInfo.split("(")[0];
  }

  getAppUrl() {
    if (this.isAndroid()) {
      return this.googlePlayStoreLink.trim();
    }
    if (this.isIOS()) {
      return this.iosAppStoreLink.trim();
    }
    return undefined;
  }

  getMinAppVersion() {
    if (this.isAndroid()) {
      return this.minAppVersionAndroid.trim();
    }
    if (this.isIOS()) {
      return this.minAppVersionIOS.trim();
    }
    return undefined;
  }

  isIOS() {
    const { userAgent } = navigator;
    return this.isHybrid() && (userAgent.toLowerCase().includes("iphone") || userAgent.toLowerCase().includes("ipad"));
  }

  isAndroid() {
    const { userAgent } = navigator;
    return this.isHybrid() && userAgent.toLowerCase().includes("android");
  }

  isHybrid() {
    const { userAgent } = navigator;
    return (
      userAgent.startsWith("SalesforceMobileSDK") &&
      (userAgent.includes("CommunityHybridContainer/") ||
        userAgent.includes("playgroundcommunity"))
    );
  }
}