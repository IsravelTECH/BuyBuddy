import 'dart:js_interop';

@JS('redirectToStripeCheckout')
external void _redirectToStripeCheckout(JSString sessionId, JSString publishableKey);

void redirectToStripe(String sessionId, String publishableKey) {
  _redirectToStripeCheckout(sessionId.toJS, publishableKey.toJS);
}
