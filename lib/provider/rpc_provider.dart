import 'dart:async';
import 'dart:convert';

import '../../provider/types/relayer_request.dart';
import '../../provider/types/relayer_response.dart';
import '../../provider/types/rpc_request.dart';
import '../../relayer/url_builder.dart';
import '../../relayer/webview.dart';

import 'package:web3dart/json_rpc.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'types/outbound_message.dart';

/// Rpc Provider
class RpcProvider implements RpcService {
  final WebViewRelayer _overlay;

  RpcProvider(this._overlay);

  /// Sending message to relayer
  Future<JavascriptMessage> send(
      {required MagicRPCRequest request,
      required Completer<JavascriptMessage> completer}) {
    var msgType = OutboundMessageType.MAGIC_HANDLE_REQUEST;

    var relayerRequest = RelayerRequest(
        msgType:
            '${msgType.toString().split('.').last}-${URLBuilder.instance.encodedParams}',
        payload: request);

    _overlay.enqueue(
        relayerRequest: relayerRequest, id: request.id, completer: completer);

    return completer.future;
  }

  /* web3dart wrapper */
  @override
  Future<RPCResponse> call(String function, [List? params]) {
    params ??= [];

    var request = MagicRPCRequest(method: function, params: params);

    /* Send the RPCRequest to Magic Relayer and decode it by using RPCResponse from web3dart */
    return send(request: request, completer: Completer<JavascriptMessage>())
        .then((jsMsg) {
      var relayerResponse = RelayerResponse<dynamic>.fromJson(
          json.decode(jsMsg.message), (json) => json as dynamic);
      return relayerResponse.response;
    });
  }
}
