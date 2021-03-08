import 'package:bloc/bloc.dart';
import 'package:deus_mobile/data_source/stock_data.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../locator.dart';
import '../../../provider_service.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  /// Reads the data from the phone (keys etc.) and fetches data from the server.
  Future<bool> initializeData() async {
    // if the data has already been fetched, skip this method.
    if (state is SplashSuccess) return true;

    emit(SplashLoading());

    /// get data from device
    try {
      debugPrint("Loading data...");
      final sharedPrefs = await SharedPreferences.getInstance();
      debugPrint("Received sharedPreferences.");
      await locator<OmniServices>().createOmniServices(sharedPrefs: sharedPrefs);
      debugPrint("Created providers.");

      /// get data from server
      final bool gotStockData = await StockData.getData();
      debugPrint("got Stock data.");
      final bool gotStockAddresses = await StockData.getStockAddresses();
      debugPrint("got Stock addresses.");

      if (!gotStockData || !gotStockAddresses) {
        emit(SplashError());
        return false;
      }
    } catch (e) {
      emit(SplashError());
      return false;
    }

    emit(SplashSuccess());
    return true;
  }
}
