import 'dart:io';
import 'dart:convert';

class GetNetworkData {
  Future<HttpClientResponse> getNetworkDataUsingPostMethod(
      String url, Map requestsend) async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    HttpClientRequest request = await client.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(requestsend)));
    HttpClientResponse response = await request.close();

    //String reply = await response.transform(utf8.decoder).join();
    //print(jsonDecode(reply));
    return response;
  }
}
