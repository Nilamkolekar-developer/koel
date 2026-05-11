// freeze_frame_controller.dart

import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart';
import 'package:autopeepal/services/reConnectService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/services/api_services.dart';

class FreezeFrameController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────
  final AuthApiService _apiServices = AuthApiService();

  // ── Arguments ─────────────────────────────────────────────
  late DtcCode dtc;
  late int ffSet;
  late int ecuId;
  late SessionModel sessionModel;

  // ── State ─────────────────────────────────────────────────
  final RxList<FreezeFrameUIModel> freezeFrameList = <FreezeFrameUIModel>[].obs;
  final RxString title = ''.obs;
  final RxString error = ''.obs;
  final RxBool isLoading = false.obs;

  // ─────────────────────────────────────────────────────────
  // onInit  ← constructor
 @override
void onInit() {
  super.onInit();

  final args = Get.arguments as Map<String, dynamic>?;
  if (args != null) {
    dtc          = args['dtc']          as DtcCode?      ?? DtcCode();
    ffSet        = args['ffSet']        as int?          ?? 0;
    ecuId        = args['ecuId']        as int?          ?? 0;
    // ✅ SessionModel? — nullable cast since .value can be null
    sessionModel = args['sessionModel'] as SessionModel? ?? SessionModel();
  }

  title.value = dtc.code ?? '';
  getFreezeFrame(dtc.code ?? '');
}

  // ─────────────────────────────────────────────────────────
  // GetFreezeFrame  ← async Task GetFreezeFrame(string dtc_code)
  // ─────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
// GetFreezeFrame  ← exact mirror of C# GetFreezeFrame()
// ─────────────────────────────────────────────────────────────
  Future<void> getFreezeFrame(String dtcCode) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      // ── Init analyze object ──────────────────────────────────
      // ← new FreezeFrameAnalyze { freeze_frame = new List<...>() }
      final FreezeFrameAnalyze freezeFrameAnalyze = FreezeFrameAnalyze(
        freezeFrame: <FreezeFrameAnalyzeResult>[],
      );

      // ── Load from local storage ──────────────────────────────
      // ← ("FreezeFrame_LocalList").GetData()
      final prefs = await SharedPreferences.getInstance();
      final jsonListData = prefs.getString('FreezeFrame_LocalList') ?? '';

      if (jsonListData.isEmpty) {
        // ← UserDialogs.Instance.AlertAsync("Freeze frame not found in local DB")
        _showAlert("Freeze frame not found in local DB");
        return;
      }

      debugPrint(
          "/api/v1/datasets/get-freeze-frames/\n\nRESPONSE :\n$jsonListData");

      // ← JsonConvert.DeserializeObject<FreezeFrameModel>(JsonListData)
      final FreezeFrameModel result =
          FreezeFrameModel.fromJson(jsonDecode(jsonListData));

      if (result.message == "success") {
        if (result.results != null && result.results!.isNotEmpty) {
          // ← result.results.FirstOrDefault(x => x.id == ff_set)
          final freezeFrameSet =
              result.results!.firstWhereOrNull((x) => x.id == ffSet);

          if (freezeFrameSet == null) {
            _showAlert("Freeze frame not found.");
            error.value = "Freeze frame not found.";
            return;
          }

          // ── Load env snapshot codes ────────────────────────
          // ← if (Dtc.environment_snapshot != null)
          List<EnvironmentSnapshotCode> envSnapshotCodes = [];
          if (dtc.environmentSnapshot != null) {
            // ← ($"EnvSet_LocalList_forEcu_{this.ecuId}").GetData()
            final envSetData =
                prefs.getString('EnvSet_LocalList_forEcu_$ecuId') ?? '';

            if (envSetData.isNotEmpty) {
              debugPrint(
                  "/api/v1/datasets/get-environment-snapshot/?ecu=$ecuId\n\nRESPONSE :\n$envSetData");

              // ← JsonConvert.DeserializeObject<EnvSetModel>(envSetData)
              final EnvSetModel envSetModel =
                  EnvSetModel.fromJson(jsonDecode(envSetData));

              // ← envSetModel?.results?.FirstOrDefault(x => x.id == Dtc.environment_snapshot)
              //                        ?.environment_snapshot_code
              envSnapshotCodes = envSetModel.results
                      ?.firstWhereOrNull((x) => x.id == dtc.environmentSnapshot)
                      ?.environmentSnapshotCode ??
                  [];
            }
          }

          // ── Get freeze frame from dongle ───────────────────
          // ← App.USBconnectorService / WificonnectorService
          FreezeFrameResponseModel? freezeFrameResponse;

          if (App.connectedVia == "USB") {
            freezeFrameResponse = (await App.usbConnectorService!
                .getFreezeFrame(dtcCode, freezeFrameSet, envSnapshotCodes)) as FreezeFrameResponseModel?;
          } else if (App.connectedVia == "WIFI") {
            freezeFrameResponse = await App.wifiConnectorService!
                .getFreezeFrame(dtcCode, freezeFrameSet, envSnapshotCodes);
          }

          if (freezeFrameResponse == null) {
            error.value = "No response from dongle.";
            return;
          }

          if (freezeFrameResponse.status == "NOERROR") {
            // ← ObservableCollection<FreezeFrameUIModel> dummyList
            final List<FreezeFrameUIModel> dummyList = [];

            // ← foreach (var frame in freezeFrame.dtcs)
            for (final frame in freezeFrameResponse.dtcs ?? []) {
              // ← freeze_frame.freeze_frame_code.FirstOrDefault(
              //       x => x.code == frame.code && x.priority == frame.priority)
              final item = freezeFrameSet.freezeFrameCode?.firstWhereOrNull(
                  (x) => x.code == frame.code && x.priority == frame.priority);

              if (item != null) {
                // ← dummyList.Add(new FreezeFrameUIModel { ... })
                dummyList.add(FreezeFrameUIModel(
                  id: item.id ?? 0,
                  code: item.code ?? '',
                  desc: item.desc ?? '',
                  unit: item.unit ?? '',
                  priority: frame.priority ?? 0,
                  value: frame.value ?? '',
                ));

                // ← freezeFrameAnalyze.freeze_frame.Add(new FreezeFrameAnalyzeResult { ... })
                freezeFrameAnalyze.freezeFrame?.add(FreezeFrameAnalyzeResult(
                  code: title.value,
                  pidName: '${item.code}-${item.desc}',
                  value: '${frame.value}',
                  created: DateTime.now()
                      .toUtc()
                      .toIso8601String()
                      .replaceAll(RegExp(r'\.\d+'), ''),
                ));
              } else if (envSnapshotCodes.isNotEmpty) {
                // ← envSnapshotCodes.FirstOrDefault(
                //       x => frame.code == x.pid_code.code.Substring(2))
                final envCode = envSnapshotCodes.firstWhereOrNull((x) {
                  final pidCode = x.pidCode?.code ?? '';
                  return pidCode.length >= 2 &&
                      frame.code == pidCode.substring(2);
                });

                if (envCode != null) {
                  // ← envCode.pid_code?.pi_code_variable?.FirstOrDefault()
                  final firstVar = envCode.pidCode?.piCodeVariable?.firstOrNull;

                  // ← dummyList.Add(new FreezeFrameUIModel { ... })
                  dummyList.add(FreezeFrameUIModel(
                    id: envCode.id ?? 0,
                    code: envCode.pidCode?.code ?? '',
                    desc: firstVar?.shortName ?? '',
                    unit: firstVar?.unit ?? '',
                    priority: frame.priority ?? 0,
                    value: frame.value ?? '',
                  ));

                  // ← freezeFrameAnalyze.freeze_frame.Add(...)
                  freezeFrameAnalyze.freezeFrame?.add(FreezeFrameAnalyzeResult(
                    code: title.value,
                    pidName: '${envCode.pidCode?.code}-${firstVar?.shortName}',
                    value: '${frame.value}',
                    created: DateTime.now()
                        .toUtc()
                        .toIso8601String()
                        .replaceAll(RegExp(r'\.\d+'), ''),
                  ));
                }
              }
            }

            // ← FreezeFrameList = new ObservableCollection<FreezeFrameUIModel>(dummyList)
            freezeFrameList.assignAll(dummyList);

            // ── Post or save offline ─────────────────────────
            // ← isReachable.InternetNetwork() && sessionModel.id != 0
            final connectivity = await Connectivity().checkConnectivity();
            final bool hasInternet =
                connectivity.contains(ConnectivityResult.mobile) ||
                    connectivity.contains(ConnectivityResult.wifi);

            if (hasInternet && (sessionModel.id ?? 0) != 0) {
              // ← services.AnalyzeFreezeFrame(freezeFrameAnalyze, sessionModel.id)
              final response = await _apiServices.analyzeFreezeFrame(
                  freezeFrameAnalyze, sessionModel.id ?? 0);

              if (response.message != "success") {
                // ← UserDialogs.Instance.AlertAsync(result.message, "Error", "OK")
                _showAlert(response.message ?? 'Error');
              }
            } else {
              // ── Save offline ─────────────────────────────
              // ← ("OfflineAnalyze_FreezeFrame").GetData() / SaveData()
              try {
                const key = 'OfflineAnalyze_FreezeFrame';

                List<FreezeFrameOfflineAnalyze> data = [];
                final existing = prefs.getString(key);
                if (existing != null && existing.isNotEmpty) {
                  // ← JsonConvert.DeserializeObject<List<FreezeFrameOfflineAnalyze>>(JsonData)
                  final decoded = jsonDecode(existing) as List;
                  data = decoded
                      .map((e) => FreezeFrameOfflineAnalyze.fromJson(e))
                      .toList();
                }

                // ← new FreezeFrameOfflineAnalyze { type = "freeze_frame", ... }
                data.add(FreezeFrameOfflineAnalyze(
                  type: 'freeze_frame',
                  freezeFrame: freezeFrameAnalyze,
                  srnId: sessionModel.id,
                  srNumber: sessionModel.srNumber ?? '',
                ));

                // ← ("OfflineAnalyze_FreezeFrame").SaveData(JsonData)
                await prefs.setString(
                  key,
                  jsonEncode(data.map((e) => e.toJson()).toList()),
                );
              } catch (ex) {
                // ← UserDialogs.Instance.AlertAsync(ex.Message, "Error", "OK")
                _showAlert(ex.toString());
              }
            }
          } else {
            // ← Error = freezeFrame.status
            error.value = freezeFrameResponse.status ?? '';

            // ← if (freezeFrame.status == "Communication Error")
            if (freezeFrameResponse.status == "Communication Error") {
              // ← UserDialogs.Instance.ConfirmAsync("Do you want to reconnect?", ...)
              _showConfirm(
                title: freezeFrameResponse.status ?? '',
                message: "Do you want to reconnect?",
                onYes: () {
                  // ← new ReconnectService().ReconnectDongle()
                  ReconnectService().reconnectDongle();
                },
              );
            }
          }
        } else {
          // ← UserDialogs.Instance.AlertAsync("Freeze frame not found.", "Error", "OK")
          _showAlert("Freeze frame not found.");
          error.value = "Freeze frame not found.";
        }
      } else {
        // ← UserDialogs.Instance.AlertAsync(result.message, "Error", "OK")
        _showAlert(result.message ?? 'Error');
        error.value = result.message ?? 'Error';
      }
    } catch (ex) {
      // ← catch (Exception ex) { UserDialogs.Instance.AlertAsync(ex.Message) }
      _showAlert(ex.toString());
      error.value = ex.toString();
    } finally {
      isLoading.value = false;
    }
  }

// ─────────────────────────────────────────────────────────────
// Alert  ← UserDialogs.Instance.AlertAsync
// ─────────────────────────────────────────────────────────────
  void _showAlert(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

// ─────────────────────────────────────────────────────────────
// Confirm  ← UserDialogs.Instance.ConfirmAsync
// ─────────────────────────────────────────────────────────────
  void _showConfirm({
    required String title,
    required String message,
    required VoidCallback onYes,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onYes();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }


  
}
