import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/api/app_envirments.dart';
import 'package:autopeepal/api/app_urls.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/actuatorTest_model.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/categoryRoot_model.dart';
import 'package:autopeepal/models/changePassword_model.dart';
import 'package:autopeepal/models/checkJobCard_model.dart';
import 'package:autopeepal/models/createTickit_model.dart';
import 'package:autopeepal/models/createUserReq_model.dart';
import 'package:autopeepal/models/creteSessionReq_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:autopeepal/models/expert_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/getApiRespomnse_model.dart';
import 'package:autopeepal/models/iorTest_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/latestAppVersion_model.dart';
import 'package:autopeepal/models/latestDB_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/modelList_model.dart';
import 'package:autopeepal/models/notification_model.dart';
import 'package:autopeepal/models/oem_model.dart';
import 'package:autopeepal/models/parameter_model.dart';
import 'package:autopeepal/models/partReplacementAnalyze_model.dart';
import 'package:autopeepal/models/pidLiveRecord_model.dart';
import 'package:autopeepal/models/registerDongle_model.dart';
import 'package:autopeepal/models/remoteJobCard_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/firmwareUpdate_model.dart';
import 'package:autopeepal/models/srSearchReq_model.dart';
import 'package:autopeepal/models/srSearchResp_model.dart';
import 'package:autopeepal/models/tickitList_model.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/uploadEngineHr_model.dart';
import 'package:autopeepal/models/variant_model.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../models/user_model.dart';
import 'package:path/path.dart' as p;

class AuthApiService {
  late HttpClient client;

  ApiServices({int timeout = 100}) {
    // 1. Replicating HttpClientHandler with certificate bypass
    client = HttpClient();

    // ServerCertificateCustomValidationCallback equivalent
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    // 2. Setting the timeout
    client.connectionTimeout = Duration(seconds: timeout);
  }

  static Future<UserResModel> login(UserModel model) async {
    UserResModel loginResponse = UserResModel();

    final url = Uri.parse("${AppEnvironment.baseUrl}${AppURLs.login}");

    try {
      print("👉 loginOnline() STARTED");
      print("👉 Calling API login");

      // =========================
      // CHECK INTERNET
      // =========================
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        loginResponse.message = "Check internet connection.";
        return loginResponse;
      }

      // =========================
      // REQUEST BODY
      // =========================
      final jsonBody = jsonEncode(model.toJson());

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      print("👉 API RESPONSE RECEIVED");

      final String data = response.body;

      // =========================
      // SUCCESS RESPONSE
      // =========================
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseJson = jsonDecode(data);

        loginResponse = UserResModel.fromJson(responseJson);

        print("User: ${loginResponse.user}");
        print("Error: ${loginResponse.error}");
        print("Detail: ${loginResponse.detail}");

        // =========================
        // SAVE TOKEN
        // =========================
        if (loginResponse.token != null) {
          await AppPreferences.setString(
            "accessToken",
            loginResponse.token?.access ?? '',
          );

          await AppPreferences.setString(
            "refreshToken",
            loginResponse.token?.refresh ?? '',
          );
        }

        // =========================
        // SAVE USER INFO
        // =========================
        await AppPreferences.saveUser(
          userId: loginResponse.userId.toString(),
          name:
              "${loginResponse.firstName ?? ''} ${loginResponse.lastName ?? ''}"
                  .trim(),
          email: loginResponse.user ?? '',
        );

        // =========================
        // PROFILE SAFE PARSING (FIXED)
        // =========================
        final profile = responseJson['profile'];

        if (profile != null) {
          print("👉 PROFILE RAW: $profile");

          // -------------------------
          // WORKSHOP (SAFE INT OR OBJECT)
          // -------------------------
          final workshopRaw = profile['workshop'];

          if (workshopRaw != null) {
            if (workshopRaw is int) {
              App.workshop = workshopRaw;
            } else if (workshopRaw is Map && workshopRaw['id'] != null) {
              App.workshop = int.tryParse(workshopRaw['id'].toString());
            }
          }

          // -------------------------
          // WORKSHOP GROUP (SAFE INT OR OBJECT)
          // -------------------------
          final workshopGrpRaw = profile['workshop_group'];

          if (workshopGrpRaw != null) {
            if (workshopGrpRaw is int) {
              App.workshopGrp = workshopGrpRaw;
            } else if (workshopGrpRaw is Map && workshopGrpRaw['id'] != null) {
              App.workshopGrp = int.tryParse(workshopGrpRaw['id'].toString());
            }
          }

          print("✅ workshop: ${App.workshop}");
          print("✅ workshopGrp: ${App.workshopGrp}");
        }

        // =========================
        // OEM ID SAFE
        // =========================
        final oemId = responseJson['profile']?['oem'];

        if (oemId is int) {
          await AppPreferences.setInt("oemId", oemId);
        } else if (oemId is Map && oemId['id'] != null) {
          await AppPreferences.setInt(
            "oemId",
            int.tryParse(oemId['id'].toString()) ?? 0,
          );
        }

        loginResponse.message = "success";
      }

      // =========================
      // ERROR RESPONSE
      // =========================
      else {
        loginResponse.message =
            "${response.statusCode}: ${_extractErrorMessage(data)}";
      }

      print("👉 LOGIN FINISHED");
    }

    // =========================
    // EXCEPTION HANDLING
    // =========================
    on SocketException {
      loginResponse.message =
          "Network unreachable. Please check your connection.";
    } on TimeoutException {
      loginResponse.message =
          "Server is taking too long to respond. Please try again.";
    } catch (e) {
      print("❌ LOGIN ERROR: $e");

      loginResponse.message = "An unexpected error occurred: ${e.toString()}";
    }

    // =========================
    // FINAL RESULT
    // =========================
    if (loginResponse.message != "success") {
      print("❌ LOGIN FAILED");
    }

    return loginResponse;
  }

  static String _extractErrorMessage(String data) {
    try {
      final decoded = jsonDecode(data);
      return decoded['message'] ?? decoded['error'] ?? data;
    } catch (_) {
      return data;
    }
  }

  Future<InvantabUserResModel> invantabLogin(InvantabUserModel model) async {
    InvantabUserResModel loginResponse = InvantabUserResModel();

    try {
      // Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url = Uri.parse("http://143.244.142.0/api/v1/accounts/login");
        final jsonPayload = jsonEncode(model.toJson());

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonPayload,
        );

        final data = response.body;

        // Equivalent to Debug.WriteLine
        // developer.log(
        //   'REQUEST :\n$jsonPayload\n\nRESPONSE :\n$data',
        //   name: 'Invantab Login API',
        // );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Map JSON to Model
          loginResponse = InvantabUserResModel.fromJson(jsonDecode(data));
          loginResponse.status = "success";
        } else {
          // Handle API Error
          loginResponse.message =
              "ApiServices.invantabLogin() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        loginResponse.message = "Please check internet connection.";
      }

      return loginResponse;
    } catch (e) {
      loginResponse.status =
          "Exception in ApiServices.invantabLogin() : ${e.toString()}";
      return loginResponse;
    }
  }

  Future<UserResModel> loginAgain(UserModel model) async {
    UserResModel loginResponse = UserResModel();

    try {
      // 1. Prepare Authorization Header
      Map<String, String> headers = {
        'Authorization': 'JWT ${App.jwtToken}',
        'Content-Type': 'application/json',
      };

      // 2. Execute Logout (GET Request)
      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.logout);
      final response = await http.get(url, headers: headers);

      final data = response.body;

      // Using print instead of developer.log
      print('--- Logout API ---');
      print('URL: $url');
      print('RESPONSE: $data');
      print('------------------');

      // 3. Execute Login
      loginResponse = await login(model);

      return loginResponse;
    } catch (e) {
      print("Error in loginAgain: ${e.toString()}");
      return loginResponse;
    }
  }

  Future<CreateUserResModel> createNewUser(CreateUserReqModel model) async {
    CreateUserResModel createUserResModel = CreateUserResModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.registerUser);

        final jsonPayload = jsonEncode(model.toJson());

        // 2. Execute POST Request
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonPayload,
        );

        final data = response.body;

        // Print logs
        print('--- User Registration API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('-----------------------------');

        // 3. Handle Status Codes
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success (200-299)
          createUserResModel.createUserRes =
              CreateUserRes.fromJson(jsonDecode(data));
          createUserResModel.status = "success";
          createUserResModel.apiStatus = "created";
        } else if (response.statusCode == 400) {
          // Bad Request
          createUserResModel.createUserError =
              CreateUserError.fromJson(jsonDecode(data));
          createUserResModel.status = "success";
          createUserResModel.apiStatus = "bad request";
        } else if (response.statusCode == 500 || response.statusCode == 503) {
          // Server Errors
          createUserResModel.status =
              "ApiServices.createNewUser() : ${response.statusCode}";
        } else {
          // Other errors
          createUserResModel.status =
              "${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        createUserResModel.status = "Check internet connection.";
      }

      return createUserResModel;
    } catch (ex) {
      print("Exception in ApiServices.createNewUser(): ${ex.toString()}");
      createUserResModel.status =
          "Exception in ApiServices.createNewUser() : ${ex.toString()}";
      return createUserResModel;
    }
  }

  Future<LatestAppVersionModel> checkLatestAppVersion() async {
    LatestAppVersionModel latestAppVersionModel = LatestAppVersionModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/runtimerevision/latest/');

        // 2. Prepare Authorization Header (JWT)
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs
        print('--- Check Latest App Version API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('------------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON body
          latestAppVersionModel =
              LatestAppVersionModel.fromJson(jsonDecode(data));
          latestAppVersionModel.message = "success";
        } else {
          // Handle API Error
          latestAppVersionModel.message =
              "ApiServices.checkLatestAppVersion() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        latestAppVersionModel.message = "Check internet connection.";
      }

      return latestAppVersionModel;
    } catch (ex) {
      print(
          "Exception in ApiServices.checkLatestAppVersion(): ${ex.toString()}");
      latestAppVersionModel.message =
          "Exception in ApiServices.checkLatestAppVersion() : ${ex.toString()}";
      return latestAppVersionModel;
    }
  }

  Future<LatestDbVersionModel> checkLatestDbVersion() async {
    LatestDbVersionModel latestDbVersionModel = LatestDbVersionModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url =
            Uri.parse('${AppEnvironment.baseUrl}/api/v1/dbrevision/latest/');

        // 2. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs
        print('--- Check Latest Db Version API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('----------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Map JSON to Model
          // Assumes your model has a fromJson factory
          latestDbVersionModel =
              LatestDbVersionModel.fromJson(jsonDecode(data));
          latestDbVersionModel.message = "success";
        } else {
          // Handle API Error
          latestDbVersionModel.message =
              "ApiServices.checkLatestDbVersion() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        latestDbVersionModel.message = "Check internet connection.";
      }

      return latestDbVersionModel;
    } catch (ex) {
      print(
          "Exception in ApiServices.checkLatestDbVersion(): ${ex.toString()}");
      latestDbVersionModel.message =
          "Exception in ApiServices.checkLatestDbVersion() : ${ex.toString()}";
      return latestDbVersionModel;
    }
  }

  Future<AllModelsModel> getAllModels(int oemId) async {
    AllModelsModel allModelsModel = AllModelsModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        // 2. Build URL with query parameters
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/models/get-models/?oem=$oemId');

        // 3. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs
        print('--- Get All Models API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('--------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Map JSON to Model
          // Assumes AllModelsModel has a fromJson factory
          allModelsModel = AllModelsModel.fromJson(jsonDecode(data));
          allModelsModel.message = "success";
        } else {
          // Handle API Error
          allModelsModel.message =
              "ApiServices.getAllModels() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        allModelsModel.message = "Check internet connection.";
      }

      return allModelsModel;
    } catch (ex) {
      print("Exception in ApiServices.getAllModels(): ${ex.toString()}");
      allModelsModel.message =
          "Exception in ApiServices.getAllModels() : ${ex.toString()}";
      return allModelsModel;
    }
  }

  Future<Root> getAllPids(String token) async {
    Root root = Root();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/datasets/get-pid-datasets/');

        // 2. Prepare Authorization Header with the passed token
        Map<String, String> headers = {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        };

        // 3. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs (Replaces Debug.WriteLine)
        print('--- Get All Pids API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Parse the JSON string into the Root object
          // Assumes your Root class has a fromJson factory
          root = Root.fromJson(jsonDecode(data));
          root.message = "success";
        } else {
          // Handle API Error
          root.message =
              "ApiServices.getAllPids() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        root.message = "Check internet connection.";
      }

      return root;
    } catch (ex) {
      print("Exception in ApiServices.getAllPids(): ${ex.toString()}");
      root.message = "Exception in ApiServices.getAllPids() : ${ex.toString()}";
      return root;
    }
  }

  Future<Root> getPidDataset(int datasetId) async {
    Root root = Root();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        // 2. Build URL with query parameter 'id'
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/datasets/get-pid-datasets/?id=$datasetId');

        // 3. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs
        print('--- Get PID Dataset API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('---------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Map JSON to Model
          root = Root.fromJson(jsonDecode(data));
          root.message = "success";
        } else {
          // Handle API Error
          root.message =
              "ApiServices.getPidDataset() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        root.message = "Check internet connection.";
      }

      return root;
    } catch (ex) {
      print("Exception in ApiServices.getPidDataset(): ${ex.toString()}");
      root.message =
          "Exception in ApiServices.getPidDataset() : ${ex.toString()}";
      return root;
    }
  }

  Future<DtcMainModel> getAllDtcs(String token) async {
    DtcMainModel results = DtcMainModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/datasets/get-dtc-datasets/');

        // 2. Prepare Authorization Header with the passed token
        Map<String, String> headers = {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        };

        // 3. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs (Replaces Debug.WriteLine)
        print('--- Get All Dtcs API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Parse the JSON string into the DtcMainModel object
          results = DtcMainModel.fromJson(jsonDecode(data));
          results.message = "success";
        } else {
          // Handle API Error
          results.message =
              "ApiServices.getAllDtcs() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        results.message = "Check internet connection.";
      }

      return results;
    } catch (ex) {
      print("Exception in ApiServices.getAllDtcs(): ${ex.toString()}");
      results.message =
          "Exception in ApiServices.getAllDtcs() : ${ex.toString()}";
      return results;
    }
  }

  Future<VariantModel> getVariantList(int oemId) async {
    VariantModel results = VariantModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        // 2. Build URL with the oem query parameter
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/variant/list/?oem=$oemId');

        // 3. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs
        print('--- Get Variant List API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('----------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string
          results = VariantModel.fromJson(jsonDecode(data));
          results.message = "success";
        } else {
          // Handle API Error
          results.message =
              "ApiServices.getVariantList() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        results.message = "Check internet connection.";
      }

      return results;
    } catch (ex) {
      print("Exception in ApiServices.getVariantList(): ${ex.toString()}");
      results.message =
          "Exception in ApiServices.getVariantList() : ${ex.toString()}";
      return results;
    }
  }

  Future<ParameterModel> getParameterList() async {
    ParameterModel results = ParameterModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url =
            Uri.parse('${AppEnvironment.baseUrl}/api/v1/parameter/list/');

        // 2. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs
        print('--- Get Parameter List API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Map JSON string to the model
          // Assumes ParameterModel has a fromJson factory
          results = ParameterModel.fromJson(jsonDecode(data));
          results.message = "success";
        } else {
          // Handle API Error
          results.message =
              "ApiServices.getParameterList() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        results.message = "Check internet connection.";
      }

      return results;
    } catch (ex) {
      print("Exception in ApiServices.getParameterList(): ${ex.toString()}");
      results.message =
          "Exception in ApiServices.getParameterList() : ${ex.toString()}";
      return results;
    }
  }

  Future<FreezeFrameModel> getFreezeFrameList() async {
    FreezeFrameModel results = FreezeFrameModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/datasets/get-freeze-frames/');

        // 2. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs (Equivalent to Debug.WriteLine)
        print('--- Get Freeze Frame List API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('---------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into your model
          // Assumes FreezeFrameModel has a fromJson factory
          results = FreezeFrameModel.fromJson(jsonDecode(data));
          results.message = "success";
        } else {
          // Handle API Error
          results.message =
              "ApiServices.getFreezeFrameList() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        results.message = "Please check internet connection.";
      }

      return results;
    } catch (ex) {
      print("Exception in ApiServices.getFreezeFrameList(): ${ex.toString()}");
      results.message =
          "Exception in ApiServices.getFreezeFrameList() : ${ex.toString()}";
      return results;
    }
  }

  Future<EnvSetModel> getEnvSetList(int ecuId) async {
    EnvSetModel results = EnvSetModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        // 2. Build URL with the ecu query parameter
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/datasets/get-environment-snapshot/?ecu=$ecuId');

        // 3. Prepare Authorization Header
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Print logs (Equivalent to Debug.WriteLine)
        print('--- Get Env Set List API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('----------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into your model
          // Assumes EnvSetModel has a fromJson factory constructor
          results = EnvSetModel.fromJson(jsonDecode(data));
          results.message = "success";
        } else {
          // Handle API Error
          results.message =
              "ApiServices.getEnvSetList() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        results.message = "Please check internet connection.";
      }

      return results;
    } catch (ex) {
      print("Exception in ApiServices.getEnvSetList(): ${ex.toString()}");
      results.message =
          "Exception in ApiServices.getEnvSetList() : ${ex.toString()}";
      return results;
    }
  }

  Future<CreateSessionResModel> createSession(
      CreateSessionReqModel model) async {
    CreateSessionResModel createSessionResModel = CreateSessionResModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        // 2. Get Device Unique ID
        // Note: In Flutter, you usually use the 'device_info_plus' package for this.
        // Assuming you have a helper method similar to your C# extension:
        List<String> deviceIdData =
            await AndroidOperationsService.getDeviceUniqueId();
        model.macId = deviceIdData[0];

        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/new/srsession-create/');
        final jsonPayload = jsonEncode(model.toJson());

        // 3. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Print logs
        print('--- Create SRN Session API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the response
          createSessionResModel =
              CreateSessionResModel.fromJson(jsonDecode(data));
          createSessionResModel.message = "success";
        } else {
          // Handle API Error
          createSessionResModel.message =
              "ApiServices.createSession() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        createSessionResModel.message = "Please check internet connection.";
      }

      return createSessionResModel;
    } catch (ex) {
      print("Exception in ApiServices.createSession(): ${ex.toString()}");
      createSessionResModel.success = false;
      createSessionResModel.message =
          "Exception in ApiServices.createSession() : ${ex.toString()}";
      return createSessionResModel;
    }
  }

  Future<void> uploadEngineHrs(UploadEngineHrsModel model) async {
    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare URL and Payload
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/srsession-hrs/create/');
        final jsonPayload = jsonEncode(model.toJson());

        // 3. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // 5. Debug Logging
        print('--- Upload Engine Hrs API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('-----------------------------');
      }
    } catch (ex) {
      // Logic mirrors your empty catch block
      print("Error in uploadEngineHrs: ${ex.toString()}");
    }
  }

  Future<SessionListModel> getSessionBySrNumber(GetSrModel model) async {
    SessionListModel sessionListResModel = SessionListModel();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/get/srsession-by-srnumber');
        final jsonPayload = jsonEncode(model.toJson());

        // 2. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Print logs
        print('--- Get Session By SR Number API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('------------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the response body into a single SessionModel
          final sessionResModel = SessionModel.fromJson(jsonDecode(data));

          sessionListResModel.message = "success";

          // Replicating your C# logic: Initialize the list and add the single result
          sessionListResModel.results = <SessionModel>[];
          sessionListResModel.results.add(sessionResModel);
        } else {
          // Handle API Error
          sessionListResModel.message =
              "ApiServices.getSessionBySrNumber() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        sessionListResModel.message = "Please check internet connection.";
      }

      return sessionListResModel;
    } catch (ex) {
      print(
          "Exception in ApiServices.getSessionBySrNumber(): ${ex.toString()}");
      sessionListResModel.message =
          "Exception in ApiServices.getSessionBySrNumber() : ${ex.toString()}";
      return sessionListResModel;
    }
  }

  Future<SessionListModel> getSessionList(int userId) async {
    SessionListModel sessionListModel = SessionListModel();

    try {
      // 1. Prepare the URL with the query parameter
      final url = Uri.parse(
          '${AppEnvironment.baseUrl}/api/v1/analyze/srsession-list/?created_by=$userId');

      // 2. Prepare Authorization Headers
      Map<String, String> headers = {
        'Authorization': 'JWT ${App.jwtToken}',
        'Content-Type': 'application/json',
      };

      // 3. Execute the GET Request
      final response = await http.get(url, headers: headers);
      final data = response.body;

      // Optional: Logging similar to your C# Debug.WriteLine
      print('--- Get Session List API ---');
      print('URL: $url');
      print('RESPONSE: $data');
      print('----------------------------');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 4. Deserialize the JSON string into the model
        // Assumes SessionListModel has a fromJson factory constructor
        sessionListModel = SessionListModel.fromJson(jsonDecode(data));
        sessionListModel.message = "success";
      } else {
        // Handle API level errors
        sessionListModel.message =
            "ApiServices.getSessionList() : ${response.statusCode}";
      }

      return sessionListModel;
    } catch (ex) {
      // 5. Catch and return exceptions
      print("Exception in ApiServices.getSessionList(): ${ex.toString()}");
      sessionListModel.message =
          "Exception in ApiServices.getSessionList() : ${ex.toString()}";
      return sessionListModel;
    }
  }

  Future<SessionListModel> getAllSessionList(int userId) async {
    SessionListModel sessionListModel = SessionListModel();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare the URL with the query parameter
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/srsession-list/?created_by=$userId');

        // 3. Prepare Authorization Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute the GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Debug printing (Replaces Debug.WriteLine)
        print('--- Get All Session List API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('--------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into the model
          // sessionListModel = SessionListModel.fromJson(jsonDecode(data));
          final decoded = jsonDecode(data);

          final safeJson = Map<String, dynamic>.from(decoded);

          sessionListModel = SessionListModel.fromJson(safeJson);
          sessionListModel.message = "success";
        } else {
          // Handle API level errors
          sessionListModel.message =
              "ApiServices.getAllSessionList() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        sessionListModel.message = "Please check internet connection.";
      }

      return sessionListModel;
    } catch (ex) {
      print("Exception in ApiServices.getAllSessionList(): ${ex.toString()}");
      sessionListModel.message =
          "Exception in ApiServices.getAllSessionList() : ${ex.toString()}";
      return sessionListModel;
    }
  }

  // Future<CloseSessionResponse> closeSession(
  //     int srSessionId, CloseSession model) async {
  //   CloseSessionResponse closeSessionResponse = CloseSessionResponse();

  //   try {
  //     // 1. Check Connectivity using your service
  //     bool isConnected = await AndroidOperationsService.hasInternet();

  //     if (isConnected) {
  //       // 2. Prepare URL (Path parameters) and JSON body
  //       final url = Uri.parse(
  //           '${AppEnvironment.baseUrl}/api/v1/analyze/sr-session/$srSessionId/close-session/');
  //       final jsonPayload = jsonEncode(model.toJson());

  //       // 3. Prepare Authorization Headers
  //       Map<String, String> headers = {
  //         'Authorization': 'JWT ${App.jwtToken}',
  //         'Content-Type': 'application/json',
  //       };

  //       // 4. Execute the PUT Request
  //       final response = await http.put(
  //         url,
  //         headers: headers,
  //         body: jsonPayload,
  //       );

  //       final data = response.body;

  //       // Optional: Debug printing
  //       print('--- Close Session API ---');
  //       print('URL: $url');
  //       print('REQUEST: $jsonPayload');
  //       print('RESPONSE: $data');
  //       print('-------------------------');

  //       if (response.statusCode >= 200 && response.statusCode < 300) {
  //         // Success: Deserialize the response
  //         closeSessionResponse =
  //             CloseSessionResponse.fromJson(jsonDecode(data));
  //         closeSessionResponse.message = "success";
  //       } else {
  //         // Handle API level errors
  //         closeSessionResponse.message =
  //             "ApiServices.closeSession() : ${response.statusCode}\n${_extractErrorMessage(data)}";
  //       }
  //     } else {
  //       closeSessionResponse.message = "Please check internet connection.";
  //     }

  //     return closeSessionResponse;
  //   } catch (ex) {
  //     print("Exception in ApiServices.closeSession(): ${ex.toString()}");
  //     closeSessionResponse.message =
  //         "Exception in ApiServices.closeSession() : ${ex.toString()}";
  //     return closeSessionResponse;
  //   }
  // }
  Future<CloseSessionResponse> closeSession(
    int srSessionId,
    CloseSessionRequest model,
  ) async {
    CloseSessionResponse closeSessionResponse = CloseSessionResponse();

    try {
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        final url = Uri.parse(
          '${AppEnvironment.baseUrl}/api/v1/analyze/sr-session/$srSessionId/close-session/',
        );

        final jsonPayload = jsonEncode(model.toJson());

        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        final response = await http.put(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        print('--- Close Session API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('-------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          closeSessionResponse =
              CloseSessionResponse.fromJson(jsonDecode(data));
          closeSessionResponse.message = "success";
        } else {
          closeSessionResponse.message =
              "ApiServices.closeSession(): ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        closeSessionResponse.message = "Please check internet connection.";
      }

      return closeSessionResponse;
    } catch (ex) {
      print("Exception: ${ex.toString()}");
      closeSessionResponse.message = "Exception: ${ex.toString()}";
      return closeSessionResponse;
    }
  }

  // Future<OemModel> getAllOem() async {
  //   OemModel oemModel = OemModel();

  //   try {
  //     // 1. Check Connectivity using your service
  //     bool isConnected = await AndroidOperationsService.hasInternet();

  //     if (isConnected) {
  //       final url = Uri.parse('${AppEnvironment.baseUrl}/api/v1/oem/oem/');

  //       // 2. Execute GET Request
  //       // Note: Authorization is commented out in your C# code,
  //       // but I've added the header structure if you need it later.
  //       final response = await http.get(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           // 'Authorization': 'JWT ${App.jwtToken}',
  //         },
  //       );

  //       final data = response.body;

  //       // 3. Handle Status Codes
  //       if (response.statusCode >= 200 && response.statusCode < 300) {
  //         // Success: Deserialize the JSON string into the model
  //         oemModel = OemModel.fromJson(jsonDecode(data));
  //         oemModel.message = "success";
  //       } else {
  //         // Handle API level errors
  //         oemModel.message =
  //             "ApiServices.getAllOem() : ${response.statusCode}\n${_extractErrorMessage(data)}";
  //       }
  //     } else {
  //       oemModel.message = "Please check internet connection.";
  //     }

  //     return oemModel;
  //   } catch (ex) {
  //     print("Exception in ApiServices.getAllOem(): ${ex.toString()}");
  //     oemModel.message =
  //         "Exception in ApiServices.getAllOem() : ${ex.toString()}";
  //     return oemModel;
  //   }
  // }
  Future<OemModel> getAllOem() async {
    OemModel oemModel = OemModel();

    try {
      print("🔵 getAllOem() called");

      // 🔐 Check token
      print("🔐 JWT Token: ${App.jwtToken}");

      bool isConnected = await AndroidOperationsService.hasInternet();

      if (!isConnected) {
        oemModel.message = "Please check internet connection.";
        print("❌ No internet connection");
        return oemModel;
      }

      final url = Uri.parse('${AppEnvironment.baseUrl}/api/v1/oem/oem/');

      print("🌐 Request URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',

          // 🔥 AUTH FIX (IMPORTANT)
          'Authorization': 'Bearer ${App.jwtToken}', // OR 'JWT ${App.jwtToken}'
        },
      );

      print("🟡 Status Code: ${response.statusCode}");
      print("🟡 Response Body: ${response.body}");

      final data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        oemModel = OemModel.fromJson(jsonDecode(data));
        oemModel.message = "success";

        print("✅ OEM fetched successfully");
      } else {
        oemModel.message =
            "ApiServices.getAllOem() : ${response.statusCode}\n${_extractErrorMessage(data)}";

        print("❌ API Error: ${oemModel.message}");
      }

      return oemModel;
    } catch (ex, stack) {
      print("❌ Exception in getAllOem: $ex");
      print("📛 Stacktrace: $stack");

      oemModel.message =
          "Exception in ApiServices.getAllOem() : ${ex.toString()}";

      return oemModel;
    }
  }

  Future<CategoryRootModel> getAllCategories() async {
    // Initializing with optional/nullable fields allows this call
    CategoryRootModel model = CategoryRootModel();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        final url =
            Uri.parse('${AppEnvironment.baseUrl}/api/v1/user/category/list/');

        // 2. Execute GET Request
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'JWT ${App.jwtToken}', // Uncomment if needed
          },
        );

        final data = response.body;

        // 3. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize JSON to CategoryRootModel
          model = CategoryRootModel.fromJson(jsonDecode(data));
          model.message = "success";
        } else {
          // Handle API Error
          model.message =
              "ApiServices.getAllCategories() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        model.message = "Please check internet connection.";
      }

      return model;
    } catch (ex) {
      print("Exception in ApiServices.getAllCategories(): ${ex.toString()}");
      model.message =
          "Exception in ApiServices.getAllCategories() : ${ex.toString()}";
      return model;
    }
  }

  Future<String> getWorkShopData() async {
    try {
      // 1. Define the URL
      final url =
          Uri.parse('${AppEnvironment.baseUrl}/api/v1/oem/get-workshop');

      // 2. Execute the GET Request
      // Note: If you need headers, add the headers: {} parameter here.
      final response = await http.get(url);

      // 3. Read the body content
      final data = response.body;

      // Optional: Log the response
      print('--- Get Workshop Data API ---');
      print('URL: $url');
      print('RESPONSE: $data');
      print('-----------------------------');

      return data;
    } catch (ex) {
      // 4. Handle exceptions
      // Assuming you have the showMessage extension we created earlier
      "Exception in ApiServices.getWorkShopData() : ${ex.toString()}"
          .showMessage();

      return "";
    }
  }

  Future<SessionListModel> getSessionBySessionId(int sessionId) async {
    // Ensure your SessionListModel constructor handles initialization
    // (e.g., results: [] if it is required)
    SessionListModel sessionListModel = SessionListModel(results: []);

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Build URL with query parameter 'id'
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/srsession-list/?id=$sessionId');

        // 3. Prepare Authorization Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute the GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Optional: Debug logging
        print('--- Get Session By Session ID API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('--------------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into the model
          sessionListModel = SessionListModel.fromJson(jsonDecode(data));
          sessionListModel.message = "success";
        } else {
          // Handle API level errors
          sessionListModel.message =
              "ApiServices.getSessionBySessionId() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        sessionListModel.message = "Please check internet connection.";
      }

      return sessionListModel;
    } catch (ex) {
      print(
          "Exception in ApiServices.getSessionBySessionId(): ${ex.toString()}");
      sessionListModel.message =
          "Exception in ApiServices.getSessionBySessionId() : ${ex.toString()}";
      return sessionListModel;
    }
  }

  Future<RegDongleRespons> registerDongle(
      RegisterDongleModel registerDongleModel, String token) async {
    // Ensure your model constructor allows empty initialization
    // or provide required fields if necessary.
    RegDongleRespons regDongleRespons = RegDongleRespons();

    try {
      // 1. Check Connectivity
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/devices/register/odb-device/');
        final jsonPayload = jsonEncode(registerDongleModel.toJson());

        // 2. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        };

        // 3. Execute POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Optional: Debug logging
        print('--- Register Dongle API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('---------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize response
          regDongleRespons = RegDongleRespons.fromJson(jsonDecode(data));
          regDongleRespons.status = "success";
        } else {
          // Handle API level errors
          regDongleRespons.message =
              "ApiServices.registerDongle() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        regDongleRespons.message = "Please check internet connection.";
      }

      return regDongleRespons;
    } catch (ex) {
      print("Exception in ApiServices.registerDongle(): ${ex.toString()}");
      regDongleRespons.message =
          "Exception in ApiServices.registerDongle() : ${ex.toString()}";
      return regDongleRespons;
    }
  }

  Future<ValidateVariantResponseModel> getVariantPartValue(
      ValidateVariantRequestModel model) async {
    ValidateVariantResponseModel validateVariantResModel =
        ValidateVariantResponseModel();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze_prodbud/validateESN-flashing');
        final jsonPayload = jsonEncode(model.toJson());

        // 2. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Debug printing (Replaces Debug.WriteLine)
        print('--- Get Variant Part Value API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('----------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize JSON to ValidateVariantResponseModel
          validateVariantResModel =
              ValidateVariantResponseModel.fromJson(jsonDecode(data));
          validateVariantResModel.message = "success";
        } else {
          // Handle API level errors
          validateVariantResModel.message =
              "ApiServices.getVariantPartValue() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        validateVariantResModel.message = "Please check internet connection.";
      }

      return validateVariantResModel;
    } catch (ex) {
      print("Exception in ApiServices.getVariantPartValue(): ${ex.toString()}");
      validateVariantResModel.message =
          "Exception in ApiServices.getVariantPartValue() : ${ex.toString()}";
      return validateVariantResModel;
    }
  }

  Future<VariantPartRoot> getVariantPartValueNew(String srNumber) async {
    // Initialize the model. Ensure the constructor handles required fields if any.
    VariantPartRoot variantPartResponse = VariantPartRoot();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Build URL with query parameter 'sr_number'
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/get/srsession/part-replacement/list/?sr_number=$srNumber');

        // 3. Prepare Authorization Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute the GET Request
        final response = await http.get(url, headers: headers);
        final data = response.body;

        // Debug printing
        print('--- Get Variant Part Value New API ---');
        print('URL: $url');
        print('RESPONSE: $data');
        print('--------------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize JSON to VariantPartRoot
          variantPartResponse = VariantPartRoot.fromJson(jsonDecode(data));
          variantPartResponse.message = "success";
        } else {
          // Handle API level errors
          variantPartResponse.message =
              "ApiServices.getVariantPartValueNew() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        variantPartResponse.message = "Please check internet connection.";
      }

      return variantPartResponse;
    } catch (ex) {
      print(
          "Exception in ApiServices.getVariantPartValueNew(): ${ex.toString()}");
      variantPartResponse.message =
          "Exception in ApiServices.getVariantPartValueNew() : ${ex.toString()}";
      return variantPartResponse;
    }
  }

  Future<PartReplacementAnalyzeRes> partReplacementAnalyze(
      PartReplacementAnalyzeModel model, int sessionId) async {
    // Initialize with an empty list to match your C# 'new List<...>' logic
    PartReplacementAnalyzeRes analyze = PartReplacementAnalyzeRes(
      result: <PartReplacementAnalyzeResponse>[],
    );

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$sessionId/part-replacement/');

        final jsonPayload = jsonEncode(model.toJson());

        // 2. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 3. Execute the POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Debug printing
        print('--- Part Replacement Analyze API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('------------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize JSON list into the result property
          final List<dynamic> decodedList = jsonDecode(data);

          analyze.result = decodedList
              .map((item) => PartReplacementAnalyzeResponse.fromJson(item))
              .toList();

          analyze.message = "success";
        } else {
          // Handle API level errors
          analyze.message =
              "ApiServices.partReplacementAnalyze() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        analyze.message = "Please check internet connection.";
      }

      return analyze;
    } catch (ex) {
      print(
          "Exception in ApiServices.partReplacementAnalyze(): ${ex.toString()}");
      analyze.message =
          "Exception in ApiServices.partReplacementAnalyze() : ${ex.toString()}";
      return analyze;
    }
  }

  Future<VariantPartReplacementEcuResponse> partReplacementEcu(
      VariantPartReplacementEcuRequest model, int sessionId) async {
    // Initialize the response model
    VariantPartReplacementEcuResponse ecuResponse =
        VariantPartReplacementEcuResponse();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare URL and Payload
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/techbud-ecu-partreplacement/$sessionId/ecu');

        final jsonPayload = jsonEncode(model.toJson());

        // 3. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute the POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Debug printing (Replaces Debug.WriteLine)
        print('--- Ecu Replacement API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('---------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize JSON to VariantPartReplacementEcuResponse
          ecuResponse =
              VariantPartReplacementEcuResponse.fromJson(jsonDecode(data));
          ecuResponse.message = "success";
        } else {
          // Handle API level errors
          ecuResponse.message =
              "ApiServices.partReplacementEcu() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        ecuResponse.message = "Please check internet connection.";
      }

      return ecuResponse;
    } catch (ex) {
      print("Exception in ApiServices.partReplacementEcu(): ${ex.toString()}");
      ecuResponse.message =
          "Exception in ApiServices.partReplacementEcu() : ${ex.toString()}";
      return ecuResponse;
    }
  }

  Future<VariantPartReplacementFipResponse> partReplacementFip(
      VariantPartReplacementFipRequest model, int sessionId) async {
    // Initialize response model
    VariantPartReplacementFipResponse fipResponse =
        VariantPartReplacementFipResponse();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare URL and JSON Payload
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/techbud-fip-partreplacement/$sessionId/fip');

        final jsonPayload = jsonEncode(model.toJson());

        // 3. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Debug printing (Matches your Debug.WriteLine)
        print('--- Fip Replacement API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('---------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize response body
          fipResponse =
              VariantPartReplacementFipResponse.fromJson(jsonDecode(data));
          fipResponse.message = "success";
        } else {
          // Handle API level errors
          fipResponse.message =
              "ApiServices.partReplacementFip() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        fipResponse.message = "Please check internet connection.";
      }

      return fipResponse;
    } catch (ex) {
      print("Exception in ApiServices.partReplacementFip(): ${ex.toString()}");
      fipResponse.message =
          "Exception in ApiServices.partReplacementFip() : ${ex.toString()}";
      return fipResponse;
    }
  }

  Future<VariantPartReplacementInjectorResponse> partReplacementInjectors(
      VariantPartReplacementInjectorRequest model, int sessionId) async {
    // Initialize the response model
    VariantPartReplacementInjectorResponse injectorResponse =
        VariantPartReplacementInjectorResponse();

    try {
      // 1. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare URL and Payload
        final url = Uri.parse(
            '${AppEnvironment.baseUrl}/api/v1/analyze/techbud-injector-partreplacement/$sessionId/injector');

        final jsonPayload = jsonEncode(model.toJson());

        // 3. Prepare Headers
        Map<String, String> headers = {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        };

        // 4. Execute the POST Request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonPayload,
        );

        final data = response.body;

        // Debug printing (Matches your Debug.WriteLine)
        print('--- Injectors Replacement API ---');
        print('URL: $url');
        print('REQUEST: $jsonPayload');
        print('RESPONSE: $data');
        print('---------------------------------');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize response body
          injectorResponse =
              VariantPartReplacementInjectorResponse.fromJson(jsonDecode(data));
          injectorResponse.message = "success";
        } else {
          // Handle API level errors
          injectorResponse.message =
              "ApiServices.partReplacementInjectors() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        injectorResponse.message = "Please check internet connection.";
      }

      return injectorResponse;
    } catch (ex) {
      print(
          "Exception in ApiServices.partReplacementInjectors(): ${ex.toString()}");
      injectorResponse.message =
          "Exception in ApiServices.partReplacementInjectors() : ${ex.toString()}";
      return injectorResponse;
    }
  }

  Future<VariantPartReplacementOtherResponse> partReplacementOther(
      VariantPartReplacementOtherRequest model, int sessionId) async {
    VariantPartReplacementOtherResponse otherResponse =
        VariantPartReplacementOtherResponse();

    try {
      // 1. Prepare URL and Payload
      final url = Uri.parse(
          '${AppEnvironment.baseUrl}/api/v1/analyze/techbud-other-partreplacement/$sessionId/other-part');

      final jsonPayload = jsonEncode(model.toJson());

      // 2. Prepare Headers
      Map<String, String> headers = {
        'Authorization': 'JWT ${App.jwtToken}',
        'Content-Type': 'application/json',
      };

      // 3. Execute the POST Request
      final response = await http.post(
        url,
        headers: headers,
        body: jsonPayload,
      );

      // 4. Handle Response
      final data = response.body;

      // Optional: Debugging
      print('--- Other Part Replacement API ---');
      print('URL: $url');
      print('RESPONSE: $data');
      print('----------------------------------');

      // Deserialize and set success message
      otherResponse =
          VariantPartReplacementOtherResponse.fromJson(jsonDecode(data));
      otherResponse.message = "success";

      return otherResponse;
    } catch (ex) {
      print(
          "Exception in ApiServices.partReplacementOther(): ${ex.toString()}");
      otherResponse.message =
          "Exception in ApiServices.partReplacementOther() : ${ex.toString()}";
      return otherResponse;
    }
  }

  Future<String> readStringFromUrl(String url) async {
    try {
      // 1. Create URI from string
      final uri = Uri.parse(url);

      // 2. Execute GET request
      // Dart's http.get is similar to SendAsync with ResponseHeadersRead
      // as it streams the body efficiently.
      final response = await http.get(uri);

      // 3. Check for success status code (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        // Throwing an exception matches your 'throw new Exception' logic
        throw Exception(response.body);
      }
    } catch (ex) {
      // 4. Handle exceptions and return empty string as per your C# code
      print("Error in readStringFromUrl: ${ex.toString()}");
      return "";
    }
  }

  double downloadProgress = 0.0;

  Future<String> readDataFile(String url) async {
    String downloadedText = "";

    try {
      downloadProgress = 0;

      // Use http.Client to handle streamed responses
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));

      // Send request and get streamed response
      final response = await client.send(request).timeout(
            const Duration(seconds: 150),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final int? contentLength = response.contentLength;
        List<int> bytes = [];
        int totalBytesRead = 0;

        // Stream the response body
        final completer = Completer<String>();

        response.stream.listen(
          (List<int> chunk) {
            bytes.addAll(chunk);
            totalBytesRead += chunk.length;

            // Update progress if content length is known
            if (contentLength != null && contentLength > 0) {
              downloadProgress = totalBytesRead / contentLength;
              // Optional: notify listeners or use a ValueNotifier for UI updates
            }
          },
          onDone: () {
            downloadedText = utf8.decode(bytes);
            completer.complete(downloadedText);
          },
          onError: (error) {
            completer.complete("");
          },
          cancelOnError: true,
        );

        return await completer.future;
      }
    } catch (ex) {
      print("Exception in readDataFile: ${ex.toString()}");
    }

    return downloadedText;
  }

  Future<String> readStringFromUrl1(String url) async {
    try {
      // 1. Initialize the HTTP client
      // Note: You can also use http.get(Uri.parse(url)) directly
      final response = await http.get(Uri.parse(url));

      // 2. Check if the request was successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // response.body automatically handles the decoding of the stream
        return response.body;
      } else {
        return "";
      }
    } catch (ex) {
      // 3. Handle any exceptions (network errors, timeouts, etc.)
      print("Exception in readStringFromUrl1: ${ex.toString()}");
      return "";
    }
  }

  Future<AllModelsModel?> get_All_Models(String token, int id) async {
    String dataString = "";

    try {
      // 1. Get previously saved OEM data from your storage service
      // Assuming 'storage' is an instance of a helper class or SharedPreferences
      var savedOemData =
          await AndroidOperationsService.getData("selctedOemModel");

      if (savedOemData != null && savedOemData.isNotEmpty) {
        var selectedOem = AllOemModel.fromJson(jsonDecode(savedOemData));
        id = selectedOem.id ?? id;
      }

      // 2. Prepare the Request
      final url =
          Uri.parse("${AppEnvironment.baseUrl}models/get-models/?oem=$id");
      final headers = {
        'Authorization': 'JWT $token',
        'Content-Type': 'application/json',
      };

      // 3. Execute GET Request
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 401) {
        // Handle Unauthorized - You could throw an exception here to trigger the catch block
        throw Exception("Unauthorized");
      } else {
        dataString = response.body;
      }

      // 4. Save the raw JSON data locally (Caching)
      await AndroidOperationsService.saveData("modeljson", dataString);

      // 5. Deserialize and return
      return AllModelsModel.fromJson(jsonDecode(dataString));
    } catch (ex) {
      // 6. Handle Exceptions (matches your catch block logic)
      debugPrint("Exception in getAllModels: ${ex.toString()}");

      // Display Alert (Requires a BuildContext, or a global key)
      // GlobalContextService.showDialog("ERROR", "Please Re-Login");

      // 7. Clear Preferences/Sessions
      await AppPreferences.removeToken();
      await AppPreferences.clearLoginSession();

      // 8. Redirect to Login Page
      // NavigationService.pushAndRemoveUntil(const LoginPage());

      return null;
    }
  }

  Future<Uint8List?> getImageFromUrlAsync(String url) async {
    try {
      // 1. Fetch the image as a byte array (Uint8List in Dart)
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 2. Return the bytes (equivalent to returning the stream in C#)
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (ex) {
      print("Exception in getImageFromUrlAsync: ${ex.toString()}");
      return null;
    }
  }

  Future<FirmwareUpdateModel> getLatestFirmwareVersion(
      String partNumber) async {
    // Initialize the results model
    FirmwareUpdateModel results = FirmwareUpdateModel();

    try {
      // 1. Check Connectivity
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare URL with Query Parameter
        final url = Uri.parse(
            'http://143.244.142.0/api/v1/pipo/firmware_manager/list/?part_no=$partNumber');

        // 3. Execute GET Request
        final response = await http.get(url);

        final data = response.body;

        // 4. Debug Logging - FIXED: Removed the 'name' parameter for print()
        print("--- Get Latest Firmware Version API ---");
        print("URL: $url");
        print("RESPONSE: $data");
        print("---------------------------------------");

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize JSON to FirmwareUpdateModel
          // It's safer to decode once and use the result
          final decodedData = jsonDecode(data);
          results = FirmwareUpdateModel.fromJson(decodedData);
          results.message = "success";
        } else {
          // Handle API Level Errors
          results.message =
              "ApiServices.getLatestFirmwareVersion() : ${response.statusCode}\n${_extractErrorMessage(data)}";
        }
      } else {
        results.message = "Please check internet connection.";
      }

      return results;
    } catch (ex) {
      print(
          "Exception in ApiServices.getLatestFirmwareVersion(): ${ex.toString()}");
      results.message =
          "Exception in ApiServices.getLatestFirmwareVersion() : ${ex.toString()}";
      return results;
    }
  }

  Future<FirmwareUpdateResponseModel> updateFirmware(
      FirmwareUpdateModel model) async {
    // 1. Prepare URL and initialize response
    final String url = "${AppEnvironment.baseUrl}devices/fotax/latest/firmware";
    FirmwareUpdateResponseModel respons = FirmwareUpdateResponseModel();

    try {
      // 2. Check Connectivity using your service
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 3. Serialize Model to JSON
        final jsonPayload = jsonEncode(model.toJson());

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // Add Authorization header here if required by this endpoint:
            // 'Authorization': 'JWT ${App.jwtToken}',
          },
          body: jsonPayload,
        );

        final data = response.body;

        // Debugging
        print("--- Update Firmware API ---");
        print("URL: $url");
        print("PAYLOAD: $jsonPayload");
        print("RESPONSE: $data");
        print("---------------------------");

        if (response.statusCode == 200) {
          // Success: Deserialize JSON to FirmwareUpdateResponseModel
          respons = FirmwareUpdateResponseModel.fromJson(jsonDecode(data));
        } else {
          // Error: Store the status code as the error
          respons.error = response.statusCode.toString();
        }
      } else {
        respons.error = "No internet connection";
      }

      return respons;
    } catch (ex) {
      print("Exception in ApiServices.updateFirmware(): ${ex.toString()}");
      respons.error =
          "Exception in ApiServices.updateFirmware() : ${ex.toString()}";
      return respons;
    }
  }

  Future<bool> existPasswordCheck(UserModel model) async {
    try {
      // 1. Prepare URL and Payload
      final url = Uri.parse("${AppEnvironment.baseUrl}accounts/login/");
      final jsonPayload = jsonEncode(model.toJson());

      // 2. Execute POST Request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      // 3. Check for Status Code 200 (OK)
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      // 4. Handle Exceptions
      print("Exception in ApiServices.existPasswordCheck(): ${ex.toString()}");

      // Equivalent to your show_message()
      // _showErrorMessage("Exception in ApiServices.existPasswordCheck() : ${ex.toString()}");

      return false;
    }
  }

  Future<bool> changePassword(ChangePassword cp, String token) async {
    try {
      // 1. Prepare URL and Payload
      final url =
          Uri.parse("${AppEnvironment.baseUrl}accounts/password/change/");
      final jsonPayload = jsonEncode(cp.toJson());

      // 2. Prepare Headers (Including JWT Token)
      final Map<String, String> headers = {
        'Authorization': 'JWT $token',
        'Content-Type': 'application/json',
      };

      // 3. Execute POST Request
      // We use await to prevent blocking the UI thread
      final response = await http.post(
        url,
        headers: headers,
        body: jsonPayload,
      );

      // 4. Handle Response
      if (response.statusCode == 200) {
        return true;
      } else {
        // You can log response.body here to see why it failed
        print("Change Password Failed: ${response.body}");
        return false;
      }
    } catch (ex) {
      // 5. Exception Handling
      print("Exception in ApiServices.changePassword(): ${ex.toString()}");

      // Equivalent to your show_message()
      // showMessage("Exception in ApiServices.changePassword() : ${ex.toString()}");

      return false;
    }
  }

  Future<JobcardNumber> getJobCardNumber() async {
    // 1. Initialize the response model
    JobcardNumber jobcardNumber = JobcardNumber();

    try {
      // 2. Prepare URL
      final url = Uri.parse("${AppEnvironment.baseUrl}analyze/gen-name");

      // 3. Execute GET Request with Authorization header
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      // 4. Read the response body
      final data = response.body;

      // 5. Check if successful and deserialize
      if (response.statusCode >= 200 && response.statusCode < 300) {
        jobcardNumber = JobcardNumber.fromJson(jsonDecode(data));
      } else {
        jobcardNumber.error = "Jobcard number not created";
      }

      return jobcardNumber;
    } catch (ex) {
      // 6. Handle Exceptions
      print("Exception in ApiServices.getJobCardNumber(): ${ex.toString()}");
      jobcardNumber.error = "Jobcard number not created";
      return jobcardNumber;
    }
  }

  Future<List<JobCardModel>?> getJobCard(String token, String filename) async {
    try {
      String data = "";

      // 1. Connectivity Check (Using standard Cross-Platform check or your service)
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare Request
        final url = Uri.parse("${AppEnvironment.baseUrl}analyze/my-job-card/");
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
        );

        data = response.body;

        // 3. Handle Unauthorized
        if (response.statusCode == 401) {
          // Direct equivalent to DisplayAlert and NavigationPage switch
          // Note: 'context' or a navigatorKey is required in Flutter for this
          print("Unauthorized: You need to Login again to continue");

          // Clearing preferences directly as in your MAUI logic
          await AppPreferences.clearLoginSession();

          // Navigation (Assuming you have a way to access the global navigator)
          // navigatorKey.currentState?.pushAndRemoveUntil(...)

          return null;
        }
        // 4. Handle Success
        else if (response.statusCode >= 200 && response.statusCode < 300) {
          final List<dynamic> userInfo = jsonDecode(data);
          final list = userInfo.map((x) => JobCardModel.fromJson(x)).toList();

          // SaveData equivalent
          await AppPreferences.setString("JsonList", data);

          return list;
        }
        // 5. Handle Error Response
        else {
          Map<String, dynamic> htmlAttributes = jsonDecode(data);
          print(htmlAttributes["detail"]);
          return null;
        }
      }
      // 6. Offline Logic (Else block)
      else {
        // GetData equivalent
        String? jsonListData = await AppPreferences.getString("JsonList");

        if (jsonListData != null && jsonListData.isNotEmpty) {
          final List<dynamic> userInfo = jsonDecode(jsonListData);
          final list = userInfo.map((x) => JobCardModel.fromJson(x)).toList();
          return list;
        }
        return null;
      }
    } catch (ex) {
      // 7. Catch Block Logic
      print("Session is Expired");

      // Clear and Redirect logic
      await AppPreferences.clearLoginSession();
      // navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));

      return null;
    }
  }

  Future<CheckJobCardModel?> checkJobCard(
      String token, String jobCardNumber) async {
    try {
      // 1. Prepare Basic Authentication (Basic authData)
      String authData = "uptime_user:data1234";
      String authHeaderValue = base64Encode(utf8.encode(authData));

      // 2. Prepare the OData URL
      // String interpolation used for the JobCardNumber parameter
      final url = Uri.parse(
          "https://udaanapprovals.vecv.net/sap/opu/odata/sap/ZODATA_FIR_SRV/ES_HEADER(JobCrd='$jobCardNumber')?&\$format=json");

      // 3. Execute GET Request
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic $authHeaderValue',
          'Content-Type': 'application/json',
        },
      );

      // 4. Read Response Body
      final data = response.body;

      // 5. Deserialize JSON
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedData = jsonDecode(data);
        return CheckJobCardModel.fromJson(decodedData);
      } else {
        print("Error CheckJobCard: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 6. Handle Exceptions (Equivalent to your show_message)
      print("Exception in ApiServices.checkJobCard(): ${ex.toString()}");
      // You can call your UI alert method here
      return null;
    }
  }

  Future<List<JobcardModelSecond>?> checkJobCardSecondAPI(
      String token, String jobCardNumber) async {
    try {
      // 1. Construct the URL with query parameters
      final String url =
          "http://eos.eicher.in:8082/Api/Ticket/$jobCardNumber?Username=pbhujbal@vecv.in&password=eicher@123";

      // 2. Execute the GET request
      // Note: We use await instead of .Result
      final response = await http.get(Uri.parse(url));

      // 3. Get the response body
      final String data = response.body;

      // 4. Check status code and deserialize
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Decode the raw JSON string into a List
        final List<dynamic> decodedList = jsonDecode(data);

        // Map the list into your model objects
        return decodedList
            .map((item) => JobcardModelSecond.fromJson(item))
            .toList();
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (ex) {
      // 5. Handle exceptions matching your show_message logic
      print(
          "Exception in ApiServices.checkJobCardSecondAPI(): ${ex.toString()}");

      // If you have a custom show_message function:
      // show_message(ex.toString());

      return null;
    }
  }

  Future<MainResultClass?> sendJobCard(SendJobcardData model) async {
    try {
      MainResultClass mainResultClass = MainResultClass();

      // 1. Check Connectivity
      bool isConnected = await AndroidOperationsService.hasInternet();

      if (isConnected) {
        // 2. Prepare URL and Payload
        final url = Uri.parse("${AppEnvironment.baseUrl}analyze/job-card/");
        final jsonPayload = jsonEncode(model.toJson());

        // 3. Execute POST Request
        // Using await instead of .Result to keep the app responsive
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
          body: jsonPayload,
        );

        final String data = response.body;

        // 4. Handle Bad Request (400) - Usually for Duplicate JobCards
        if (response.statusCode == 400) {
          var userInfo = SameJobcard.fromJson(jsonDecode(data));
          mainResultClass.sameJobcard = userInfo;
          mainResultClass.createJobcard = null;
        }
        // 5. Handle Success / Other Cases
        else {
          // Note: You might want to check for 200/201 specifically
          var userInfo = JobCardModel.fromJson(jsonDecode(data));
          mainResultClass.sameJobcard = null;
          mainResultClass.createJobcard = userInfo;
        }
      }

      return mainResultClass;
    } catch (ex) {
      // 6. Handle Exceptions (Matches your show_message logic)
      print("Exception in ApiServices.sendJobCard(): ${ex.toString()}");

      // If you have a custom show_message function:
      // show_message(ex.toString());

      return null;
    }
  }

  Future<List<ExistJobCardResult>?> getExistJobCard(
      String token, String jobCardNumber) async {
    try {
      // 1. Prepare URL with query parameter
      final url = Uri.parse(
          "${AppEnvironment.baseUrl}analyze/job-card/?job_card_name=$jobCardNumber");

      // 2. Execute GET Request
      // Headers include the JWT token as per your C# logic
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 3. Read Response Body
      final String data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 4. Deserialize the wrapper object (ExistJobCard)
        final decodedData = jsonDecode(data);
        final existJobCardWrapper = ExistJobCard.fromJson(decodedData);

        // 5. Return the results list (matches ExistJobCard.results in C#)
        return existJobCardWrapper.results;
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 6. Handle Exceptions (matches your show_message logic)
      print("Exception in ApiServices.getExistJobCard(): ${ex.toString()}");

      // If you have your custom show_message:
      // show_message("${ex.toString()}");

      return null;
    }
  }

  Future<Result?> postJobCardSession(PostJobCardSession postJobCardSession,
      String token, String jobCardId) async {
    try {
      // 1. Prepare URL with the specific JobCardId path parameter
      final String url =
          "${AppEnvironment.baseUrl}analyze/job-card/$jobCardId/job-card-session/";

      // 2. Serialize the input model to JSON
      final String jsonPayload = jsonEncode(postJobCardSession.toJson());

      // 3. Execute POST Request
      // Replaces .Result with await to keep the app responsive
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      // 4. Get response body
      final String data = response.body;

      // 5. Check status code and deserialize
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedData = jsonDecode(data);
        return Result.fromJson(decodedData);
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 6. Handle Exceptions (matches your show_message logic)
      print("Exception in ApiServices.postJobCardSession(): ${ex.toString()}");

      // If you have your custom show_message:
      // show_message(ex.toString());

      return null;
    }
  }

  Future<List<ModelNameClass>?> getModel(
      String token, String selectedModelType) async {
    try {
      List<ModelNameClass> modelNameClasses = [];

      // 1. Prepare Request
      final url = Uri.parse("${AppEnvironment.baseUrl}oem/get-models-dtc/");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 2. Read Response Body
      final String data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 3. Parse JSON as a Map (dynamic list in your C#)
        final Map<String, dynamic> decodedData = jsonDecode(data);

        // Access the "models" key
        final Map<String, dynamic> adminPackageList = decodedData["models"];

        // 4. Iterate through the dictionary/map
        adminPackageList.forEach((key, value) {
          // value corresponds to your ModelListModel in C#
          // We access the nested list 'NA_NA' and its first element
          var naNaList = value['NA_NA'] as List;

          if (naNaList.isNotEmpty) {
            ModelNameClass model = ModelNameClass(
              modelName: key,
              id: naNaList[0]['model_id'],
            );
            modelNameClasses.add(model);
          }
        });

        // 5. Filter the list based on selectedModelType (LINQ Where equivalent)
        final filteredList = modelNameClasses
            .where((x) => x.modelName!
                .toLowerCase()
                .contains(selectedModelType.toLowerCase()))
            .toList();

        return filteredList;
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (ex) {
      // 6. Handle Exceptions
      print("Exception in ApiServices.getModel(): ${ex.toString()}");

      // show_message implementation here

      return null;
    }
  }

  Future<OnlineExpertModel?> getOnlineExpert(String token) async {
    try {
      // 1. Prepare URL
      final url = Uri.parse(
          "${AppEnvironment.baseUrl}user/online-expert-users/?format=json");

      // 2. Execute GET Request
      // Headers include the JWT token as per your C# logic
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 3. Read Response Body
      final String data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 4. Deserialize JSON to OnlineExpertModel
        final decodedData = jsonDecode(data);
        return OnlineExpertModel.fromJson(decodedData);
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 5. Handle Exceptions (matches your show_message logic)
      print("Exception in ApiServices.getOnlineExpert(): ${ex.toString()}");

      // If you have your custom show_message:
      // show_message(ex.toString());

      return null;
    }
  }

  Future<MainResponseModel?> createRemoteJobCard(
      RemoteJobCardModel model, String sessionId) async {
    try {
      MainResponseModel mainResultClass = MainResponseModel();

      // 1. Prepare URL and Payload
      final String url =
          "${AppEnvironment.baseUrl}analyze/job-card-session/$sessionId/remote-session/";
      final String jsonPayload = jsonEncode(model.toJson());

      // 2. Execute POST Request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      final String data = response.body;

      // 3. Handle Bad Request (400) - Already Exist logic
      if (response.statusCode == 400) {
        final badResult = BadRequestResponseModel.fromJson(jsonDecode(data));
        mainResultClass.status = "Already Exist";
        mainResultClass.badRequestResponseModel = badResult;
      }
      // 4. Handle Success / New Request logic
      else if (response.statusCode >= 200 && response.statusCode < 300) {
        final newResult = ResponseJobCardModel.fromJson(jsonDecode(data));
        mainResultClass.status = "New";
        mainResultClass.newRequestResponseModel = newResult;
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }

      return mainResultClass;
    } catch (ex) {
      // 5. Exception Handling
      print("Exception in ApiServices.createRemoteJobCard(): ${ex.toString()}");

      // Equivalent to show_message if you have a UI helper
      // show_message(ex.toString());

      return null;
    }
  }

  Future<ResponseJobCardModel?> updateRemoteJobCard(RemoteJobCardModel model,
      String sessionId, String remoteSessionId) async {
    try {
      // 1. Prepare URL with interpolated path parameters
      final String url =
          "${AppEnvironment.baseUrl}analyze/job-card-session/$sessionId/remote-session/$remoteSessionId/";

      // 2. Serialize the model to JSON
      final String jsonPayload = jsonEncode(model.toJson());

      // 3. Execute PUT Request
      // We use await instead of .Result to keep the UI responsive
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      // 4. Get the response body
      final String data = response.body;

      // 5. Check status code and deserialize
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        return ResponseJobCardModel.fromJson(decodedData);
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 6. Handle Exceptions (matches your show_message logic)
      print("Exception in ApiServices.updateRemoteJobCard(): ${ex.toString()}");

      // If you have your custom show_message:
      // show_message("${ex.toString()}");

      return null;
    }
  }

  Future<ResponseRoot?> getRemoteSession(String getRemoteSessionId) async {
    try {
      // 1. Prepare URL using string interpolation
      final String url =
          "${AppEnvironment.baseUrl}analyze/job-card-session/$getRemoteSessionId/remote-session/";

      // 2. Execute GET Request
      // Headers include the JWT token from your App constants
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      // 3. Get the response body
      final String data = response.body;

      // 4. Check status code and deserialize
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        return ResponseRoot.fromJson(decodedData);
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 5. Exception Handling (matches your show_message logic)
      print("Exception in ApiServices.getRemoteSession(): ${ex.toString()}");

      // If you have a custom UI alert:
      // show_message(ex.toString());

      return null;
    }
  }

  Future<ResponseRoot?> getExpertRequestList(String expertUser) async {
    try {
      // 1. Initialize result object (matching C# logic)
      ResponseRoot result = ResponseRoot();

      // 2. Prepare URL with query parameter
      final String url =
          "${AppEnvironment.baseUrl}analyze/expert-user-status-list/?expert_user=$expertUser";

      // 3. Execute GET Request
      // Headers include the JWT token from your App constants
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      // 4. Get the response body
      final String data = response.body;

      // 5. Deserialize the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        result = ResponseRoot.fromJson(decodedData);
        return result;
      } else {
        print("API Error: ${response.statusCode} - $data");
        // You could handle specific status codes here if needed
        return null;
      }
    } catch (ex) {
      // 6. Exception Handling (matches your show_message logic)
      print(
          "Exception in ApiServices.getExpertRequestList(): ${ex.toString()}");

      // Equivalent to your show_message call
      // show_message("${ex.toString()}");

      return null;
    }
  }

  Future<ResponseJobCardModel?> acceptRemoteRequest(
      ResponseJobCardModel acceptOrDeclineModel,
      String jobCardRequestId,
      String remoteSessionId) async {
    try {
      // 1. Prepare the URL with interpolated path parameters
      final String url =
          "${AppEnvironment.baseUrl}analyze/job-card-session/$jobCardRequestId/remote-session/$remoteSessionId/";

      // 2. Serialize the model to JSON
      final String jsonPayload = jsonEncode(acceptOrDeclineModel.toJson());

      // 3. Execute the PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT ${App.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      // 4. Read the response body
      final String data = response.body;

      // 5. Check status and deserialize
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedData = jsonDecode(data);
        return ResponseJobCardModel.fromJson(decodedData);
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (e) {
      // 6. Handle Exceptions (matches your catch-return-null logic)
      print("Exception in acceptRemoteRequest: ${e.toString()}");
      return null;
    }
  }

  Future<String?> getDongleList(String token) async {
    try {
      // 1. Construct the full URL
      final String url =
          "${AppEnvironment.baseUrl}devices/list/obd-dongles/active/";

      // 2. Execute the GET request
      // Using await instead of .Result to keep the UI responsive
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 3. Get the raw response body
      final String data = response.body;

      // 4. Return the data string (matching your C# return type)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 5. Handle Exceptions (matches your show_message logic)
      print("Exception in ApiServices.getDongleList(): ${ex.toString()}");

      // If you have a custom show_message function:
      // show_message(ex.toString());

      return null;
    }
  }

  Future<dynamic> getData(String token) async {
    try {
      // 1. Prepare Request
      final url = Uri.parse("${AppEnvironment.baseUrl}oem/get-data");

      // 2. Execute GET Request
      // Headers include the JWT token as per your C# logic
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 3. Read Response Body
      final String data = response.body;

      // 4. Handle Unauthorized (401)
      if (response.statusCode == 401) {
        // Equivalent to show_message("Token has expired")
        print("Token has expired");
        // You can call your UI alert here
      }

      // 5. Deserialize to dynamic (Map or List)
      final dynamic list = jsonDecode(data);

      return list;
    } catch (ex) {
      // 6. Handle Exceptions (Matches your UserDialogs.Alert logic)
      print("Alert Get dat api: ${ex.toString()}");

      // If using a dialog library in Flutter:
      // showAlertDialog(context, "Alert Get dat api", ex.toString());

      return null;
    }
  }

  Future<List<IVNResult>?> getIvnDtc(String token, int id) async {
    try {
      // 1. Prepare Request
      final url = Uri.parse(
          "${AppEnvironment.baseUrl}ivn/get-ivn-dtc-datasets/?id=$id");

      // 2. Execute GET Request
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 3. Read Response Body
      final String data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 4. Parse the wrapper object (IvnDtc)
        final decodedData = jsonDecode(data);
        final ivnDtcWrapper = IvnDtc.fromJson(decodedData);

        // 5. Return the nested results list
        return ivnDtcWrapper.results;
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 6. Handle Exceptions (Matches your UserDialogs.Alert logic)
      print("Alert Get ivn dtc api: ${ex.toString()}");

      // If you want to show a dialog in Flutter:
      // showAlertDialog(context, "Alert Get dat api", ex.toString());

      return null;
    }
  }

  Future<List<PidResult>?> getIvnPid(String token, int id) async {
    try {
      // 1. Prepare the URL with the query parameter
      final url = Uri.parse(
          "${AppEnvironment.baseUrl}ivn/get-ivn-pid-datasets/?id=$id");

      // 2. Set up headers with JWT token
      final headers = {
        'Authorization': 'JWT $token',
        'Content-Type': 'application/json',
      };

      // 3. Execute the GET request
      // We use await instead of .Result to prevent blocking the UI thread
      final response = await http.get(url, headers: headers);

      // 4. Extract the response body
      final String data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 5. Parse the JSON string into our PIDModel
        final Map<String, dynamic> decodedData = jsonDecode(data);

        // Assuming PIDModel has a fromJson factory constructor
        final pidModel = PidModel.fromJson(decodedData);

        // 6. Return the results list
        return pidModel.results;
      } else {
        // Handle non-success status codes
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (ex) {
      // 7. Exception Handling (Matches your UserDialogs.Alert logic)
      // You can use a package like flutter_styled_toast or a built-in AlertDialog
      print("Alert Get dat api: ${ex.toString()}");

      // Example of how you might handle the alert in Flutter:
      // showDialog(context: context, builder: (_) => AlertDialog(title: Text("Alert"), content: Text(ex.toString())));

      return null;
    }
  }

  Future<DTCMaskRoot?> getDtcMask(String token) async {
    try {
      // 1. Prepare the URL
      final url = Uri.parse("${AppEnvironment.baseUrl}dtc_mask/dtc-mask/");

      // 2. Execute the GET Request
      // We use await to handle the response asynchronously
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      // 3. Read the response body
      final String data = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 4. Deserialize JSON to DTCMaskRoot
        final decodedData = jsonDecode(data);
        return DTCMaskRoot.fromJson(decodedData);
      } else {
        print("API Error: ${response.statusCode} - $data");
        return null;
      }
    } catch (ex) {
      // 5. Exception Handling
      print("Exception in getDtcMask: ${ex.toString()}");

      // Equivalent to your C# catch block logic
      return null;
    }
  }

  Future<List<DtcResults>?> getDtc(String token, int id) async {
    String data = '';
    try {
      List<DtcResults> results = [];

      // 1. Check Connectivity (Equivalent to Microsoft.Maui.Networking.NetworkAccess)
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare Request
        final url = Uri.parse(
            "${AppEnvironment.baseUrl}datasets/get-dtc-datasets/?id=$id");

        // 3. Execute GET Request
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
        );

        data = response.body;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // 4. Parse using Wrapper Model (DtcMainModel)
          final decodedData = jsonDecode(data);
          results = DtcMainModel.fromJson(decodedData).results ?? [];
        }
      } else {
        // 5. Offline Logic (Equivalent to ("dtcjson").GetData() extension)
        // Assuming you have a helper to get local data, like SharedPreferences
        data = await AppPreferences.getString("dtcjson") ?? "";

        if (data.isNotEmpty) {
          final List<dynamic> decodedList = jsonDecode(data);
          results =
              decodedList.map((item) => DtcResults.fromJson(item)).toList();
        }
      }

      return results;
    } catch (ex) {
      // 6. Handle Exceptions (Matches UserDialogs logic)
      print("Alert Get dat api: ${ex.toString()}");

      // If you have a global navigation key for dialogs:
      // show_alert_dialog("Alert Get dat api", ex.toString());

      return null;
    }
  }

  Future<List<ResultUnlock>?> getUnlockData() async {
    try {
      // 1. Check Connectivity (Equivalent to Microsoft.Maui.Networking.NetworkAccess)
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare URL
        final url = Uri.parse("${AppEnvironment.baseUrl}models/unlock-list/");

        // 3. Execute GET Request
        // Using a local client instance as per your C# 'client = new HttpClient()'
        final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        // 4. Read Response Body
        final String data = response.body;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // 5. Deserialize using the wrapper model (UnlockEcuModel)
          final decodedData = jsonDecode(data);
          final unlockEcuModel = UnlockEcuModel.fromJson(decodedData);

          return unlockEcuModel.results;
        } else {
          return null;
        }
      } else {
        // No internet access
        return null;
      }
    } catch (ex) {
      // Exception handling - returning null to match C# logic
      print("Exception in getUnlockData: ${ex.toString()}");
      return null;
    }
  }

  Future<GdModelGD?> getGd(
      String token, String dtcPCode, int subModelId) async {
    try {
      // 1. Construct URL (Ensure AppEnvironment.baseUrl is correctly set)
      final String url =
          "${AppEnvironment.baseUrl}/api/v1/gdauthor/gd/gd-by-year_id-dtc_id/?dtc_code=$dtcPCode&name=$subModelId";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      print("GD API Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("GD API RESPONSE: ${response.body}");

        // FIX: Decode the String body into a Map<String, dynamic>
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Pass the decoded Map to your model's factory constructor
        return GdModelGD.fromJson(jsonData);
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (ex) {
      // This catches the 'type String is not a subtype of Map' error
      print("Exception in ApiServices.getGd() : ${ex.toString()}");
      return null;
    }
  }

  Future<String> readTextFile(String fileName) async {
    try {
      // In Dart, you must provide the full path as declared in pubspec.yaml
      // Replicating your "SanitasCore.JsonFiles" logic:
      final String path = "assets/json_files/$fileName";

      // rootBundle.loadString is the equivalent to StreamReader.ReadToEnd()
      final String text = await rootBundle.loadString(path);

      return text;
    } catch (e) {
      // Matches your C# catch block logic
      print("Error reading text file: $e");
      return "";
    }
  }

  void showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                // Closes the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> readJsonFile(String jsonFileUrl) async {
    try {
      // 1. Prepare and execute the GET request
      // We use Uri.parse because http.get requires a Uri object, not just a string
      final response = await http.get(Uri.parse(jsonFileUrl));

      // 2. Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Equivalent to respo.IsSuccessStatusCode
        return response.body;
      } else {
        // Equivalent to throwing an exception with the content string
        throw Exception(response.body);
      }
    } catch (ex) {
      // 3. Exception Handling
      // Matches your C# catch block returning an empty string
      print("Error reading JSON URL: $ex");
      return "";
    }
  }

  Future<void> dtcRecord(List<PostDtcRecord> pdr, String token, int jobCardId,
      String datetime) async {
    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Request Body (Matches 'obg' object in C#)
        final Map<String, dynamic> requestData = {
          'created': datetime,
          'dtc': pdr.map((item) => item.toJson()).toList(),
        };

        final String jsonBody = jsonEncode(requestData);

        // 3. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/dtc-record/";

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Debug Logging (Matches Debug.WriteLine)
        print("--- DTC Record API ---");
        print("URL: $url");
        print("REQUEST: $jsonBody");
        print("RESPONSE: $responseData");
        print("----------------------");
      }
    } catch (ex) {
      // Matches your empty catch block logic
      print("Exception in ApiServices.dtcRecord() : ${ex.toString()}");
    }
  }

  Future<void> clearDtcRecord1(List<PostDtcRecord> pdr, String token,
      int jobCardId, String datetime) async {
    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Request Body (Matching your DtcC object in C#)
        final Map<String, dynamic> requestData = {
          'created': datetime,
          'cleardtc': pdr.map((item) => item.toJson()).toList(),
        };

        final String jsonBody = jsonEncode(requestData);

        // 3. Prepare the specific URL for clearing records
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/new/clear-record/";

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Console Print (Equivalent to Debug.WriteLine)
        print("--- Clear DTC Record API ---");
        print("URL: $url");
        print("REQUEST: $jsonBody");
        print("RESPONSE: $responseData");
      }
    } catch (ex) {
      // Matches your empty catch block logic
      print("Exception in ApiServices.clearDtcRecord1() : ${ex.toString()}");
    }
  }

  Future<void> postGdComment(GdCommentModel model, int jobCardId) async {
    try {
      // 1. Check Connectivity (Equivalent to Microsoft.Maui.Networking.NetworkAccess)
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Request Body
        // Converts the Dart model to a JSON string
        final String jsonBody = jsonEncode(model.toJson());

        // 3. Prepare the URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/gd/";

        // 4. Execute POST Request
        // Uses App.jwtToken for the Authorization header
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Console Print (Equivalent to Debug.WriteLine)
        print("--- Gd Record API ---");
        print("URL: $url");
        print("REQUEST: $jsonBody");
        print("RESPONSE: $responseData");
        print("---------------------");
      }
    } catch (ex) {
      // Matches your empty catch block logic
      print("Exception in ApiServices.postGdComment() : ${ex.toString()}");
    }
  }

  Future<void> clearDtcRecord(
      List<ClearDtcRecord> cdr, String token, int jobCardId) async {
    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare Headers
        final headers = {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        };

        // 3. Replicate the bracket removal logic:
        // C# code: JsonConvert.SerializeObject(CDR).Replace("]", "").Replace("[", "")
        // This sends the object(s) without the surrounding array brackets.
        String jsonBody = jsonEncode(cdr);
        String strippedJson = jsonBody.replaceAll('[', '').replaceAll(']', '');

        // 4. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/clear-record/";

        // 5. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: strippedJson,
        );

        // 6. Handle Response
        final String responseData = response.body;

        // 7. Console Print (Equivalent to Debug.WriteLine)
        print("--- Clear DTC Record API ---");
        print("URL: $url");
        print("REQUEST: $strippedJson");
        print("RESPONSE: $responseData");
      }
    } catch (ex) {
      // Empty catch as per your C# implementation
      print("Exception in ApiServices.clearDtcRecord(): ${ex.toString()}");
    }
  }

  Future<FreezeFrameAnalyzeResponse> analyzeFreezeFrame(
      FreezeFrameAnalyze model, int sessionId) async {
    // Initialize response object
    FreezeFrameAnalyzeResponse freezeFrameAnalyzeResponse =
        FreezeFrameAnalyzeResponse();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare Request Data
        final String jsonBody = jsonEncode(model.toJson());
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$sessionId/freeze-frame/";

        // 3. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String data = response.body;

        // 4. Debug Logging
        print(
            "Analyze FreezeFrame API\nURL: $url\nREQUEST: $jsonBody\nRESPONSE: $data");

        // 5. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map<String, dynamic> decodedData = jsonDecode(data);
          freezeFrameAnalyzeResponse =
              FreezeFrameAnalyzeResponse.fromJson(decodedData);
          freezeFrameAnalyzeResponse.message = "success";
        } else {
          // Equivalent to ExtractErrorMessage(Data)
          String errorContent = extractErrorMessage(data);
          freezeFrameAnalyzeResponse.message =
              "ApiServices.analyzeFreezeFrame() : ${response.statusCode}\n$errorContent";
        }
      } else {
        freezeFrameAnalyzeResponse.message =
            "Please check internet connection.";
      }
    } catch (ex) {
      freezeFrameAnalyzeResponse.message =
          "Exception in ApiServices.analyzeFreezeFrame() : ${ex.toString()}";
    }

    return freezeFrameAnalyzeResponse;
  }

// Helper to mimic your C# ExtractErrorMessage logic
  String extractErrorMessage(String data) {
    try {
      var decoded = jsonDecode(data);
      if (decoded is Map && decoded.containsKey('detail')) {
        return decoded['detail'].toString();
      }
      return data;
    } catch (_) {
      return data;
    }
  }

  Future<bool> pidWriteRecord(
      List<PidWriteRecordItem> pwr, String token, int jobCardId) async {
    bool returnValue = false;
    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Request Wrapper (Matching the 'obg' object in C#)
        final Map<String, dynamic> requestBody = {
          'pid_write_records': pwr.map((item) => item.toJson()).toList(),
        };

        final String json = jsonEncode(requestBody);

        // 3. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/pid-write-record/";

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
          body: json,
        );

        final String data = response.body;

        // 5. Debug Print (Equivalent to Debug.WriteLine)
        print("--- Pid Write Record API ---");
        print("URL: $url");
        print("REQUEST: $json");
        print("RESPONSE: $data");

        // 6. Check Status Codes (OK = 200, Created = 201)
        if (response.statusCode == 200 || response.statusCode == 201) {
          returnValue = true;
        } else {
          returnValue = false;
        }
      }
      return returnValue;
    } catch (ex) {
      print("Exception in ApiServices.pidWriteRecord(): ${ex.toString()}");
      return false;
    }
  }

  Future<bool> pidLiveRecord(
      List<PIDLiveRecord> plr, String token, int jobCardId) async {
    try {
      bool returnValue = false;

      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare Headers
        final headers = {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        };

        // 3. Replicate the Substring logic:
        // C# code: JsonConvert.SerializeObject(PLR).Substring(1).Substring(0, length - 1)
        // This removes the [ and ] from the start and end of the JSON string.
        String fullJson = jsonEncode(plr.map((item) => item.toJson()).toList());
        String jValue = fullJson.substring(1, fullJson.length - 1);

        // 4. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/new/job-card-session/$jobCardId/pid-live-record/";

        // 5. Execute POST Request
        // Using await instead of .Result to keep the app responsive
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jValue,
        );

        final String responseData = response.body;

        // 6. Debug/Console Logging
        print("--- Pid Live Record API ---");
        print("URL: $url");
        print("REQUEST: $jValue");
        print("RESPONSE: $responseData");
        print("RECORD RESPONSE $responseData");

        // 7. Handle Status Codes
        if (response.statusCode == 400) {
          // Equivalent to HttpStatusCode.BadRequest
          returnValue = false;
        } else {
          // Your C# logic defaults to true for any non-400 status
          returnValue = true;
        }
      }

      return returnValue;
    } catch (ex) {
      // Matches your C# catch block returning false
      print("Exception in ApiServices.pidLiveRecord(): ${ex.toString()}");
      return false;
    }
  }

  Future<bool> pidSnapshotRecord(List<SnapshotRecord> sr, String token,
      int jobCardId, String datetime) async {
    try {
      bool returnValue = false;

      // 1. Check Connectivity (Equivalent to Microsoft.Maui.Networking.NetworkAccess)
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Request Body (Wrapper Object)
        final Map<String, dynamic> requestBody = {
          'created': datetime,
          'pid_snapshot': sr.map((item) => item.toJson()).toList(),
        };

        final String jsonBody = jsonEncode(requestBody);

        // 3. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/pid-snapshot-record/";

        // 4. Execute POST Request
        // We use await here instead of .Result to keep the UI thread responsive
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Debug and Console Logging (Equivalent to Debug.WriteLine)
        print("--- Pid Snapshot Record API ---");
        print("URL: $url");
        print("REQUEST: $jsonBody");
        print("RESPONSE: $responseData");
        print("SNAPSHOT RESPONSE $responseData");

        // 6. Handle Status Code (Checks specifically for 201 Created)
        if (response.statusCode == 201) {
          returnValue = true;
        } else {
          returnValue = false;
        }
      }

      return returnValue;
    } catch (ex) {
      // Matches your C# catch block logic returning false
      print("Exception in ApiServices.pidSnapshotRecord(): ${ex.toString()}");
      return false;
    }
  }

  // Future<bool> flashRecord(
  //     List<FlashRecord> fr, String token, int jobCardId) async {
  //   bool returnValue = false;
  //   try {
  //     // 1. Check Connectivity
  //     var connectivityResult = await (Connectivity().checkConnectivity());

  //     if (connectivityResult.contains(ConnectivityResult.mobile) ||
  //         connectivityResult.contains(ConnectivityResult.wifi)) {
  //       // 2. Prepare Headers
  //       final headers = {
  //         'Authorization': 'JWT $token',
  //         'Content-Type': 'application/json',
  //       };

  //       // 3. Replicate bracket stripping logic
  //       // C# code: JsonConvert.SerializeObject(FR).Replace("]", "").Replace("[", "")
  //       String jsonBody = jsonEncode(fr.map((item) => item.toJson()).toList());
  //       String jValue = jsonBody.replaceAll('[', '').replaceAll(']', '');

  //       // 4. Prepare URL
  //       final String url =
  //           "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/flash-record/";

  //       // 5. Execute POST Request
  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: headers,
  //         body: jValue,
  //       );

  //       final String responseData = response.body;

  //       // 6. Debug Printing
  //       print("--- Flash Record API ---");
  //       print("URL: $url");
  //       print("REQUEST: $jValue");
  //       print("RESPONSE: $responseData");

  //       // 7. Status Code Logic
  //       // Note: Your C# logic says "if NOT OK OR NOT Created, ReturnValue = true"
  //       // I have kept this logic exactly as you wrote it.
  //       if (response.statusCode != 200 && response.statusCode != 201) {
  //         returnValue = true;
  //       } else {
  //         returnValue = false;
  //       }
  //     }

  //     return returnValue;
  //   } catch (ex) {
  //     // Matches your C# catch block returning false
  //     print("Exception in ApiServices.flashRecord(): ${ex.toString()}");
  //     return false;
  //   }
  // }
  Future<bool> flashRecord(
      List<FlashRecord> fr, String token, int jobCardId) async {
    bool returnValue = false;
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        final headers = {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        };

        String jsonBody = jsonEncode(fr.map((item) => item.toJson()).toList());
        String jValue = jsonBody.replaceAll('[', '').replaceAll(']', '');

        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardId/flash-record/";

        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jValue,
        );

        final String responseData = response.body;

        print("--- Flash Record API ---");
        print("URL: $url");
        print("REQUEST: $jValue");
        print("RESPONSE: $responseData");
        print("STATUS: ${response.statusCode}");

        // ✅ Match original C# intent: true = saved, false = not saved
        // Original C# condition was always true due to || bug,
        // but actual intent is: success on 200 or 201
        returnValue =
            (response.statusCode == 200 || response.statusCode == 201);
      }

      return returnValue;
    } catch (ex) {
      print("Exception in ApiServices.flashRecord(): ${ex.toString()}");
      return false;
    }
  }

  Future<bool> routineTestRecord(List<RoutineTestAnalyzeModel> fr, String token,
      int jobCardSessionId) async {
    bool returnValue = false;
    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Root Model (Equivalent to RoutineTestAnalyzeRootModel)
        final Map<String, dynamic> rootModel = {
          'routine_test': fr.map((item) => item.toJson()).toList(),
        };

        final String jsonBody = jsonEncode(rootModel);

        // 3. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardSessionId/routine-test/";

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Debug Logging (Equivalent to Debug.WriteLine)
        print("--- Routine Test Analyze API ---");
        print("URL: $url");
        print("REQUEST: $jsonBody");
        print("RESPONSE: $responseData");

        // 6. Status Code Logic
        // Note: Your C# code returns 'true' if the status is NOT 200 and NOT 201.
        // I have preserved this specific logic.
        if (response.statusCode != 200 && response.statusCode != 201) {
          returnValue = true;
        } else {
          returnValue = false;
        }
      }

      return returnValue;
    } catch (ex) {
      // Matches your C# catch block returning false
      print("Exception in ApiServices.routineTestRecord(): ${ex.toString()}");
      return false;
    }
  }

  Future<bool> postActuatorTestResult(
      ActuatorTestAnalyzeModel model, int jobCardSessionId) async {
    bool returnValue = false;

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare the Root Model (Wraps single model in a list)
        final Map<String, dynamic> rootModel = {
          'actuator': [model.toJson()],
        };

        final String jsonBody = jsonEncode(rootModel);

        // 3. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/analyze/job-card-session/$jobCardSessionId/actuator/";

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Debug Logging
        print("--- Actuator Test Analyze API ---");
        print("URL: $url");
        print("REQUEST: $jsonBody");
        print("RESPONSE: $responseData");

        // 6. Handle Response Status
        if (response.statusCode >= 200 && response.statusCode < 300) {
          returnValue = true;
        } else {
          returnValue = false;
        }
      }

      return returnValue;
    } catch (ex) {
      // Matches your C# catch block returning false
      print(
          "Exception in ApiServices.postActuatorTestResult(): ${ex.toString()}");
      return false;
    }
  }

  Future<bool> closeJobCard(
      List<ResCloseSession> resCloses, String token, String jobCardId) async {
    try {
      bool returnValue;

      // 1. Prepare Headers using App.jwtToken
      final headers = {
        'Authorization': 'JWT ${App.jwtToken}',
        'Content-Type': 'application/json',
      };

      // 2. Replicate bracket stripping logic
      // C# code: JsonConvert.SerializeObject(resCloses).Replace("]", "").Replace("[", "")
      String jsonString = jsonEncode(resCloses.map((i) => i.toJson()).toList());
      String jValue = jsonString.replaceAll('[', '').replaceAll(']', '');

      // 3. Perform PUT Request
      // Note: In your C# code, this isn't awaited/resulted, but in Dart
      // it's safer to let it fire before checking the GET status.
      final String baseUrl = AppEnvironment.baseUrl;
      final String url =
          "${baseUrl}analyze/job-card-session/$jobCardId/close-session/";

      // We trigger the PUT (mimicking your PutAsync call)
      http.put(
        Uri.parse(url),
        headers: headers,
        body: jValue,
      );

      // 4. Perform GET Request (This is what determines your ReturnValue)
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // 5. Handle Response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Equivalent to response.IsSuccessStatusCode
        final String data = response.body;
        print("Close Session Data: $data");
        returnValue = true;
      } else {
        returnValue = false;
      }

      return returnValue;
    } catch (ex) {
      // 6. Exception Handling
      // Replicates your show_message call
      //showMessage("Error: ${ex.toString()}\n\n$stackTrace" as BuildContext);
      return false;
    }
  }

  Future<bool> closeRemoteSession() async {
    try {
      bool returnValue;

      // 1. Prepare Headers (Using App.jwtToken)
      final headers = {
        'Authorization': 'JWT ${App.jwtToken}',
        'Content-Type': 'application/json',
      };

      // 2. Prepare URL (Using App.remoteSessionId)
      final String url =
          "${AppEnvironment.baseUrl}analyze/remote-session/${App.remoteSessionId}/close-session/";

      // 3. Execute PUT Request
      // Passing an empty string as the body to match string.Empty
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: '',
      );

      // 4. Read response data

      // 5. Check Status Codes (200 OK or 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        returnValue = true;
      } else {
        returnValue = false;
      }

      return returnValue;
    } catch (ex) {
      // 6. Error Handling
      // Replicates your show_message call with stack trace
      // showMessage("${ex.toString()}\n\n$stackTrace");
      return false;
    }
  }

  Future<IorTestModel> getIorTest(String token, int id) async {
    // Initialize the results object
    IorTestModel results = IorTestModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 2. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/ior-test/ior-test-list/";

        // 3. Execute GET Request
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT $token',
            'Content-Type': 'application/json',
          },
        );

        final String data = response.body;

        // 4. Debug Logging
        print("GET ROUTINE TEST API\nURL: $url\nRESPONSE: $data");

        // 5. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into the model
          final Map<String, dynamic> decodedData = jsonDecode(data);
          results = IorTestModel.fromJson(decodedData);
          results.message = "success";
        } else {
          // API Error
          String errorContent = extractErrorMessage(data);
          results.message =
              "ApiServices.getIorTest() : ${response.statusCode}\n$errorContent";
        }
      } else {
        // No Internet
        results.message = "Please check internet connection.";
      }

      return results;
    } catch (ex) {
      // Exception handling
      results.message =
          "Exception in ApiServices.getIorTest() : ${ex.toString()}";
      return results;
    }
  }

  Future<ActuatorTestModel> getActuatorTest() async {
    // 1. Initialize the result object
    ActuatorTestModel results = ActuatorTestModel();

    try {
      // 2. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 3. Prepare URL and Headers
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/ior-test/actuator-test-list/";

        // 4. Execute GET Request
        // Using App.jwtToken as per your C# logic
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
        );

        final String data = response.body;

        // 5. Debug Logging
        print("--- Actuator Test API ---");
        print("URL: $url");
        print("RESPONSE: $data");

        // 6. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Deserialize JSON into the model
          final Map<String, dynamic> decodedData = jsonDecode(data);
          results = ActuatorTestModel.fromJson(decodedData);
          results.message = "success";
        } else {
          // Handle API error
          String errorDetail = extractErrorMessage(data);
          results.message =
              "ApiServices.getActuatorTest() : ${response.statusCode}\n$errorDetail";
        }
      } else {
        // Handle No Internet
        results.message = "Please check internet connection.";
      }
    } catch (ex) {
      // Handle Exceptions
      results.message =
          "Exception in ApiServices.getActuatorTest() : ${ex.toString()}";
    }

    return results;
  }

  Future<String> experNotfy(NotificationModel notificationModel,
      NotificationM notificationModel1, String expertId) async {
    try {
      // 1. Prepare the payload (NotificationRoot)
      final Map<String, dynamic> notificationRoot = {
        'to': '/topics/$expertId',
        'data': notificationModel.toJson(),
        // 'notification': notificationModel1.toJson(), // Uncomment if needed
      };

      final String jsonBody = jsonEncode(notificationRoot);

      // 2. Execute POST Request to FCM Legacy Endpoint
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          'Authorization':
              'key== AAAA7_-LssA:APA91bG15iL62SoWaNGA2ZgQW-qUEAl0MvD9faziRdEyUPQXshylefQHGJw0H2RDDUrjG7Xcezi6fpbba5iLIrOK54peesX-UZ8PE84rVwsLBl2OwspO0urkQGFFseiJkhZc6W8QCuXG',
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      // 3. Read response

      // Returning empty string as per your C# logic
      return "";
    } catch (ex) {
      // 4. Error Handling
      // Replicates your show_message call with stack trace
      // showMessage("${ex.toString()}\n\n$stackTrace");
      return "";
    }
  }

  Future<TicketListModel> getTicketList(int userId) async {
    // 1. Initialize the response object
    TicketListModel ticketListModel = TicketListModel();

    try {
      // 2. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 3. Prepare URL with Query Parameter
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/workshop/get/ticket/?user=$userId";

        // 4. Execute GET Request
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'JWT ${App.jwtToken}',
            'Content-Type': 'application/json',
          },
        );

        final String data = response.body;

        // 5. Debug Logging (Equivalent to Debug.WriteLine)
        print("Get Ticket List API\nURL: $url\nRESPONSE: $data");

        // 6. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into the model
          final Map<String, dynamic> decodedData = jsonDecode(data);
          ticketListModel = TicketListModel.fromJson(decodedData);
          ticketListModel.message = "success";
        } else {
          // API Error
          String errorContent = extractErrorMessage(data);
          ticketListModel.message =
              "ApiServices.getTicketList() : ${response.statusCode}\n$errorContent";
        }
      } else {
        // No Internet
        ticketListModel.message = "Please check internet connection.";
      }
    } catch (ex) {
      // Exception handling
      ticketListModel.message =
          "Exception in ApiServices.getTicketList() : ${ex.toString()}";
    }

    return ticketListModel;
  }

  Future<IssueModel> getIssueList() async {
    // 1. Initialize the response object
    IssueModel issueListModel = IssueModel();

    try {
      // 2. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 3. Prepare URL
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/workshop/get-ticket-issue/";

        // 4. Execute GET Request
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // Authorization is commented out in your C#, mirroring that here:
            // 'Authorization': 'JWT ${App.jwtToken}',
          },
        );

        final String data = response.body;

        // 5. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into the model
          final Map<String, dynamic> decodedData = jsonDecode(data);
          issueListModel = IssueModel.fromJson(decodedData);
          issueListModel.message = "success";
        } else {
          // API Error
          String errorContent = extractErrorMessage(data);
          issueListModel.message =
              "ApiServices.getIssueList() : ${response.statusCode}\n$errorContent";
        }
      } else {
        // No Internet
        issueListModel.message = "Please check internet connection.";
      }
    } catch (ex) {
      // Exception handling
      issueListModel.message =
          "Exception in ApiServices.getIssueList() : ${ex.toString()}";
    }

    return issueListModel;
  }

  Future<RelatedIssue> getRelatedIssueList(String type) async {
    // 1. Initialize the response object
    RelatedIssue relatedIssueListModel = RelatedIssue();

    try {
      // 2. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        // 3. Prepare URL with Query Parameter
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/workshop/get-ticket-issue-choices/?ticket_issue=$type";

        // 4. Execute GET Request
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // Authorization is commented out in your C#, keeping it consistent:
            // 'Authorization': 'JWT ${App.jwtToken}',
          },
        );

        final String data = response.body;

        // 5. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success: Deserialize the JSON string into the model
          final Map<String, dynamic> decodedData = jsonDecode(data);
          relatedIssueListModel = RelatedIssue.fromJson(decodedData);
          relatedIssueListModel.message = "success";
        } else {
          // API Error
          String errorContent = extractErrorMessage(data);
          relatedIssueListModel.message =
              "ApiServices.getRelatedIssueList() : ${response.statusCode}\n$errorContent";
        }
      } else {
        // No Internet
        relatedIssueListModel.message = "Please check internet connection.";
      }
    } catch (ex) {
      // Exception handling
      relatedIssueListModel.message =
          "Exception in ApiServices.getRelatedIssueList() : ${ex.toString()}";
    }

    return relatedIssueListModel;
  }

  Future<CreateTicketResponseModel> createTicket(
      CreateTicketModel model) async {
    CreateTicketResponseModel responseModel = CreateTicketResponseModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        final String url =
            "${AppEnvironment.baseUrl}/api/v1/workshop/create/ticket/";

        // 2. Initialize Multipart Request
        var request = http.MultipartRequest('POST', Uri.parse(url));

        // 3. Add Headers
        request.headers['Authorization'] = 'JWT ${App.jwtToken}';

        // 4. Add Form Fields (StringContent equivalent)
        request.fields['application_type'] = model.applicationType ?? "";
        request.fields['region'] = model.region ?? "";
        request.fields['workshop'] = model.workshop ?? "";
        request.fields['location'] = model.location ?? "";
        request.fields['ticket_issue'] = model.ticketIssue ?? "";
        request.fields['ticket_issue_choices'] =
            model.ticketIssueChoicesUuid ?? "";
        request.fields['invoice_no'] = model.invoiceNo ?? "";
        request.fields['level_status'] = model.levelStatus ?? "";
        request.fields['serial_number'] = model.serialNumber ?? "";
        request.fields['invoice_date'] = model.invoiceDate ?? "";
        request.fields['comment'] = model.comment ?? "";

        // 5. Add File Attachment (ByteArrayContent equivalent)
        if (model.attachment != null && model.attachment!.isNotEmpty) {
          // Determine MimeType (Simplified equivalent of GetMimeType)
          String fileName = model.fileName ?? "upload.jpg";
          String ext = p.extension(fileName).replaceAll('.', '');

          request.files.add(
            http.MultipartFile.fromBytes(
              'attachment',
              model.attachment!,
              filename: fileName,
              contentType:
                  MediaType('application', ext.isEmpty ? 'octet-stream' : ext),
            ),
          );
        }

        // 6. Send Request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        var data = response.body;

        // Debug Log
        print("Create Ticket API\nURL: $url\nRESPONSE: $data");

        // 7. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          responseModel = CreateTicketResponseModel.fromJson(jsonDecode(data));
          responseModel.message = "success";
        } else {
          String errorContent = extractErrorMessage(data);
          responseModel.message =
              "ApiServices.createTicket() : ${response.statusCode}\n$errorContent";
        }
      } else {
        responseModel.message = "Please check internet connection.";
      }
    } catch (ex) {
      responseModel.message =
          "Exception in ApiServices.createTicket() : ${ex.toString()}";
    }

    return responseModel;
  }

  // Future<CreateTicketResponseModel> createTicketWithoutAuthentication(
  //     CreateTicketModel model) async {
  //   CreateTicketResponseModel responseModel = CreateTicketResponseModel();

  //   try {
  //     // 1. Check Connectivity
  //     var connectivityResult = await (Connectivity().checkConnectivity());

  //     if (connectivityResult.contains(ConnectivityResult.mobile) ||
  //         connectivityResult.contains(ConnectivityResult.wifi)) {
  //       // Note the updated URL from your C# code
  //       final String url =
  //           "${AppEnvironment.baseUrl}/api/v1/workshop/new/create/ticket/";

  //       // 2. Initialize Multipart Request
  //       var request = http.MultipartRequest('POST', Uri.parse(url));

  //       // 3. Add Form Fields (StringContent equivalent)
  //       // Note: mapping model.emailId to the "user" key as per your C# code
  //       request.fields['user'] = model.emailId ?? "";
  //       request.fields['application_type'] = model.applicationType ?? "";
  //       request.fields['region'] = model.region ?? "";
  //       request.fields['workshop'] = model.workshop ?? "";
  //       request.fields['location'] = model.location ?? "";
  //       request.fields['ticket_issue'] = model.ticketIssue ?? "";
  //       request.fields['ticket_issue_choices'] =
  //           model.ticketIssueChoicesUuid ?? "";
  //       request.fields['invoice_no'] = model.invoiceNo ?? "";
  //       request.fields['level_status'] = model.levelStatus ?? "";
  //       request.fields['serial_number'] = model.serialNumber ?? "";
  //       request.fields['invoice_date'] = model.invoiceDate ?? "";
  //       request.fields['comment'] = model.comment ?? "";

  //       // 4. Add File Attachment
  //       if (model.attachment != null && model.attachment!.isNotEmpty) {
  //         String fileName = model.fileName ?? "upload.jpg";

  //         // Using path package correctly to get extension
  //         String ext = p.extension(fileName).replaceAll('.', '');

  //         request.files.add(
  //           http.MultipartFile.fromBytes(
  //             'attachment',
  //             model.attachment!,
  //             filename: fileName,
  //             contentType:
  //                 MediaType('application', ext.isEmpty ? 'octet-stream' : ext),
  //           ),
  //         );
  //       }

  //       // 5. Send Request
  //       var streamedResponse = await request.send();
  //       var response = await http.Response.fromStream(streamedResponse);
  //       var data = response.body;

  //       // Debug Logging
  //       print("Create Ticket Without Auth API\nURL: $url\nRESPONSE: $data");

  //       // 6. Handle Response
  //       if (response.statusCode >= 200 && response.statusCode < 300) {
  //         responseModel = CreateTicketResponseModel.fromJson(jsonDecode(data));
  //         responseModel.message = "success";
  //       } else {
  //         String errorContent = extractErrorMessage(data);
  //         responseModel.message =
  //             "ApiServices.createTicketWithoutAuth() : ${response.statusCode}\n$errorContent";
  //       }
  //     } else {
  //       responseModel.message = "Please check internet connection.";
  //     }
  //   } catch (ex) {
  //     responseModel.message =
  //         "Exception in ApiServices.createTicketWithoutAuth() : ${ex.toString()}";
  //   }

  //   return responseModel;
  // }
//   Future<CreateTicketResponseModel> createTicketWithoutAuthentication(
//     CreateTicketModel model) async {
//   CreateTicketResponseModel responseModel = CreateTicketResponseModel();

//   try {
//     var connectivityResult = await (Connectivity().checkConnectivity());

//     if (connectivityResult.contains(ConnectivityResult.mobile) ||
//         connectivityResult.contains(ConnectivityResult.wifi)) {

//       final String url = "${AppEnvironment.baseUrl}/api/v1/workshop/new/create/ticket/";

//       var request = http.MultipartRequest('POST', Uri.parse(url));

//       // --- 401 FIX: CLEAR HEADERS ---
//       request.headers.remove('Authorization');
//       request.headers['Accept'] = 'application/json';

//       // --- FIELD MAPPING FIX ---
//       request.fields['emailId'] = model.emailId ?? "";
//       request.fields['application_type'] = "Windows"; // Based on your logs
//       request.fields['region'] = model.region ?? "";
//       request.fields['workshop'] = model.workshop ?? "";
//       request.fields['location'] = model.location ?? "";
//       request.fields['ticket_issue'] = model.ticketIssue ?? "";

//       // Use the exact key name from your debug logs
//       request.fields['ticketissuechoices_uuid'] = model.ticketIssueChoicesUuid ?? "";

//       request.fields['invoice_no'] = model.invoiceNo ?? "";
//       request.fields['level_status'] = "Level1";
//       request.fields['serial_number'] = model.serialNumber ?? "";
//       request.fields['invoice_date'] = model.invoiceDate ?? "";
//       request.fields['comment'] = model.comment ?? "";
//       request.fields['market_place'] = "e69a8d32-8411-4e25-9996-a5a28f435456";
//       request.fields['user'] = model.user ?? "0";

//       // --- MULTIPART FILE ---
//       if (model.attachment != null && model.attachment!.isNotEmpty) {
//         String fileName = model.fileName ?? "upload.jpg";

//         // Use lookupMimeType if possible, otherwise keep your MediaType logic
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'attachment',
//             model.attachment!,
//             filename: fileName,
//             contentType: MediaType('image', 'jpeg'),
//           ),
//         );
//       }

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       var data = response.body;

//       print("Create Ticket (Multipart Guest)\nURL: $url\nRESPONSE: $data");

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         responseModel = CreateTicketResponseModel.fromJson(jsonDecode(data));
//         responseModel.message = "success";
//       } else {
//         // This is where you will see the "bad_authorization_header" error if it fails
//         responseModel.message = "Error: ${response.statusCode}\n$data";
//       }
//     } else {
//       responseModel.message = "Please check internet connection.";
//     }
//   } catch (ex) {
//     responseModel.message = "Exception: ${ex.toString()}";
//   }

//   return responseModel;
// }
  Future<CreateTicketResponseModel> createTicketWithoutAuthentication(
      CreateTicketModel model) async {
    CreateTicketResponseModel responseModel = CreateTicketResponseModel();

    try {
      final url = Uri.parse(
          "${AppEnvironment.baseUrl}/api/v1/workshop/new/create/ticket/");

      var request = http.MultipartRequest("POST", url);

      /// ================= HEADERS =================
      request.headers['Accept'] = 'application/json';

      /// ================= FORM DATA (MATCH MAUI EXACTLY) =================
      request.fields['user'] = model.emailId ?? "";
      request.fields['application_type'] = model.applicationType ?? "";
      request.fields['region'] = model.region ?? "";
      request.fields['workshop'] = model.workshop ?? "";
      request.fields['location'] = model.location ?? "";
      request.fields['ticket_issue'] = model.ticketIssue ?? "";
      request.fields['ticket_issue_choices'] =
          model.ticketIssueChoicesUuid ?? "";
      request.fields['invoice_no'] = model.invoiceNo ?? "";
      request.fields['level_status'] = model.levelStatus ?? "";
      request.fields['serial_number'] = model.serialNumber ?? "";
      request.fields['invoice_date'] = model.invoiceDate ?? "";
      request.fields['comment'] = model.comment ?? "";

      /// ================= FILE ATTACHMENT =================
      if (model.attachment != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            model.attachment!,
            filename: model.fileName ?? "file.jpg",
          ),
        );
      }

      /// ================= SEND REQUEST =================
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("URL: $url");
      print("REQUEST: ${request.fields}");
      print("RESPONSE: ${response.body}");

      /// ================= RESPONSE HANDLING =================
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        responseModel = CreateTicketResponseModel.fromJson(data);
        responseModel.message = "success";
      } else {
        responseModel.message =
            "Error: ${response.statusCode}\n${response.body}";
      }
    } catch (e) {
      responseModel.message = "Exception: $e";
    }

    return responseModel;
  }

  String getMimeType(String fileName) {
    final extension = p.extension(fileName).toLowerCase();

    return switch (extension) {
      ".csv" => "text/csv",
      ".txt" => "text/plain",
      ".pdf" => "application/pdf",
      ".zip" => "application/zip",
      ".doc" => "application/msword",
      ".docx" =>
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ".xls" => "application/vnd.ms-excel",
      ".xlsx" =>
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      ".jpg" || ".jpeg" => "image/jpeg",
      ".png" => "image/png",
      ".gif" => "image/gif",
      ".mp4" => "video/mp4",
      ".json" => "application/json",
      _ => "application/octet-stream",
    };
  }

  Future<SRSearchRespModel> searchSrNumber(SRSearchRequestModel model) async {
    SRSearchRespModel srSearchRespModel = SRSearchRespModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        final String jsonBody = jsonEncode(model.toJson());

        // 2. Prepare Basic Auth (Username:Password)
        // Note: Replicating your Prod Server credentials
        const String username = "IKONNECT";
        const String password = "ikkoel123\$\$"; // Escaping $ in Dart strings

        // Basic Auth string: base64(username:password)
        final String credentials = "$username:$password";
        final String authToken = base64.encode(utf8.encode(credentials));

        // 3. Prepare URL
        const String url =
            "https://kpulsesvc.koel.co.in:2096/siebel/v1.0/service/Service Request Connect BS/QueryByExample";

        // 4. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Basic $authToken',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        final String responseData = response.body;

        // 5. Debug Logging
        print(
            "Search SR Number\nURL: $url\nRequest: $jsonBody\nRESPONSE: $responseData");

        // 6. Handle Response Logic
        if (response.statusCode >= 200 && response.statusCode < 300) {
          srSearchRespModel =
              SRSearchRespModel.fromJson(jsonDecode(responseData));
          srSearchRespModel.error = "success";
        } else if (responseData.contains('"ERROR":')) {
          // Specifically checking for your "ERROR" key in the JSON string
          srSearchRespModel =
              SRSearchRespModel.fromJson(jsonDecode(responseData));
        } else {
          srSearchRespModel.error =
              "${response.statusCode}\n${extractErrorMessage(responseData)}";
        }
      } else {
        srSearchRespModel.error = "Please check internet connection.";
      }

      return srSearchRespModel;
    } catch (ex) {
      srSearchRespModel.error =
          "Exception in ApiServices.searchSrNumber() : ${ex.toString()}";
      return srSearchRespModel;
    }
  }

  Future<GetAPIResponseModel> getApiResponse(String endpoint,
      {bool isAuthenticated = true}) async {
    GetAPIResponseModel responseData = GetAPIResponseModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        final String url = "${AppEnvironment.baseUrl}$endpoint";

        // 2. Prepare Headers
        final Map<String, String> headers = {
          'Accept': 'application/json',
        };

        if (isAuthenticated) {
          headers['Authorization'] = 'JWT ${App.jwtToken}';
        }

        // 3. Execute GET Request
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );

        final String data = response.body;

        // 4. Debug Logging (using developer.log for better console handling)
        //  log("URL: $url\nRESPONSE :\n$data", name: "Get API Response");

        // 5. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          responseData.success = true;
          responseData.data = data;
        } else {
          responseData.success = false;
          String errorMsg = extractErrorMessage(data);
          responseData.data = "${response.statusCode}\n$errorMsg";
        }
      } else {
        // No Internet
        responseData.success = false;
        responseData.data = "Please check your Internet";
      }
    } catch (ex) {
      // Exception handling
      responseData.success = false;
      responseData.data = "Exception : ${ex.toString()}";
    }

    return responseData;
  }

  Future<GetAPIResponseModel> postApi(String endpoint, String json,
      {bool isAuthenticated = true}) async {
    GetAPIResponseModel responseData = GetAPIResponseModel();

    try {
      // 1. Check Connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        final String url = "${AppEnvironment.baseUrl}$endpoint";

        // 2. Prepare Headers
        final Map<String, String> headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };

        if (isAuthenticated) {
          headers['Authorization'] = 'JWT ${App.jwtToken}';
        }

        // 3. Execute POST Request
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: json,
        );

        final String data = response.body;

        // 4. Debug Printing (Equivalent to Debug.WriteLine)
        print("--- POST API Response ---");
        print("URL: $url");
        print("REQUEST: $json");
        print("RESPONSE: $data");

        // 5. Handle Response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          responseData.success = true;
          responseData.data = data;
        } else {
          responseData.success = false;
          String errorMsg = extractErrorMessage(data);
          responseData.data = "${response.statusCode}\n$errorMsg";
        }
      } else {
        // No Internet
        responseData.success = false;
        responseData.data = "Please check your Internet";
      }
    } catch (ex) {
      // Exception handling
      responseData.success = false;
      responseData.data = "Exception : ${ex.toString()}";
    }

    return responseData;
  }

  void extractFromElement(dynamic element, List<String> messages) {
    // 1. Handle Objects (Map in Dart)
    if (element is Map<String, dynamic>) {
      element.forEach((key, value) {
        extractFromElement(value, messages);
      });
    }
    // 2. Handle Arrays (List in Dart)
    else if (element is List) {
      for (var item in element) {
        extractFromElement(item, messages);
      }
    }
    // 3. Handle Strings
    else if (element is String) {
      messages.add(element);
    }
    // 4. Handle Numbers and Booleans
    else if (element is num || element is bool) {
      messages.add(element.toString());
    }
  }

  Future<OTPResponseModel> sendOtpOnMail(
      String api, ChangePasswordModel request) async {
    // 1. Initialize the response model
    OTPResponseModel getOpt = OTPResponseModel();

    try {
      // 2. Serialize the request model to JSON
      final String jsonBody = jsonEncode(request.toJson());

      // 3. Prepare the URL
      final String url = "${AppEnvironment.baseUrl}$api";

      // 4. Execute the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      // 5. Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String responseBody = response.body;

        // Deserialize the JSON into the model
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);
        getOpt = OTPResponseModel.fromJson(decodedData);
      }
    } catch (ex) {
      // Replicates your Console.WriteLine logic
      print("Exception: ${ex.toString()}");
    }

    return getOpt;
  }

  Future<OTPResponseModel> reSendOtpOnMail(
      String api, ChangePasswordModel request) async {
    // 1. Initialize the response model
    OTPResponseModel getOpt = OTPResponseModel();

    try {
      // 2. Serialize the request model to JSON string
      final String jsonBody = jsonEncode(request.toJson());

      // 3. Construct the full URL
      final String url = "${AppEnvironment.baseUrl}$api";

      // 4. Execute the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      // 5. Read and handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String responseBody = response.body;

        // Deserialize the JSON string into the Map and then the Model
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);
        getOpt = OTPResponseModel.fromJson(decodedData);
      }
    } catch (ex) {
      // Replicates your Console.WriteLine logic for debugging
      print("Exception: ${ex.toString()}");
    }

    return getOpt;
  }

  Future<VerifyOTPResponseModel> verifyOtpService(
      String api, VerifyOTPResponseModel request) async {
    // 1. Initialize the response model
    VerifyOTPResponseModel getOpt = VerifyOTPResponseModel();

    try {
      // 2. Serialize the request model to a JSON string
      final String jsonBody = jsonEncode(request.toJson());

      // 3. Construct the full URL
      final String url = "${AppEnvironment.baseUrl}$api";

      // 4. Execute the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      // 5. Read and handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String responseBody = response.body;

        // Deserialize the JSON string into a Map and then the Model
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);
        getOpt = VerifyOTPResponseModel.fromJson(decodedData);
      }
    } catch (ex) {
      // Replicates your Console.WriteLine logic for error tracking
      print("Exception: ${ex.toString()}");
    }

    return getOpt;
  }

  Future<OTPResponseModel> changePasswordService(
      String api, ResetPasswordModel request) async {
    // 1. Initialize the response model
    OTPResponseModel resetPasswordResponse = OTPResponseModel();

    try {
      // 2. Serialize the request model to a JSON string
      final String jsonBody = jsonEncode(request.toJson());

      // 3. Construct the full URL
      final String url = "${AppEnvironment.baseUrl}$api";

      // 4. Execute the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      // 5. Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String responseBody = response.body;

        // Deserialize the JSON string into the model
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);
        resetPasswordResponse = OTPResponseModel.fromJson(decodedData);
      }
    } catch (ex) {
      // Replicates your Console.WriteLine logic
      print("Exception: ${ex.toString()}");
    }

    return resetPasswordResponse;
  }
}

class ErrorModel {
  String? error;

  ErrorModel({this.error});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}

class NotificationModel {
  String? body;
  String? title;

  NotificationModel({this.body, this.title});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      body: json['body'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'title': title,
    };
  }
}

class DataModel {
  String? body;
  String? title;
  String? key1;
  String? key2;

  DataModel({
    this.body,
    this.title,
    this.key1,
    this.key2,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      body: json['body'],
      title: json['title'],
      key1: json['key_1'],
      key2: json['key_2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'title': title,
      'key_1': key1,
      'key_2': key2,
    };
  }
}

class NotificationRoot {
  String? to;
  NotificationModel? notification;
  DataModel? data;

  NotificationRoot({
    this.to,
    this.notification,
    this.data,
  });

  factory NotificationRoot.fromJson(Map<String, dynamic> json) {
    return NotificationRoot(
      to: json['to'],
      notification: json['notification'] != null
          ? NotificationModel.fromJson(json['notification'])
          : null,
      data: json['data'] != null ? DataModel.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'notification': notification?.toJson(),
      'data': data?.toJson(),
    };
  }
}
